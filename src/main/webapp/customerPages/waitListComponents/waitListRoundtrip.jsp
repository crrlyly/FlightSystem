<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>

<% 

	String type = request.getParameter("type");
	session.setAttribute("type", type);

	ApplicationDB db = new ApplicationDB();
	Connection con = db.getConnection();

	if(type.equals("outbound")){
		
		String airID = request.getParameter("outbound-airID");
		int flightNum = Integer.parseInt(request.getParameter("outbound-flightNum"));
		int ticketNum = Integer.parseInt(request.getParameter("ticketNum"));
		
	
	    String sql = "INSERT INTO waitinglist VALUES (?,?,?)";
	    PreparedStatement stmt = con.prepareStatement(sql);
	    stmt.setString(1, airID);
	    stmt.setInt(2, flightNum);
	    stmt.setInt(3, ticketNum);
	    
	    stmt.executeUpdate();
	    stmt.close();
	    
		
	}
	else if(type.equals("return")){
		String airID = request.getParameter("return-airID");
		int flightNum = Integer.parseInt(request.getParameter("return-flightNum"));
		int ticketNum = Integer.parseInt(request.getParameter("ticketNum"));
	
	    
	    String sql = "INSERT INTO waitinglist VALUES (?,?,?)";
	    PreparedStatement stmt = con.prepareStatement(sql);
	    stmt.setString(1, airID);
	    stmt.setInt(2, flightNum);
	    stmt.setInt(3, ticketNum);
	    
	    stmt.executeUpdate();
	    stmt.close();
	    
	}
	else{
		String airID1 = request.getParameter("outbound-airID");
		int flightNum1 = Integer.parseInt(request.getParameter("outbound-flightNum"));
		int ticketNum = Integer.parseInt(request.getParameter("ticketNum"));
		
		String airID2 = request.getParameter("return-airID");
		int flightNum2 = Integer.parseInt(request.getParameter("return-flightNum"));
		
	    
	    String sql = "INSERT INTO waitinglist VALUES (?,?,?)";
	    PreparedStatement stmt = con.prepareStatement(sql);
	    stmt.setString(1, airID1);
	    stmt.setInt(2, flightNum1);
	    stmt.setInt(3, ticketNum);
	    
	    stmt.executeUpdate();
	    stmt.close();
	    
	   
	    PreparedStatement stmt2 = con.prepareStatement(sql);
	    stmt2.setString(1, airID2);
	    stmt2.setInt(2, flightNum2);
	    stmt2.setInt(3, ticketNum);
	    
	    stmt2.executeUpdate();
	    stmt2.close();

	}

    db.closeConnection(con);

    response.sendRedirect("../userProfile.jsp");
%>