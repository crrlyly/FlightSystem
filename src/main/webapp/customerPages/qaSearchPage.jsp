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

	<form method="get" action="qaPageCode/showQA.jsp">
			<h3>Browse Questions and Answers</h3>
			<jsp:include page="homePageComponents/searchComponent.jsp">
			  <jsp:param name="searchType" value="QAtable" />
			  <jsp:param name="primaryID" value="question" />
			  <jsp:param name="input" value="Enter a question keyword..." />
			  <jsp:param name="searchId" value="question" />
			</jsp:include>
			
			
			<input style="display:block;margin-top:20px;margin-bottom: 20px;" type="submit" value="Search Question">
		</form>
		
	<div id='line' style='width: 100%; height: 2px; background-color:black; margin: 10px 0px;'></div>
	
	
	<form method="post" action="qaPageCode/submitQuestion.jsp">
			<h3>Have a question? Create One Here!</h3>
			<label for="question">Question:</label>
			<input type="text" id="question" name="question" placeholder="Enter your question..."><br><br>
		<input style="display:block;margin-top:20px;margin-bottom: 20px;" type="submit" value="Submit Your Question">
	</form>
		
		
		
		<a href='customerHome.jsp'>Return to home-page</a>
		



</body>
</html>
