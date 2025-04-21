<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*,java.time.*,java.text.*" %>

<%
try {
    String sortBy = request.getParameter("sortBy");
    String sortOrder = request.getParameter("sortOrder");
    String minPriceStr = request.getParameter("minPrice");
    String maxPriceStr = request.getParameter("maxPrice");
    String airline = request.getParameter("airline");
    String takeOffStart = request.getParameter("takeOffStart");
    String takeOffEnd = request.getParameter("takeOffEnd");
    String landingStart = request.getParameter("landingStart");
    String landingEnd = request.getParameter("landingEnd");

    Set<String> comboSet = (Set<String>) session.getAttribute("roundTripCombos");
    if (comboSet == null || comboSet.isEmpty()) {
        out.println("<p>No roundtrip results saved in session.</p>");
        return;
    }
    List<String[]> savedCombos = new ArrayList<>();
    for (String combo : comboSet) {
        savedCombos.add(combo.split("-"));
    }

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

    // Filter
    List<Map<String, Object>> filtered = new ArrayList<>();
    for (Map<String, Object> pair : fullCombos) {
        Map<String, Object> outb = (Map<String, Object>) pair.get("outbound");
        Map<String, Object> ret = (Map<String, Object>) pair.get("return");

        double totalPrice = (Double) outb.get("price") + (Double) ret.get("price");
        String outAirline = (String) outb.get("airID");
        Time outDepTime = (Time) outb.get("departure_time");
        Time retArrTime = (Time) ret.get("arrival_time");

        boolean match = true;
        if (minPriceStr != null && !minPriceStr.isEmpty() && totalPrice < Double.parseDouble(minPriceStr)) match = false;
        if (maxPriceStr != null && !maxPriceStr.isEmpty() && totalPrice > Double.parseDouble(maxPriceStr)) match = false;
        if (airline != null && !airline.isEmpty() && !"none".equals(airline) && !outAirline.equals(airline)) match = false;
        if (takeOffStart != null && !takeOffStart.isEmpty() && outDepTime.before(Time.valueOf(takeOffStart + ":00"))) match = false;
        if (takeOffEnd != null && !takeOffEnd.isEmpty() && outDepTime.after(Time.valueOf(takeOffEnd + ":00"))) match = false;
        if (landingStart != null && !landingStart.isEmpty() && retArrTime.before(Time.valueOf(landingStart + ":00"))) match = false;
        if (landingEnd != null && !landingEnd.isEmpty() && retArrTime.after(Time.valueOf(landingEnd + ":00"))) match = false;

        if (match) filtered.add(pair);
    }

    // Sort
    if (sortBy != null && sortOrder != null && !"none".equals(sortBy) && !"none".equals(sortOrder)) {
        Comparator<Map<String, Object>> comparator = null;

        if ("price".equalsIgnoreCase(sortBy)) {
            comparator = new Comparator<Map<String, Object>>() {
                public int compare(Map<String, Object> a, Map<String, Object> b) {
                    try {
                        Map<String, Object> aOut = (Map<String, Object>) a.get("outbound");
                        Map<String, Object> aRet = (Map<String, Object>) a.get("return");
                        Map<String, Object> bOut = (Map<String, Object>) b.get("outbound");
                        Map<String, Object> bRet = (Map<String, Object>) b.get("return");
                        double priceA = (Double) aOut.get("price") + (Double) aRet.get("price");
                        double priceB = (Double) bOut.get("price") + (Double) bRet.get("price");
                        return Double.compare(priceA, priceB);
                    } catch (Exception e) { return 0; }
                }
            };
        } else if ("duration".equalsIgnoreCase(sortBy)) {
            comparator = new Comparator<Map<String, Object>>() {
                public int compare(Map<String, Object> a, Map<String, Object> b) {
                    try {
                        Map<String, Object> aOut = (Map<String, Object>) a.get("outbound");
                        Map<String, Object> aRet = (Map<String, Object>) a.get("return");
                        Map<String, Object> bOut = (Map<String, Object>) b.get("outbound");
                        Map<String, Object> bRet = (Map<String, Object>) b.get("return");

                        long durA = ((Time) aOut.get("arrival_time")).getTime() - ((Time) aOut.get("departure_time")).getTime();
                        durA += ((Time) aRet.get("arrival_time")).getTime() - ((Time) aRet.get("departure_time")).getTime();

                        long durB = ((Time) bOut.get("arrival_time")).getTime() - ((Time) bOut.get("departure_time")).getTime();
                        durB += ((Time) bRet.get("arrival_time")).getTime() - ((Time) bRet.get("departure_time")).getTime();

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

    // Output results
    if (filtered.isEmpty()) {
        out.println("<p>No roundtrip flights match the selected filters.</p>");
    } else {
    	for (Map<String, Object> pair : filtered) {
    	    Map<String, Object> outbound = (Map<String, Object>) pair.get("outbound");
    	    Map<String, Object> returnFlight = (Map<String, Object>) pair.get("return");

    	    double total = (Double) outbound.get("price") + (Double) returnFlight.get("price");

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
    	    out.println("<hr></div>");
    	}
    }

    db.closeConnection(con);
} catch (Exception e) {
    out.println("<p>Error: " + e.getMessage() + "</p>");
    e.printStackTrace();
}
%>
