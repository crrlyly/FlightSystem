<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>


<!DOCTYPE>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title>User login</title>
	</head>
	<body>
		<% try {
			
		    String username = request.getParameter("username");
		    String password = request.getParameter("password");
		   
	
			//Get the database connection
			ApplicationDB db = new ApplicationDB();	
			Connection con = db.getConnection();		

			//Create a SQL statement
			String sql = "SELECT * FROM user WHERE username=? AND password=?";
			PreparedStatement stmt = con.prepareStatement(sql);
			stmt.setString(1, username);
			stmt.setString(2, password);
			//Run the query against the database.
			
			ResultSet rs = stmt.executeQuery();
			
			if (rs.next()) {
				session.setAttribute("user", username); 
				session.setAttribute("userID", rs.getInt("userID"));
			

	           String role = rs.getString("userType");
	           out.println("<h2>Login successful for user: " + username + "</h2>");
	           // Check user role and display appropriate content
	           if ("customer".equalsIgnoreCase(role)) {
	        	   response.sendRedirect("customerPages/customerHome.jsp");
	           } else if ("customerrep".equalsIgnoreCase(role)) {
	        	   response.sendRedirect("customerRepPages/repHome.jsp");
	           } else if ("siteAdmin".equalsIgnoreCase(role)) {
	        	   response.sendRedirect("adminPages/adminHome.jsp");
	           }
	        } else {
	            out.println("<h2>Login failed. Incorrect username or password.</h2>");
	            out.println("<a href='login.jsp'>Please Login</a>");
	        }
			// Close connections
			rs.close();
			stmt.close();
			db.closeConnection(con);
		} catch (Exception e) {
		    out.println("An error occurred: " + e.getMessage());
		    e.printStackTrace();
		}
		%>

	</body>
</html>