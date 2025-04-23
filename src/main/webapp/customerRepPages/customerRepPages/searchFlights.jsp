<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>

<!DOCTYPE html>
<html>
<head>
    <style>
        body {
            margin: 20px;
        }
        table {
            border-collapse: collapse;
            width: 100%;
            margin-top: 20px;
            text-align: left;
        }
        th, td {
            border: 1px solid #ddd;
        }
    </style>
</head>
<body>

    <!-- Home Button -->
    <div style="display: flex; align-items: center;">
	  <h2>Search Flights for an Airport</h2>
	  <div style="margin-left: 20px;">
	  	<form action="../repHome.jsp" method="get">
	      <input type="submit" value="Customer Representative Home Page" style="background-color: darkgrey; color: white; border: 1px black; cursor: pointer;">
	    </form>
	  </div>
	</div>

    <!-- Search Form -->
    <form action="searchFlights.jsp" method="get">
        <label for="airID">Airport ID:</label><br>
        <input type="text" id="airport" name="airport" placeholder="e.g., JFK" required><br><br>
        <input type="submit" value="Search" style="background-color: darkgrey; color: white; border: 1px black; cursor: pointer;">
    </form>

    <%
    String airport = request.getParameter("airport");

    if (airport != null && !airport.trim().isEmpty()) {
    	airport = airport.trim().toUpperCase();
        try {

            ApplicationDB db = new ApplicationDB();
            Connection con = db.getConnection();

            String query = "SELECT airID, flightNum, flightType, price, " +
                    "departure_date, departure_time, arrival_date, arrival_time, " +
                    "dep_portID, arr_portID, craftNum " +
                    "FROM flight WHERE dep_portID = ? OR arr_portID = ? " +
                    "ORDER BY departure_date, departure_time";

            PreparedStatement ps = con.prepareStatement(query);
            ps.setString(1, airport);
            ps.setString(2, airport);
            ResultSet rs = ps.executeQuery();

            if (rs.isBeforeFirst()) {
                %>
                <h3>Flights at Airport: <%= airport %></h3>
                <table>
                    <tr>
                    <th>Airline</th>
                    <th>Flight Number</th>
                    <th>Type</th>
                    <th>Price</th>
                    <th>Departure Date</th>
                    <th>Departure Time</th>
                    <th>Arrival Date</th>
                    <th>Arrival Time</th>
                    <th>Departure Airport</th>
                    <th>Arrival Airport</th>
                    <th>Aircraft #</th>
                </tr>
<%
            while (rs.next()) {
%>
                <tr>
                    <td><%= rs.getString("airID") %></td>
                    <td><%= rs.getInt("flightNum") %></td>
                    <td><%= rs.getString("flightType") %></td>
                    <td><%= rs.getDouble("price") %></td>
                    <td><%= rs.getDate("departure_date") %></td>
                    <td><%= rs.getTime("departure_time") %></td>
                    <td><%= rs.getDate("arrival_date") %></td>
                    <td><%= rs.getTime("arrival_time") %></td>
                    <td><%= rs.getString("dep_portID") %></td>
                    <td><%= rs.getString("arr_portID") %></td>
                    <td><%= rs.getInt("craftNum") %></td>
                </tr>
<%
            }
%>
            </table>
<%                
            } else {
%>
                <p>No flights found for airport <strong> <%= airport %></strong>.</p>
<%

            }
            rs.close();
            ps.close();
            con.close();
        } catch (Exception e) {
            %>
            <p>Error: <%= e.getMessage() %></p>
            <%
        }
    }
    %>
</body>
</html>
