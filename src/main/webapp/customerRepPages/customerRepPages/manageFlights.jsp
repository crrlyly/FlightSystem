<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1" import="com.cs336.pkg.*" %>
<%@ page import="java.sql.*, java.util.*, java.sql.Date, java.sql.Time" %>
<!DOCTYPE html>
<html>
<head>
   <title>Manage Flights</title>
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
	  <h2>Manage Flights</h2>
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
               int flightNum = Integer.parseInt(request.getParameter("flightNum"));
               String flightType = request.getParameter("flightType");
               double price = Double.parseDouble(request.getParameter("price"));
               int operatingDays = Integer.parseInt(request.getParameter("operating_days"));
               Date depDate = Date.valueOf(request.getParameter("departure_date"));
               Time depTime = Time.valueOf(request.getParameter("departure_time"));
               Date arrDate = Date.valueOf(request.getParameter("arrival_date"));
               Time arrTime = Time.valueOf(request.getParameter("arrival_time"));
               String depPortId = request.getParameter("dep_portID");
               String arrPortId = request.getParameter("arr_portID");
               String domesticReg = request.getParameter("domestic_reg");
               String internationalReg = request.getParameter("international_reg");
               int craftNum = Integer.parseInt(request.getParameter("craftNum"));
               int openFirstSeats = Integer.parseInt(request.getParameter("openFirstSeats"));
               int openBusinessSeats = Integer.parseInt(request.getParameter("openBusinessSeats"));
               int openEconomySeats = Integer.parseInt(request.getParameter("openEconomySeats"));
               
               // Check airId exists in flight
               PreparedStatement checkFlight = con.prepareStatement("SELECT airID FROM airline WHERE airID = ?");
               checkFlight.setString(1, airId);
               ResultSet flightExists = checkFlight.executeQuery();
               
               if (!flightExists.next()) {
                   message = "Airline ID not found. Please choose another.";
                   messageType = "error";
               } else {
                   // Insert new aircraft
                   String insertSql = "INSERT INTO flight (airID, flightNum, flightType, price, operating_days, departure_date, departure_time, arrival_date, arrival_time, dep_portID, arr_portID, domestic_reg, international_reg, craftNum, openFirstSeats, openBusinessSeats, openEconomySeats) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                   PreparedStatement insertPs = con.prepareStatement(insertSql);
                   insertPs.setString(1, airId);
                   insertPs.setInt(2, flightNum);
                   insertPs.setString(3, flightType);
                   insertPs.setDouble(4, price);
                   insertPs.setInt(5, operatingDays);
                   insertPs.setDate(6, depDate);
                   insertPs.setTime(7, depTime);
                   insertPs.setDate(8, arrDate);
                   insertPs.setTime(9, arrTime);
                   insertPs.setString(10, depPortId);
                   insertPs.setString(11, arrPortId);
                   insertPs.setString(12, domesticReg);
                   insertPs.setString(13, internationalReg);
                   insertPs.setInt(14, craftNum);
                   insertPs.setInt(15, openFirstSeats);
                   insertPs.setInt(16, openBusinessSeats);
                   insertPs.setInt(17, openEconomySeats);

                   
                   int rows = insertPs.executeUpdate();
                   if (rows > 0) {
                	    response.sendRedirect("manageFlights.jsp?msg=Flight+added+successfully!&type=success");
                	    return;
                	} 
               }
           }
           
           // Handle EDIT operation
           else if ("edit".equals(actionType) && request.getParameter("airID") != null) {
        	   String airId = request.getParameter("airID");
               int flightNum = Integer.parseInt(request.getParameter("flightNum"));
               String flightType = request.getParameter("flightType");
               double price = Double.parseDouble(request.getParameter("price"));
               int operatingDays = Integer.parseInt(request.getParameter("operating_days"));
               Date depDate = Date.valueOf(request.getParameter("departure_date"));
               Time depTime = Time.valueOf(request.getParameter("departure_time"));
               Date arrDate = Date.valueOf(request.getParameter("arrival_date"));
               Time arrTime = Time.valueOf(request.getParameter("arrival_time"));
               String depPortId = request.getParameter("dep_portID");
               String arrPortId = request.getParameter("arr_portID");
               String domesticReg = request.getParameter("domestic_reg");
               String internationalReg = request.getParameter("international_reg");
               int craftNum = Integer.parseInt(request.getParameter("craftNum"));
               int openFirstSeats = Integer.parseInt(request.getParameter("openFirstSeats"));
               int openBusinessSeats = Integer.parseInt(request.getParameter("openBusinessSeats"));
               int openEconomySeats = Integer.parseInt(request.getParameter("openEconomySeats"));
               
               
               PreparedStatement updateA = con.prepareStatement(
            		    "UPDATE flight SET flightType = ?, price = ?, operating_days = ?, departure_date = ?, departure_time = ?, arrival_date = ?, arrival_time = ?, dep_portID = ?, arr_portID = ?, domestic_reg = ?, international_reg = ?, craftNum = ?, openFirstSeats = ?, openBusinessSeats = ?, openEconomySeats = ? WHERE airID = ? AND flightNum = ?");
            		updateA.setString(1, flightType);
            		updateA.setDouble(2, price);
            		updateA.setInt(3, operatingDays);
            		updateA.setDate(4, depDate);
            		updateA.setTime(5, depTime);
            		updateA.setDate(6, arrDate);
            		updateA.setTime(7, arrTime);
            		updateA.setString(8, depPortId);
            		updateA.setString(9, arrPortId);
            		updateA.setString(10, domesticReg);
            		updateA.setString(11, internationalReg);
            		updateA.setInt(12, craftNum);
            		updateA.setInt(13, openFirstSeats);
            		updateA.setInt(14, openBusinessSeats);
            		updateA.setInt(15, openEconomySeats);
            		updateA.setString(16, airId); 
            		updateA.setInt(17, flightNum);

               int rows = updateA.executeUpdate();
               if(rows > 0){
            	    response.sendRedirect("manageFlights.jsp?msg=Flight+updated+successfully!&type=success");
            	    return;
            	}
               else{
            	   message = "Flight not found or could not be updated.!";
            	   messageType = "error";
               }
           }
           
           // Handle DELETE operation
           else if ("delete".equals(actionType) && request.getParameter("airID") != null) {
               String airID = request.getParameter("airID");
               int flightNum = Integer.parseInt(request.getParameter("flightNum"));
                
               String deleteSql = "DELETE FROM flight WHERE airID = ? AND flightNum =?";
               PreparedStatement deletePs = con.prepareStatement(deleteSql);
               deletePs.setString(1, airID);
               deletePs.setInt(2, flightNum);
               
               int rows = deletePs.executeUpdate();
               if (rows > 0) {
                   message = "Flight deleted successfully!";
                   messageType = "success";
               } else {
                   message = "Flight not found or could not be deleted.";
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

   <form action="manageFlights.jsp" method="post" style="margin-bottom: 20px;">
       <input type="hidden" name="actionType" value="add"/>
       <input type="submit" value="Add New Flight"/>
   </form>
   <table>
       <tr>
        <th>Airline ID</th>
        <th>Flight #</th>
        <th>Type</th>
        <th>Price</th>
        <th>Days</th>
        <th>Dep Date</th>
        <th>Dep Time</th>
        <th>Arr Date</th>
        <th>Arr Time</th>
        <th>Dep Port</th>
        <th>Arr Port</th>
        <th>Domestic Reg</th>
        <th>Intl Reg</th>
        <th>Craft #</th>
        <th>1st Seats</th>
        <th>Biz Seats</th>
        <th>Eco Seats</th>
        <th>Actions</th>
    </tr>
<%
	//Load aircrafts from DB
	try {
	    ApplicationDB db = new ApplicationDB();	
	    Connection con = db.getConnection();
	    String sql = "SELECT * FROM flight";
	    PreparedStatement ps = con.prepareStatement(sql);
	    ResultSet rs = ps.executeQuery();
	    while (rs.next()) { 
%>

       <tr>
           	<td><%= rs.getString("airID") %></td>
	        <td><%= rs.getInt("flightNum") %></td>
	        <td><%= rs.getString("flightType") %></td>
	        <td><%= rs.getDouble("price") %></td>
	        <td><%= rs.getInt("operating_days") %></td>
	        <td><%= rs.getDate("departure_date") %></td>
	        <td><%= rs.getTime("departure_time") %></td>
	        <td><%= rs.getDate("arrival_date") %></td>
	        <td><%= rs.getTime("arrival_time") %></td>
	        <td><%= rs.getString("dep_portID") %></td>
	        <td><%= rs.getString("arr_portID") %></td>
	        <td><%= rs.getString("domestic_reg") %></td>
	        <td><%= rs.getString("international_reg") %></td>
	        <td><%= rs.getInt("craftNum") %></td>
	        <td><%= rs.getInt("openFirstSeats") %></td>
	        <td><%= rs.getInt("openBusinessSeats") %></td>
	        <td><%= rs.getInt("openEconomySeats") %></td>
           <td>
               <!-- Edit Button -->
               <form method="post" action="manageFlights.jsp" style="display:inline;">
                   <input type="hidden" name="actionType" value="editForm"/>
                   <input type="hidden" name="airID" value="<%= rs.getString("airID") %>"/>
                	<input type="hidden" name="flightNum" value="<%= rs.getInt("flightNum") %>"/>
                   <input type="submit" value="Edit" class="action-btn"/>
               </form>
               <!-- Delete Button -->
               <form method="post" action="manageFlights.jsp" style="display:inline;">
                   <input type="hidden" name="actionType" value="delete"/>
                   <input type="hidden" name="airID" value="<%= rs.getString("airID") %>"/>
                	<input type="hidden" name="flightNum" value="<%= rs.getInt("flightNum") %>"/>
                   <input type="submit" value="Delete" onclick="return confirm('Are you sure you want to delete this flight?')"/>
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
	    String airID = "";
	    int flightNum = 0;
	    String flightType = "";
	    double price = 0.0;
	    int operating_days = 0;
	    Date departure_date = null;
	    Time departure_time = null;
	    Date arrival_date = null;
	    Time arrival_time = null;
	    String dep_portID = "";
	    String arr_portID = "";
	    String domestic_reg = "";
	    String international_reg = "";
	    int craftNum = 0;
	    int openFirstSeats = 0;
	    int openBusinessSeats = 0;
	    int openEconomySeats = 0;
	    
	    if ("editForm".equals(action) && airID != null) {
	    	airID = request.getParameter("airID");
	        flightNum = Integer.parseInt(request.getParameter("flightNum"));
	    	try {
	            ApplicationDB db = new ApplicationDB();	
	            Connection con = db.getConnection();
	            String sql = "SELECT * FROM flight WHERE airID = ? AND flightNum = ?";
	            PreparedStatement ps = con.prepareStatement(sql);
	            ps.setString(1, airID);
	            ps.setInt(2, flightNum);
	            ResultSet rs = ps.executeQuery();
	            if (rs.next()) {
	            	airID = rs.getString("airID");
	                flightNum = rs.getInt("flightNum");
	                flightType = rs.getString("flightType");
	                price = rs.getDouble("price");
	                operating_days = rs.getInt("operating_days");
	                departure_date = rs.getDate("departure_date");
	                departure_time = rs.getTime("departure_time");
	                arrival_date = rs.getDate("arrival_date");
	                arrival_time = rs.getTime("arrival_time");
	                dep_portID = rs.getString("dep_portID");
	                arr_portID = rs.getString("arr_portID");
	                domestic_reg = rs.getString("domestic_reg");
	                international_reg = rs.getString("international_reg");
	                craftNum = rs.getInt("craftNum");
	                openFirstSeats = rs.getInt("openFirstSeats");
	                openBusinessSeats = rs.getInt("openBusinessSeats");
	                openEconomySeats = rs.getInt("openEconomySeats");
	                
	            }
	            con.close();
	        } catch (Exception e) {
	            out.println("Error loading aircraft: " + e.getMessage());
	        }
	    }
%>
   <h3><%= "editForm".equals(action) ? "Edit Flight" : "Add New Flight" %></h3>
   <form method="post" action="manageFlights.jsp">
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
	        		<td>Flight Number:</td>
	        		<td><input type="number" name="flightNum" value="<%= flightNum %>"/></td>
	        	</tr>
	        	<tr>
	        		<td>Flight Type:</td>
	        		<td><input type="text" name="flightType" value="<%= flightType %>"/></td>
	        	</tr>
	        	<tr>
	        		<td>Price:</td
	        		><td><input type="number" step="0.01" name="price" value="<%= price %>"/></td>
	        	</tr>
	        	<tr>
	        		<td>Operating Days:</td>
	        		<td><input type="number" name="operating_days" value="<%= operating_days %>"/></td>
	        	</tr>
	        	<tr>
	        		<td>Departure Date:</td>
	        		<td><input type="date" name="departure_date" value="<%= departure_date %>"/></td>
	        	</tr>
	        	<tr>
	        		<td>Departure Time:</td>
	        		<td><input type="time" name="departure_time" value="<%= departure_time %>"/></td>
	        	</tr>
	        	<tr>
	        		<td>Arrival Date:</td>
	        		<td><input type="date" name="arrival_date" value="<%= arrival_date %>"/></td>
	        	</tr>
	        	<tr>
	        		<td>Arrival Time:</td>
	        		<td><input type="time" name="arrival_time" value="<%= arrival_time %>"/></td>
	        	</tr>
	        	<tr>
	        		<td>Departure Port ID:</td>
	        		<td><input type="text" name="dep_portID" value="<%= dep_portID %>"/></td>
	        	</tr>
	        	<tr>
	        		<td>Arrival Port ID:</td>
	        		<td><input type="text" name="arr_portID" value="<%= arr_portID %>"/></td>
	        	</tr>
	        	<tr>
	        		<td>Domestic Registration:</td>
	        		<td><input type="text" name="domestic_reg" value="<%= domestic_reg %>"/></td>
	        	</tr>
	       		 <tr>
	       		 	<td>International Registration:</td>
	       		 	<td><input type="text" name="international_reg" value="<%= international_reg %>"/></td>
	       		 </tr>
	        	<tr>
	        		<td>Craft Number:</td>
	        		<td><input type="number" name="craftNum" value="<%= craftNum %>"/></td>
	        	</tr>
	        	<tr>
	        		<td>Open First Class Seats:</td>
	        		<td><input type="number" name="openFirstSeats" value="<%= openFirstSeats %>"/></td>
	        	</tr>
	        	<tr>
	        		<td>Open Business Class Seats:</td>
	        		<td><input type="number" name="openBusinessSeats" value="<%= openBusinessSeats %>"/></td>
	        	</tr>
	        	<tr>
	        		<td>Open Economy Seats:</td><td><input type="number" name="openEconomySeats" value="<%= openEconomySeats %>"/></td>
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
