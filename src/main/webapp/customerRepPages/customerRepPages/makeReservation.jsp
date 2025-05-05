<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.lang.*, java.io.*, java.util.*, java.sql.*, java.text.SimpleDateFormat" %>

<!DOCTYPE html>
<html>
<head>
   <title>Reserve Flights for Users</title>
   <style>
       table {width: 60%; border: 1px solid black; border-collapse: collapse;}
       th, td { border: 1px solid black; padding: 8px; }
       th { background-color: #f2f2f2; }
       .action-btn { margin-right: 10px; }
       .message { padding: 10px; margin-bottom: 15px; border-radius: 4px; }
       .success { background-color: #d4edda; color: #155724; }
       .error { background-color: #f8d7da; color: #721c24; }
   </style>
</head>
<body>
   <div style="display: flex; align-items: center;">
      <h2>Reserve Flights for Users</h2>
      <div style="margin-left: 20px;">
        <form action="../repHome.jsp" method="get">
          <input type="submit" value="Customer Representative Home Page" style="background-color: darkgrey; color: white; border: 1px black; cursor: pointer;">
        </form>
      </div>
   </div>

   <!-- Rep Verification Form -->
   <form method="post" action="makeReservation.jsp">
       <label for="repFirstName">Enter Your First Name:</label>
       <input type="text" name="repFirstName" required />
       <label for="repLastName">Enter Your Last Name:</label>
       <input type="text" name="repLastName" required />
       <input type="hidden" name="action" value="verifyRep" />
       <input type="submit" value="Verify Representative" />
   </form>

<%
   String action = request.getParameter("action");

   if ("verifyRep".equals(action)) {
       String repFirstName = request.getParameter("repFirstName");
       String repLastName = request.getParameter("repLastName");
	   session.setAttribute("repFullName", repFirstName + " " + repLastName);


       try {
           ApplicationDB db = new ApplicationDB();
           Connection con = db.getConnection();

           PreparedStatement ps = con.prepareStatement("SELECT * FROM user WHERE fname = ? AND lname = ? AND userType = 'customerRep'");
           ps.setString(1, repFirstName);
           ps.setString(2, repLastName);
           ResultSet rs = ps.executeQuery();

           if (rs.next()) {
               String repName = rs.getString("username");
               session.setAttribute("repName", repName);
               int repID = rs.getInt("userID");
               session.setAttribute("repID", repID);
               
               out.println("<div class='message success'>Welcome, " + repName + "! You are now verified as a customer representative.</div>");
           } else {
               out.println("<div class='message error'>No matching representative found. Please check the name or ensure you're a customer representative.</div>");
           }

           con.close();
       } catch (Exception e) {
           out.println("<div class='message error'>Error: " + e.getMessage() + "</div>");
       }
   }

   // Show search user form only if rep is verified
   if (session.getAttribute("repName") != null) {
%>
   <form method="post" action="makeReservation.jsp">
       <label for="userID">Enter UserID to Search:</label>
       <input type="text" name="userID" required />
       <input type="hidden" name="action" value="searchUser" />
       <input type="submit" value="Search User" />
   </form>
<%
   }

   if ("searchUser".equals(action)) {
       String repName = (String) session.getAttribute("repName");
       if (repName == null) {
           out.println("<div class='message error'>Please verify yourself as a representative before searching for a user.</div>");
       } else {
           String userID = request.getParameter("userID");

           try {
               ApplicationDB db = new ApplicationDB();
               Connection con = db.getConnection();

               PreparedStatement ps = con.prepareStatement("SELECT * FROM user WHERE userID = ?");
               ps.setString(1, userID);
               ResultSet rs = ps.executeQuery();

               if (rs.next()) {
                   String userType = rs.getString("userType");
                   if (!"customer".equals(userType)) {
%>
                       <div class="message error">User is not a customer. Cannot proceed with reservation.</div>
<%
                   } else {
%>
                       <div class="message success">
                           <strong>User Found:</strong><br>
                           Name: <%= rs.getString("fname") %> <%= rs.getString("lname") %><br>
                           Email: <%= rs.getString("email") %><br>
                           User ID: <%= rs.getInt("userID") %><br>
                       </div>

                   		
<%						//set the user to search flights and be brought to the search flight page for that user
						session.setAttribute("user", rs.getString("username")); 
						session.setAttribute("userID", rs.getInt("userID"));
						session.setAttribute("userFullName", rs.getString("fname") + " " + rs.getString("lname"));
						session.setAttribute("repStatus", true);
						
						
						%>
						
							<a href="../../customerPages/customerHome.jsp">Click to go to the user's home-page to make a flight reservation.</a>
						
						<% 


						
                   }
               } else {
%>
                   <div class="message error">User with ID <%= userID %> not found.</div>
<%
               }

               con.close();
           } catch (Exception e) {
               out.println("<div class='message error'>Error: " + e.getMessage() + "</div>");
           }
       }
   }
   

   if ("search".equals(action)) {
       String repName = (String) session.getAttribute("repName");
       if (repName == null) {
           out.println("<div class='message error'>Please verify yourself as a representative before searching for flights.</div>");
    
       }
   }
%>

</body>
</html>
