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
	
		<% try {
			
		    String username = request.getParameter("username").toLowerCase();
		    String password = request.getParameter("password");
		    String fname = request.getParameter("fname").toLowerCase();
		    String lname = request.getParameter("lname").toLowerCase();
		    String email = request.getParameter("email").toLowerCase();
		    String phoneNum = request.getParameter("phone");
		    String dob = request.getParameter("dob");
		    
		   
	
			//Get the database connection
			ApplicationDB db = new ApplicationDB();	
			Connection con = db.getConnection();	
			
			String checkUser = "SELECT COUNT(*) AS user_count FROM user WHERE username = ?";
			PreparedStatement checkStmt = con.prepareStatement(checkUser);
			checkStmt.setString(1, username);
		    ResultSet rs = checkStmt.executeQuery();
		    if (rs.next() && rs.getInt("user_count") > 0) {
		    	request.setAttribute("message", "Username already taken. Please choose another username.");
		    	RequestDispatcher dispatcher = request.getRequestDispatcher("signUp.jsp");
		        dispatcher.forward(request, response);
	        } else {
	        	 // If username does not exist, insert new user
	            String sql = "INSERT INTO user (fname, lname, email, phone_num, username, password, dob, userType) VALUES (?, ?, ?, ?, ?, ?, ?, 'customer')";
	            PreparedStatement stmt = con.prepareStatement(sql);
	            stmt.setString(1, fname);
	            stmt.setString(2, lname);
	            stmt.setString(3, email);
	            stmt.setString(4, phoneNum);
	            stmt.setString(5, username);
	            stmt.setString(6, password);
	            stmt.setString(7, dob);

	            int result = stmt.executeUpdate();

	            if (result > 0) {
	                out.println("<h2>Successfully created an account!</h2>");
	                out.println("<p><a href='login.jsp'>Return to login page</p>");
	            } else {
	                out.println("<h2>Account creation failed.</h2>");
	            }
	            stmt.close();
	        }
		
		    rs.close();
	        checkStmt.close();
	        db.closeConnection(con); 
		} catch (Exception e) {
		    out.println("An error occurred: " + e.getMessage());
		    e.printStackTrace();
		}
		%>
	    
	 
	   

	</body>
</html>