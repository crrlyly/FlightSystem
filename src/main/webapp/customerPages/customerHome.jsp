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
		
		<% 
			Boolean repStatusObj = (Boolean) session.getAttribute("repStatus");
	
		    if (repStatusObj != null && repStatusObj) {
				String repFullName = (String) session.getAttribute("repFullName");
				String userFullName = (String) session.getAttribute("userFullName");
				%> 
				<h1>Welcome to <%= userFullName %>'s home-page!</h1>
				<h3>Customer Representative: <%= repFullName %> <span style="color:green;">Active</span></h3> 
				<a style="color: green;"href="../customerRepPages/repHome.jsp">Back to Customer Rep Page</a>
				<div style="margin-bottom: 20px;"></div><% 				
			}
			else{
				%> <h1>Welcome to the customer home-page!</h1> <%
			}
		%>
		<a style="" href="userProfile.jsp">View User Profile</a> 
		<div id='line' style='width: 100%; height: 2px; background-color:black; margin: 20px 0px;'></div>
		
		<h2>Search For Flights:</h2>
		<form method="get" action="searchFlight.jsp">
			<h3>Search Departing Location</h3>
			<jsp:include page="homePageComponents/searchComponent.jsp">
			  <jsp:param name="searchType" value="airport" />
			  <jsp:param name="primaryID" value="port" />
			  <jsp:param name="input" value="Where from" />
			  <jsp:param name="searchId" value="departing" />
			  <jsp:param name="col" value="name" />
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
			</select>
			
			
			<div id="non-multi-date">
			    <label style="display:block;margin-top:20px;" for="departure-date">Date of Departure:</label>
			    <input type="date" name="departure-date" required min="<%= today %>">
			</div>
			
			<label style="margin-top:10px;">
			    <input type="checkbox" name="flexible" value="yes"> Flexible dates (+/- 3 days)
			</label>
			
		
			<select style="display:block;margin-top:20px;" name="class" required>
			  <option value="" disabled selected>Select boarding class</option>
			  <option value="first">first class</option>
			  <option value="economy">economy class</option>
			  <option value="business">business class</option>
			</select>
			
		
			<input style="display:block;margin-top:20px;" type="submit" value="Search Flights">
		</form>
		
		<div id='line' style='width: 100%; height: 2px; background-color:black; margin: 20px 0px;'></div>
		
		<%
			    if (repStatusObj == null || !repStatusObj) {
			%>
			    <a href="qaSearchPage.jsp">Need help?</a>
			
			    <form action="../logout.jsp" method="post" style="margin-top: 30px;">
			        <input type="submit" value="Logout">
			    </form>
			<%
			    }
		%>

	<script>
		
	</script>
	
	</body>
</html>