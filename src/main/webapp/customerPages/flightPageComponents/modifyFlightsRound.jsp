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
		<form id="form" method="get"
      action="flightPageComponents/flightModifyRoundTrip.jsp"
      style="padding-bottom: 10px; display:none;">
      
		    <h3>Sort Options:</h3>
		    
		    <label for="sortBy">Sort by:</label>
		    <select name="sortBy" id="sortBy" required>
		    	<option value="none">None</option>
		        <option value="price">Price</option>
		        <option value="out_departure_time">Out-bound Take-off Time</option>
		        <option value="ret_departure_time">Returning Take-off Time</option>
		        <option value="out_arrival_time">Out-bound Landing Time</option>
		       	<option value="ret_arrival_time">Returning Landing Time</option>
		        
		        <option value="out_duration">Out-bound Flight Duration</option>
		        <option value="ret_duration">Returning Flight Duration</option>
		        
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
	
			
			
			<label for="outAirline" style="display: block;">Select an Out-bound airline:</label>
			<select name="outAirline" >
			    <option value="none">None</option>
			    <%
			    	StringBuilder outputHtml = new StringBuilder();
				    ApplicationDB db = new ApplicationDB();
			        Connection con = db.getConnection();
			        String query = "select distinct airid from flight where dep_portid = ? and arr_portid = ?";
			        PreparedStatement stmt = con.prepareStatement(query.toString());
			        stmt.setString(1, (String) session.getAttribute("depID"));
			        stmt.setString(2, (String) session.getAttribute("arrID"));
			        ResultSet rs = stmt.executeQuery();
			        
			        while(rs.next()){
			        	String airID = rs.getString("airID");
			        	outputHtml.append("<option value='" + airID + "'>" + airID + "</option>");
			        }
			        
					
			        rs.close();
			        stmt.close();
			        db.closeConnection(con);
			    %>
			    <%= outputHtml.toString() %>
			</select>
			
			<label for="retAirline" style="display: block;">Select a Returning airline:</label>
			<select name="retAirline" >
			    <option value="none">None</option>
			    <%
			    	StringBuilder outputHtml2 = new StringBuilder();
				    ApplicationDB db2 = new ApplicationDB();
			        Connection con2 = db2.getConnection();
			        String query2 = "select distinct airid from flight where dep_portid = ? and arr_portid = ?";
			        PreparedStatement stmt2 = con2.prepareStatement(query2.toString());
			        stmt2.setString(1, (String) session.getAttribute("arrID"));
			        stmt2.setString(2, (String) session.getAttribute("depID"));
			        ResultSet rs2 = stmt2.executeQuery();
			        
			        while(rs2.next()){
			        	String airID = rs2.getString("airID");
			        	outputHtml2.append("<option value='" + airID + "'>" + airID + "</option>");
			        }
			        
					
			        rs2.close();
			        stmt2.close();
			        db2.closeConnection(con);
			    %>
			    <%= outputHtml2.toString() %>
			</select>
			
					
		    <label for="outTakeOffStart" style="display: block;">Out-bound Take-off between:</label>
		    <input type="time" name="outTakeOffStart" />
		    and
		    <input type="time" name="outTakeOffEnd" />
		    
		    <label for="retTakeOffStart" style="display: block;">Returning Take-off between:</label>
		    <input type="time" name="retTakeOffStart" />
		    and
		    <input type="time" name="retTakeOffEnd" />
		
		    <label for="outLandingStart" style="display: block;">Out-bound Landing between:</label>
		    <input type="time" name="outLandingStart" />
		    and
		    <input type="time" name="outLandingEnd" />
		    
		    <label for="retLandingStart" style="display: block;">Returning  Landing between:</label>
		    <input type="time" name="retLandingStart" />
		    and
		    <input type="time" name="retLandingEnd" />
		    
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