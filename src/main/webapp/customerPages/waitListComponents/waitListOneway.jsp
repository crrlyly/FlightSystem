<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>

<% 

	String airID = request.getParameter("airID");
	int flightNum = Integer.parseInt(request.getParameter("flightNum"));
	int ticketNum = Integer.parseInt(request.getParameter("ticketNum"));
	
	//put it in the waiting list
	ApplicationDB db = new ApplicationDB();
    Connection con = db.getConnection();
    
    String sql = "INSERT INTO waitinglist VALUES (?,?,?)";
    PreparedStatement stmt = con.prepareStatement(sql);
    stmt.setString(1, airID);
    stmt.setInt(2, flightNum);
    stmt.setInt(3, ticketNum);
    
    stmt.executeUpdate();
    stmt.close();
    
    response.sendRedirect("../userProfile.jsp");
%>