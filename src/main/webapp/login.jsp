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
		
		<h1>Please Log In!</h1>
	  	<form method="get" action="loginCode.jsp"> 
        	<div>
            	<label for="username">Username:</label>
            	<input type="text" name="username" required>
        	</div>
        	<div>
            	<label for="password">Password:</label>
            	<input type="password" name="password" required>
        	</div>
        	<div>
            	<button type="submit">Login</button>
        	</div>
	    </form>
	    
	    <a href="signUp.jsp">Sign Up!</a>
	   

	</body>
</html>