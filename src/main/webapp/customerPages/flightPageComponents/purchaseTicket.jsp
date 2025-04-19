<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*,java.time.*"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
    <title>Filtered & Sorted Flights</title>
</head>
<body>
	
	<%
	    String flightNum = request.getParameter("flightNum");
	    String airID = request.getParameter("airID");
	    String depPortID = request.getParameter("depPortID");
	    String arrPortID = request.getParameter("arrPortID");
	    String price = request.getParameter("price");
	    String depDate = request.getParameter("departureDate");
	    String depTime = request.getParameter("departureTime");
	    String arrDate = request.getParameter("arrivalDate");
	    String arrTime = request.getParameter("arrivalTime");

        String outboundFlight = request.getParameter("outboundFlight");
        String returnFlight = request.getParameter("returnFlight");
        String totalPrice = request.getParameter("totalPrice");
	%>

	<% if (outboundFlight != null && returnFlight != null) { %>
	    <h2>Confirm Your Round Trip</h2>
	    <p>
	        Out-bound Flight #: <%= outboundFlight %><br>
	        Return Flight #: <%= returnFlight %><br>
	        
	        
	        Total Price: $<%= totalPrice %>
	    </p>
	    <form method="post" action="finalizeTicket.jsp">
	        <input type="hidden" name="outboundFlight" value="<%= outboundFlight %>"/>
	        <input type="hidden" name="returnFlight" value="<%= returnFlight %>"/>
	        <input type="hidden" name="totalPrice" value="<%= totalPrice %>"/>
	        <input type="submit" value="Confirm and Purchase Round Trip"/>
	    </form>
	<% } else { %>
	    <h2>Confirm Your Flight</h2>
	    <p>
	        Flight #: <%= flightNum %><br>
	        Airline: <%= airID %><br>
	        From: <%= depPortID %> → <%= arrPortID %><br>
	        Departure: <%= depDate %> at <%= depTime %><br>
	        Arrival: <%= arrDate %> at <%= arrTime %><br>
	        Price: $<%= price %>
	    </p>
	    <form method="post" action="finalizeTicket.jsp">
	        <input type="hidden" name="flightNum" value="<%= flightNum %>"/>
	        <input type="submit" value="Confirm and Purchase"/>
	    </form>
	<% } %>

</body>
</html>
