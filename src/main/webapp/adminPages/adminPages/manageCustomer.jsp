<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1" import="com.cs336.pkg.*" %>
<%@ page import="java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html>
<head>
   <title>Manage Customer</title>
   <style>
       table, th, td { border: 1px solid black; border-collapse: collapse; padding: 8px; }
   </style>
</head>
<body>
	<div style="display: flex; align-items: center;">
	  <h2>Customers</h2>
	  <div style="margin-left: 20px;">
	  	<form action="../adminHome.jsp" method="get">
	      <input type="submit" value="Admin Home">
	    </form>
	  </div>
	</div>
<%
   // Process form submissions
   String actionType = request.getParameter("actionType");
   String message = null;
   String messageType = null;
   
   if (actionType != null) {
       try {
           ApplicationDB db = new ApplicationDB();	
           Connection con = db.getConnection();
           
           // Handle ADD operation
           if ("add".equals(actionType) && request.getParameter("username") != null) {
               String fname = request.getParameter("fname");
               String lname = request.getParameter("lname");
               String email = request.getParameter("email");
               String phone = request.getParameter("phone_num");
               String username = request.getParameter("username");
               String password = request.getParameter("password");
               String dob = request.getParameter("dob");
               
               // Check if username exists
               PreparedStatement checkUser = con.prepareStatement("SELECT username FROM user WHERE username = ?");
               checkUser.setString(1, username);
               ResultSet userExists = checkUser.executeQuery();
               
               if (userExists.next()) {
                   message = "Username already exists. Please choose another.";
                   messageType = "error";
               } else if (username == null || username.trim().isEmpty() || password == null || password.trim().isEmpty()) {
                   message = "Username and password are required fields.";
                   messageType = "error";
               } else {
                   // Insert new customer rep
                   String insertSql = "INSERT INTO user (fname, lname, email, phone_num, username, password, dob, userType) VALUES (?, ?, ?, ?, ?, ?, ?, 'Customer')";
                   PreparedStatement insertPs = con.prepareStatement(insertSql);
                   insertPs.setString(1, fname);
                   insertPs.setString(2, lname);
                   insertPs.setString(3, email);
                   insertPs.setString(4, phone);
                   insertPs.setString(5, username);
                   insertPs.setString(6, password);
                   insertPs.setString(7, dob);
                   
                   int rowsAffected = insertPs.executeUpdate();
                   if (rowsAffected > 0) {
                       message = "Customer added successfully!";
                       messageType = "success";
                   }
               }
           }
           
           // Handle EDIT operation
           else if ("edit".equals(actionType) && request.getParameter("userID") != null) {
               int userID = Integer.parseInt(request.getParameter("userID"));
               String fname = request.getParameter("fname");
               String lname = request.getParameter("lname");
               String email = request.getParameter("email");
               String phone = request.getParameter("phone_num");
               String username = request.getParameter("username");
               String password = request.getParameter("password");
               String dob = request.getParameter("dob");
               
               // Check if username exists and belongs to a different user
               PreparedStatement checkUser = con.prepareStatement("SELECT username FROM user WHERE username = ? AND userID != ?");
               checkUser.setString(1, username);
               checkUser.setInt(2, userID);
               ResultSet userExists = checkUser.executeQuery();
               
               if (userExists.next()) {
                   message = "Username already exists. Please choose another.";
                   messageType = "error";
               } else {
                   StringBuilder updateSql = new StringBuilder("UPDATE user SET fname=?, lname=?, email=?, phone_num=?, username=?");
                   
                   // Only update password if provided
                   if (password != null && !password.trim().isEmpty()) {
                       updateSql.append(", password=?");
                   }
                   
                   updateSql.append(", dob=? WHERE userID=?");
                   
                   PreparedStatement updatePs = con.prepareStatement(updateSql.toString());
                   updatePs.setString(1, fname);
                   updatePs.setString(2, lname);
                   updatePs.setString(3, email);
                   updatePs.setString(4, phone);
                   updatePs.setString(5, username);
                   
                   int paramIndex = 6;
                   if (password != null && !password.trim().isEmpty()) {
                       updatePs.setString(paramIndex++, password);
                   }
                   
                   updatePs.setString(paramIndex++, dob);
                   updatePs.setInt(paramIndex, userID);
                   
                   int rowsAffected = updatePs.executeUpdate();
                   if (rowsAffected > 0) {
                       message = "Customer updated successfully!";
                       messageType = "success";
                   }
               }
           }
           
           // Handle DELETE operation
           else if ("delete".equals(actionType) && request.getParameter("userID") != null) {
               int userID = Integer.parseInt(request.getParameter("userID"));
               
               String deleteSql = "DELETE FROM user WHERE userID = ? AND userType = 'Customer'";
               PreparedStatement deletePs = con.prepareStatement(deleteSql);
               deletePs.setInt(1, userID);
               
               int rowsAffected = deletePs.executeUpdate();
               if (rowsAffected > 0) {
                   message = "Customer deleted successfully!";
                   messageType = "success";
               } else {
                   message = "Failed to delete user. User not found or is not a customer.";
                   messageType = "error";
               }
           }
           
           con.close();
       } catch (Exception e) {
           message = "Error: " + e.getMessage();
           messageType = "error";
       }
   }
   
   // Display message if there is one
   if (message != null) {
%>
   <div class="message <%= messageType %>">
       <%= message %>
   </div>
<%
   }
%>

   <form action="manageCustomer.jsp" method="post" style="margin-bottom: 20px;">
       <input type="hidden" name="actionType" value="add"/>
       <input type="submit" value="Add New User"/>
   </form>
   <table>
       <tr>
           <th>ID</th>
           <th>Name</th>
           <th>Email</th>
           <th>Phone</th>
           <th>Username</th>
           <th>DOB</th>
           <th>Actions</th>
       </tr>
<%
   // Load customer reps from DB
   try {
       ApplicationDB db = new ApplicationDB();	
       Connection con = db.getConnection();
       String sql = "SELECT * FROM user WHERE userType = 'Customer'";
       PreparedStatement ps = con.prepareStatement(sql);
       ResultSet rs = ps.executeQuery();
       while (rs.next()) {
%>
       <tr>
           <td><%= rs.getInt("userID") %></td>
           <td><%= rs.getString("fname") != null ? rs.getString("fname") : "" %> <%= rs.getString("lname") != null ? rs.getString("lname") : "" %></td>
           <td><%= rs.getString("email") != null ? rs.getString("email") : "" %></td>
           <td><%= rs.getString("phone_num") != null ? rs.getString("phone_num") : "" %></td>
           <td><%= rs.getString("username") %></td>
           <td><%= rs.getDate("dob") != null ? rs.getDate("dob") : "" %></td>
           <td>
               <!-- Edit Button -->
               <form method="post" action="manageCustomer.jsp#editSection" style="display:inline;">
                   <input type="hidden" name="actionType" value="editForm"/>
                   <input type="hidden" name="userID" value="<%= rs.getInt("userID") %>"/>
                   <input type="submit" value="Edit" class="action-btn"/>
               </form>
               <!-- Delete Button -->
               <form method="post" action="manageCustomer.jsp" style="display:inline;">
                   <input type="hidden" name="actionType" value="delete"/>
                   <input type="hidden" name="userID" value="<%= rs.getInt("userID") %>"/>
                   <input type="submit" value="Delete" onclick="return confirm('Are you sure you want to delete this customer?')"/>
               </form>
           </td>
       </tr>
<%
       }
       con.close();
   } catch (Exception e) {
       out.println("Error: " + e.getMessage());
   }
%>
   </table>
<%
   // Optional: render form for Add or Edit
   String action = request.getParameter("actionType");
   if ("add".equals(action) || "editForm".equals(action)) {
       String userID = request.getParameter("userID");
       String fname = "", lname = "", email = "", phone = "", username = "", dob = "";
       if ("editForm".equals(action) && userID != null) {
           try {
               ApplicationDB db = new ApplicationDB();	
               Connection con = db.getConnection();
               String sql = "SELECT * FROM user WHERE userID = ?";
               PreparedStatement ps = con.prepareStatement(sql);
               ps.setInt(1, Integer.parseInt(userID));
               ResultSet rs = ps.executeQuery();
               if (rs.next()) {
                   fname = rs.getString("fname") != null ? rs.getString("fname") : "";
                   lname = rs.getString("lname") != null ? rs.getString("lname") : "";
                   email = rs.getString("email") != null ? rs.getString("email") : "";
                   phone = rs.getString("phone_num") != null ? rs.getString("phone_num") : "";
                   username = rs.getString("username");
                   dob = rs.getDate("dob") != null ? rs.getDate("dob").toString() : "";
               }
               con.close();
           } catch (Exception e) {
               out.println("Error loading user: " + e.getMessage());
           }
       }
%>
   <h3 id="formSection"><%= "editForm".equals(action) ? "Edit User" : "Add New User" %></h3>
   <form method="post" action="manageCustomer.jsp#formSection">
       <input type="hidden" name="actionType" value="<%= "editForm".equals(action) ? "edit" : "add" %>"/>
       <% if ("editForm".equals(action)) { %>
           <input type="hidden" name="userID" value="<%= userID %>"/>
       <% } %>
       <table style="border: none;">
           <tr>
               <td>First Name:</td>
               <td><input type="text" name="fname" value="<%= fname %>"/></td>
           </tr>
           <tr>
               <td>Last Name:</td>
               <td><input type="text" name="lname" value="<%= lname %>"/></td>
           </tr>
           <tr>
               <td>Email:</td>
               <td><input type="email" name="email" value="<%= email %>"/></td>
           </tr>
           <tr>
               <td>Phone:</td>
               <td><input type="text" name="phone_num" value="<%= phone %>"/></td>
           </tr>
           <tr>
               <td>Username:</td>
               <td><input type="text" name="username" value="<%= username %>" required/></td>
           </tr>
           <tr>
               <td>Password:</td>
               <td><input type="password" name="password" <%= "add".equals(action) ? "required" : "" %>/></td>
           </tr>
           <tr>
               <td>Date of Birth:</td>
               <td><input type="date" name="dob" value="<%= dob %>"/></td>
           </tr>
           <tr>
               <td colspan="2">
                   <input type="submit" value="<%= "editForm".equals(action) ? "Update User" : "Create User" %>"/>
               </td>
           </tr>
       </table>
   </form>
<%
   }
%>
   	
</body>
</html>