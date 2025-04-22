<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>

<!DOCTYPE>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title>Customer Representative Home Page</title>
	</head>
	<body>
		
		<h2>Welcome to the Customer Representative Home Page!</h2>
		<h3>Manage Flight Reservation</h3>
		<div style="display: flex; align-items: center;">
			<form action="customerRepPages/makeReservation.jsp" method="get" style="margin-right: 10px;">
		      <input type="submit" value="Make Reservation">
		    </form>
		    <form action="customerRepPages/editReservation.jsp" method="get">
		      <input type="submit" value="Edit Reservation">
		    </form>
		</div>
		<div style="margin-top: 10px;">
			<h3>Customer Interaction</h3>
			<div style="margin-top: 10px; display: flex; align-items: center;">
				<form method="get" action="customerRepPages/replyQuestions.jsp" style="margin-right: 10px;">
					<input type="submit" value="Respond to User Inquiries">
				</form>
			</div>
		</div>
		<div style="margin-top: 10px;">
			<h3>Flight Management</h3>
			<div style="margin-top: 10px; display: flex; align-items: center;">
				<form method="get" action="customerRepPages/manageAircrafts.jsp">
					<input type="submit" value="Manage Aircrafts">
				</form>
				<form method="get" action="customerRepPages/manageAirports.jsp">
					<input type="submit" value="Manage Airports">
				</form>
				<form method="get" action="customerRepPages/manageFlight.jsp" style="margin-right: 10px;">
					<input type="submit" value="Manage Flights">
				</form>
			</div>
		</div>
		<div style="margin-top: 10px;">
			<h3>Reports & Lookups</h3>
			<div style="margin-top: 10px; display: flex; align-items: center;">
				<form method="get" action="customerRepPages/searchWaitingList.jsp">
					<input type="submit" value="Waiting List Lookup">
				</form>
				<form method="get" action="customerRepPages/searchFlights.jsp">
					<input type="submit" value="Flights by Airports">
				</form>
			</div>
		</div>
		<form action="../logout.jsp" method="post" style="margin-top: 20px;">
    		<input type="submit" value="Logout">
		</form>

	</body>
</html>