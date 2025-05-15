<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*,java.time.*"%>
<%@ page import="java.util.stream.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Customer Support Desk: View and Reply to Inquiries</title>
    <style>
        table, th, td { border: 1px solid black; border-collapse: collapse; padding: 8px; }
        th { background-color: #f2f2f2; }
        .action-btn { margin-right: 10px; }
        .message { padding: 10px; margin-bottom: 15px; border-radius: 4px; }
        .success { background-color: #d4edda; color: #155724; }
        .error { background-color: #f8d7da; color: #721c24; }
    </style>
</head>
<body>
    <div style="display: flex; align-items: center;">
	  <h2>Customer Support Desk: View and Reply to Inquiries</h2>
	  <div style="margin-left: 20px;">
	  	<form action="../repHome.jsp" method="get">
	      <input type="submit" value="Customer Representative Home Page" style="background-color: darkgrey; color: white; border: 1px black; cursor: pointer;">
	    </form>
	  </div>
	</div>

<%
    String actionType = request.getParameter("actionType");
    String message = null;
    String messageType = null;

    if (request.getParameter("msg") != null && request.getParameter("type") != null) {
        message = request.getParameter("msg");
        messageType = request.getParameter("type");
    }

    if (actionType != null) {
        try {
            ApplicationDB db = new ApplicationDB();
            Connection con = db.getConnection();

            if ("respond".equals(actionType) && request.getParameter("questionID") != null) {
                int questionID = Integer.parseInt(request.getParameter("questionID"));
                String responseL = request.getParameter("response");

                PreparedStatement userStmt = con.prepareStatement("SELECT userID FROM postquestions WHERE questionID = ?");
                userStmt.setInt(1, questionID);
                ResultSet rsUser = userStmt.executeQuery();

                if (!rsUser.next()) {
                    message = "User not found for the question.";
                    messageType = "error";
                } else {
                    int userID = rsUser.getInt("userID");

                    PreparedStatement updateQa = con.prepareStatement("UPDATE qatable SET response = ? WHERE questionID = ?");
                    updateQa.setString(1, responseL);
                    updateQa.setInt(2, questionID);

                    int rows = updateQa.executeUpdate();
                    if (rows > 0) {
                        PreparedStatement insertAns = con.prepareStatement("INSERT IGNORE INTO provideanswer (questionID, userID, answerDate) VALUES (?, ?, NOW())");
                        insertAns.setInt(1, questionID);
                        insertAns.setInt(2, userID);
                        insertAns.executeUpdate();

                        message = "Response submitted successfully.";
                        messageType = "success";
                    } else {
                        message = "Failed to update QAtable.";
                        messageType = "error";
                    }
                }
            }

            con.close();
        } catch (Exception e) {
            message = "Error: " + e.getMessage();
            messageType = "error";
        }
    }

    if (message != null) {
%>
    <div class="message <%= messageType %>"><%= message %></div>
<%
    }
%>

<h3>Unanswered Questions</h3>
<table>
    <tr>
        <th>Question ID</th>
        <th>User ID</th>
        <th>Question</th>
        <th>Response</th>
        <th>Actions</th>
    </tr>
<%
    try {
        ApplicationDB db = new ApplicationDB();
        Connection con = db.getConnection();
        PreparedStatement ps = con.prepareStatement("SELECT * FROM qatable WHERE response IS NULL");
        ResultSet rs = ps.executeQuery();

        while (rs.next()) {
            int qid = rs.getInt("questionID");
            String question = rs.getString("question");
%>
    <tr>
        <td><%= qid %></td>
        <td>
        <%
            PreparedStatement getID = con.prepareStatement("SELECT userID FROM postquestions WHERE questionID = ?");
            getID.setInt(1, qid);
            ResultSet rss = getID.executeQuery();
            if (rss.next()) {
                out.print(rss.getInt("userID"));
            } else {
                out.print("N/A");
            }
        %>
        </td>
        <td><%= question %></td>
        <td>Pending</td>
        <td>
            <form method="post" style="display:inline;">
                <input type="hidden" name="actionType" value="respond"/>
                <input type="hidden" name="questionID" value="<%= qid %>"/>
                <input type="text" name="response" placeholder="Type response..." required/>
                <input type="submit" value="Submit Response" class="action-btn"/>
            </form>
        </td>
    </tr>
<%
        }
        con.close();
    } catch (Exception e) {
        out.println("Error fetching unanswered: " + e.getMessage());
    }
%>
</table>

<form method="get" style="margin-top: 30px;">
    <input type="hidden" name="showAnswered" value="true"/>
    <input type="submit" value="View Answered Questions" style="background-color: darkgrey; color: white; padding: 8px; cursor: pointer;"/>
</form>
<%
    String showAnswered = request.getParameter("showAnswered");
    if ("true".equalsIgnoreCase(showAnswered)) {
%>
<h3 style="margin-top: 30px;">Answered Questions</h3>
<table>
    <tr>
        <th>Question ID</th>
        <th>User ID</th>
        <th>Question</th>
        <th>Response</th>
        <th>Answer Date</th>
    </tr>
<%
    try {
        ApplicationDB db = new ApplicationDB();
        Connection con = db.getConnection();

        PreparedStatement ps = con.prepareStatement(
            "SELECT q.questionID, q.question, q.response, p.userID, a.answerDate " +
            "FROM qatable q " +
            "JOIN postquestions p ON q.questionID = p.questionID " +
            "LEFT JOIN provideanswer a ON q.questionID = a.questionID " +
            "WHERE q.response IS NOT NULL"
        );

        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
%>
    <tr>
        <td><%= rs.getInt("questionID") %></td>
        <td><%= rs.getInt("userID") %></td>
        <td><%= rs.getString("question") %></td>
        <td><%= rs.getString("response") %></td>
        <td><%= rs.getTimestamp("answerDate") != null ? rs.getTimestamp("answerDate") : "N/A" %></td>
    </tr>
<%
        }
        con.close();
    } catch (Exception e) {
        out.println("Error fetching answered: " + e.getMessage());
    }
%>
</table>
<%
    } 
%>

</body>
</html>
