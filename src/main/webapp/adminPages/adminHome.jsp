<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>

<!DOCTYPE html>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title>Admin Home Page</title>
	</head>
	<body>

		<h2>Welcome to the Admin Home Page!</h2>

		<div style="margin-top: 10px;">
			<h3>Manage Users</h3>
			<ul>
				<li><a href="adminPages/manageCustomerRep.jsp">Manage Customer Representatives</a></li>
				<li><a href="adminPages/manageCustomer.jsp">Manage Customers</a></li>
			</ul>
		</div>
		
		<div style="margin-top: 10px;">
	    	<h3>Sales Reports</h3>
			<form method="get" action="adminPages/salesReport.jsp">
			    <label for="month">Select Month:</label>
			    <select name="month" id="month">
			        <option value="1">January</option>
		            <option value="2">February</option>
		            <option value="3">March</option>
		            <option value="4">April</option>
		            <option value="5">May</option>
		            <option value="6">June</option>
		            <option value="7">July</option>
		            <option value="8">August</option>
		            <option value="9">September</option>
		            <option value="10">October</option>
		            <option value="11">November</option>
		            <option value="12">December</option>
			    </select>
			    <label for="year">Select Year:</label>
			    <select name="year" id="year">
			        <% 
			            int currentYear = java.time.Year.now().getValue();
			            for (int y = currentYear; y >= currentYear - 5; y--) {
			        %>
			            <option value="<%= y %>"><%= y %></option>
			        <% } %>
			    </select>
			    <button type="submit">Get Sales Report</button>
			</form>
		</div>

		<div style="margin-top: 10px;">
			<h3>Reservation Lists</h3>
			<ul>
				<li><a href="adminPages/reservations.jsp">Click here to query reservations</a></li>
			</ul>
		</div>

		<div style="margin-top: 10px;">
			<h3>Revenue Summaries</h3>
			<ul>
				<li><a href="adminPages/revenues.jsp">Click here to query revenues</a></li>
			</ul>
		</div>

		<div style="margin-top: 10px;">
			<h3>Top Customers & Flights</h3>
			<ul>
				<li><a href="adminPages/mostRevenueCustomer.jsp">Customer with Most Total Revenue</a></li>
				<li><a href="adminPages/mostActiveFlights.jsp">List of Most Active Flights</a></li>
			</ul>
		</div>

		<form action="../logout.jsp" method="post" style="margin-top: 20px;">
    		<input type="submit" value="Logout">
		</form>

	</body>
</html>