<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>

<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
    <title>Search Bar Code</title>

    <style>
        .item {
            padding: 8px;
            cursor: pointer;
        }
        .item:hover {
            background-color: #f0f0f0;
        }
    </style>
</head>
<body>

	<%
	    String query = request.getParameter("q");
	    String type = request.getParameter("type");
	    String id = request.getParameter("id");
	    String inputID = request.getParameter("inputId");
	
	    if (query != null && type != null && !query.trim().isEmpty()) {
	        try {
	            ApplicationDB db = new ApplicationDB();    
	            Connection con = db.getConnection();      
	
	            String sql;
	            if (id.equals("question")) {
	                sql = "SELECT question, " + id + "ID FROM " + type + " WHERE question LIKE ?";
	            } else {
	                sql = "SELECT name, " + id + "ID FROM " + type + " WHERE name LIKE ?";
	            }
	
	            PreparedStatement stmt = con.prepareStatement(sql);
	            stmt.setString(1, "%" + query + "%");
	            ResultSet rs = stmt.executeQuery();
	
	            boolean found = false;
	
	            while (rs.next()) {
	                found = true;
	                String label;
	                String code = "";
	                String safeCode = "";
	
	                if (id.equals("question")) {
	                    label = rs.getString("question");
	                } else {
	                    label = rs.getString("name");
	                    code = rs.getString(2);
	                    safeCode = code.replaceAll("'", "\\\\'");
	                }
	
	                String safeLabel = label.replaceAll("'", "\\\\'");
	                String suggestionsId = "suggestions_" + id;
	%>
	                <div class="item" onclick="
	                    const input = document.getElementById('<%= inputID %>');
	                    const box = document.getElementById('<%= suggestionsId %>');
	                    <% if (!id.equals("question")) { %>
	                        if (input) input.value = '<%= safeLabel %> (<%= safeCode %>)';
	                    <% } else { %>
	                        if (input) input.value = '<%= safeLabel %>';
	                    <% } %>
	                    if (box) box.style.display = 'none';
	                ">
	                    <%= label %><% if (!id.equals("question")) { %> (<%= code %>)<% } %>
	                </div>
	<%
	            }
	
	            if (!found) {
	                out.println("<div class='item'>No matches found.</div>");
	            }
	
	            rs.close();
	            stmt.close();
	            db.closeConnection(con);
	        } catch (Exception e) {
	            out.println("<div class='item'>Error: " + e.getMessage() + "</div>");
	            e.printStackTrace();
	        }
	    }
	%>
	


</body>
</html>
