<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*,java.time.*,java.text.*" %>

<%
try {
	String sortBy = request.getParameter("sortBy");
	String sortOrder = request.getParameter("sortOrder");

	String minPriceStr = request.getParameter("minPrice");
	String maxPriceStr = request.getParameter("maxPrice");

	String outAirline = request.getParameter("outAirline");
	String retAirline = request.getParameter("retAirline");

	String outTakeOffStart = request.getParameter("outTakeOffStart");
	String outTakeOffEnd = request.getParameter("outTakeOffEnd");

	String retTakeOffStart = request.getParameter("retTakeOffStart");
	String retTakeOffEnd = request.getParameter("retTakeOffEnd");

	String outLandingStart = request.getParameter("outLandingStart");
	String outLandingEnd = request.getParameter("outLandingEnd");

	String retLandingStart = request.getParameter("retLandingStart");
	String retLandingEnd = request.getParameter("retLandingEnd");

    Set<String> comboSet = (Set<String>) session.getAttribute("roundTripCombos");
    if (comboSet == null || comboSet.isEmpty()) {
        out.println("<p>No roundtrip results saved in session.</p>");
        return;
    }
    List<String[]> savedCombos = new ArrayList<>();
    for (String combo : comboSet) {
        savedCombos.add(combo.split("-"));
    }
    
    String boardClass = (String) session.getAttribute("class");

    
    double bookingFee = 20.0;


    double classSurcharge = 0.0;
    if ("first".equalsIgnoreCase(boardClass)) {
        classSurcharge = 1000.0;
    } else if ("business".equalsIgnoreCase(boardClass)) {
        classSurcharge = 300.0;
    } else if ("economy".equalsIgnoreCase(boardClass)) {
        classSurcharge = 100.0;
    }
    
    double adjustedMinPrice = minPriceStr != null && !minPriceStr.isEmpty() 
    	    ? Double.parseDouble(minPriceStr) - classSurcharge - bookingFee 
    	    : Double.MIN_VALUE;

   	double adjustedMaxPrice = maxPriceStr != null && !maxPriceStr.isEmpty() 
   	    ? Double.parseDouble(maxPriceStr) - classSurcharge - bookingFee 
   	    : Double.MAX_VALUE;


    ApplicationDB db = new ApplicationDB();
    Connection con = db.getConnection();

    List<Map<String, Object>> fullCombos = new ArrayList<>();

    for (String[] combo : savedCombos) {
        String outAirID = combo[0];
        String outFlightNum = combo[1];
        String retAirID = combo[2];
        String retFlightNum = combo[3];

        Map<String, Object> pair = new HashMap<>();

        PreparedStatement stmt = con.prepareStatement("SELECT * FROM flight WHERE airID = ? AND flightNum = ?");
        stmt.setString(1, outAirID);
        stmt.setString(2, outFlightNum);
        ResultSet rsOut = stmt.executeQuery();

        if (rsOut.next()) {
            Map<String, Object> outData = new HashMap<>();
            outData.put("airID", rsOut.getString("airID"));
            outData.put("flightNum", rsOut.getString("flightNum"));
            outData.put("depPortID", rsOut.getString("dep_portID"));
            outData.put("arrPortID", rsOut.getString("arr_portID"));
            outData.put("departure_date", rsOut.getString("departure_date"));
            outData.put("arrival_date", rsOut.getString("arrival_date"));
            outData.put("departure_time", rsOut.getTime("departure_time"));
            outData.put("arrival_time", rsOut.getTime("arrival_time"));
            outData.put("price", rsOut.getDouble("price"));
            pair.put("outbound", outData);
        }
        rsOut.close();

        stmt.setString(1, retAirID);
        stmt.setString(2, retFlightNum);
        ResultSet rsRet = stmt.executeQuery();

        if (rsRet.next()) {
            Map<String, Object> retData = new HashMap<>();
            retData.put("airID", rsRet.getString("airID"));
            retData.put("flightNum", rsRet.getString("flightNum"));
            retData.put("depPortID", rsRet.getString("dep_portID"));
            retData.put("arrPortID", rsRet.getString("arr_portID"));
            retData.put("departure_date", rsRet.getString("departure_date"));
            retData.put("arrival_date", rsRet.getString("arrival_date"));
            retData.put("departure_time", rsRet.getTime("departure_time"));
            retData.put("arrival_time", rsRet.getTime("arrival_time"));
            retData.put("price", rsRet.getDouble("price"));
            pair.put("return", retData);
        }
        rsRet.close();
        stmt.close();

        if (pair.containsKey("outbound") && pair.containsKey("return")) {
            fullCombos.add(pair);
        }
    }

    List<Map<String, Object>> filtered = new ArrayList<>();
    for (Map<String, Object> pair : fullCombos) {
    	Map<String, Object> outb = (Map<String, Object>) pair.get("outbound");
    	Map<String, Object> ret = (Map<String, Object>) pair.get("return");

    	double totalPrice = (Double) outb.get("price") + (Double) ret.get("price") + classSurcharge + bookingFee;

    	String outboundAirID = (String) outb.get("airID");
    	String returnAirID = (String) ret.get("airID");

    	Time outDepTime = (Time) outb.get("departure_time");
    	Time outArrTime = (Time) outb.get("arrival_time");
    	Time retDepTime = (Time) ret.get("departure_time");
    	Time retArrTime = (Time) ret.get("arrival_time");

    	boolean match = true;

    	if (minPriceStr != null && !minPriceStr.isEmpty() && totalPrice < Double.parseDouble(minPriceStr)) match = false;
    	if (maxPriceStr != null && !maxPriceStr.isEmpty() && totalPrice > Double.parseDouble(maxPriceStr)) match = false;

    	if (outAirline != null && !"none".equalsIgnoreCase(outAirline) && !outboundAirID.equalsIgnoreCase(outAirline)) {
		    match = false;
		}


    	if (retAirline != null && !"none".equalsIgnoreCase(retAirline) && !returnAirID.equalsIgnoreCase(retAirline)) {
		    match = false;
		}

    	if (outTakeOffStart != null && !outTakeOffStart.isEmpty() && outDepTime.before(Time.valueOf(outTakeOffStart + ":00"))) match = false;
    	if (outTakeOffEnd != null && !outTakeOffEnd.isEmpty() && outDepTime.after(Time.valueOf(outTakeOffEnd + ":00"))) match = false;

    	if (outLandingStart != null && !outLandingStart.isEmpty() && outArrTime.before(Time.valueOf(outLandingStart + ":00"))) match = false;
    	if (outLandingEnd != null && !outLandingEnd.isEmpty() && outArrTime.after(Time.valueOf(outLandingEnd + ":00"))) match = false;

    	if (retTakeOffStart != null && !retTakeOffStart.isEmpty() && retDepTime.before(Time.valueOf(retTakeOffStart + ":00"))) match = false;
    	if (retTakeOffEnd != null && !retTakeOffEnd.isEmpty() && retDepTime.after(Time.valueOf(retTakeOffEnd + ":00"))) match = false;

    	if (retLandingStart != null && !retLandingStart.isEmpty() && retArrTime.before(Time.valueOf(retLandingStart + ":00"))) match = false;
    	if (retLandingEnd != null && !retLandingEnd.isEmpty() && retArrTime.after(Time.valueOf(retLandingEnd + ":00"))) match = false;

    	if (match) filtered.add(pair);
    }

    
    if (sortBy != null && sortOrder != null && !"none".equals(sortBy) && !"none".equals(sortOrder)) {
    Comparator<Map<String, Object>> comparator = null;

    if ("price".equalsIgnoreCase(sortBy)) {
        comparator = new Comparator<Map<String, Object>>() {
            public int compare(Map<String, Object> a, Map<String, Object> b) {
                try {
                    double priceA = (Double) ((Map) a.get("outbound")).get("price") + (Double) ((Map) a.get("return")).get("price");
                    double priceB = (Double) ((Map) b.get("outbound")).get("price") + (Double) ((Map) b.get("return")).get("price");
                    return Double.compare(priceA, priceB);
                } catch (Exception e) { return 0; }
            }
        };
    } else if ("out_departure_time".equalsIgnoreCase(sortBy)) {
        comparator = new Comparator<Map<String, Object>>() {
            public int compare(Map<String, Object> a, Map<String, Object> b) {
                try {
                    Time timeA = (Time) ((Map) a.get("outbound")).get("departure_time");
                    Time timeB = (Time) ((Map) b.get("outbound")).get("departure_time");
                    return timeA.compareTo(timeB);
                } catch (Exception e) { return 0; }
            }
        };
    } else if ("ret_departure_time".equalsIgnoreCase(sortBy)) {
        comparator = new Comparator<Map<String, Object>>() {
            public int compare(Map<String, Object> a, Map<String, Object> b) {
                try {
                    Time timeA = (Time) ((Map) a.get("return")).get("departure_time");
                    Time timeB = (Time) ((Map) b.get("return")).get("departure_time");
                    return timeA.compareTo(timeB);
                } catch (Exception e) { return 0; }
            }
        };
    } else if ("out_arrival_time".equalsIgnoreCase(sortBy)) {
        comparator = new Comparator<Map<String, Object>>() {
            public int compare(Map<String, Object> a, Map<String, Object> b) {
                try {
                    Time timeA = (Time) ((Map) a.get("outbound")).get("arrival_time");
                    Time timeB = (Time) ((Map) b.get("outbound")).get("arrival_time");
                    return timeA.compareTo(timeB);
                } catch (Exception e) { return 0; }
            }
        };
    } else if ("ret_arrival_time".equalsIgnoreCase(sortBy)) {
        comparator = new Comparator<Map<String, Object>>() {
            public int compare(Map<String, Object> a, Map<String, Object> b) {
                try {
                    Time timeA = (Time) ((Map) a.get("return")).get("arrival_time");
                    Time timeB = (Time) ((Map) b.get("return")).get("arrival_time");
                    return timeA.compareTo(timeB);
                } catch (Exception e) { return 0; }
            }
        };
    } else if ("out_duration".equalsIgnoreCase(sortBy)) {
        comparator = new Comparator<Map<String, Object>>() {
            public int compare(Map<String, Object> a, Map<String, Object> b) {
                try {
                    long durA = ((Time) ((Map) a.get("outbound")).get("arrival_time")).getTime() - ((Time) ((Map) a.get("outbound")).get("departure_time")).getTime();
                    long durB = ((Time) ((Map) b.get("outbound")).get("arrival_time")).getTime() - ((Time) ((Map) b.get("outbound")).get("departure_time")).getTime();
                    return Long.compare(durA, durB);
                } catch (Exception e) { return 0; }
            }
        };
    } else if ("ret_duration".equalsIgnoreCase(sortBy)) {
        comparator = new Comparator<Map<String, Object>>() {
            public int compare(Map<String, Object> a, Map<String, Object> b) {
                try {
                    long durA = ((Time) ((Map) a.get("return")).get("arrival_time")).getTime() - ((Time) ((Map) a.get("return")).get("departure_time")).getTime();
                    long durB = ((Time) ((Map) b.get("return")).get("arrival_time")).getTime() - ((Time) ((Map) b.get("return")).get("departure_time")).getTime();
                    return Long.compare(durA, durB);
                } catch (Exception e) { return 0; }
            }
        };
    }

    if (comparator != null) {
        if ("desc".equalsIgnoreCase(sortOrder)) {
            Collections.sort(filtered, Collections.reverseOrder(comparator));
        } else {
            Collections.sort(filtered, comparator);
        }
    }
}

    if (filtered.isEmpty()) {
        out.println("<p>No roundtrip flights match the selected filters.</p>");
    } else {
    	for (Map<String, Object> pair : filtered) {
    	    Map<String, Object> outbound = (Map<String, Object>) pair.get("outbound");
    	    Map<String, Object> returnFlight = (Map<String, Object>) pair.get("return");

    	    double total = (Double) outbound.get("price") + (Double) returnFlight.get("price")+ classSurcharge + bookingFee;


    	    out.println("<div style='margin-bottom: 20px;'>");
    	    out.println("<p><strong>Outbound:</strong> " + outbound.get("airID") + " #" + outbound.get("flightNum"));
    	    out.println(" | " + outbound.get("depPortID") + " > " + outbound.get("arrPortID"));
    	    out.println(" | Departs: " + outbound.get("departure_date") + " " + outbound.get("departure_time"));
    	    out.println(" | Arrives: " + outbound.get("arrival_date") + " " + outbound.get("arrival_time") + "</p>");

    	    out.println("<p><strong>Return:</strong> " + returnFlight.get("airID") + " #" + returnFlight.get("flightNum"));
    	    out.println(" | " + returnFlight.get("depPortID") + " > " + returnFlight.get("arrPortID"));
    	    out.println(" | Departs: " + returnFlight.get("departure_date") + " " + returnFlight.get("departure_time"));
    	    out.println(" | Arrives: " + returnFlight.get("arrival_date") + " " + returnFlight.get("arrival_time") + "</p>");

    	    out.println("<p><strong>Total Price: $" + String.format("%.2f", total) + "</strong></p>");
    	    out.println("<form method='post' action='purchaseTicket.jsp'>");
    	    out.println("<input type='hidden' name='outboundlineID' value='" + outbound.get("airID") + "'/>");
    	    out.println("<input type='hidden' name='outboundFlight' value='" + outbound.get("flightNum") + "'/>");
    	    
    	    out.println("<input type='hidden' name='retlineID' value='" + returnFlight.get("airID") + "'/>");
    	    out.println("<input type='hidden' name='returnFlight' value='" + returnFlight.get("flightNum") + "'/>");
    	    out.println("<input type='hidden' name='totalPrice' value='" + outbound.get("flightNum") + "'/>");
    	    out.println("<input type='submit' value='Book Round Trip'/>");
    	    out.println("</form>");
    	    out.println("<hr></div>");
    	    
    	    
    	    
    	    
    	}
    }

    db.closeConnection(con);
} catch (Exception e) {
    out.println("<p>Error: " + e.getMessage() + "</p>");
    e.printStackTrace();
}
%>
