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
    Set<Integer> printedFlights = new HashSet<>();
    Set<String> airlineList = new HashSet<>();
    StringBuilder flightHtml = new StringBuilder();
    StringBuilder returnHtml = new StringBuilder();

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

    boolean anyResults = false;

    if (!"roundtrip".equalsIgnoreCase(tripType)) {
        PreparedStatement stmt = con.prepareStatement(sql);
        for (int bit : dayBits) {
            stmt.setInt(1, bit);
            stmt.setString(2, depPortID);
            stmt.setString(3, arrPortID);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                String airlineName = rs.getString("airID");
                airlineList.add(airlineName);
                int flightNum = rs.getInt("flightNum");
                if (!printedFlights.contains(flightNum)) {
                    printedFlights.add(flightNum);
                    anyResults = true;

                    java.sql.Time depTime = rs.getTime("departure_time");
                    java.sql.Time arrTime = rs.getTime("arrival_time");
                    java.text.SimpleDateFormat timeFormat = new java.text.SimpleDateFormat("hh:mm a");
                    String formattedDepTime = timeFormat.format(depTime);
                    String formattedArrTime = timeFormat.format(arrTime);

                    double basePrice = rs.getDouble("price");
                    double totalPrice = basePrice + classSurcharge;

                    flightHtml.append("<p style='margin-top: 15px; line-height: 24px;'>\u2708\ufe0f Flight #").append(flightNum)
                        .append(" | From ").append(rs.getString("dep_portID"))
                        .append(" > To ").append(rs.getString("arr_portID"))
                        .append(" | Class: ").append(boardingClass != null ? boardingClass : "economy")
                        .append(" | Total Price: $").append(String.format("%.2f", totalPrice))
                        .append("<form method='post' action='flightPageComponents/purchaseTicket.jsp'>")
                        .append("<input type='hidden' name='flightNum' value='").append(flightNum).append("'/>")
                        .append("<input type='hidden' name='airID' value='").append(rs.getString("airID")).append("'/>")
                        .append("<input type='hidden' name='depPortID' value='").append(rs.getString("dep_portID")).append("'/>")
                        .append("<input type='hidden' name='arrPortID' value='").append(rs.getString("arr_portID")).append("'/>")
                        .append("<input type='hidden' name='price' value='").append(totalPrice).append("'/>")
                        .append("<input type='submit' value='Reserve Flight Ticket'/>")
                        .append("</form></p>");
                }
            }
            rs.close();
        }
        stmt.close();
    }

    if ("roundtrip".equalsIgnoreCase(tripType)) {
        PreparedStatement returnStmt = con.prepareStatement(sql);
        for (int bit : dayBits) {
            returnStmt.setInt(1, bit);
            returnStmt.setString(2, arrPortID);
            returnStmt.setString(3, depPortID);
            ResultSet rs = returnStmt.executeQuery();

            while (rs.next()) {
                int flightNum = rs.getInt("flightNum");
                if (!printedFlights.contains(flightNum)) {
                    printedFlights.add(flightNum);
                    anyResults = true;

                    java.sql.Time depTime = rs.getTime("departure_time");
                    java.sql.Time arrTime = rs.getTime("arrival_time");
                    java.text.SimpleDateFormat timeFormat = new java.text.SimpleDateFormat("hh:mm a");
                    String formattedDepTime = timeFormat.format(depTime);
                    String formattedArrTime = timeFormat.format(arrTime);

                    double basePrice = rs.getDouble("price");
                    double totalPrice = basePrice + classSurcharge;

                    returnHtml.append("<p style='margin-top: 15px; line-height: 24px;'>Return Flight #").append(flightNum)
    .append(" | From ").append(rs.getString("dep_portID"))
    .append(" > To ").append(rs.getString("arr_portID"))
    .append(" | Class: ").append(boardingClass != null ? boardingClass : "economy")
    .append(" | Total Price: $").append(String.format("%.2f", totalPrice))
    .append(" | Departure Date: ").append(rs.getString("departure_date"))
    .append(" | Departure Time: ").append(formattedDepTime)
    .append(" | Arrival Date: ").append(rs.getString("arrival_date"))
    .append(" | Arrival Time: ").append(formattedArrTime)
    .append("<form method='post' action='flightPageComponents/purchaseTicket.jsp'>")
    .append("<input type='hidden' name='flightNum' value='").append(flightNum).append("'/>")
    .append("<input type='hidden' name='airID' value='").append(rs.getString("airID")).append("'/>")
    .append("<input type='hidden' name='depPortID' value='").append(rs.getString("dep_portID")).append("'/>")
    .append("<input type='hidden' name='arrPortID' value='").append(rs.getString("arr_portID")).append("'/>")
    .append("<input type='hidden' name='price' value='").append(totalPrice).append("'/>")
    .append("<input type='hidden' name='departureDate' value='").append(rs.getString("departure_date")).append("'/>")
    .append("<input type='hidden' name='departureTime' value='").append(formattedDepTime).append("'/>")
    .append("<input type='hidden' name='arrivalDate' value='").append(rs.getString("arrival_date")).append("'/>")
    .append("<input type='hidden' name='arrivalTime' value='").append(formattedArrTime).append("'/>")
    .append("<input type='submit' value='Reserve Return Ticket'/>")
    .append("</form></p>");
                }
            }
            rs.close();
        }
        returnStmt.close();
    }

    db.closeConnection(con);
    request.setAttribute("airlineList", airlineList);
    out.println("<h3>Flights found:</h3>");
    String printedFlightNums = printedFlights.toString().replaceAll("[\\[\\] ]", "");
    request.setAttribute("printedFlightNums", printedFlightNums);
%>

<jsp:include page="flightPageComponents/modifyFlights.jsp" />
<div id="line" style="width: 100%; height: 2px; background-color:black; margin: 10px 0px;"></div>

<%
    if (anyResults) {
        out.println(flightHtml.toString());
        if ("roundtrip".equalsIgnoreCase(tripType)) {
            out.println(returnHtml.toString());
        }
    } else {
        out.println("<p>No flights found for this route and selected date(s).</p>");
    }
} catch (Exception e) {
    out.println("<p>Error: " + e.getMessage() + "</p>");
    e.printStackTrace();
}
%>

</body>
</html>
