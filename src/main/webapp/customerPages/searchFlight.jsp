<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*,java.time.*"%>
<%@ page import="java.util.stream.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
    <title>Flight Search Results</title>
</head>
<body>

<%
try {
    Set<String> airlineList = new HashSet<>();
    StringBuilder outputHtml = new StringBuilder();

    String departing = request.getParameter("search_departing");
    String arriving = request.getParameter("search_arriving");
    String tripType = request.getParameter("tripType");
    String departureDateStr = request.getParameter("departure-date");
    String flexible = request.getParameter("flexible");
    String boardingClass = request.getParameter("class");

    String depPortID = request.getParameter("code_departing");
    String arrPortID = request.getParameter("code_arriving");

    if (depPortID == null && departing != null && departing.contains("(")) {
        depPortID = departing.substring(departing.indexOf("(") + 1, departing.indexOf(")")).trim();
    }
    if (arrPortID == null && arriving != null && arriving.contains("(")) {
        arrPortID = arriving.substring(arriving.indexOf("(") + 1, arriving.indexOf(")")).trim();
    }

    double classSurcharge = 0.0;
    if ("first".equalsIgnoreCase(boardingClass)) {
        classSurcharge = 1000.0;
    } else if ("business".equalsIgnoreCase(boardingClass)) {
        classSurcharge = 300.0;
    } else if ("economy".equalsIgnoreCase(boardingClass)) {
        classSurcharge = 100.0;
    }

    Set<Integer> dayBits = new HashSet<>();
    if (departureDateStr != null && !departureDateStr.isEmpty()) {
        LocalDate selectedDate = LocalDate.parse(departureDateStr);
        int range = "yes".equalsIgnoreCase(flexible) ? 3 : 0;
        for (int i = -range; i <= range; i++) {
            LocalDate date = selectedDate.plusDays(i);
            int bit = 1 << (date.getDayOfWeek().getValue() - 1);
            dayBits.add(bit);
        }
    }

    ApplicationDB db = new ApplicationDB();
    Connection con = db.getConnection();
    String sql = "SELECT * FROM flight WHERE (operating_days & ?) > 0 AND dep_portID = ? AND arr_portID = ?";

    if (!"roundtrip".equalsIgnoreCase(tripType)) {
        PreparedStatement stmt = con.prepareStatement(sql);
        Set<String> shownFlightNums = new HashSet<>();
        for (int bit : dayBits) {
            stmt.setInt(1, bit);
            stmt.setString(2, depPortID);
            stmt.setString(3, arrPortID);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                String flightNum = rs.getString("flightNum");
                if (shownFlightNums.contains(flightNum)) continue;
                shownFlightNums.add(flightNum);
                String airID = rs.getString("airID");
                String depPort = rs.getString("dep_portID");
                String arrPort = rs.getString("arr_portID");
                String priceStr = rs.getString("price");
                String depDate = rs.getString("departure_date");
                String arrDate = rs.getString("arrival_date");
                String depTime = new java.text.SimpleDateFormat("hh:mm a").format(rs.getTime("departure_time"));
                String arrTime = new java.text.SimpleDateFormat("hh:mm a").format(rs.getTime("arrival_time"));

                double totalPrice = Double.parseDouble(priceStr) + classSurcharge;

                outputHtml.append("<div style='margin-bottom: 20px;'>")
                    .append("<p>Flight #").append(flightNum)
                    .append(" | ").append(depPort).append(" > ").append(arrPort)
                    .append(" | Class: ").append(boardingClass)
                    .append(" | Departs: ").append(depDate).append(" ").append(depTime)
                    .append(" | Arrives: ").append(arrDate).append(" ").append(arrTime)
                    .append("</p>")
                    .append("<p><strong>Total Price: $").append(String.format("%.2f", totalPrice)).append("</strong></p>")
                    .append("<form method='post' action='flightPageComponents/purchaseTicket.jsp'>")
                    .append("<input type='hidden' name='flightNum' value='").append(flightNum).append("'/>")
                    .append("<input type='hidden' name='totalPrice' value='").append(String.format("%.2f", totalPrice)).append("'/>")
                    .append("<input type='submit' value='Book Flight'/>")
                    .append("</form></div>")
                    .append("<div id='line' style='width: 100%; height: 2px; background-color:black; margin: 10px 0px;'></div>");
            }
            rs.close();
        }
        stmt.close();
    }

    if ("roundtrip".equalsIgnoreCase(tripType)) {
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
                data.put("depPortID", rs.getString("dep_portID"));
                data.put("arrPortID", rs.getString("arr_portID"));
                data.put("price", rs.getString("price"));
                data.put("depDate", rs.getString("departure_date"));
                data.put("arrDate", rs.getString("arrival_date"));
                data.put("depTime", new java.text.SimpleDateFormat("hh:mm a").format(rs.getTime("departure_time")));
                data.put("arrTime", new java.text.SimpleDateFormat("hh:mm a").format(rs.getTime("arrival_time")));
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
                data.put("class", boardingClass);
                data.put("depPortID", rs.getString("dep_portID"));
                data.put("arrPortID", rs.getString("arr_portID"));
                data.put("price", rs.getString("price"));
                data.put("depDate", rs.getString("departure_date"));
                data.put("arrDate", rs.getString("arrival_date"));
                data.put("depTime", new java.text.SimpleDateFormat("hh:mm a").format(rs.getTime("departure_time")));
                data.put("arrTime", new java.text.SimpleDateFormat("hh:mm a").format(rs.getTime("arrival_time")));
                returns.add(data);
            }
            rs.close();
        }
        returnStmt.close();

        Set<String> shownRoundTripCombos = new HashSet<>();
        for (Map<String, String> outbound : departures) {
            for (Map<String, String> ret : returns) {
                LocalDate outboundDate = LocalDate.parse(outbound.get("depDate"));
                LocalDate returnDate = LocalDate.parse(ret.get("depDate"));
                if (!returnDate.isAfter(outboundDate)) continue;

                String comboKey = outbound.get("flightNum") + "-" + ret.get("flightNum");
                if (shownRoundTripCombos.contains(comboKey)) continue;
                shownRoundTripCombos.add(comboKey);

                double total = Double.parseDouble(outbound.get("price")) + Double.parseDouble(ret.get("price")) + (2 * classSurcharge);

                outputHtml.append("<div style='margin-bottom: 20px;'>")
                    .append("<p>Outbound Flight #").append(outbound.get("flightNum"))
                    .append(" | ").append(outbound.get("depPortID")).append(" > ").append(outbound.get("arrPortID"))
                    .append(" | Class: ").append(boardingClass)
                    .append(" | Departs: ").append(outbound.get("depDate")).append(" ").append(outbound.get("depTime"))
                    .append(" | Arrives: ").append(outbound.get("arrDate")).append(" ").append(outbound.get("arrTime"))
                    .append("</p>")
                    .append("<p>Return Flight #").append(ret.get("flightNum"))
                    .append(" | ").append(ret.get("depPortID")).append(" > ").append(ret.get("arrPortID"))
                    .append(" | Class: ").append(boardingClass)
                    .append(" | Departs: ").append(ret.get("depDate")).append(" ").append(ret.get("depTime"))
                    .append(" | Arrives: ").append(ret.get("arrDate")).append(" ").append(ret.get("arrTime"))
                    .append("</p>")
                    .append("<p><strong>Total Price: $").append(String.format("%.2f", total)).append("</strong></p>")
                    .append("<form method='post' action='flightPageComponents/purchaseTicket.jsp'>")
                    .append("<input type='hidden' name='outboundFlight' value='").append(outbound.get("flightNum")).append("'/>")
                    .append("<input type='hidden' name='returnFlight' value='").append(ret.get("flightNum")).append("'/>")
                    .append("<input type='hidden' name='totalPrice' value='").append(String.format("%.2f", total)).append("'/>")
                    .append("<input type='submit' value='Book Round Trip'/>")
                    .append("</form></div>")
                    .append("<div id='line' style='width: 100%; height: 2px; background-color:black; margin: 10px 0px;'></div>");
            }
        }
    }

    db.closeConnection(con);
    request.setAttribute("airlineList", airlineList);
    out.println("<h3>Flights found:</h3>");
    
%>
<jsp:include page="flightPageComponents/modifyFlights.jsp" />
<div id="line" style="width: 100%; height: 2px; background-color:black; margin: 10px 0px;"></div>
    
<% 
    out.println(outputHtml.toString());
} catch (Exception e) {
    out.println("<p>Error: " + e.getMessage() + "</p>");
    e.printStackTrace();
}
%>


</body>
</html>
