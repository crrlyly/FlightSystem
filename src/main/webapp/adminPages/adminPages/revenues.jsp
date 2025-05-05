<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1" import="com.cs336.pkg.*" %>
<%@ page import="java.sql.*, java.util.*, java.text.*" %>
<!DOCTYPE html>
<html>
<head>
   <style>
       table, th, td { border: 1px solid black; border-collapse: collapse; padding: 8px; }
   </style>
</head>

<body>
      <div style="display: flex; align-items: center;">
		  <h2>Revenue Summaries Page</h2>
		  <div style="margin-left: 20px;">
		  	<form action="../adminHome.jsp" method="get">
		      <input type="submit" value="Admin Home">
		    </form>
		  </div>
	</div>
    
    <div>
        <h3>Select Filter Criteria</h3>
        
        <form method="post" action="revenues.jsp">
            <div style="margin-bottom:10px">
                <label>Filter by:</label>
                <input type="radio" name="filterType" value="flight" id="filter-flight" <%= "flight".equals(request.getParameter("filterType")) ? "checked" : "" %>>
                <label for="filter-flight">Flight</label>
                
                <input type="radio" name="filterType" value="airline" id="filter-airline" <%= "airline".equals(request.getParameter("filterType")) ? "checked" : "" %>>
                <label for="filter-airline">Airline</label>
                
                <input type="radio" name="filterType" value="customer" id="filter-customer" <%= "customer".equals(request.getParameter("filterType")) ? "checked" : "" %>>
                <label for="filter-customer">Customer</label>
            </div>
            
            <div id="flightFilter" <%= "flight".equals(request.getParameter("filterType")) ? "" : "style='display:none;'" %>>
                <label for="flightNum">Flight Number:</label>
                <select name="flightNum" id="flightNum">
                    <option value="">Select Flight Number</option>
                    <%
                    try {
                        ApplicationDB db = new ApplicationDB();
                        Connection con = db.getConnection();
                        
                        String sql = "SELECT DISTINCT flightNum FROM ticketlistsflights ORDER BY flightNum";
                        PreparedStatement ps = con.prepareStatement(sql);
                        ResultSet rs = ps.executeQuery();
                        
                        String selectedFlight = request.getParameter("flightNum");
                        
                        while (rs.next()) {
                            String flightNum = rs.getString("flightNum");
                            boolean isSelected = flightNum.equals(selectedFlight);
                    %>
                        <option value="<%= flightNum %>" <%= isSelected ? "selected" : "" %>><%= flightNum %></option>
                    <%
                        }
                        rs.close();
                        ps.close();
                        con.close();
                    } catch (Exception e) {
                        out.println("Error loading flight numbers: " + e.getMessage());
                    }
                    %>
                </select>
            </div>
            
            <div id="airlineFilter" <%= "airline".equals(request.getParameter("filterType")) ? "" : "style='display:none;'" %>>
                <label for="airID">Airline:</label>
                <select name="airID" id="airID">
                    <option value="">Select Airline</option>
                    <%
                    try {
                        ApplicationDB db = new ApplicationDB();
                        Connection con = db.getConnection();
                        
                        String sql = "SELECT DISTINCT airID FROM airline ORDER BY airID";
                        PreparedStatement ps = con.prepareStatement(sql);
                        ResultSet rs = ps.executeQuery();
                        
                        String selectedAirline = request.getParameter("airID");
                        
                        while (rs.next()) {
                            String airID = rs.getString("airID");
                            boolean isSelected = airID.equals(selectedAirline);
                    %>
                        <option value="<%= airID %>" <%= isSelected ? "selected" : "" %>><%= airID %></option>
                    <%
                        }
                        rs.close();
                        ps.close();
                        con.close();
                    } catch (Exception e) {
                        out.println("Error loading airlines: " + e.getMessage());
                    }
                    %>
                </select>
            </div>

            <div id="customerFilter" <%= "customer".equals(request.getParameter("filterType")) ? "" : "style='display:none;'" %>>
                <label for="userID">Customer:</label>
                <select name="userID" id="userID">
                    <option value="">Select Customer (userID - Last Name)</option>
                    <%
                    try {
                        ApplicationDB db = new ApplicationDB();
                        Connection con = db.getConnection();
                        
                        // Assuming repName in tickets table stores customer names
                        String sql = "SELECT DISTINCT userID, lname FROM user WHERE userType='Customer' ORDER BY userID";
                        PreparedStatement ps = con.prepareStatement(sql);
                        ResultSet rs = ps.executeQuery();
                        
                        String selectedCustomer = request.getParameter("userID");
                        
                        while (rs.next()) {
                            String userID = rs.getString("userID");
                            String lname = rs.getString("lname");
                            boolean isSelected = userID != null && userID.equals(selectedCustomer);
                    %>
                        <option value="<%= userID %>" <%= isSelected ? "selected" : "" %>><%= userID %> - <%= lname %></option>
                    <%
                        }
                        rs.close();
                        ps.close();
                        con.close();
                    } catch (Exception e) {
                        out.println("Error loading customers: " + e.getMessage());
                    }
                    %>
                </select>
            </div>
            
            <button type="submit" style="margin-top: 10px">Generate Revenue Summary</button>
        </form>
    </div>
    
    <script> // another way to insert java code < can add async tag for unordered script downloading and defer tag for ordered script downloading
        // Show/hide filter options based on selection
        document.addEventListener('DOMContentLoaded', function() { //make sure elements are loaded before using them
            const flightFilter = document.getElementById('flightFilter');
            const airlineFilter = document.getElementById('airlineFilter');
            const customerFilter = document.getElementById('customerFilter');
            //event listener to check if user clicks a diff radio button
            document.querySelectorAll('input[name="filterType"]').forEach(radio => {
                radio.addEventListener('change', function() {
                    flightFilter.style.display = (this.value === 'flight') ? 'block' : 'none'; // (if flight selected, display'block', else display nothing)
                    airlineFilter.style.display = (this.value === 'airline') ? 'block' : 'none';
                    customerFilter.style.display = (this.value === 'customer') ? 'block' : 'none';
                });
            });
        });
    </script>
    
    <div class="revenue-summary">
        <%
        String filterType = request.getParameter("filterType");
        
        if (filterType != null && !filterType.isEmpty()) {
            String filter = null;
            String filterValue = null;
            String filterDisplay = null;
            
            if ("flight".equals(filterType)) {
                filterValue = request.getParameter("flightNum");
                filter = "flightNum";
                filterDisplay = "Flight " + filterValue;
            } else if ("airline".equals(filterType)) {
                filterValue = request.getParameter("airID");
                filter = "airID";
                filterDisplay = "Airline " + filterValue;
            } else if ("customer".equals(filterType)) {
                filterValue = request.getParameter("userID");
                filter = "userID";
                filterDisplay = "Customer " + filterValue;
            }
            
            if (filterValue != null && !filterValue.isEmpty()) {
                try {
                    ApplicationDB db = new ApplicationDB();
                    Connection con = db.getConnection();
                    
                    StringBuilder queryBuilder = new StringBuilder();
                    
                    if ("flight".equals(filterType)) {
                        queryBuilder.append("SELECT ");
                        queryBuilder.append("tf.flightNum, ");
                        queryBuilder.append("COUNT(t.ticketNum) AS ticket_count, ");
                        queryBuilder.append("SUM(t.booking_price) AS total_revenue, ");
                        queryBuilder.append("AVG(t.booking_price) AS avg_ticket_price ");
                        queryBuilder.append("FROM ticketlistsflights tf ");
                        queryBuilder.append("JOIN tickets t ON tf.ticketNum = t.ticketNum ");
                        queryBuilder.append("WHERE tf.flightNum = ? ");
                        queryBuilder.append("GROUP BY tf.flightNum");

                    } else if ("airline".equals(filterType)) {
                        queryBuilder.append("SELECT ");
                        queryBuilder.append("COALESCE(COUNT(t.ticketNum), 0) AS ticket_count, ");
                        queryBuilder.append("COALESCE(SUM(t.booking_price), 0) AS total_revenue, ");
                        queryBuilder.append("COALESCE(AVG(t.booking_price), 0) AS avg_ticket_price ");
                        queryBuilder.append("FROM airline a ");
                        queryBuilder.append("LEFT JOIN ticketlistsflights tf ON tf.airID = a.airID ");
                        queryBuilder.append("LEFT JOIN tickets t ON tf.ticketNum = t.ticketNum ");
                        queryBuilder.append("WHERE a.airID = ?");
                        
                    } else if ("customer".equals(filterType)) {
                        queryBuilder.append("SELECT ");
                        queryBuilder.append("COALESCE(COUNT(t.ticketNum), 0) AS ticket_count, ");
                        queryBuilder.append("COALESCE(SUM(t.booking_price), 0) AS total_revenue, ");
                        queryBuilder.append("COALESCE(AVG(t.booking_price), 0) AS avg_ticket_price ");
                        queryBuilder.append("FROM user u ");
                        queryBuilder.append("LEFT JOIN tickets t ON t.userID = u.userID ");
                        queryBuilder.append("WHERE u.userID = ?");
                    }

                    
                    PreparedStatement ps = con.prepareStatement(queryBuilder.toString());
                    ps.setString(1, filterValue);
                    ResultSet rs = ps.executeQuery();

                    if (rs.next()) {
                        double totalRevenue = rs.getDouble("total_revenue");
                        int ticketCount = rs.getInt("ticket_count");
                        double avgTicketPrice = rs.getDouble("avg_ticket_price");

                        // Get detailed ticket information
                        String detailQuery = "";
                        if ("flight".equals(filterType)) {
                            detailQuery = "SELECT t.*, tf.flightNum, tf.airID FROM tickets t " +
                                          "JOIN ticketlistsflights tf ON t.ticketNum = tf.ticketNum " +
                                          "WHERE tf.flightNum = ? ORDER BY t.purchase_date DESC";
                        } else if ("airline".equals(filterType)) {
                            detailQuery = "SELECT t.*, tf.flightNum, tf.airID FROM tickets t " +
                                          "JOIN ticketlistsflights tf ON t.ticketNum = tf.ticketNum " +
                                          "WHERE tf.airID = ? ORDER BY t.purchase_date DESC";
                        } else if ("customer".equals(filterType)) {
                            detailQuery = "SELECT t.*, tf.flightNum, tf.airID, u.userID FROM tickets t " +
                                          "JOIN ticketlistsflights tf ON t.ticketNum = tf.ticketNum " +
                                          "JOIN user u ON t.userID = u.userID " +
                                          "WHERE u.userID = ? ORDER BY t.purchase_date DESC";
                        }


                        PreparedStatement detailPs = con.prepareStatement(detailQuery);
                        detailPs.setString(1, filterValue);
                        ResultSet detailRs = detailPs.executeQuery();
                    %>
                        <h3>Revenue Summary for <%= filterDisplay %></h3>

                        <div class="summary-card">
                            <p>Total Revenue: <%= String.format("%.2f", totalRevenue) %></p>
                            <p>Total Tickets: <%= ticketCount %></p>
                            <p>Average Ticket Price: <%= String.format("%.2f", avgTicketPrice) %></p>
                        </div>

                        <h4>Detailed Ticket Information</h4>
                        <table>
                            <tr>
                                <th>Ticket ID</th>
                                <th>Flight Number</th>
                                <th>Airline</th>
                                <th>Customer</th>
                                <th>Purchase Date</th>
                                <th>Total Fare</th>
                            </tr>
                            <% 
                            while (detailRs.next()) { 
                                String purchaseDateTime = "";
                                java.sql.Timestamp timestamp = detailRs.getTimestamp("purchase_date");
                                if (timestamp != null) {
                                    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
                                    purchaseDateTime = dateFormat.format(timestamp);
                                }
                             %>
                                <tr>
                                    <td><%= detailRs.getInt("ticketNum") %></td>
                                    <td><%= detailRs.getString("flightNum") %></td>
                                    <td><%= detailRs.getString("airID") %></td>
                                    <td><%= detailRs.getString("userID") != null ? detailRs.getString("userID") : "N/A" %></td>
                                    <td><%= purchaseDateTime %></td>
                                    <td><%= String.format("%.2f", detailRs.getDouble("booking_price")) %></td>
                                </tr>
                            <% } 
                            detailRs.close();
                            detailPs.close();
                            %>
                        </table>
                    <%
                    } else {
                    %>
                        <div class="no-data">
                            <h3>No Revenue Data Available</h3>
                            <p>No revenue data found for <%= filterDisplay %>. There might be no tickets associated with this selection.</p>
                        </div>
                    <%
                    }

                    rs.close();
                    ps.close();
                    con.close();
                    %>
		<%
                } catch (Exception e) {
        %>
                    <div class="error">
                        <h3>Error Generating Revenue Report</h3>
                        <p><%= e.getMessage() %></p>
                    </div>
        <%
                }
            }
        }
        %>
    </div>
</body>
</html>