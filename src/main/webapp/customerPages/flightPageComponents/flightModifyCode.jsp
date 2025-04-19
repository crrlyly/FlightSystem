<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*,java.time.*"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
    <title>Filtered and Sorted Flights</title>
</head>
<body>

<%
try {
    String outboundFlight = request.getParameter("outboundFlight");
    String returnFlight = request.getParameter("returnFlight");

    if (outboundFlight != null && returnFlight != null) {
        // Round trip booking
        String totalPrice = request.getParameter("totalPrice");
    } else {
        String flightNumsParam = request.getParameter("flightNums");
        Set<Integer> flightNumsSet = new HashSet<>();

        if (flightNumsParam != null && !flightNumsParam.trim().isEmpty()) {
            String[] split = flightNumsParam.split(",");
            for (String f : split) {
                try {
                    flightNumsSet.add(Integer.parseInt(f.trim()));
                } catch (NumberFormatException ex) {
                    // ignore invalid entry
                }
            }
        }

        String sortBy = request.getParameter("sortBy");
        String sortOrder = request.getParameter("sortOrder");
        String minPriceStr = request.getParameter("minPrice");
        String maxPriceStr = request.getParameter("maxPrice");
        String airline = request.getParameter("airline");
        String takeOffStart = request.getParameter("takeOffStart");
        String takeOffEnd = request.getParameter("takeOffEnd");
        String landingStart = request.getParameter("landingStart");
        String landingEnd = request.getParameter("landingEnd");

        StringBuilder query = new StringBuilder("SELECT * FROM flight WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (!flightNumsSet.isEmpty()) {
            query.append(" AND flightNum IN (");
            int i = 0;
            for (Integer f : flightNumsSet) {
                if (i++ > 0) query.append(",");
                query.append("?");
                params.add(f);
            }
            query.append(")");
        }

        if (minPriceStr != null && !minPriceStr.isEmpty()) {
            query.append(" AND price >= ?");
            params.add(Double.parseDouble(minPriceStr));
        }
        if (maxPriceStr != null && !maxPriceStr.isEmpty()) {
            query.append(" AND price <= ?");
            params.add(Double.parseDouble(maxPriceStr));
        }
        if (airline != null && !airline.isEmpty() && !airline.equals("none")) {
            query.append(" AND airID = ?");
            params.add(airline);
        }
        if (takeOffStart != null && !takeOffStart.isEmpty()) {
            query.append(" AND departure_time >= ?");
            params.add(Time.valueOf(takeOffStart + ":00"));
        }
        if (takeOffEnd != null && !takeOffEnd.isEmpty()) {
            query.append(" AND departure_time <= ?");
            params.add(Time.valueOf(takeOffEnd + ":00"));
        }
        if (landingStart != null && !landingStart.isEmpty()) {
            query.append(" AND arrival_time >= ?");
            params.add(Time.valueOf(landingStart + ":00"));
        }
        if (landingEnd != null && !landingEnd.isEmpty()) {
            query.append(" AND arrival_time <= ?");
            params.add(Time.valueOf(landingEnd + ":00"));
        }

        if (sortBy != null && sortOrder != null && !sortBy.equals("none") && !sortOrder.equals("none")) {
            if (sortBy.equals("duration")) {
                query.append(" ORDER BY TIME_TO_SEC(arrival_time) - TIME_TO_SEC(departure_time) ").append(sortOrder.toUpperCase());
            } else {
                query.append(" ORDER BY ").append(sortBy).append(" ").append(sortOrder.toUpperCase());
            }
        }

        ApplicationDB db = new ApplicationDB();
        Connection con = db.getConnection();
        PreparedStatement stmt = con.prepareStatement(query.toString());

        for (int i = 0; i < params.size(); i++) {
            stmt.setObject(i + 1, params.get(i));
        }

        ResultSet rs = stmt.executeQuery();

        boolean anyResults = false;
        out.println("<h3>Filtered Flights:</h3>");
        while (rs.next()) {
            anyResults = true;

            java.sql.Time depTime = rs.getTime("departure_time");
            java.sql.Time arrTime = rs.getTime("arrival_time");

            java.text.SimpleDateFormat timeFormat = new java.text.SimpleDateFormat("hh:mm a");
            String formattedDepTime = timeFormat.format(depTime);
            String formattedArrTime = timeFormat.format(arrTime);

            out.println("<p style='margin-top: 15px; line-height: 24px;'>Flight #" + rs.getInt("flightNum") +
                " | From: " + rs.getString("dep_portID") +
                " > To: " + rs.getString("arr_portID") +
                " | Airline: " + rs.getString("airID") +
                " | Price: $" + rs.getDouble("price") +
                " | Departure Date: " + rs.getString("departure_date") +
                " | Departure Time: " + formattedDepTime +
                " | Arrival Date: " + rs.getString("arrival_date") +
                " | Arrival Time: " + formattedArrTime +
                "</p>" +
                "<form method='post' action='purchaseTicket.jsp'>" +
                "<input type='hidden' name='flightNum' value='" + rs.getInt("flightNum") + "'/>" +
                "<input type='hidden' name='airID' value='" + rs.getString("airID") + "'/>" +
                "<input type='hidden' name='depPortID' value='" + rs.getString("dep_portID") + "'/>" +
                "<input type='hidden' name='arrPortID' value='" + rs.getString("arr_portID") + "'/>" +
                "<input type='hidden' name='price' value='" + rs.getDouble("price") + "'/>" +
                "<input type='hidden' name='departureDate' value='" + rs.getString("departure_date") + "'/>" +
                "<input type='hidden' name='departureTime' value='" + formattedDepTime + "'/>" +
                "<input type='hidden' name='arrivalDate' value='" + rs.getString("arrival_date") + "'/>" +
                "<input type='hidden' name='arrivalTime' value='" + formattedArrTime + "'/>" +
                "<input type='submit' value='Reserve Flight Ticket'/>" +
                "</form>");
        }

        if (!anyResults) {
            out.println("<p>No flights found matching the filter and sort criteria.</p>");
        }

        rs.close();
        stmt.close();
        db.closeConnection(con);
    }
} catch (Exception e) {
    out.println("<p>Error: " + e.getMessage() + "</p>");
    e.printStackTrace();
}
%>

</body>
</html>
