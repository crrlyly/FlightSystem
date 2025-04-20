<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>

<!DOCTYPE>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title></title>
	</head>
	<body style="padding-bottom: 10px;">
		
		<button id='modify'>Modify Flights</button>
		<form id="form" method="get" action="flightPageComponents/flightModifyCode.jsp" style="padding-bottom: 10px; display:none;" >
		    <h3>Sort Options:</h3>
		    
		    <label for="sortBy">Sort by:</label>
		    <select name="sortBy" id="sortBy" required>
		    	<option value="none">None</option>
		        <option value="price">Price</option>
		        <option value="departure_time">Take-off Time</option>
		        <option value="arrival_time">Landing Time</option>
		        <option value="duration">Flight Duration</option>
		    </select>
		
		    <label for="sortOrder">Order:</label>
		    <select name="sortOrder" id="sortOrder" required>
		    	<option value="none">None</option>
		        <option value="asc">Ascending</option>
		        <option value="desc">Descending</option>
		    </select>
		
		    <h3>Filter Options:</h3>
		
		    <label for="minPrice" style="display: block;">Min Price:</label>
		    <input type="number" name="minPrice" step="0.01" min="0" />
		
		    <label for="maxPrice" style="display: block;">Max Price:</label>
		    <input type="number" name="maxPrice" step="0.01" min="0" />
	
			
			<%
			    Object obj = request.getAttribute("airlineList");
			%>
			
			<label for="airline" style="display: block;">Select an airline:</label>
			<select name="airline" >
			    <option value="none"></option>
			    <%
			        if (obj instanceof Set<?>) {
			            for (Object item : (Set<?>) obj) {
			                String name = String.valueOf(item); // safe conversion
			    %>
			                <option value="<%= name %>"><%= name %></option>
			    <%
			            }
			        }
			    %>
			</select>
			
					
		    <label for="takeOffStart" style="display: block;">Take-off between:</label>
		    <input type="time" name="takeOffStart" />
		    and
		    <input type="time" name="takeOffEnd" />
		
		    <label for="landingStart" style="display: block;">Landing between:</label>
		    <input type="time" name="landingStart" />
		    and
		    <input type="time" name="landingEnd" />
		    <input type="hidden" name="flightNums" value="<%= request.getAttribute("printedFlightNums") %>">
		    
		
		    
		    <input type="submit" style="display: block; margin-top: 10px;" value="Apply Filters & Sort" />
		</form>
		
		
		

	<script>
	
		const form = document.getElementById('form');
		const button = document.getElementById('modify')
		let state = 0;
		
		button.addEventListener('click', function(event) {
	      if(state === 0){
	    	  form.style.display = 'block';
	    	  state = 1;
	      }
	      else{
	    	  form.style.display = 'none';
	    	  state = 0;
	      }
	    });
		
	
		
	</script>
	
	</body>
</html>