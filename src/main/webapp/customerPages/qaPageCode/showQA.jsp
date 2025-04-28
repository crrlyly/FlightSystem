<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>

<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
    <title>Filtered and Sorted Flights</title>
</head>
<body>

<%
String question = request.getParameter("search_question");

if (question != null && !question.trim().isEmpty()) {
    try {
        ApplicationDB db = new ApplicationDB();
        Connection con = db.getConnection();

        String query = "SELECT questionID, question, response FROM qatable WHERE question LIKE ?";
        PreparedStatement stmt = con.prepareStatement(query);
        stmt.setString(1, question + "%");

        ResultSet rs = stmt.executeQuery();

        if (rs.next()) {
            String qid = rs.getString("questionID");
            String questionText = rs.getString("question");
            String answerText = rs.getString("response");

            String query2 = "SELECT postedDate, answerDate FROM provideAnswer JOIN postQuestions USING (questionID) WHERE questionID = ?";
            PreparedStatement stmt2 = con.prepareStatement(query2);
            stmt2.setString(1, qid);
            ResultSet rs2 = stmt2.executeQuery();

            String postDate = "N/A";
            String answerDate = "N/A";

            if (rs2.next()) {
                postDate = rs2.getString("postedDate");
                answerDate = rs2.getString("answerDate");
            }
            
            

            out.println("<h2>Question:</h2>");
            out.println("<p>" + questionText + "</p>");
            out.println("<h4>Posted On: " + postDate + "</h4>");
            out.println("<h2>Answer:</h2>");
            out.println("<p>" + answerText + "</p>");
            out.println("<h4>Answered On: " + answerDate + "</h4>");

            rs2.close();
            stmt2.close();
        } else {
            out.println("<h2>Could not find question.</h2>");
        }

        rs.close();
        stmt.close();
        db.closeConnection(con);
    } catch (Exception e) {
        out.println("<p>Error: " + e.getMessage() + "</p>");
        e.printStackTrace();
    }
} else {
    out.println("<p>Please enter a question to search.</p>");
}
%>

<div id='line' style='width: 100%; height: 2px; background-color:black; margin: 10px 0px;'></div>

<a href='../qaSearchPage.jsp'>Back</a>

</body>
</html>
