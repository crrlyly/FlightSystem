<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*,java.time.*"%>
<%@ page import="java.util.stream.*" %>

<%

	String tripType = request.getParameter("tripType");
	int ticketNum = Integer.parseInt(request.getParameter("ticketNum"));
	String classType = request.getParameter("classType");

	if(tripType.equals("oneway")){
		String airID = request.getParameter("airID");
		int flightNum = Integer.parseInt(request.getParameter("flightNum"));
	
		
		waitOn(ticketNum, flightNum, airID, classType);
	
	}
	else if(tripType.equals("roundtrip")){
		String outboundAirID = request.getParameter("outbound-airID");
		int outboundFlightNum = Integer.parseInt(request.getParameter("outbound-flightNum"));
		
		String returnAirID = request.getParameter("return-airID");
		int returnFlightNum = Integer.parseInt(request.getParameter("return-flightNum"));
		

		waitOn(ticketNum, outboundFlightNum, outboundAirID, classType);
		waitOn(ticketNum, returnFlightNum, returnAirID, classType);
			
		
	}
	
%>




<%!
	public static void waitOn(int ticketNum, int flightNum, String airID, String classType){
		try{
			
	
			String openSeats = "open" + classType + "seats";
					
			ApplicationDB db = new ApplicationDB();    
			Connection con = db.getConnection();    
			
			String deletePerson = "delete from waitinglist where flightNum = ? and airid = ? and ticketnum = ?";
			PreparedStatement check = con.prepareStatement(deletePerson);
			check.setInt(1, flightNum);
			check.setString(2, airID);
			check.setInt(3, ticketNum);
			check.executeUpdate();
			check.close();
		
		//change ticket status to ongoing
			String changeStatus = "Update tickets set ticket_status = 'ongoing' where ticketnum = ?";
			PreparedStatement check2 = con.prepareStatement(changeStatus);
			check2.setInt(1, ticketNum);
			check2.executeUpdate();
			check2.close();
			
		
		//add 1 to flight seats
		
			String flightAdd = "Update flight JOIN ticketlistsflights USING (flightNum, airID) set " + openSeats + " =  " + openSeats + " + 1 where ticketnum = ?";
			PreparedStatement check3 = con.prepareStatement(flightAdd);
			check3.setInt(1, ticketNum);
			check3.executeUpdate();
			check3.close();
		
		
		    db.closeConnection(con);
		}
		catch (Exception e) {
	        e.printStackTrace();
	    }
	}

%>


<h2>Ticket Added to Ongoing Flights!</h2>
<a href="../userProfile.jsp">Go back to profile to view.</a>
