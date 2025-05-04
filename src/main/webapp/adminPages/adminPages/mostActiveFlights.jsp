<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>

<!DOCTYPE html>
<html>
<head>
   <style>
       table, th, td { border: 1px solid black; border-collapse: collapse; padding: 8px; }
   </style>
</head>
<body>
    <div style="display: flex; align-items: center;">
		<h2>Most Active Flights</h2>
		<div style="margin-left: 20px;">
			<form action="../adminHome.jsp" method="get">
				<input type="submit" value="Admin Home">
			</form>
		</div>
	</div>
    
    <%
    try {
        ApplicationDB db = new ApplicationDB();
        Connection con = db.getConnection();
        
        // top 5 most active flights (flights with most tickets sold)
        String query = "SELECT f.*, COUNT(tf.ticketNum) as ticket_count " +
               "FROM flight f " +
               "JOIN ticketlistsflights tf ON f.flightNum = tf.flightNum AND f.airID = tf.airID " +
               "JOIN tickets t ON tf.ticketNum = t.ticketNum " +
               "GROUP BY f.airID, f.flightNum, f.flightType " +
               "ORDER BY ticket_count DESC " +
               "LIMIT 5";
        
        PreparedStatement ps = con.prepareStatement(query);
        ResultSet rs = ps.executeQuery();
        
        // Check if there are results
        boolean hasResults = false;
        rs.last();
        if (rs.getRow() > 0) {
            hasResults = true;
            rs.beforeFirst();
        }
        //put select statement into an organized table
        if (hasResults) {
            %>
            <table>
                <tr>
                    <th>Rank</th>
                    <th>Airline</th>
                    <th>Flight #</th>
                    <th>Type</th>
                    <th>Route</th>
                    <th>Departure</th>
                    <th>Arrival</th>
                    <th>Available Seats</th>
                    <th>Price</th>
                    <th>Aircraft #</th>
                    <th>Tickets Sold</th>
                </tr>
                <%
                int rank = 1;
                while (rs.next()) {
                    String departDateTime = rs.getDate("departure_date") + " " + rs.getTime("departure_time");
                    String arriveDateTime = rs.getDate("arrival_date") + " " + rs.getTime("arrival_time");
                    int totalAvailableSeats = rs.getInt("openFirstSeats") + rs.getInt("openBusinessSeats") + rs.getInt("openEconomySeats");                    %>
                    <tr>
                        <td><%= rank++ %></td>
                        <td><%= rs.getString("airID") %></td>
                        <td><%= rs.getInt("flightNum") %></td>
                        <td><%= rs.getString("flightType") %></td>
                        <td><%= rs.getString("dep_portID") %> to <%= rs.getString("arr_portID") %></td>
                        <td><%= departDateTime %></td>
                        <td><%= arriveDateTime %></td>
                        <td>
						    F: <%= rs.getInt("openFirstSeats") %>, 
						    B: <%= rs.getInt("openBusinessSeats") %>, 
						    E: <%= rs.getInt("openEconomySeats") %>
						</td>
                        <td class="price">$<%= String.format("%.2f", rs.getDouble("price")) %></td>
                        <td><%= rs.getInt("craftNum") %></td>
                        <td><%= rs.getInt("ticket_count") %></td>
                    </tr>
                    <%
                }
                %>
            </table>
            <%
        } else {
            %>
            <p>No flight data found.</p>
            <%
        }
        
        rs.close();
        ps.close();
        
        // show ALL flights ordered by activity
        String allFlightsQuery = "SELECT f.airID, f.flightNum, f.dep_portID, f.arr_portID, f.flightType, f.price, " +
                          "COUNT(tf.ticketNum) as ticket_count " +
                          "FROM flight f " +
                          "LEFT JOIN ticketlistsflights tf ON f.flightNum = tf.flightNum AND f.airID = tf.airID " +
                          "LEFT JOIN tickets t ON tf.ticketNum = t.ticketNum " +
                          "GROUP BY f.airID, f.flightNum, f.dep_portID, f.arr_portID, f.flightType, f.price " +
                          "ORDER BY ticket_count DESC";
        
        PreparedStatement allPs = con.prepareStatement(allFlightsQuery);
        ResultSet allRs = allPs.executeQuery();
        %>
        
        <h3>All Flights Ranked by Activity</h3>
        <table>
            <tr>
                <th>Rank</th>
                <th>Airline</th>
                <th>Flight #</th>
                <th>Route</th>
                <th>Type</th>
                <th>Price</th>
                <th>Tickets Sold</th>
            </tr>
            <%
            int allRank = 1;
            while (allRs.next()) {
                String route = allRs.getString("dep_portID") + " to " + allRs.getString("arr_portID");
                %>
                <tr>
                    <td><%= allRank++ %></td>
                    <td><%= allRs.getString("airID") %></td>
                    <td><%= allRs.getInt("flightNum") %></td>
                    <td><%= route %></td>
                    <td><%= allRs.getString("flightType") %></td>
                    <td class="price">$<%= String.format("%.2f", allRs.getDouble("price")) %></td>
                    <td><%= allRs.getInt("ticket_count") %></td>
                </tr>
                <%
            }
            allRs.close();
            allPs.close();
            %>
        </table>
        
        <%
        con.close();
    } catch (Exception e) {
        %>
        <div class="error">
            <h3>Error Generating Flight Activity Report</h3>
            <p><%= e.getMessage() %></p>
            <p>Stack trace:</p>
            <pre>
                <% 
                StringWriter sw = new StringWriter();
                e.printStackTrace(new PrintWriter(sw));
                out.println(sw.toString());
                %>
            </pre>
        </div>
        <%
    }
    %>
</body>
</html>