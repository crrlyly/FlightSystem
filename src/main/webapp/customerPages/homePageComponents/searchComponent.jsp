<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>

<%
	String searchType = request.getParameter("searchType"); // "airport"
	String searchId = request.getParameter("searchId");     // "departing" or "arriving"
	String placeholder = request.getParameter("input");     // "Where from..."
	String idKey = request.getParameter("primaryID");
	String inputId = "search_" + searchId;
	String suggestionsId = "suggestions_" + searchId; 
	String col = request.getParameter("col");
%>

<!DOCTYPE>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title>Automatic Search Bar</title>
		
		<style>
        #suggestions {
            border: 1px solid #ccc;
            max-height: 150px;
            overflow-y: auto;
            background: white;
            position: absolute;
            display: none;
            width: 250px;
        }
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
		<input type="text" id="<%= inputId %>" name="<%= inputId %>" placeholder="<%= placeholder + "?"%>" autocomplete="off" required>
		<div id="<%= suggestionsId %>"></div>
	
	<script>
	(function() {
		  const searchBox = document.getElementById("<%= inputId %>");
		  const suggestions = document.getElementById("<%= suggestionsId %>");

		  searchBox.addEventListener("input", function () {
		    const query = this.value.trim();
		    if (query === "") {
		      suggestions.style.display = "none";
		      return;
		    }

		    const xhr = new XMLHttpRequest();
		    xhr.open("GET", "<%= request.getContextPath() %>/customerPages/homePageComponents/searchBarLookup.jsp?type=<%= searchType %>&inputId=<%=inputId%>&id=<%= idKey %>&q=" + encodeURIComponent(query), true);

		    xhr.onload = function () {
	    	  if (xhr.status === 200) {
	    	    suggestions.style.display = "block";
	    	    suggestions.innerHTML = xhr.responseText.trim();
	    	  }
	    	};
		    xhr.send();
		  });

		  document.addEventListener("click", function (e) {
		    if (!searchBox.contains(e.target) && !suggestions.contains(e.target)) {
		      suggestions.style.display = "none";
		    }
		  });
		})();
	</script>
	
	</body>
		

	</body>
</html>