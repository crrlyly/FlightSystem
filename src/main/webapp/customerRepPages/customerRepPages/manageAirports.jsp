<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1" import="com.cs336.pkg.*" %>
<%@ page import="java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html>
<head>
   <title>Manage Airports</title>
   <style>
       table, th, td { border: 1px solid black; border-collapse: collapse; padding: 8px; }
       th { background-color: #f2f2f2; }
       .action-btn { margin-right: 10px; }
       .message { padding: 10px; margin-bottom: 15px; border-radius: 4px; }
       .success { background-color: #d4edda; color: #155724; }
       .error { background-color: #f8d7da; color: #721c24; }
   </style>
</head>
<body>
   <div style="display: flex; align-items: center;">
	  <h2>Manage Airports</h2>
	  <div style="margin-left: 20px;">
	  	<form action="../repHome.jsp" method="get">
	      <input type="submit" value="Customer Representative Home Page" style="background-color: darkgrey; color: white; border: 1px black; cursor: pointer;">
	    </form>
	  </div>
	</div>
   
<%
   // Process form submissions
   String actionType = request.getParameter("actionType");
   String message = null;
   String messageType = null;
   
   if (request.getParameter("msg") != null && request.getParameter("type") != null) {
       message = request.getParameter("msg");
       messageType = request.getParameter("type");
   }
   
   if (actionType != null) {
       try {
           ApplicationDB db = new ApplicationDB();	
           Connection con = db.getConnection();
           
           // ADD operation
           
           if ("add".equals(actionType) && request.getParameter("portID") != null) {
        	   String portID = request.getParameter("portID");
        	   String location = request.getParameter("location");
        	   String name = request.getParameter("name");
        	   
        	   // Check if portID already exists
        	   String checkSql = "SELECT COUNT(*) FROM airport WHERE portID = ?";
        	   PreparedStatement checkPs = con.prepareStatement(checkSql);
        	   checkPs.setString(1, portID);
        	   ResultSet rs = checkPs.executeQuery();
        	   if (rs.next() && rs.getInt(1) > 0){
        		   message = "Error: Airport ID already exists!";
        	   }
        	   else{
        			// Insert new aircraft
                   String insertSql = "INSERT INTO airport (portID, location, name) VALUES (?, ?, ?)";
                   PreparedStatement insertPs = con.prepareStatement(insertSql);
                   insertPs.setString(1, portID);
                   insertPs.setString(2, location);
                   insertPs.setString(3, name);               
            	   
                       int rows = insertPs.executeUpdate();
                       if (rows > 0) {
                    	    response.sendRedirect("manageAirports.jsp?msg=Airport+added+successfully!&type=success");
                    	    return;
                    	}
        		   
        	   }
        	   
        	   
            }
           
           // Handle EDIT operation
           else if ("edit".equals(actionType) && request.getParameter("portID") != null) {
               String portID = request.getParameter("portID");
               String location = request.getParameter("location");        	   
               String name = request.getParameter("name");
               
               PreparedStatement updateA = con.prepareStatement(
            		   "UPDATE airport SET location = ?, name = ? WHERE portID = ?");
               updateA.setString(1, location);
               updateA.setString(2, name);
               updateA.setString(3, portID);               
               
               int rows = updateA.executeUpdate();
               if(rows > 0){
            	    response.sendRedirect("manageAirports.jsp?msg=Airport+updated+successfully!&type=success");
            	    return;
            	}
               else{
            	   message = "Airport not found or could not be updated.!";
            	   messageType = "error";
               }
           }
           
           // Handle DELETE operation
           else if ("delete".equals(actionType) && request.getParameter("portID") != null) {
               String portID = request.getParameter("portID");
               
               String deleteSql = "DELETE FROM airport WHERE portID = ?";
               PreparedStatement deletePs = con.prepareStatement(deleteSql);
               deletePs.setString(1, portID);
               
               int rows = deletePs.executeUpdate();
               if (rows > 0) {
                   message = "Airport deleted successfully!";
                   messageType = "success";
               } else {
                   message = "Airport not found or could not be deleted.";
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
   if (message != null){
%>
	<div class="message <%=messageType %>">
	 	<%= message %>
	</div>
<% 
   }
%>

   <form action="manageAirports.jsp" method="post" style="margin-bottom: 20px;">
       <input type="hidden" name="actionType" value="add"/>
       <input type="submit" value="Add New Airports"/>
   </form>
   <table>
       <tr>
           <th>Airport ID</th>
           <th>Location</th>
           <th>Name</th>
           <th>Actions</th>
       </tr>
<%
	//Load aircrafts from DB
	try {
	    ApplicationDB db = new ApplicationDB();	
	    Connection con = db.getConnection();
	    String sql = "SELECT * FROM airport";
	    PreparedStatement ps = con.prepareStatement(sql);
	    ResultSet rs = ps.executeQuery();
	    while (rs.next()) { 
%>

       <tr>
           	<td><%= rs.getString("portID") %></td>          
			<td><%= rs.getString("location") %></td>             
			<td><%= rs.getString("name") %></td>       

           <td>
               <!-- Edit Button -->
               <form method="post" action="manageAirports.jsp" style="display:inline;">
    				<input type="hidden" name="actionType" value="editForm"/>
    				<input type="hidden" name="portID" value="<%= rs.getString("portID") %>"/>
   					<input type="submit" value="Edit" class="action-btn"/>
				</form>

               <!-- Delete Button -->
               <form method="post" action="manageAirports.jsp" style="display:inline;">
                   <input type="hidden" name="actionType" value="delete"/>
                   <input type="hidden" name="portID" value="<%= rs.getString("portID") %>"/>
                   <input type="submit" value="Delete" onclick="return confirm('Are you sure you want to delete this airport?')"/>
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
	//Optional: render form for Add or Edit
	String action = request.getParameter("actionType");	
	String portID = "";
	String location = "";
	String name = "";
			
	if ("add".equals(action)|| "editForm".equals(action)) {
	    portID = request.getParameter("portID");
	    
	    if (portID != null && !portID.isEmpty()) {
	        try {
	            ApplicationDB db = new ApplicationDB();	
	            Connection con = db.getConnection();
	            String sql = "SELECT * FROM airport WHERE portID = ?";
	            PreparedStatement ps = con.prepareStatement(sql);
	            ps.setString(1, portID);
	            ResultSet rs = ps.executeQuery();
	            if (rs.next()) {
	                portID = rs.getString("portID");
	                location = rs.getString("location");
	                name = rs.getString("name");
	                
	            }
	            con.close();
	        } catch (Exception e) {
	            out.println("Error loading airports: " + e.getMessage());
	        }
	    
	} else{
		portID = "";
        location = "";
        name = "";
	}
%>
   <h3><%= "editForm".equals(action) ? "Edit Airport" : "Add New Airport" %></h3>
   <form method="post" action="manageAirports.jsp">
       <input type="hidden" name="actionType" value="<%= "editForm".equals(action) ? "edit" : "add" %>"/>	
       <table style="border: none;">
			<tr>
 				<td>Airport ID:</td>
    			<td>
        			<% if ("editForm".equals(action)) { %>
            			<input type="text" name="portID" value="<%= portID %>" readonly/>
        			<% } else { %>
            			<input type="text" name="portID" value="<%= portID %>"/>
        			<% } %>
    			</td>
			</tr> 
           <tr>
               <td>Location:</td>
               <td><input type="text" name="location" value="<%= location %>"/></td>
           </tr>
           <tr>
               <td>Name:</td>
               <td><input type="text" name="name" value="<%= name %>"/></td>
           </tr>
           <tr>
               <td colspan="2">
                   <input type="submit" value="<%= "editForm".equals(action) ? "Update Airport" : "Add Airport" %>"/>
               </td>
           </tr>
       </table>
   </form>
<%
	}
%>
</body>
</html>