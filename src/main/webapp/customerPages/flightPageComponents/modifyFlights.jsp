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
	<body>
		
		<button id='modify'>Modify Flights</button>
		<form id="form" method="get" style="padding-bottom: 10px; display:none;" >
		    <h3>Sort Options:</h3>
		    
		    <label for="sortBy">Sort by:</label>
		    <select name="sortBy" id="sortBy">
		        <option value="price">Price</option>
		        <option value="takeOffTime">Take-off Time</option>
		        <option value="landingTime">Landing Time</option>
		        <option value="duration">Flight Duration</option>
		    </select>
		
		    <label for="sortOrder">Order:</label>
		    <select name="sortOrder" id="sortOrder">
		        <option value="asc">Ascending</option>
		        <option value="desc">Descending</option>
		    </select>
		
		    <h3>Filter Options:</h3>
		
		    <label for="minPrice" style="display: block;">Min Price:</label>
		    <input type="number" name="minPrice" step="0.01" min="0" />
		
		    <label for="maxPrice" style="display: block;">Max Price:</label>
		    <input type="number" name="maxPrice" step="0.01" min="0" />
		
		    <label for="numStops" style="display: block;">Number of Stops:</label>
		    <select name="numStops">
		        <option value="">Any</option>
		        <option value="0">Non-stop</option>
		        <option value="1">1 stop</option>
		        <option value="2">2+ stops</option>
		    </select>
		
		    <label for="airline" style="display: block;">Airline:</label>
		    <select name="airline">
		        <option value="">Any</option>
		        <option value="Delta">Delta</option>
		        <option value="United">United</option>
		        <option value="American Airlines">American Airlines</option>
		    </select>
		
		    <label for="takeOffStart" style="display: block;">Take-off between:</label>
		    <input type="time" name="takeOffStart" />
		    and
		    <input type="time" name="takeOffEnd" />
		
		    <label for="landingStart" style="display: block;">Landing between:</label>
		    <input type="time" name="landingStart" />
		    and
		    <input type="time" name="landingEnd" />
		
		    <br><br>
		    <input type="submit" value="Apply Filters & Sort" />
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