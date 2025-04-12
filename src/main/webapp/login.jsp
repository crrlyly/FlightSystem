<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>

<!DOCTYPE>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title>Customer Login Form</title>
	</head>
	<body>
		<h1>Please log in!</h1>
		<form action="loginCode.jsp" method="POST">
			Username: <input type="text" name="username"/> <br/>
			Password: <input type="password" name="password"/> <br/>
			<input type="submit" value="Submit"/>
		</form>
		<a href="signUp.jsp">Sign Up!</a>
	</body>
</html>