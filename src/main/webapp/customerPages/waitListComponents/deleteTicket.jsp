<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>

<%
    String ticketNum = request.getParameter("ticketNum");
 

    if (ticketNum != null) {
    	
        ApplicationDB db = new ApplicationDB();
        Connection con = db.getConnection();

        PreparedStatement ps = con.prepareStatement(
            "DELETE FROM ticketlistsflights WHERE ticketNum = ?"
        );
        ps.setInt(1, Integer.parseInt(ticketNum));
     

        ps.executeUpdate();
        ps.close();
        
        
        PreparedStatement ps2 = con.prepareStatement(
            "DELETE FROM tickets WHERE ticketNum = ?"
        );
        ps2.setInt(1, Integer.parseInt(ticketNum));
     

        ps2.executeUpdate();
        ps2.close();
        
        
        
        db.closeConnection(con);
    }

    response.sendRedirect("../userProfile.jsp");
%>