<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*,java.time.*"%>
<%@ page import="java.util.stream.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
    <title>Flight Search Results</title>
</head>
<body>

<% 
	/*Display Pending Tickets (meaning on waitlist) (waitlisted)
	
	Display Currently Active Tickets (Flight didnt happen yet but have ticket) (ongoing)
	
	Display Past Tickets (past)
	
	Display questions they asked (even the unanswered ones)*/
	
	Object userIDObj = session.getAttribute("userID");
    if (userIDObj == null) {
        out.println("<p>Error: You must be logged in to submit a question.</p>");
        return;
    }
    int userID = (int) userIDObj;
    
    ApplicationDB db = new ApplicationDB();    
    Connection con = db.getConnection();    

    String getUser = "Select * from user where userID = ?";
    PreparedStatement check = con.prepareStatement(getUser);
    check.setInt(1, userID);
    ResultSet rs = check.executeQuery();
    
    String username = "";
    String email = "";
    String phone = "";
    
    if (rs.next()) {
        username = rs.getString("username");
        email = rs.getString("email");
        phone = rs.getString("phone_num");
    } 
    
    rs.close();
    check.close();
%>

	<h1>Profile</h1>
	<a href="customerHome.jsp">Go Back to Home Page</a>
	<div id='line' style='width: 100%; height: 2px; background-color:black; margin: 10px 0px;'></div>
	<h2>User Info</h2>
	<h3>Username: <%=username%></h3>
	<h3>UserID: <%=userID%></h3>
	<h3>Email: <%=email%></h3>
	<h3>Phone: <%=phone%></h3>
	<div id='line' style='width: 100%; height: 2px; background-color:black; margin: 10px 0px;'></div>
	
	<h2 style='margin-bottom: 10px;'>Your Submitted Questions</h2>
	<button id="quest-btn" style="margin: 20px 0px;">Open Question List</button>
	<div id="quest-container" style="display:none;">
		<%
		
			String getQuestion = "Select * from qaTable join postquestions q using (questionID) left join provideanswer a using (questionID) where q.userID = ?";
			PreparedStatement check2 = con.prepareStatement(getQuestion);
			check2.setInt(1, userID);
			ResultSet rs2 = check2.executeQuery();
			
			StringBuilder outputHtml = new StringBuilder();
			StringBuilder outputHtml2 = new StringBuilder();
			List<String> answered = new ArrayList<>();
			List<String> unanswered = new ArrayList<>();
			
			while (rs2.next()) {
			    String question = rs2.getString("question");
			    String postedDate = rs2.getString("postedDate");
			    String respond = rs2.getString("response");
			    String answerDate = rs2.getString("answerDate");
			
			    StringBuilder block = new StringBuilder();
			    block.append("<div style='margin-bottom: 70px;'>")
			        .append("<h2>Question: </h2><p>").append(question).append("</p>")
			        .append("<h4>Posted On: ").append(postedDate).append("</h4>")
			        .append("<h2>Answer: </h2><p>").append(respond != null ? response : "Not yet answered.").append("</p>")
			        .append("<h4>Answered On: ").append(answerDate != null ? answerDate : "Not yet answered.").append("</h4></div>");
			
			    if (respond == null) {
			        unanswered.add(block.toString());
			    } else {
			        answered.add(block.toString());
			    }
			}
			
			out.println("<h2>Unanswered Questions</h2>");
			for (String html : unanswered) {
			    out.println(html);
			}
			
			out.println("<div id='line' style='width: 30%; height: 2px; background-color:black; margin: 5px 0px;'></div>");
			
			out.println("<h2>Answered Questions</h2>");
			for (String html : answered) {
			    out.println(html);
			}
		
			
		
			rs2.close();
			check2.close();
		%>
	</div>

<div id='line' style='width: 100%; height: 2px; background-color:black; margin: 5px 0px;'></div>

<h2>Your Tickets</h2>

<button  id="wait-btn" style="margin: 20px 0px;">Open Waiting-List Tickets</button>
<div id="wait-container" style="display:none;">
<%
//display tickets that are in waitinglist
	String getWaiting = "SELECT * FROM tickets t JOIN ticketlistsflights tf USING (ticketNum) JOIN flight f USING (airID, flightnum) where t.userID = ? and flight_trip = 'Oneway' order by ticketnum asc";
	PreparedStatement check3 = con.prepareStatement(getWaiting);
	check3.setInt(1, userID);
	ResultSet rs3 = check3.executeQuery();
    StringBuilder oneway = new StringBuilder();
    StringBuilder roundtrip = new StringBuilder();
    

	while (rs3.next()) {
		String flightTrip = rs3.getString("flight_trip");
		String ticketStat = rs3.getString("ticket_status");
		
		String sql = "SELECT * FROM flight f JOIN aircraft a USING (craftNum) WHERE f.airID = ? and f.flightnum = ?";
	    PreparedStatement stmt = con.prepareStatement(sql);
	    stmt.setString(1, rs3.getString("airID"));
	    stmt.setInt(2, rs3.getInt("flightNum"));
	    ResultSet rscraft = stmt.executeQuery();
	    
	    String classType = rs3.getString("class");
	    
	    
	    String totalSeatsString = classType + "SeatNum";
	    String openSeatsString = "open" + classType + "seats";
	    
	    int totalSeats = 0;
	    int openSeats = 0;
	    if(rscraft.next()){
	    	totalSeats = rscraft.getInt(totalSeatsString);
	    	openSeats = rscraft.getInt(openSeatsString);
	    }
	    
		if(ticketStat.equals("waitlist")){
			
			String depDate = rs3.getString("departure_date");
            String arrDate = rs3.getString("arrival_date");
            String depTime = new java.text.SimpleDateFormat("hh:mm a").format(rs3.getTime("departure_time"));
            String arrTime = new java.text.SimpleDateFormat("hh:mm a").format(rs3.getTime("arrival_time"));
            
            Double bookingPrice = rs3.getDouble("booking_price");
			
			oneway.append("<div style='margin-bottom: 20px;'>")
			.append("<p>Flight #").append(rs3.getString("flightNum"))
			.append(" | ").append(rs3.getString("dep_portID")).append(" > ").append(rs3.getString("arr_portID"))
			.append(" | Departs: ").append(depDate).append(" ").append(depTime)
			.append(" | Arrives: ").append(arrDate).append(" ").append(arrTime)
			.append("</p>")
			.append("<p><strong>Price:: $").append(String.format("%.2f", bookingPrice)).append("</strong></p>");
			
			
			//get top of waitlist
			
			String waitSql = "SELECT * FROM waitinglist WHERE airID = ? and flightnum = ? order by ticketNum asc limit 1";
		    PreparedStatement waitCheck = con.prepareStatement(waitSql);
		    waitCheck.setString(1, rs3.getString("airID"));
		    waitCheck.setInt(2, rs3.getInt("flightNum"));
		    ResultSet waitrs = waitCheck.executeQuery();
		    
		    int firstWaitListTicketNum = 0;
		    if(waitrs.next()){
		    	firstWaitListTicketNum = waitrs.getInt("ticketNum");
		    }
			
			if(totalSeats >= openSeats + 1 && firstWaitListTicketNum == rs3.getInt("ticketNum")){
				oneway.append("<form method='post' action='waitListComponents/waitListToOngoing.jsp' style='padding-bottom: 10px;'>")
				.append("<input type='hidden' name='ticketNum' value='")
				.append(rs3.getInt("ticketNum"))
				.append("'/>")
				.append("<input type='hidden' name='flightNum' value='")
				.append(rs3.getInt("flightNum"))
				.append("'/>")
				.append("<input type='hidden' name='airID' value='")
				.append(rs3.getString("airID"))
				.append("'/>")
				.append("<input type='hidden' name='classType' value='")
				.append(classType)
				.append("'/>")
				.append("<input type='hidden' name='tripType' value='")
				.append("oneway")
				.append("'/>")
				.append("<input type='submit' value='Seat Opened! Reserve now!'/>")
				.append("</form>");
			}
			
			oneway.append("</div>")
		    .append("<div id='line' style='width: 20%; height: 2px; background-color:black; margin: 10px 0px;'></div>");
		}
		
		
    }
	
	String getWaiting2 = "SELECT * FROM tickets t JOIN ticketlistsflights tf USING (ticketNum) JOIN flight f USING (airID, flightnum) where t.userID = ? and flight_trip = 'Roundtrip' order by ticketnum asc";
	PreparedStatement checking = con.prepareStatement(getWaiting2);
	checking.setInt(1, userID);
	ResultSet rs4 = checking.executeQuery();    
	int counter = 0;
	
	ArrayList<String> list = new ArrayList<>();
	
	int openSpots = 0;
	
	while (rs4.next()) {
		String flightTrip = rs4.getString("flight_trip");
		String ticketStat = rs4.getString("ticket_status");
		
		
		String sql = "SELECT * FROM flight f JOIN aircraft a USING (craftNum) WHERE f.airID = ? and f.flightnum = ?";
	    PreparedStatement stmt = con.prepareStatement(sql);
	    stmt.setString(1, rs4.getString("airID"));
	    stmt.setInt(2, rs4.getInt("flightNum"));
	    ResultSet rscraft = stmt.executeQuery();
	    
	    String classType = rs4.getString("class");
	    
		
	    
	    String totalSeatsString = classType + "SeatNum";
	    String openSeatsString = "open" + classType + "seats";
	    
	    int totalSeats1 = 0;
	    int openSeats1 = 0;
	    if(rscraft.next()){
	    	totalSeats1 = rscraft.getInt(totalSeatsString);
	    	openSeats1 = rscraft.getInt(openSeatsString);
	    }
	    
	    //find if in a waitinglist
	    
	    String inList1 = "SELECT 1 FROM waitinglist WHERE airID = ? AND flightnum = ? AND ticketNum = ?";
		PreparedStatement listCheck = con.prepareStatement(inList1);
		listCheck.setString(1, rs4.getString("airID"));
		listCheck.setInt(2, rs4.getInt("flightNum"));
		listCheck.setInt(3, rs4.getInt("ticketNum"));
		ResultSet listrs = listCheck.executeQuery();
		
		int there = 0;
		if (listrs.next()) {
		    there = listrs.getInt(1); 
		}
		

		if(ticketStat.equals("waitlist")){
			if(there == 0 && (totalSeats1 >= openSeats1 + 1)){
				openSpots += 1;
				list.add(rs4.getString("airID"));
				list.add(String.valueOf(rs4.getInt("flightNum")));
			}

			if(there == 1){
			  	//get top of waitlist
				
				String waitSql = "SELECT * FROM waitinglist WHERE airID = ? and flightnum = ? order by ticketNum asc limit 1";
			    PreparedStatement waitCheck = con.prepareStatement(waitSql);
			    waitCheck.setString(1, rs4.getString("airID"));
			    waitCheck.setInt(2, rs4.getInt("flightNum"));
			    ResultSet waitrs = waitCheck.executeQuery();

			    
			    int firstWaitListTicketNum = 0;
			    if(waitrs.next()){
			    	firstWaitListTicketNum = waitrs.getInt("ticketNum");
			    }
			    
				if((firstWaitListTicketNum == rs4.getInt("ticketNum")) && (totalSeats1 >= openSeats1 + 1)){
					openSpots += 1;
					list.add(rs4.getString("airID"));
					list.add(String.valueOf(rs4.getInt("flightNum")));

				}
			}
			
			
			String depDate = rs4.getString("departure_date");
            String arrDate = rs4.getString("arrival_date");
            String depTime = new java.text.SimpleDateFormat("hh:mm a").format(rs4.getTime("departure_time"));
            String arrTime = new java.text.SimpleDateFormat("hh:mm a").format(rs4.getTime("arrival_time"));
            
            Double bookingPrice = rs4.getDouble("booking_price");
			
            if(counter == 0){
				roundtrip.append("<div style='margin-bottom: 20px;'>")
				.append("<p>Outbound Flight #").append(rs4.getInt("flightNum"))
				.append(" | ").append(rs4.getString("dep_portID")).append(" > ").append(rs4.getString("arr_portID"))
				.append(" | Departs: ").append(depDate).append(" ").append(depTime)
				.append(" | Arrives: ").append(arrDate).append(" ").append(arrTime)
				.append("</p>");
            	counter = 1;
            }
            else{
            	counter = 0;
            	roundtrip.append("<p>Return Flight #").append(rs4.getInt("flightNum"))
				.append(" | ").append(rs4.getString("dep_portID")).append(" > ").append(rs4.getString("arr_portID"))
				.append(" | Departs: ").append(depDate).append(" ").append(depTime)
				.append(" | Arrives: ").append(arrDate).append(" ").append(arrTime)
				.append("</p>")
				.append("<p><strong>Price:: $").append(String.format("%.2f", bookingPrice)).append("</strong></p>")
				.append("</div>");
            	

				
				if(openSpots == 2){
					roundtrip.append("<form method='post' action='waitListComponents/waitListToOngoing.jsp' style='padding-bottom: 10px;'>")
				    .append("<input type='hidden' name='ticketNum' value='")
				    .append(rs4.getInt("ticketNum"))
				    .append("'/>")
				    .append("<input type='hidden' name='outbound-flightNum' value='")
				    .append(Integer.parseInt(list.get(1)))
				    .append("'/>")
				    .append("<input type='hidden' name='outbound-airID' value='")
				    .append(list.get(0))
				    .append("'/>")
				    .append("<input type='hidden' name='return-flightNum' value='")
				    .append(Integer.parseInt(list.get(3)))
				    .append("'/>")
				    .append("<input type='hidden' name='return-airID' value='")
				    .append(list.get(2))
				    .append("'/>")
				    .append("<input type='hidden' name='classType' value='")
				    .append(classType)
				    .append("'/>")
				    .append("<input type='hidden' name='tripType' value='roundtrip'/>")
				    .append("<input type='submit' value='Seat Opened! Reserve now!'/>")
				    .append("</form>");
				}
				
			    roundtrip.append("<div id='line' style='width: 20%; height: 2px; background-color:black; margin: 10px 0px;'></div>");
            	openSpots = 0;
            	list.clear();
            }
		}
		
    }
	
	out.println(oneway.toString());
	out.println(roundtrip.toString());
	
	rs4.close();
	checking.close();
	
	rs3.close();
	check3.close();
    
%>
</div>



<button id="on-btn" style="margin: 20px 0px; display: block;">Open Ongoing Tickets</button>

<div id="on-container" style="display:none;">
	<%
	//display tickets that are in waitinglist
		String getOngoing = "SELECT * FROM tickets t JOIN ticketlistsflights tf USING (ticketNum) JOIN flight f USING (airID, flightnum) where t.userID = ? and flight_trip = 'Oneway' order by ticketnum asc";
		PreparedStatement checkO = con.prepareStatement(getOngoing);
		checkO.setInt(1, userID);
		ResultSet rsO = checkO.executeQuery();
	    StringBuilder onewayO = new StringBuilder();
	    StringBuilder roundtripO = new StringBuilder();
	
		while (rsO.next()) {
			String flightTrip = rsO.getString("flight_trip");
			String ticketStat = rsO.getString("ticket_status");
			
			if(ticketStat.equals("ongoing")){
				
				String depDate = rsO.getString("departure_date");
	            String arrDate = rsO.getString("arrival_date");
	            String depTime = new java.text.SimpleDateFormat("hh:mm a").format(rsO.getTime("departure_time"));
	            String arrTime = new java.text.SimpleDateFormat("hh:mm a").format(rsO.getTime("arrival_time"));
	            
	            Double bookingPrice = rsO.getDouble("booking_price");
				
	            onewayO.append("<div style='margin-bottom: 20px;'>")
				.append("<p>Flight #").append(rsO.getString("flightNum"))
				.append(" | ").append(rsO.getString("dep_portID")).append(" > ").append(rsO.getString("arr_portID"))
				.append(" | Departs: ").append(depDate).append(" ").append(depTime)
				.append(" | Arrives: ").append(arrDate).append(" ").append(arrTime)
				.append("</p>")
	            .append("<p><strong>Price:: $").append(String.format("%.2f", bookingPrice)).append("</strong></p>");
	            
	            if(rsO.getString("class").equals("First") || rsO.getString("class").equals("Business")){
					onewayO.append("<form method='post' action='waitListComponents/deleteTicket.jsp' style='padding-bottom: 10px;'>")
				    .append("<input type='hidden' name='ticketNum' value='")
				    .append(rsO.getInt("ticketNum"))
				    .append("'/>")
				    .append("<input type='submit' value='Delete Reservation'/>")
				    .append("</form>");
	            	
	            }
	            onewayO.append("</div>")
			    .append("<div id='line' style='width: 20%; height: 2px; background-color:black; margin: 10px 0px;'></div>");
			}
			
			
	    }
		
		String getOngoing2 = "SELECT * FROM tickets t JOIN ticketlistsflights tf USING (ticketNum) JOIN flight f USING (airID, flightnum) where t.userID = ? and flight_trip = 'Roundtrip' order by ticketnum asc";
		PreparedStatement checkO2 = con.prepareStatement(getOngoing2);
		checkO2.setInt(1, userID);
		ResultSet rsO2 = checkO2.executeQuery();    
		int counter2 = 0;
		
		while (rsO2.next()) {
			String flightTrip = rsO2.getString("flight_trip");
			String ticketStat = rsO2.getString("ticket_status");
			
			if(ticketStat.equals("ongoing")){
				
				String depDate = rsO2.getString("departure_date");
	            String arrDate = rsO2.getString("arrival_date");
	            String depTime = new java.text.SimpleDateFormat("hh:mm a").format(rsO2.getTime("departure_time"));
	            String arrTime = new java.text.SimpleDateFormat("hh:mm a").format(rsO2.getTime("arrival_time"));
	            
	            Double bookingPrice = rsO2.getDouble("booking_price");
				
	            if(counter2 == 0){
	            	roundtripO.append("<div style='margin-bottom: 20px;'>")
					.append("<p>Outbound Flight #").append(rsO2.getString("flightNum"))
					.append(" | ").append(rsO2.getString("dep_portID")).append(" > ").append(rsO2.getString("arr_portID"))
					.append(" | Departs: ").append(depDate).append(" ").append(depTime)
					.append(" | Arrives: ").append(arrDate).append(" ").append(arrTime)
					.append("</p>");
	            	counter2 = 1;
	            }
	            else{
	            	counter2 = 0;
	            	roundtripO.append("<p>Return Flight #").append(rsO2.getInt("flightNum"))
					.append(" | ").append(rsO2.getString("dep_portID")).append(" > ").append(rsO2.getString("arr_portID"))
					.append(" | Departs: ").append(depDate).append(" ").append(depTime)
					.append(" | Arrives: ").append(arrDate).append(" ").append(arrTime)
					.append("</p>")
					.append("<p><strong>Price:: $").append(String.format("%.2f", bookingPrice)).append("</strong></p>");
					

		            if(rsO2.getString("class").equals("First") || rsO2.getString("class").equals("Business")){
		            	roundtripO.append("<form method='post' action='waitListComponents/deleteTicket.jsp' style='padding-bottom: 10px;'>")
					    .append("<input type='hidden' name='ticketNum' value='")
					    .append(rsO2.getInt("ticketNum"))
					    .append("'/>")
					    .append("<input type='submit' value='Delete Reservation'/>")
					    .append("</form>");
		            	
		            }
	            	
		            roundtripO.append("</div>")
				    .append("<div id='line' style='width: 20%; height: 2px; background-color:black; margin: 10px 0px;'></div>");
	            
	            }
			}
			
	    }
		
		out.println(onewayO.toString());
		out.println(roundtripO.toString());
		
		rsO.close();
		checkO.close();
		
		rsO2.close();
		checkO2.close();
	    	
	%>

</div>


<button id="past-btn" style="margin: 40px 0px; display: block;">Open Past Tickets</button>

<div id="past-container" style="display:none;">

<%
		String getPast = "SELECT * FROM tickets t JOIN ticketlistsflights tf USING (ticketNum) JOIN flight f USING (airID, flightnum) where t.userID = ? and flight_trip = 'Oneway' order by ticketnum asc";
		PreparedStatement checkP = con.prepareStatement(getPast);
		checkP.setInt(1, userID);
		ResultSet rsP = checkP.executeQuery();
	    StringBuilder onewayP = new StringBuilder();
	    StringBuilder roundtripP = new StringBuilder();
	
		while (rsP.next()) {
			String flightTrip = rsP.getString("flight_trip");
			String ticketStat = rsP.getString("ticket_status");
			
			if(ticketStat.equals("past")){
				
				String depDate = rsP.getString("departure_date");
	            String arrDate = rsP.getString("arrival_date");
	            String depTime = new java.text.SimpleDateFormat("hh:mm a").format(rsP.getTime("departure_time"));
	            String arrTime = new java.text.SimpleDateFormat("hh:mm a").format(rsP.getTime("arrival_time"));
	            
	            Double bookingPrice = rsP.getDouble("booking_price");
				
	            onewayP.append("<div style='margin-bottom: 20px;'>")
				.append("<p>Flight #").append(rsP.getString("flightNum"))
				.append(" | ").append(rsP.getString("dep_portID")).append(" > ").append(rsP.getString("arr_portID"))
				.append(" | Departs: ").append(depDate).append(" ").append(depTime)
				.append(" | Arrives: ").append(arrDate).append(" ").append(arrTime)
				.append("</p>")
				.append("<p><strong>Price:: $").append(String.format("%.2f", bookingPrice)).append("</strong></p>")
				.append("</div>")
			    .append("<div id='line' style='width: 20%; height: 2px; background-color:black; margin: 10px 0px;'></div>");
			}
			
			
	    }
		
		String getPast2 = "SELECT * FROM tickets t JOIN ticketlistsflights tf USING (ticketNum) JOIN flight f USING (airID, flightnum) where t.userID = ? and flight_trip = 'Roundtrip' order by ticketnum asc";
		PreparedStatement checkP2 = con.prepareStatement(getPast2);
		checkP2.setInt(1, userID);
		ResultSet rsP2 = checkP2.executeQuery();    
		int counter3 = 0;
		
		while (rsP2.next()) {
			String flightTrip = rsP2.getString("flight_trip");
			String ticketStat = rsP2.getString("ticket_status");
			
			if(ticketStat.equals("past")){
				
				String depDate = rsP2.getString("departure_date");
	            String arrDate = rsP2.getString("arrival_date");
	            String depTime = new java.text.SimpleDateFormat("hh:mm a").format(rsP2.getTime("departure_time"));
	            String arrTime = new java.text.SimpleDateFormat("hh:mm a").format(rsP2.getTime("arrival_time"));
	            
	            Double bookingPrice = rsP2.getDouble("booking_price");
				
	            if(counter3 == 0){
	            	roundtripP.append("<div style='margin-bottom: 20px;'>")
					.append("<p>Outbound Flight #").append(rsP2.getString("flightNum"))
					.append(" | ").append(rsO2.getString("dep_portID")).append(" > ").append(rsP2.getString("arr_portID"))
					.append(" | Departs: ").append(depDate).append(" ").append(depTime)
					.append(" | Arrives: ").append(arrDate).append(" ").append(arrTime)
					.append("</p>");
	            	counter3 = 1;
	            }
	            else{
	            	counter3 = 0;
	            	roundtripP.append("<p>Return Flight #").append(rsP2.getInt("flightNum"))
					.append(" | ").append(rsP2.getString("dep_portID")).append(" > ").append(rsP2.getString("arr_portID"))
					.append(" | Departs: ").append(depDate).append(" ").append(depTime)
					.append(" | Arrives: ").append(arrDate).append(" ").append(arrTime)
					.append("</p>")
					.append("<p><strong>Price:: $").append(String.format("%.2f", bookingPrice)).append("</strong></p>")
					.append("</div>")
				    .append("<div id='line' style='width: 20%; height: 2px; background-color:black; margin: 10px 0px;'></div>");
	            
	            }
			}
			
	    }
		
		out.println(onewayP.toString());
		out.println(roundtripP.toString());
		
		rsP.close();
		checkP.close();
		
		rsP2.close();
		checkP2.close();
	    
		db.closeConnection(con);
	
	%>



</div>


<script>

	const qbtn = document.getElementById("quest-btn")
	const qctn = document.getElementById("quest-container")
	let state = 0;
	qbtn.addEventListener("click", function (){
		if(state == 0){
			qctn.style.display = 'block';
			state = 1;
			qbtn.textContent = 'Close Question List';
			return;
		}
		qctn.style.display = 'none';
		state = 0;
		qbtn.textContent = 'Open Question List';
	})
	
	const wbtn = document.getElementById("wait-btn")
	const wctn = document.getElementById("wait-container")
	let state2 = 0;
	wbtn.addEventListener("click", function (){
		if(state2 == 0){
			wctn.style.display = 'block';
			state2 = 1;
			wbtn.textContent = 'Close Waiting List';
			return;
		}
		wctn.style.display = 'none';
		state2 = 0;
		wbtn.textContent = 'Open Waiting List';
	})
	
	const obtn = document.getElementById("on-btn")
	const octn = document.getElementById("on-container")
	let state3 = 0;
	obtn.addEventListener("click", function (){
		if(state3 == 0){
			octn.style.display = 'block';
			state3 = 1;
			obtn.textContent = 'Close Ongoing List';
			return;
		}
		octn.style.display = 'none';
		state3 = 0;
		obtn.textContent = 'Open Ongoing List';
	})
	
	const pbtn = document.getElementById("past-btn")
	const pctn = document.getElementById("past-container")
	let state4 = 0;
	pbtn.addEventListener("click", function (){
		if(state4 == 0){
			pctn.style.display = 'block';
			state4 = 1;
			pbtn.textContent = 'Close Past Tickets';
			return;
		}
		pctn.style.display = 'none';
		state4 = 0;
		pbtn.textContent = 'Open Past Tickets';
	})

</script>


</body>
</html>
