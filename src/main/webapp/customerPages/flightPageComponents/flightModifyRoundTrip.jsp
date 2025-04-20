<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>

<%
    // Get today’s date in yyyy-MM-dd format
    java.time.LocalDate today = java.time.LocalDate.now();
%>

<!DOCTYPE>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title>Customer Login Form</title>
	</head>
	<body>
		
		<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*,java.time.*, java.text.*" %>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>

<%
try {
    String sortBy = request.getParameter("sortBy");
    String sortOrder = request.getParameter("sortOrder");
    String minPriceStr = request.getParameter("minPrice");
    String maxPriceStr = request.getParameter("maxPrice");
    String airlineFilter = request.getParameter("airline");
    String takeOffStartStr = request.getParameter("takeOffStart");
    String takeOffEndStr = request.getParameter("takeOffEnd");
    String landingStartStr = request.getParameter("landingStart");
    String landingEndStr = request.getParameter("landingEnd");

    String depPortID = (String) session.getAttribute("depID");
    String arrPortID = (String) session.getAttribute("arrID");
    String boardingClass = (String) session.getAttribute("class");

    String departureDateStr = request.getParameter("departure-date");
    LocalDate selectedDate = LocalDate.parse(departureDateStr);
    Set<Integer> dayBits = new HashSet<>();
    for (int i = -3; i <= 3; i++) {
        LocalDate date = selectedDate.plusDays(i);
        int bit = 1 << (date.getDayOfWeek().getValue() - 1);
        dayBits.add(bit);
    }

    ApplicationDB db = new ApplicationDB();
    Connection con = db.getConnection();
    String sql = "SELECT * FROM flight WHERE (operating_days & ?) > 0 AND dep_portID = ? AND arr_portID = ?";
    
    List<Map<String, String>> departures = new ArrayList<>();
    List<Map<String, String>> returns = new ArrayList<>();

    PreparedStatement stmt = con.prepareStatement(sql);
    for (int bit : dayBits) {
        stmt.setInt(1, bit);
        stmt.setString(2, depPortID);
        stmt.setString(3, arrPortID);
        ResultSet rs = stmt.executeQuery();
        while (rs.next()) {
            Map<String, String> data = new HashMap<>();
            data.put("flightNum", rs.getString("flightNum"));
            data.put("airID", rs.getString("airID"));
            data.put("price", rs.getString("price"));
            data.put("depDate", rs.getString("departure_date"));
            data.put("arrDate", rs.getString("arrival_date"));
            data.put("depTime", new SimpleDateFormat("HH:mm").format(rs.getTime("departure_time")));
            data.put("arrTime", new SimpleDateFormat("HH:mm").format(rs.getTime("arrival_time")));
            data.put("depPortID", rs.getString("dep_portID"));
            data.put("arrPortID", rs.getString("arr_portID"));
            departures.add(data);
        }
        rs.close();
    }
    stmt.close();

    PreparedStatement returnStmt = con.prepareStatement(sql);
    for (int bit : dayBits) {
        returnStmt.setInt(1, bit);
        returnStmt.setString(2, arrPortID);
        returnStmt.setString(3, depPortID);
        ResultSet rs = returnStmt.executeQuery();
        while (rs.next()) {
            Map<String, String> data = new HashMap<>();
            data.put("flightNum", rs.getString("flightNum"));
            data.put("airID", rs.getString("airID"));
            data.put("price", rs.getString("price"));
            data.put("depDate", rs.getString("departure_date"));
            data.put("arrDate", rs.getString("arrival_date"));
            data.put("depTime", new SimpleDateFormat("HH:mm").format(rs.getTime("departure_time")));
            data.put("arrTime", new SimpleDateFormat("HH:mm").format(rs.getTime("arrival_time")));
            data.put("depPortID", rs.getString("dep_portID"));
            data.put("arrPortID", rs.getString("arr_portID"));
            returns.add(data);
        }
        rs.close();
    }
    returnStmt.close();

    List<String> output = new ArrayList<>();
    Set<String> combos = new HashSet<>();

    for (Map<String, String> outbound : departures) {
        for (Map<String, String> ret : returns) {
            LocalDate outDate = LocalDate.parse(outbound.get("depDate"));
            LocalDate retDate = LocalDate.parse(ret.get("depDate"));
            if (!retDate.isAfter(outDate)) continue;

            double outPrice = Double.parseDouble(outbound.get("price"));
            double retPrice = Double.parseDouble(ret.get("price"));
            double total = outPrice + retPrice;

            if (minPriceStr != null && !minPriceStr.isEmpty() && total < Double.parseDouble(minPriceStr)) continue;
            if (maxPriceStr != null && !maxPriceStr.isEmpty() && total > Double.parseDouble(maxPriceStr)) continue;

            if (airlineFilter != null && !"none".equalsIgnoreCase(airlineFilter)) {
                if (!outbound.get("airID").equalsIgnoreCase(airlineFilter) &&
                    !ret.get("airID").equalsIgnoreCase(airlineFilter)) continue;
            }

            if (takeOffStartStr != null && !takeOffStartStr.isEmpty() &&
                outbound.get("depTime").compareTo(takeOffStartStr) < 0) continue;
            if (takeOffEndStr != null && !takeOffEndStr.isEmpty() &&
                outbound.get("depTime").compareTo(takeOffEndStr) > 0) continue;

            if (landingStartStr != null && !landingStartStr.isEmpty() &&
                ret.get("arrTime").compareTo(landingStartStr) < 0) continue;
            if (landingEndStr != null && !landingEndStr.isEmpty() &&
                ret.get("arrTime").compareTo(landingEndStr) > 0) continue;

            String key = outbound.get("flightNum") + "-" + ret.get("flightNum");
            if (combos.contains(key)) continue;
            combos.add(key);

            String sortValue = "";
            if ("price".equals(sortBy)) {
                sortValue = String.format("%.2f", total);
            } else if ("departure_time".equals(sortBy)) {
                sortValue = outbound.get("depTime");
            } else if ("arrival_time".equals(sortBy)) {
                sortValue = ret.get("arrTime");
            } else if ("duration".equals(sortBy)) {
                LocalTime dep = LocalTime.parse(outbound.get("depTime"));
                LocalTime arr = LocalTime.parse(ret.get("arrTime"));
                long minutes = Duration.between(dep, arr).toMinutes();
                sortValue = String.valueOf(minutes);
            }

            StringBuilder html = new StringBuilder();
            html.append("<div style='margin-bottom: 20px;'>")
                .append("<p>Outbound Flight #").append(outbound.get("flightNum"))
                .append(" | ").append(outbound.get("depPortID")).append(" > ").append(outbound.get("arrPortID"))
                .append(" | Departs: ").append(outbound.get("depDate")).append(" ").append(outbound.get("depTime"))
                .append(" | Arrives: ").append(outbound.get("arrDate")).append(" ").append(outbound.get("arrTime")).append("</p>")
                .append("<p>Return Flight #").append(ret.get("flightNum"))
                .append(" | ").append(ret.get("depPortID")).append(" > ").append(ret.get("arrPortID"))
                .append(" | Departs: ").append(ret.get("depDate")).append(" ").append(ret.get("depTime"))
                .append(" | Arrives: ").append(ret.get("arrDate")).append(" ").append(ret.get("arrTime")).append("</p>")
                .append("<p><strong>Total Price: $").append(String.format("%.2f", total)).append("</strong></p>")
                .append("<form method='post' action='purchaseTicket.jsp'>")
                .append("<input type='hidden' name='outboundFlight' value='").append(outbound.get("flightNum")).append("'/>")
                .append("<input type='hidden' name='returnFlight' value='").append(ret.get("flightNum")).append("'/>")
                .append("<input type='hidden' name='totalPrice' value='").append(String.format("%.2f", total)).append("'/>")
                .append("<input type='submit' value='Book Round Trip'/>")
                .append("</form></div>")
                .append("<div style='height:2px;background:black;margin:10px 0'></div>");

            output.add(sortValue + "___SPLIT___" + html.toString());
        }
    }

    if (!"none".equals(sortBy) && !"none".equals(sortOrder)) {
        output.sort((a, b) -> {
            String valA = a.split("___SPLIT___")[0];
            String valB = b.split("___SPLIT___")[0];
            return "asc".equalsIgnoreCase(sortOrder) ? valA.compareTo(valB) : valB.compareTo(valA);
        });
    }

    for (String block : output) {
        out.println(block.split("___SPLIT___")[1]);
    }

    db.closeConnection(con);

} catch (Exception e) {
    out.println("<p>Error: " + e.getMessage() + "</p>");
    e.printStackTrace();
}
%>
		
	
	</body>
</html>