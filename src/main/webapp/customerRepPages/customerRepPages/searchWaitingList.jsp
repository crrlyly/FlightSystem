<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>

<!DOCTYPE html>
<html>
<head>
    <style>
        body { margin: 20px; }
        table {
            border-collapse: collapse;
            width: 100%;
            margin-top: 20px;
            text-align: left;
        }
        th, td { border: 1px solid #ddd; padding: 8px; }
    </style>
</head>
<body>

<div style="display: flex; align-items: center;">
    <h2>Search Waiting List for a Flight</h2>
    <div style="margin-left: 20px;">
        <form action="../repHome.jsp" method="get">
            <input type="submit" value="Customer Representative Home Page" style="background-color: darkgrey; color: white; border: 1px black; cursor: pointer;">
        </form>
    </div>
</div>

<form action="searchWaitingList.jsp" method="get">
    <label for="airID">Flight ID:</label><br>
    <input type="text" id="airID" name="airID" placeholder="e.g., AA" required><br><br>
    <label for="flightNum">Flight Number:</label><br>
    <input type="number" id="flightNum" name="flightNum" placeholder="e.g., 123" required><br><br>
    <input type="submit" value="Search" style="background-color: darkgrey; color: white; border: 1px black; cursor: pointer;">
</form>

<%
String airID = request.getParameter("airID");
String flightNumStr = request.getParameter("flightNum");

if (airID != null && flightNumStr != null && !airID.trim().isEmpty() && !flightNumStr.trim().isEmpty()) {
    try {
        int flightNum = Integer.parseInt(flightNumStr.trim());

        ApplicationDB db = new ApplicationDB();
        Connection con = db.getConnection();

        String query = 
            "SELECT u.userID, u.fname, u.lname, u.email " +
            "FROM waitinglist w " +
            "JOIN tickets t ON w.ticketNum = t.ticketNum " +
            "JOIN user u ON t.userID = u.userID " +
            "WHERE w.airID = ? AND w.flightNum = ?";

        PreparedStatement ps = con.prepareStatement(query);
        ps.setString(1, airID.toUpperCase().trim());
        ps.setInt(2, flightNum);
        ResultSet rs = ps.executeQuery();

        if (rs.isBeforeFirst()) {
%>
<h3>Waiting List for Flight ID: <%= airID.toUpperCase() + flightNum %></h3>
<table>
    <tr>
        <th>Passenger ID</th>
        <th>First Name</th>
        <th>Last Name</th>
        <th>Email</th>
    </tr>
<%
    while (rs.next()) {
%>
    <tr>
        <td><%= rs.getInt("userID") %></td>
        <td><%= rs.getString("fname") %></td>
        <td><%= rs.getString("lname") %></td>
        <td><%= rs.getString("email") %></td>
    </tr>
<%
    }
%>
</table>
<%
        } else {
%>
<p>No passengers found on the waiting list for Flight ID: <%= airID.toUpperCase() + flightNum %>.</p>
<%
        }

        rs.close();
        ps.close();
        con.close();
    } catch (Exception e) {
%>
<p style="color: red;">Error: <%= e.getMessage() %></p>
<%
    }
}
%>

</body>
</html>
