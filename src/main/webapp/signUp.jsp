<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>

<!DOCTYPE>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title>Sign Up</title>
	</head>
	<body>
			<h1>Please Create Your Account!</h1>
			<form method="post" action="signUpCode.jsp"> 
				<div>
	            	<label for="username">Create Username:</label>
	            	<input type="text" name="username" required>
	        	</div>
	        	<div>
	            	<label for="password">Create Password:</label>
	            	<input type="password" name="password" required>
	        	</div>
	        	<div>
	            	<label for="fname">First Name:</label>
	            	<input type="text" name="fname" required>
	        	</div>
	        	<div>
	            	<label for="lname">Last Name:</label>
	            	<input type="text" name="lname" required>
	        	</div>
	        	<div>
	            	<label for="email">Email:</label>         
	            	<input type="email" name="email" required>
	        	</div>
	        	<div>
	            	<label for="phone">Phone Number:</label>
	            	<input type="tel" name="phone" placeholder="123-456-7890" required>
	        	</div>
	        	<div>
	            	<label for="dob">Date of Birth:</label>
	            	<input type="date" name="dob" required>
	        	</div>
	        	
	        	<div>
	            	<button type="submit">Sign Up</button>
	        	</div>
	   		</form>
	   		
	   		<% 
		    String message = (String) request.getAttribute("message");
		    if (message != null) {
		        out.println("<h3 style='color: red;'>" + message + "</h2>");
		    }
		    %>
	   		
	    
	    <a href="login.jsp">Go back to log in</a>	 
	   

	</body>
</html>