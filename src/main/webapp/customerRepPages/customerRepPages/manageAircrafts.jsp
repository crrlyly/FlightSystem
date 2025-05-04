<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1" import="com.cs336.pkg.*" %>
<%@ page import="java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html>
<head>
   <title>Manage Aircrafts</title>
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
	  <h2>Manage Aircrafts</h2>
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
           
           if ("add".equals(actionType) && request.getParameter("airID") != null) {
        	   String airId = request.getParameter("airID");
        	   int firstSeats = Integer.parseInt(request.getParameter("firstSeatNum"));
        	   int businessSeats = Integer.parseInt(request.getParameter("businessSeatNum"));
        	   int economySeats = Integer.parseInt(request.getParameter("economySeatNum"));
               
               // Check airId exists in Airline
               PreparedStatement checkAirline = con.prepareStatement("SELECT airID FROM airline WHERE airID = ?");
               checkAirline.setString(1, airId);
               ResultSet airlineExists = checkAirline.executeQuery();
               
               if (!airlineExists.next()) {
                   message = "Airline ID not found. Please choose another.";
                   messageType = "error";
               } else {
                   // Insert new aircraft
                   String insertSql = "INSERT INTO aircraft (airID, firstSeatNum, businessSeatNum, economySeatNum) VALUES (?, ?, ?, ?)";
                   PreparedStatement insertPs = con.prepareStatement(insertSql);
                   insertPs.setString(1, airId);
                   insertPs.setInt(2, firstSeats);
                   insertPs.setInt(3, businessSeats);
                   insertPs.setInt(4, economySeats);

                   
                   int rows = insertPs.executeUpdate();
                   if (rows > 0) {
                	    response.sendRedirect("manageAircrafts.jsp?msg=Aircraft+added+successfully!&type=success");
                	    return;
                	}
               }
           }
           
           // Handle EDIT operation
           else if ("edit".equals(actionType) && request.getParameter("craftNum") != null) {
               int craftNum = Integer.parseInt(request.getParameter("craftNum"));
               String airId = request.getParameter("airID");
        	   int firstSeats = Integer.parseInt(request.getParameter("firstSeatNum"));
        	   int businessSeats = Integer.parseInt(request.getParameter("businessSeatNum"));
        	   int economySeats = Integer.parseInt(request.getParameter("economySeatNum"));
               
               PreparedStatement updateA = con.prepareStatement(
            		   "UPDATE aircraft SET airID=?, firstSeatNum=?, businessSeatNum=?, economySeatNum=? WHERE craftNum=?");
               updateA.setString(1, airId);
               updateA.setInt(2, firstSeats);
               updateA.setInt(3, businessSeats);
               updateA.setInt(4, economySeats);
               updateA.setInt(5, craftNum);
               
               int rows = updateA.executeUpdate();
               if(rows > 0){
            	    response.sendRedirect("manageAircrafts.jsp?msg=Aircraft+updated+successfully!&type=success");
            	    return;
            	}
               else{
            	   message = "Aircraft not found or could not be updated.!";
            	   messageType = "error";
               }
           }
           
           // Handle DELETE operation
           else if ("delete".equals(actionType) && request.getParameter("craftNum") != null) {
               int craftNum = Integer.parseInt(request.getParameter("craftNum"));
               
               String deleteSql = "DELETE FROM aircraft WHERE craftNum = ?";
               PreparedStatement deletePs = con.prepareStatement(deleteSql);
               deletePs.setInt(1, craftNum);
               
               int rows = deletePs.executeUpdate();
               if (rows > 0) {
                   message = "Aircrafts deleted successfully!";
                   messageType = "success";
               } else {
                   message = "Aircraft not found or could not be deleted.";
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

   <form action="manageAircrafts.jsp" method="post" style="margin-bottom: 20px;">
       <input type="hidden" name="actionType" value="add"/>
       <input type="submit" value="Add New Aircraft"/>
   </form>
   <table>
       <tr>
           <th>Aircraft Number</th>
           <th>Airline ID</th>
           <th>First Class Seats</th>
           <th>Business Class Seats</th>
           <th>Economy Class Seats</th>
           <th>Actions</th>
       </tr>
<%
	//Load aircrafts from DB
	try {
	    ApplicationDB db = new ApplicationDB();	
	    Connection con = db.getConnection();
	    String sql = "SELECT * FROM aircraft";
	    PreparedStatement ps = con.prepareStatement(sql);
	    ResultSet rs = ps.executeQuery();
	    while (rs.next()) { 
%>

       <tr>
           	<td><%= rs.getInt("craftNum") %></td>          
			<td><%= rs.getString("airID") %></td>             
			<td><%= rs.getInt("firstSeatNum") %></td>       
			<td><%= rs.getInt("businessSeatNum") %></td>    
			<td><%= rs.getInt("economySeatNum") %></td>     

           <td>
               <!-- Edit Button -->
               <form method="post" action="manageAircrafts.jsp" style="display:inline;">
                   <input type="hidden" name="actionType" value="editForm"/>
                   <input type="hidden" name="craftNum" value="<%= rs.getInt("craftNum") %>"/>
                   <input type="submit" value="Edit" class="action-btn"/>
               </form>
               <!-- Delete Button -->
               <form method="post" action="manageAircrafts.jsp" style="display:inline;">
                   <input type="hidden" name="actionType" value="delete"/>
                   <input type="hidden" name="craftNum" value="<%= rs.getInt("craftNum") %>"/>
                   <input type="submit" value="Delete" onclick="return confirm('Are you sure you want to delete this aircraft?')"/>
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
	if ("add".equals(action) || "editForm".equals(action)) {
	    String craftNum = request.getParameter("craftNum");
	    String airID = "";
	    int availFirst = 0, availBusiness = 0, availEconomy = 0;
	    if ("editForm".equals(action) && craftNum != null) {
	        try {
	            ApplicationDB db = new ApplicationDB();	
	            Connection con = db.getConnection();
	            String sql = "SELECT * FROM aircraft WHERE craftNum = ?";
	            PreparedStatement ps = con.prepareStatement(sql);
	            ps.setInt(1, Integer.parseInt(craftNum));
	            ResultSet rs = ps.executeQuery();
	            if (rs.next()) {
	                airID = rs.getString("airID");
	                availFirst = rs.getInt("firstSeatNum");
	                availBusiness = rs.getInt("businessSeatNum");
	                availEconomy = rs.getInt("economySeatNum");
	                
	            }
	            con.close();
	        } catch (Exception e) {
	            out.println("Error loading aircraft: " + e.getMessage());
	        }
	    }
%>
   <h3><%= "editForm".equals(action) ? "Edit Aircraft" : "Add New Aircraft" %></h3>
   <form method="post" action="manageAircrafts.jsp">
       <input type="hidden" name="actionType" value="<%= "editForm".equals(action) ? "edit" : "add" %>"/>
       <% if ("editForm".equals(action)) { %>
           <input type="hidden" name="craftNum" value="<%= craftNum %>"/>
       <% } %>
       <table style="border: none;">
       	   <tr>
               <td>Airline ID:</td>
               <td><input type="text" name="airID" value="<%= airID %>"/></td>
           </tr>
           <tr>
               <td>First Class Seats:</td>
               <td><input type="number" name="firstSeatNum" value="<%= availFirst %>"/></td>
           </tr>
           <tr>
               <td>Business Class Seats:</td>
               <td><input type="number" name="businessSeatNum" value="<%= availBusiness %>"/></td>
           </tr>
           <tr>
               <td>Economy Seats:</td>
               <td><input type="number" name="economySeatNum" value="<%= availEconomy %>"/></td>
           </tr>
           <tr>
               <td colspan="2">
                   <input type="submit" value="<%= "editForm".equals(action) ? "Update Aircraft" : "Add Aircraft" %>"/>
               </td>
           </tr>
       </table>
   </form>
<%
	}
%>
</body>
</html>