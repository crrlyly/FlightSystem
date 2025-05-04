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

                // get user ID from postquestions table
                PreparedStatement userStmt = con.prepareStatement("SELECT userID FROM postquestions WHERE questionID = ?");
                userStmt.setInt(1, questionID);
                ResultSet rsUser = userStmt.executeQuery();

                if (!rsUser.next()) {
                    message = "User not found for the question.";
                    messageType = "error";
                } else {
                    int userID = rsUser.getInt("userID");

                    // Update the response in the qatable
                    PreparedStatement updateQa = con.prepareStatement("UPDATE qatable SET response = ? WHERE questionID = ?");
                    updateQa.setString(1, responseL);
                    updateQa.setInt(2, questionID);

                    int rows = updateQa.executeUpdate();
                    if (rows > 0) {
                        // Insert answerDate in provideanswer table
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
            else if ("changeStatus".equals(actionType) && request.getParameter("questionID") != null && request.getParameter("status") != null) {
                int questionID = Integer.parseInt(request.getParameter("questionID"));
                String newStatus = request.getParameter("status").toLowerCase();

                if (!newStatus.equals("pending") && !newStatus.equals("resolved")) {
                    message = "Invalid status. Use 'pending' or 'resolved'.";
                    messageType = "error";
                    // no response
                } else if (newStatus.equals("pending")) {
                    PreparedStatement clear = con.prepareStatement("UPDATE qatable SET response = NULL WHERE questionID = ?");
                    clear.setInt(1, questionID);
                    int rows = clear.executeUpdate();
                    message = (rows > 0) ? "Marked as pending." : "Failed to mark as pending.";
                    messageType = (rows > 0) ? "success" : "error";
                } else if (newStatus.equals("resolved")) {
                    String responseR = request.getParameter("response");
                    if (responseR == null || responseR.trim().isEmpty()) {
                        message = "Response cannot be empty for resolved status.";
                        messageType = "error";
                    } else {
                        // Update the response and status to resolved
                        PreparedStatement update = con.prepareStatement("UPDATE qatable SET response = ? WHERE questionID = ?");
                        update.setString(1, responseR);
                        update.setInt(2, questionID);
                        int rows = update.executeUpdate();

                        if (rows > 0) {
                            // Insert new row in provideanswer table
                            PreparedStatement getUser = con.prepareStatement("SELECT userID FROM postquestions WHERE questionID = ?");
                            getUser.setInt(1, questionID);
                            ResultSet rs = getUser.executeQuery();
                            if (rs.next()) {
                                int userID = rs.getInt("userID");
								//avoid any duplicates
                                PreparedStatement insertAns = con.prepareStatement("INSERT IGNORE INTO provideanswer (questionID, userID, answerDate) VALUES (?, ?, NOW())");
                                insertAns.setInt(1, questionID);
                                insertAns.setInt(2, userID);
                                insertAns.executeUpdate();
                                message = "Marked as resolved.";
                                messageType = "success";
                            } else {
                                message = "User not found.";
                                messageType = "error";
                            }
                        } else {
                            message = "Failed to update response.";
                            messageType = "error";
                        }
                    }
                }
            }

            con.close();
        } catch (Exception e) {
            message = "Error: " + e.getMessage();
            messageType = "error";
        }
    }

    // Display the success/error message if present
    if (message != null) {
%>
    <div class="message <%= messageType %>"><%= message %></div>
<%
    }
%>

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
        PreparedStatement ps = con.prepareStatement("SELECT * FROM qatable");
        ResultSet rs = ps.executeQuery();

        while (rs.next()) {
            int qid = rs.getInt("questionID");
            String question = rs.getString("question");
            String responseQ = rs.getString("response"); 
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
            }
            else {
            	out.print("N/A");
            }
        %>
        </td>
        <td><%= question %></td>
        <td><%= responseQ != null ? responseQ : "Pending" %></td>
        <td>
            <form method="post" style="display:inline;">
                <input type="hidden" name="actionType" value="respond"/>
                <input type="hidden" name="questionID" value="<%= qid %>"/>
                <input type="text" name="response" placeholder="Type response..." required/>
                <input type="submit" value="Submit Response" class="action-btn"/>
            </form>

            <form method="post" style="display:inline;">
                <input type="hidden" name="actionType" value="changeStatus"/>
                <input type="hidden" name="questionID" value="<%= qid %>"/>
                <input type="hidden" name="status" value="pending"/>
                <input type="submit" value="Mark Pending" class="action-btn"/>
            </form>
        </td>
    </tr>
<%
        }
        con.close();
    } catch (Exception e) {
        out.println("Error: " + e.getMessage());
    }
%>
</table>

</body>
</html>