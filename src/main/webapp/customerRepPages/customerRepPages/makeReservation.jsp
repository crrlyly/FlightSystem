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

                       <!-- Flight Search Form -->
                       <form method="post" action="makeReservation.jsp">
                           <input type="hidden" name="userID" value="<%= userID %>" />
                           <label>Departure Port:</label>
                           <input type="text" name="from" required />
                           <label>Arrival Port:</label>
                           <input type="text" name="to" required />
                           <label>Date:</label>
                           <input type="date" name="flightDate" required />
                           <label>Flight Type:</label>
                           <select name="flight_trip">
                               <option value="Oneway">Oneway</option>
                               <option value="Roundtrip">Roundtrip</option>
                           </select>
                           <input type="hidden" name="action" value="search" />
                           <br><br>
                           <input type="submit" value="Search Flights" />
                       </form>
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
       } else {
           String userID = request.getParameter("userID");
           String from = request.getParameter("from");
           String to = request.getParameter("to");
           String flightDate = request.getParameter("flightDate");

           try {
               ApplicationDB db = new ApplicationDB();
               Connection con = db.getConnection();

               PreparedStatement Ps = con.prepareStatement("SELECT * FROM flight WHERE dep_portID = ? AND arr_portID = ?");
               Ps.setString(1, from);
               Ps.setString(2, to);
               ResultSet Rs = Ps.executeQuery();
%>
               <h3>Available Flights</h3>
               <table>
                   <tr>
                       <th>Flight</th>
                       <th>Departure Date</th>
                       <th>Departure Time</th>
                       <th>Arrival Date</th>
                       <th>Arrival Time</th>
                       <th>Price</th>
                       <th>First Class Seats</th>
                       <th>Business Class Seats</th>
                       <th>Economy Class Seats</th>
                       <th>Reserve</th>
                   </tr>
<%
               while (Rs.next()) {
%>
                   <tr>
                       <td><%= Rs.getString("airID") %> - <%= Rs.getInt("flightNum") %></td>
                       <td><%= Rs.getDate("departure_date") %></td>
                       <td><%= Rs.getTime("departure_time") %></td>
                       <td><%= Rs.getDate("arrival_date") %></td>
                       <td><%= Rs.getTime("arrival_time") %></td>
                       <td>$<%= Rs.getDouble("price") %></td>
                       <td><%= Rs.getInt("openFirstSeats") %></td>
                       <td><%= Rs.getInt("openBusinessSeats") %></td>
                       <td><%= Rs.getInt("openEconomySeats") %></td>
                       <td>
                           <form method="post" action="makeReservation.jsp">
                               <input type="hidden" name="action" value="reserve" />
                               <input type="hidden" name="userID" value="<%= userID %>" />
                               <input type="hidden" name="airID" value="<%= Rs.getString("airID") %>" />
                               <input type="hidden" name="flightNum" value="<%= Rs.getInt("flightNum") %>" />
                               <input type="hidden" name="flight_trip" value="Oneway" />
                               <select name="classType">
                                   <option value="First">First</option>
                                   <option value="Business">Business</option>
                                   <option value="Economy">Economy</option>
                               </select>
                               <input type="number" name="numSeats" value="1" min="1" />
                               <input type="submit" value="Reserve" />
                           </form>
                       </td>
                   </tr>
<%
               }
               out.println("</table>");
               con.close();
           } catch (Exception e) {
               out.println("<div class='message error'>Error: " + e.getMessage() + "</div>");
           }
       }
   } else if ("reserve".equals(action)) {
       String repName = (String) session.getAttribute("repName");
       if (repName == null) {
           out.println("<div class='message error'>Representative not verified. Please log in again.</div>");
       } else {
           String userID = request.getParameter("userID");
           String airID = request.getParameter("airID");
           int flightNum = Integer.parseInt(request.getParameter("flightNum"));
           String classT = request.getParameter("classType");
           int numSeats = Integer.parseInt(request.getParameter("numSeats"));
           String flight_trip = request.getParameter("flight_trip");

           if (flight_trip == null || (!flight_trip.equals("Oneway") && !flight_trip.equals("Roundtrip"))) {
               out.println("<div class='message error'>Invalid flight trip type.</div>");
           } else {
               try {
                   ApplicationDB db = new ApplicationDB();
                   Connection con = db.getConnection();

                   PreparedStatement userCheck = con.prepareStatement("SELECT userID FROM user WHERE userID = ?");
                   userCheck.setString(1, userID);
                   ResultSet userRs = userCheck.executeQuery();

                   if (!userRs.next()) {
                       out.println("<div class='message error'>User does not exist!</div>");
                   } else {
                       PreparedStatement priceStmt = con.prepareStatement("SELECT price FROM flight WHERE airID = ? AND flightNum = ?");
                       priceStmt.setString(1, airID);
                       priceStmt.setInt(2, flightNum);
                       ResultSet priceRs = priceStmt.executeQuery();

                       double booking_price = 0.0;
                       if (priceRs.next()) {
                           booking_price = priceRs.getDouble("price");
                       }

                       PreparedStatement insertRes = con.prepareStatement(
                           "INSERT INTO tickets (ticket_status, repName, class, flight_trip, booking_price, purchase_date, userID) VALUES (?, ?, ?, ?, ?, NOW(), ?)",
                           Statement.RETURN_GENERATED_KEYS);
                       insertRes.setString(1, "past");
                       insertRes.setString(2, repName);
                       insertRes.setString(3, classT);
                       insertRes.setString(4, flight_trip);
                       insertRes.setDouble(5, booking_price);
                       insertRes.setInt(6, Integer.parseInt(userID));

                       int rowsAffected = insertRes.executeUpdate();
                       if (rowsAffected > 0) {
                           ResultSet generatedKeys = insertRes.getGeneratedKeys();
                           if (generatedKeys.next()) {
                               int ticketNum = generatedKeys.getInt(1);
                               PreparedStatement insertFlight = con.prepareStatement(
                                   "INSERT INTO ticketlistsflights (ticketNum, airID, flightNum) VALUES (?, ?, ?)");
                               insertFlight.setInt(1, ticketNum);
                               insertFlight.setString(2, airID);
                               insertFlight.setInt(3, flightNum);

                               int rowsFlightAffect = insertFlight.executeUpdate();
                               if (rowsFlightAffect > 0) {
                                   out.println("<div class='message success'>Reservation successfully made for flight " + flightNum + ".</div>");
                               } else {
                                   out.println("<div class='message error'>Flight association failed!</div>");
                               }
                           }
                       } else {
                           out.println("<div class='message error'>Reservation failed!</div>");
                       }
                   }
                   con.close();
               } catch (Exception e) {
                   out.println("<div class='message error'>Error: " + e.getMessage() + "</div>");
               }
           }
       }
   }
%>
</table>
</body>
</html>
