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
	while (rs2.next()) {
	    outputHtml.append("<div style='margin-bottom: 70px;'>")
	        .append("<h2>Question: </h2>")
	        .append("<p>").append(rs2.getString("question")).append("</p>")
	        .append("<h4>Posted On: ").append(rs2.getString("postedDate")).append("</h4>")
	        .append("<h2>Answer: </h2>")
	        .append("<p>").append(rs2.getString("response") != null ? rs2.getString("response") : "Not yet answered.").append("</p>")
	        .append("<h4>Answered On: ").append(rs2.getString("answerDate") != null ? rs2.getString("answerDate") : "Not yet answered.").append("</p>")
	        .append("</h4></div>");
	}
	
	out.println(outputHtml.toString());

	

	rs2.close();
	check2.close();
	db.closeConnection(con);
%>

</div>

<div id='line' style='width: 100%; height: 2px; background-color:black; margin: 5px 0px;'></div>

<script>

	const qbtn = document.getElementById("quest-btn")
	const qctn = document.getElementById("quest-container")
	let state = 0;
	qbtn.addEventListener("click", function (){
		if(state == 0){
			qctn.style.display = 'block';
			state = 1;
			qbtn.textContent = 'Close Button List';
			return;
		}
		qctn.style.display = 'none';
		state = 0;
		qbtn.textContent = 'Open Button List';
	})

</script>


</body>
</html>
