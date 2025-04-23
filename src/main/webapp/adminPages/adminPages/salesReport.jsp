<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*, java.time.*, java.time.format.DateTimeFormatter"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>

<%
    String monthStr = request.getParameter("month");
    String yearStr = request.getParameter("year");

    if (monthStr != null && yearStr != null) {
        try {
            int month = Integer.parseInt(monthStr);
            int year = Integer.parseInt(yearStr);

            LocalDate startDate = LocalDate.of(year, month, 1);
            LocalDate endDate = startDate.withDayOfMonth(startDate.lengthOfMonth());

            // JDBC Setup
			ApplicationDB db = new ApplicationDB();	
			Connection con = db.getConnection();

            String sql = "SELECT class, COUNT(*) AS ticketCount, SUM(booking_price) AS totalSales " +
                         "FROM Tickets " +
                         "WHERE purchase_date >= ? AND purchase_date <= ? " +
                         "GROUP BY class";

            PreparedStatement ps = con.prepareStatement(sql);
            ps.setTimestamp(1, Timestamp.valueOf(startDate.atStartOfDay()));
            ps.setTimestamp(2, Timestamp.valueOf(endDate.atTime(LocalTime.MAX)));

            ResultSet rs = ps.executeQuery();
%>

	<h2>Sales Report for <%= startDate.getMonth().name() %> <%= year %></h2>
	
	<table border="1" cellpadding="8" style="margin-top: 15px; border-collapse: collapse;">
	    <thead>
	        <tr>
	            <th>Class</th>
	            <th>Tickets Sold</th>
	            <th>Total Revenue ($)</th>
	        </tr>
	    </thead>
	    <tbody>
	        <%
	            while (rs.next()) {
	                String ticketClass = rs.getString("class");
	                int count = rs.getInt("ticketCount");
	                double revenue = rs.getDouble("totalSales");
	        %>
	        <tr>
	            <td><%= ticketClass %></td>
	            <td><%= count %></td>
	            <td><%= String.format("%.2f", revenue) %></td>
	        </tr>
	        <%
	            }
	
	            rs.close();
	            ps.close();
	            db.closeConnection(con);
	        } catch (Exception e) {
	            out.println("<p style='color:red;'>Error generating report: " + e.getMessage() + "</p>");
	        }
	    } else {
	        out.println("<p>Please select both a month and year.</p>");
	    }
	%>
	    </tbody>
	</table>
	
	<div style="margin-top: 30px;">
    <form action="../adminHome.jsp" method="get">
        <input type="submit" value="Return to Admin Home">
    </form>
	</div>
