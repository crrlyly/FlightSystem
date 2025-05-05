<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.lang.*" %>
<%@ page import="java.io.*,java.util.*,java.sql.*,java.text.SimpleDateFormat" %>
<%@ page import="java.util.stream.*" %>

<!DOCTYPE html>
<html>
<head>
   <title>Edit Flight Reservation</title>
   <style>
       table {width: 100%; border: 1px solid black; border-collapse: collapse;}
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
      <h2>Edit Flight Reservation</h2>
      <div style="margin-left: 20px;">
        <form action="../repHome.jsp" method="get">
          <input type="submit" value="Customer Representative Home Page" style="background-color: darkgrey; color: white; border: 1px black; cursor: pointer;">
        </form>
      </div>
   </div>

   <!-- Search Form for User ID -->
   <h3>Search for User by User ID</h3>
   <form method="get" action="editReservation.jsp">
      <label for="userID">User ID:</label>
      <input type="text" id="userID" name="userID" required />
      <input type="submit" value="Search" />
   </form>

   <%
      String userID = request.getParameter("userID");
      if (userID != null && !userID.isEmpty()) {
         try {
            ApplicationDB db = new ApplicationDB();
            Connection con = db.getConnection();

            // Fetch all tickets for the given user
            PreparedStatement ps = con.prepareStatement("SELECT * FROM tickets WHERE userID = ?");
            ps.setString(1, userID);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                out.println("<h3>Tickets for User ID: " + userID + "</h3>");
                out.println("<table>");
                out.println("<tr><th>Ticket Number</th><th>Class</th><th>Flight Trip</th><th>Price</th><th>Actions</th></tr>");
                
                // Loop through all the tickets for this user
                do {
                    String ticketNum = rs.getString("ticketNum");
                    String classType = rs.getString("class");
                    String flightTrip = rs.getString("flight_trip");
                    double price = rs.getDouble("booking_price");
	
                    out.println("<tr>");
                    out.println("<td>" + ticketNum + "</td>");
                    out.println("<td>" + classType + "</td>");
                    out.println("<td>" + flightTrip + "</td>");
                    out.println("<td>$" + String.format("%.2f", price) + "</td>");
                    out.println("<td><form method='get' action='editReservation.jsp'>");
                    out.println("<input type='hidden' name='ticketNum' value='" + ticketNum + "' />");
                    out.println("<input type='submit' value='Edit' />");
                    out.println("</form></td>");
                    out.println("</tr>");
                } while (rs.next());
                out.println("</table>");
            } else {
                out.println("<div class='message error'>No tickets found for User ID: " + userID + "</div>");
            }

            con.close();
         } catch (Exception e) {
            out.println("<div class='message error'>Error: " + e.getMessage() + "</div>");
         }
      } 

      String ticketNum = request.getParameter("ticketNum");
      if (ticketNum != null) {
         try {
            ApplicationDB db = new ApplicationDB();
            Connection con = db.getConnection();

            // Fetch the reservation details for the specific ticket number
            PreparedStatement ps = con.prepareStatement("SELECT * FROM tickets WHERE ticketNum = ?");
            ps.setString(1, ticketNum);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                String classType = rs.getString("class");
                String flightTrip = rs.getString("flight_trip");
                double price = rs.getDouble("booking_price");
                String ticketStatus = rs.getString("ticket_status");

                out.println("<h3>Edit Reservation - Ticket Number: " + ticketNum + "</h3>");
                out.println("<form method='post' action='editReservation.jsp'>");
                out.println("<input type='hidden' name='ticketNum' value='" + ticketNum + "' />");

                out.println("<label>Class:</label>");
                out.println("<select name='classType'>");
                out.println("<option value='First'" + (classType.equals("First") ? " selected" : "") + ">First</option>");
                out.println("<option value='Business'" + (classType.equals("Business") ? " selected" : "") + ">Business</option>");
                out.println("<option value='Economy'" + (classType.equals("Economy") ? " selected" : "") + ">Economy</option>");
                out.println("</select><br>");


                out.println("<label>Price: $" + String.format("%.2f", price) + "</label><br>");

                out.println("<input type='hidden' name='action' value='updateReservation' />");
                out.println("<input type='hidden' name='originalPrice' value='" + price + "' />");
                out.println("<input type='hidden' name='originalClass' value='" + classType + "' />");


                out.println("<input style='margin-top: 20px;' type='submit' value='Update Reservation' />");
                out.println("</form>");
                out.println("<a href='editReservation.jsp'>Back to Flight Reservation Table</a>");
            } else {
                out.println("<div class='message error'>Reservation not found for Ticket Number: " + ticketNum + "</div>");
            }

            con.close();
         } catch (Exception e) {
            out.println("<div class='message error'>Error: " + e.getMessage() + "</div>");
         }
      } 

      if ("updateReservation".equals(request.getParameter("action"))) {
          String ticketNums = request.getParameter("ticketNum");
          String classType = request.getParameter("classType");
          String flightTrip = request.getParameter("flightTrip");
          String originalClass = request.getParameter("originalClass");
          double originalPrice = 0.0;
          String originalPriceStr = request.getParameter("originalPrice");

          try {
              if (originalPriceStr != null && !originalPriceStr.trim().isEmpty()) {
                  originalPrice = Double.parseDouble(originalPriceStr.trim());
              } else {
                  out.println("<div class='message error'>Missing original price. Please go back and try again.</div>");
                  return;
              }
          } catch (NumberFormatException e) {
              out.println("<div class='message error'>Invalid price format: " + originalPriceStr + "</div>");
              return;
          }
          
          if ("first".equalsIgnoreCase(originalClass)) {
        	  originalPrice -= 1000.0;
          } else if ("business".equalsIgnoreCase(originalClass)) {
        	  originalPrice -= 300.0;
          } else if ("economy".equalsIgnoreCase(originalClass)) {
        	  originalPrice -= 100.0;
          }
          
          if ("first".equalsIgnoreCase(classType)) {
        	  originalPrice += 1000.0;
          } else if ("business".equalsIgnoreCase(classType)) {
        	  originalPrice += 300.0;
          } else if ("economy".equalsIgnoreCase(classType)) {
        	  originalPrice += 100.0;
          }
          

          try {
              ApplicationDB db = new ApplicationDB();
              Connection con = db.getConnection();

              // Update reservation details in the tickets table
              PreparedStatement ps = con.prepareStatement(
                  "UPDATE tickets SET class = ?, flight_trip = ?, booking_price = ? WHERE ticketNum = ?");
              ps.setString(1, classType);
              ps.setString(2, flightTrip);
              ps.setDouble(3, originalPrice);
              ps.setString(4, ticketNums);

              int rowsUpdated = ps.executeUpdate();
              if (rowsUpdated > 0) {
                  out.println("<div class='message success'>Reservation updated successfully.</div>");
              } else {
                  out.println("<div class='message error'>Failed to update reservation.</div>");
              }

              con.close();
          } catch (Exception e) {
              out.println("<div class='message error'>Error: " + e.getMessage() + "</div>");
          }
      }
   %>
</body>
</html>
