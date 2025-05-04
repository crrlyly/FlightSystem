<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>

<!DOCTYPE html>
<html>
<head>
   <style>
       table, th, td { border: 1px solid black; border-collapse: collapse; padding: 8px; }
   </style>
</head>
<body>
    <div style="display: flex; align-items: center;">
		<h2>Customer with Most Revenue</h2>
		<div style="margin-left: 20px;">
			<form action="../adminHome.jsp" method="get">
				<input type="submit" value="Admin Home">
			</form>
		</div>
	</div>
    
    <%
    try {
        ApplicationDB db = new ApplicationDB();
        Connection con = db.getConnection();
        
        // Query to get the customer with the highest total revenue
        String query = "SELECT u.userID, u.fname, u.lname, SUM(t.booking_price) as total_revenue " +
                       "FROM user u " +
                       "JOIN tickets t ON u.userID = t.userID " +
                       "WHERE u.userType = 'Customer' " +
                       "GROUP BY u.userID, u.fname, u.lname " +
                       "ORDER BY total_revenue DESC " +
                       "LIMIT 1";
        
        PreparedStatement ps = con.prepareStatement(query);
        ResultSet rs = ps.executeQuery();
        
        if (rs.next()) {
            %>
            <div>
                <h3>Top Revenue Customer:</h3>
                <table>
                    <tr>
                        <th>Customer ID</th>
                        <th>First Name</th>
                        <th>Last Name</th>
                        <th>Total Revenue</th>
                    </tr>
                    <tr>
                        <td><%= rs.getInt("userID") %></td>
                        <td><%= rs.getString("fname") %></td>
                        <td><%= rs.getString("lname") %></td>
                        <td>$<%= String.format("%.2f", rs.getDouble("total_revenue")) %></td>
                    </tr>
                </table>
            </div>
            <%
        } else {
            %>
            <p>No customer revenue data found.</p>
            <%
        }
        
        // Now get a list of all customers ranked by revenue
        String allCustomersQuery = "SELECT u.userID, u.fname, u.lname, SUM(t.booking_price) as total_revenue " +
                                  "FROM user u " +
                                  "JOIN tickets t ON u.userID = t.userID " +
                                  "WHERE u.userType = 'Customer' " +
                                  "GROUP BY u.userID, u.fname, u.lname " +
                                  "ORDER BY total_revenue DESC";
        
        PreparedStatement allPs = con.prepareStatement(allCustomersQuery);
        ResultSet allRs = allPs.executeQuery();
        %>
        
        <h3>All Customers Ranked by Revenue</h3>
        <table>
            <tr>
                <th>Rank</th>
                <th>Customer ID</th>
                <th>Name</th>
                <th>Total Revenue</th>
            </tr>
            <%
            int rank = 1;
            while (allRs.next()) {
                %>
                <tr>
                    <td><%= rank++ %></td>
                    <td><%= allRs.getInt("userID") %></td>
                    <td><%= allRs.getString("fname") + " " + allRs.getString("lname") %></td>
                    <td>$<%= String.format("%.2f", allRs.getDouble("total_revenue")) %></td>
                </tr>
                <%
            }
            allRs.close();
            allPs.close();
            %>
        </table>
        
        <%
        rs.close();
        ps.close();
        con.close();
    } catch (Exception e) {
        %>
        <p>Error: <%= e.getMessage() %></p>
        <%
    }
    %>
</body>
</html>