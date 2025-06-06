<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1" import="com.cs336.pkg.*" %>
<%@ page import="java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html>
<head>
	<style>
       table, th, td { border: 1px solid black; border-collapse: collapse; padding: 8px; }
   </style>
</head>

<body>
	<div style="display: flex; align-items: center;">
	  <h2>Flight Reservations</h2>
	  <div style="margin-left: 20px;">
	  	<form action="../adminHome.jsp" method="get">
	      <input type="submit" value="Admin Home">
	    </form>
	  </div>
	</div>
    <!-- by flight number -->
    <h3>Check reservations under a certain flight number:</h3>
    <form method="post" action="reservations.jsp">
        <label for="flightNum">Select Flight Number:</label>
        <select name="flightNum" id="flightNum">
            <option value="">Select Flight Number</option>
            <%
            try {
                // Get database connection
                ApplicationDB db = new ApplicationDB();
                Connection con = db.getConnection();
                
                String sql = "SELECT DISTINCT flightNum FROM flight ORDER BY flightNum";
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet flightNums = ps.executeQuery();
                
                String selectedFlight = request.getParameter("flightNum");  // Get currently selected flight (if any)

                while (flightNums.next()) { // Populate dropdown with flight numbers
                    String flightNum = flightNums.getString("flightNum");
                    boolean isSelected = flightNum.equals(selectedFlight);
            %>
                <option value="<%= flightNum %>" <%= isSelected ? "selected" : "" %>><%= flightNum %></option> <!--using SSR  -->
            <%
                }
                flightNums.close();
                ps.close();
            } catch (Exception e) {
                out.println("Error loading flight numbers: " + e.getMessage());
            }
            %>
        </select>
        <button type="submit">View Tickets</button>
    </form>
    
    <%
    // Handle display of tickets based on selected flight
    String selectedFlightNum = request.getParameter("flightNum");
    if (selectedFlightNum != null && !selectedFlightNum.trim().isEmpty()) {
        try {
            ApplicationDB db = new ApplicationDB();
            Connection con = db.getConnection();
            
            // Query to get tickets for selected flight
            String ticketQuery = "SELECT t.* FROM tickets t JOIN ticketlistsflights tf ON t.ticketNum = tf.ticketNum WHERE tf.flightNum = ? ORDER BY t.purchase_date";
            PreparedStatement ticketPs = con.prepareStatement(ticketQuery);
            ticketPs.setString(1, selectedFlightNum);
            ResultSet ticketRs = ticketPs.executeQuery();
            
            // Check if there are any tickets
            boolean hasTickets = ticketRs.isBeforeFirst();
            
            if (hasTickets) {
                // Get metadata to create table columns
                ResultSetMetaData metaData = ticketRs.getMetaData();
                int columnCount = metaData.getColumnCount();
    %>
                <h3>Tickets for Flight <%= selectedFlightNum %></h3>
                <table>
                    <tr>
                        <%
                        // table headers
                        for (int i = 1; i <= columnCount; i++) {
                            String columnName = metaData.getColumnName(i);
                        %>
                            <th><%= columnName %></th>
                        <%}%>
                    </tr>
                    
                    <% while (ticketRs.next()) { %>
                        <tr>
                            <% for (int i = 1; i <= columnCount; i++) {
	                                Object value = ticketRs.getObject(i);
	                                String displayValue = (value != null) ? value.toString() : "";
                            %>
                                <td><%= displayValue %></td>
                            <% } %>
                        </tr>
                    <% } %>
                </table>
    	<%} else {%>
                <p class="no-tickets">No tickets found for flight <%= selectedFlightNum %>.</p>
    <%
            }
            
            ticketRs.close();
            ticketPs.close();
            con.close();
        } catch (Exception e) {
            out.println("Error retrieving ticket data: " + e.getMessage());
        }
    }
    %>
    <!-- by customer name -->  
    <h3>Check reservations under a customer's name:</h3>
    <form method="post" action="reservations.jsp">
        <label for="customerName">Select Customer Name:</label>
        <select name="customerName" id="customerName">
            <option value="">Select Customer Name</option>
            <%
            try {
                // Get database connection
                ApplicationDB db = new ApplicationDB();
                Connection con = db.getConnection();
                
                // Query to get distinct flight numbers
                String sql = "SELECT DISTINCT CONCAT(fname, ' ', lname) as customerName FROM user WHERE userType='Customer' ORDER BY customerName";
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet customerNames = ps.executeQuery();
                
                // Get currently selected flight (if any)
                String selectedCustomer = request.getParameter("customerNames");
                
                // Populate dropdown with flight numbers
                while (customerNames.next()) {
                    String customerName = customerNames.getString("customerName");
                    boolean isSelected = customerName.equals(selectedCustomer);
            %>
                <option value="<%= customerName %>" <%= isSelected ? "selected" : "" %>><%= customerName %></option>
            <%
                }
                customerNames.close();
                ps.close();
            } catch (Exception e) {
                out.println("Error loading flight numbers: " + e.getMessage());
            }
            %>
        </select>
        <button type="submit">View Tickets</button>
    </form>
    
    <%
    // Handle display of tickets based on selected flight
    String selectedCustomer = request.getParameter("customerName");
    if (selectedCustomer != null && !selectedCustomer.trim().isEmpty()) {
        try {
            ApplicationDB db = new ApplicationDB();
            Connection con = db.getConnection();
            
            // Query to get tickets for selected flight
            String ticketQuery = "SELECT t.* FROM tickets t WHERE t.userID IN (SELECT userID FROM user WHERE TRIM(CONCAT(fname, ' ', lname)) = ?) ORDER BY purchase_date";
            PreparedStatement ticketPs = con.prepareStatement(ticketQuery);
            ticketPs.setString(1, selectedCustomer);
            ResultSet ticketRs = ticketPs.executeQuery();
            
            // Check if there are any tickets
            boolean hasTickets = ticketRs.isBeforeFirst();
            
            if (hasTickets) {
                // Get metadata to dynamically create table columns
                ResultSetMetaData metaData = ticketRs.getMetaData();
                int columnCount = metaData.getColumnCount();
    %>
                <h3>Tickets for Customer <%= selectedCustomer %></h3>
                <table>
                    <tr>
                        <%
                        // Generate table headers dynamically
                        for (int i = 1; i <= columnCount; i++) {
                            String columnName = metaData.getColumnName(i);
                        %>
                            <th><%= columnName %></th>
                        <%}%>
                    </tr>
                    
                    <% while (ticketRs.next()) { %>
                        <tr>
                            <% for (int i = 1; i <= columnCount; i++) {
	                                Object value = ticketRs.getObject(i);
	                                String displayValue = (value != null) ? value.toString() : "";
                            %>
                                <td><%= displayValue %></td>
                            <% } %>
                        </tr>
                    <% } %>
                </table>
    	<%} else {%>
                <p class="no-tickets">No tickets found for customer <%= selectedCustomer %>.</p>
    <%
            }
            
            ticketRs.close();
            ticketPs.close();
            con.close();
        } catch (Exception e) {
            out.println("Error retrieving ticket data: " + e.getMessage());
        }
    }
    %>
</body>
	
</html>