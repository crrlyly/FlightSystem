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
		
		<h1>Welcome to the customer home-page!</h1>
		
		<form method="get" action="">
			<h3>Search Departing Location</h3>
			<jsp:include page="homePageComponents/searchComponent.jsp">
			  <jsp:param name="searchType" value="airport" />
			  <jsp:param name="primaryID" value="port" />
			  <jsp:param name="input" value="Where from" />
			  <jsp:param name="searchId" value="departing" />
			</jsp:include>
			
			<h3>Search Arriving Location</h3>
			<jsp:include page="homePageComponents/searchComponent.jsp">
			  <jsp:param name="searchType" value="airport" />  
			  <jsp:param name="primaryID" value="port" />    
			  <jsp:param name="input" value="Where to" />    
			  <jsp:param name="searchId" value="arriving" />
			</jsp:include>
			
			<select style="display:block;margin-top:20px;" name="tripType" required>
			  <option value="" disabled selected>Select trip type</option>
			  <option value="oneway">One-way</option>
			  <option value="roundtrip">Round-trip</option>
			  <option value="multi">Multi-trip</option>
			</select>
			
			<div>
			    <label style="display:block;margin-top:20px;" for="departure-date">Date of Departure:</label>
			    <input type="date" name="departure-date" required min="<%= today %>">
			</div>
			
			<select style="display:block;margin-top:20px;" name="class" required>
			  <option value="" disabled selected>Select boarding class</option>
			  <option value="oneway">One-way</option>
			  <option value="roundtrip">Round-trip</option>
			  <option value="multi">Multi-trip</option>
			</select>
			
			
			
			<input style="display:block;margin-top:20px;" type="submit" value="Search Flights">
		</form>
		
		
		
		<form action="../logout.jsp" method="post" style="margin-top: 30px;">
    		<input type="submit" value="Logout">
		</form>


	</body>
</html>