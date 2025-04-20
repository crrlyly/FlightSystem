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
    <title>Submit Question</title>
</head>
<body>

<%
try {
    String question = request.getParameter("question");
    Object userIDObj = session.getAttribute("userID");
    if (userIDObj == null) {
        out.println("<p>Error: You must be logged in to submit a question.</p>");
        return;
    }
    int userID = (int) userIDObj;

    LocalDateTime now = LocalDateTime.now();
    String formattedDateTime = now.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"));

    ApplicationDB db = new ApplicationDB();    
    Connection con = db.getConnection();    

    // Insert the question
    String insertQuestionSql = "INSERT INTO qatable (question) VALUES (?)";
    PreparedStatement insertQuestionStmt = con.prepareStatement(insertQuestionSql);
    insertQuestionStmt.setString(1, question);
    int result = insertQuestionStmt.executeUpdate();

    if (result > 0) {
        out.println("<h2>Question submitted. A response will be administered shortly.</h2>");
    } else {
        out.println("<h2>Question failed to submit.</h2>");
    }
    insertQuestionStmt.close();

    // Retrieve the question ID
    String getQuestionID = "SELECT questionID FROM qatable WHERE question = ?";
    PreparedStatement getQidStmt = con.prepareStatement(getQuestionID);
    getQidStmt.setString(1, question);
    ResultSet rs2 = getQidStmt.executeQuery();

    int qid = -1;
    if (rs2.next()) {
        qid = rs2.getInt("questionID");
    } else {
        out.println("<h2>Failed to retrieve question ID.</h2>");
    }

    rs2.close();
    getQidStmt.close();

    // Insert into postquestions if qid was found
    if (qid != -1) {
        String insertPostSql = "INSERT INTO postquestions (userID, questionID, postedDate) VALUES (?, ?, ?)";
        PreparedStatement insertPostStmt = con.prepareStatement(insertPostSql);
        insertPostStmt.setInt(1, userID);
        insertPostStmt.setInt(2, qid);
        insertPostStmt.setString(3, formattedDateTime);
        insertPostStmt.executeUpdate();
        insertPostStmt.close();
    }

    db.closeConnection(con);
} catch (Exception e) {
    out.println("<p>An error occurred: " + e.getMessage() + "</p>");
    e.printStackTrace();
}
%>

<a href="../qaSearchPage.jsp">Back</a>

</body>
</html>
