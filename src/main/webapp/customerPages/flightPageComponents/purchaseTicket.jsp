<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
    <title>Filtered & Sorted Flights</title>
</head>
<body>
	
	<%
	
		String classType = (String) session.getAttribute("class");
		if (classType == null) {
		    out.println("<p>Error: Invalid or missing class type.</p>");
		    return;
		}
		String seat = classType + "seatnum";
		String openSeats = "open" + classType + "seats";
		Double totalPrice = (Double) session.getAttribute("totalPrice");
		
		Object userIDObj = session.getAttribute("userID");
	    if (userIDObj == null) {
	        out.println("<p>Error: You must be logged in to book a flight reservation.</p>");
	        return;
	    }
	    int userID = (int) userIDObj;
	    
	    LocalDateTime now = LocalDateTime.now();
	    String formattedDateTime = now.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"));
	    
	    ApplicationDB db = new ApplicationDB();
        Connection con = db.getConnection();
		
		
		
		//for round trip
	    if(((String) session.getAttribute("tripType")).equals("roundtrip")){
	        String outboundID = request.getParameter("outboundlineID");
	        int outboundNum = Integer.parseInt(request.getParameter("outboundFlight"));
	        String returnID = request.getParameter("retlineID");
	        int returnNum = Integer.parseInt(request.getParameter("returnFlight"));
	        //String totalPrice = request.getParameter("totalPrice"); 
	        
	    
	        String sql = "SELECT * FROM flight f JOIN aircraft a USING (craftNum) WHERE f.airID = ? and f.flightnum = ?";
	        PreparedStatement stmt = con.prepareStatement(sql);
	        stmt.setString(1, outboundID);
	        stmt.setInt(2, outboundNum);
	        ResultSet rs = stmt.executeQuery();
	        
	        int totalSeat = 0;
	        int seatOpen = 0;
	        if (rs.next()) {
                String departID = rs.getString("dep_portID");
                String arriveID = rs.getString("arr_portID");
                String departdate = rs.getString("departure_date");
                String arrivedate = rs.getString("arrival_date");
                seatOpen = rs.getInt(openSeats);
                totalSeat = rs.getInt(seat);
            }
	        
	        rs.close();
	        stmt.close();
	        
	        PreparedStatement stmt2 = con.prepareStatement(sql);
	        stmt2.setString(1, returnID);
	        stmt2.setInt(2, returnNum);
	        ResultSet rs2 = stmt2.executeQuery();  // ✅ Correct one
	        
	        int totalSeat2 = 0;
	        int seatOpen2 = 0;
	        if (rs2.next()) {
                String departID2 = rs2.getString("dep_portID");
                String arriveID2 = rs2.getString("arr_portID");
                String departdate2 = rs2.getString("departure_date");
                String arrivedate2 = rs2.getString("arrival_date");
                seatOpen2 = rs2.getInt(openSeats);
                totalSeat2 = rs2.getInt(seat);
            }
	        

	        rs2.close();
	        stmt2.close();
	        
	      /* 	if(totalSeat < seatOpen + 1){
	      		//add to waitlist
	      	}
	      	
	      	if(totalSeat2 < seatOpen2 + 1){
	      		//add to waitlist
	      	}
	      	
	      	//waitlist fails so put in tickets and ticketLists Flights
	      
	         */
	         
	         
	      //adds to ticket
	        String sql2 = "INSERT INTO tickets(ticket_status, repName, class, flight_trip, booking_price, purchase_date, userID) values ('ongoing', null, ?, ?, ?, ?, ?)";
	        PreparedStatement stmt3 = con.prepareStatement(sql2);
	        stmt3.setString(1, classType);
	        stmt3.setString(2, (String) session.getAttribute("tripType"));
	        stmt3.setDouble(3, totalPrice);
	        stmt3.setString(4, formattedDateTime);
	        stmt3.setInt(5, userID);
	        stmt3.executeUpdate();
	        stmt3.close();
	        
	        //get ticket num
	        String sql3 = "SELECT ticketNum from tickets where purchase_date = ? and userID = ? and class = ? and booking_price = ?";
	        PreparedStatement stmt4 = con.prepareStatement(sql3);
	        stmt4.setString(1, formattedDateTime);
	        stmt4.setInt(2, userID);
	        stmt4.setString(3, classType);
	        stmt4.setDouble(4, totalPrice);
	        ResultSet rs3 = stmt4.executeQuery();
	        
	        int ticketNum = 0;
	        if(rs3.next()){
	        	ticketNum = rs3.getInt("ticketNum");
	        }
	        
	        rs3.close();
	        stmt4.close();
	        
	        //insert flight 1 into ticketListFlight using ticket num
	        String sql4 = "INSERT INTO ticketListsFlights values (?, ?, ?)";
	        PreparedStatement stmt5 = con.prepareStatement(sql4);
	        stmt5.setInt(1, ticketNum);
	        stmt5.setString(2, outboundID);
	        stmt5.setInt(3, outboundNum);
	        stmt5.executeUpdate();
	        stmt5.close();
	        
	        //insert flight 2 into ticketListFlight using ticket num
	        String sql5 = "INSERT INTO ticketListsFlights values (?, ?, ?)";
	        PreparedStatement stmt6 = con.prepareStatement(sql5);
	        stmt6.setInt(1, ticketNum);
	        stmt6.setString(2, returnID);
	        stmt6.setInt(3, returnNum);
	        stmt6.executeUpdate();
	        stmt6.close();
	        
	        //add 1 to flight seat number
	        seatOpen += 1;
	        String sql6 = "UPDATE flight SET " + openSeats + " = ? WHERE airID = ? and flightNum = ?";
	        PreparedStatement stmt7 = con.prepareStatement(sql6);
	        stmt7.setInt(1, seatOpen);
	        stmt7.setString(2, outboundID);
	        stmt7.setInt(3, outboundNum);

	        stmt7.executeUpdate();
	        stmt7.close();
	        
	        seatOpen2 += 1;
	        String sql7 = "UPDATE flight SET " + openSeats + " = ? WHERE airID = ? and flightNum = ?";
	        PreparedStatement stmt8 = con.prepareStatement(sql7);
	        stmt8.setInt(1, seatOpen2);
	        stmt8.setString(2, returnID);
	        stmt8.setInt(3, returnNum);

	        stmt8.executeUpdate();
	        stmt8.close();
	        
	        
	       
	        %>
	        	<h2>Ticket Purchase Complete! Please view your ongoing ticket on your profile.</h2>
	        	<a href="../userProfile.jsp">Go To Profile</a>
	        	
	        <% 
	         
	        
	    }
	    //for one way
	    else{
		    int flightNum = Integer.parseInt(request.getParameter("flightNum"));
		    String airID = request.getParameter("airID");
		    
		  
	
	        String sql = "SELECT * FROM flight f JOIN aircraft a USING (craftNum) WHERE f.airID = ? and f.flightnum = ?";
	        PreparedStatement stmt = con.prepareStatement(sql);
	        stmt.setString(1, airID);
	        stmt.setInt(2, flightNum);
	        ResultSet rs = stmt.executeQuery();
	        
	        int totalSeat = 0;
	        int seatOpen = 0;
	        if (rs.next()) {
	        	String departID = rs.getString("dep_portID");
                String arriveID = rs.getString("arr_portID");
                String departdate = rs.getString("departure_date");
                String arrivedate = rs.getString("arrival_date");
                seatOpen = rs.getInt(openSeats);
                totalSeat = rs.getInt(seat);
            }
	        
	        if(totalSeat < seatOpen + 1){
	      		//add to waitlist
	      	}
	        
	     	//adds to ticket
	        String sql2 = "INSERT INTO tickets(ticket_status, repName, class, flight_trip, booking_price, purchase_date, userID) values ('ongoing', null, ?, ?, ?, ?, ?)";
	        PreparedStatement stmt2 = con.prepareStatement(sql2);
	        stmt2.setString(1, classType);
	        stmt2.setString(2, (String) session.getAttribute("tripType"));
	        stmt2.setDouble(3, totalPrice);
	        stmt2.setString(4, formattedDateTime);
	        stmt2.setInt(5, userID);
	        stmt2.executeUpdate();
	        stmt2.close();
	        
	        //get ticket num
	        String sql3 = "SELECT ticketNum from tickets where purchase_date = ? and userID = ? and class = ? and booking_price = ?";
	        PreparedStatement stmt3 = con.prepareStatement(sql3);
	        stmt3.setString(1, formattedDateTime);
	        stmt3.setInt(2, userID);
	        stmt3.setString(3, classType);
	        stmt3.setDouble(4, totalPrice);
	        ResultSet rs3 = stmt3.executeQuery();
	        
	        int ticketNum = 0;
	        if(rs3.next()){
	        	ticketNum = rs3.getInt("ticketNum");
	        }
	        
	        //insert into ticketListFlight using ticket num
	        String sql4 = "INSERT INTO ticketListsFlights values (?, ?, ?)";
	        PreparedStatement stmt4 = con.prepareStatement(sql4);
	        stmt4.setInt(1, ticketNum);
	        stmt4.setString(2, airID);
	        stmt4.setInt(3, flightNum);
	        stmt4.executeUpdate();
	        stmt4.close();
	        
	        //add 1 to flight seat number
	        seatOpen += 1;
	        String sql5 = "UPDATE flight SET " + openSeats + " = ? WHERE airID = ? and flightNum = ?";
	        PreparedStatement stmt5 = con.prepareStatement(sql5);
	        stmt5.setInt(1, seatOpen);
	        stmt5.setString(2, airID);
	        stmt5.setInt(3, flightNum);

	        stmt5.executeUpdate();
	        stmt5.close();
	        
	        
	       
	        %>
	        	<h2>Ticket Purchase Complete! Please view your ongoing ticket on your profile.</h2>
	        	<a href="../userProfile.jsp">Go To Profile</a>
	        	
	        <% 

    	
	    }
		
	    db.closeConnection(con);

        
	%>
	
	

	

</body>
</html>
