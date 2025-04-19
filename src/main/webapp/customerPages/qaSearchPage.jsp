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

	<form method="get" action="searchFlight.jsp">
			<h3>Search Departing Location</h3>
			<jsp:include page="homePageComponents/searchComponent.jsp">
			  <jsp:param name="searchType" value="QAtable" />
			  <jsp:param name="primaryID" value="question" />
			  <jsp:param name="input" value="Search questions" />
			  <jsp:param name="searchId" value="question" />
			</jsp:include>
			
		
			<input style="display:block;margin-top:20px;" type="submit" value="Search Question">
		</form>
		



</body>
</html>
