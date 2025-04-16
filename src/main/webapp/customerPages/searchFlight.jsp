<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*,java.time.*"%>
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
    String departing = request.getParameter("search_departing");
    String arriving = request.getParameter("search_arriving");
    String tripType = request.getParameter("tripType");
    String departureDateStr = request.getParameter("departure-date");
    String flexible = request.getParameter("flexible");
    String boardingClass = request.getParameter("class");

    // Get the airport codes from the hidden fields (if available)
    String depPortID = request.getParameter("code_departing");
    String arrPortID = request.getParameter("code_arriving");

    // Fallback: Try to extract airport code from name if code not present
    if (depPortID == null && departing != null && departing.contains("(")) {
        depPortID = departing.substring(departing.indexOf("(") + 1, departing.indexOf(")")).trim();
    }
    if (arrPortID == null && arriving != null && arriving.contains("(")) {
        arrPortID = arriving.substring(arriving.indexOf("(") + 1, arriving.indexOf(")")).trim();
    }

    Set<Integer> dayBits = new HashSet<>();
    List<LocalDate> searchDates = new ArrayList<>();

    if (departureDateStr != null && !departureDateStr.isEmpty()) {
        LocalDate selectedDate = LocalDate.parse(departureDateStr);

        int range = "yes".equalsIgnoreCase(flexible) ? 3 : 0;
        for (int i = -range; i <= range; i++) {
            LocalDate date = selectedDate.plusDays(i);
            DayOfWeek dow = date.getDayOfWeek(); // MONDAY = 1 ... SUNDAY = 7
            int bit = 1 << (dow.getValue() - 1); // Convert to bitmask
            if (!dayBits.contains(bit)) {
                dayBits.add(bit);
                searchDates.add(date);
            }
        }
    }


    // Connect and query DB
    ApplicationDB db = new ApplicationDB();
    Connection con = db.getConnection();
    
    String sql = "SELECT * FROM flight WHERE (operating_days & ?) > 0 AND dep_portID = ? AND arr_portID = ?";
    PreparedStatement stmt = con.prepareStatement(sql);

    out.println("<h3>Flights found:</h3>");
    boolean anyResults = false;

    for (int bit : dayBits) {
        stmt.setInt(1, bit);
        stmt.setString(2, depPortID);
        stmt.setString(3, arrPortID);
        ResultSet rs = stmt.executeQuery();

        while (rs.next()) {
            int flightNum = rs.getInt("flightNum");
            if (!printedFlights.contains(flightNum)) {
                printedFlights.add(flightNum);
                anyResults = true;
                out.println("<p>Flight #" + flightNum +
                            " | From: " + rs.getString("dep_portID") +
                            " → To: " + rs.getString("arr_portID") +
                            " | Price: $" + rs.getDouble("price") +
                            "</p>");
            }
        }


        rs.close();
    }

    if (!anyResults) {
        out.println("<p>No flights found for this route and selected date(s).</p>");
    }

    stmt.close();
    db.closeConnection(con);

} catch (Exception e) {
    out.println("<p>Error: " + e.getMessage() + "</p>");
    e.printStackTrace();
}
%>


</body>
</html>