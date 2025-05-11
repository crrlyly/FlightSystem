Online Travel Reservation System


CS 336: Principles of Information and Database Management
Spring 2025 
Instructor: Antonio Miranda Garcia**


Group 20: Carly Chick, Hiloni Patel, Sydney Pacheco
_________________________________________________________________________


Functional Requirements:


   1. Customer-Level Functionality:
      - Search flights by criteria such as one-way, round-trip, and flexible dates.
      - Browse and filter available flights by attributes like price, duration, and airline.
      - Make, cancel, or reschedule** reservations for business or first-class flights.
      - View past and upcoming reservations, including detailed flight information.
      - Join waiting lists for flights that are fully booked.
      - Ask questions to customer representatives and browse answers based on keywords.


   2. Admin-Level Functionality:
      - Add, edit, or delete customer and customer representative accounts.
      - Generate sales reports for specific months, summarizing system revenue.
      - View reservation lists by flight number or customer name.
      - Summarize revenue by flight, airline, or customer.
      - Identify top customers by revenue and most frequently booked flights.


   3. Customer Representative-Level Functionality:
      - Make and edit reservations on behalf of customers.
      - Respond to customer queries and manage customer questions.
      - Manage flight, aircraft, and airport information.
      - View waiting lists for fully booked flights.
      - View lists of flights arriving or departing from a particular airport.
_________________________________________________________________________


User Access Control:


   Customer: 
      - Can only manage their own reservations, search for flights, and ask questions.
      
   Admin:  
      - Has full control over customer data, flight reservations, sales reports, and other system management tasks.


   Customer Representative: 
      - Can manage flight reservations for customers, respond to customer queries, and manage flight, airport, and aircraft data.
_________________________________________________________________________


Customer/User Navigation Description:


****If you don’t choose to check “flexible dates” when searching for flights, just know that the way that we handle the days in our database is by using bits (“operating_days” in the flight table). 
For example: 
01 - available on mondays
10 - available on tuesdays
100 - available on wednesdays
1000 - available on thursdays
….
1111111 - available on all days of the week.****




Make Flights:
* On the homepage, there is an area to put in the flight information and search for the corresponding flights.
* On the flight listing page, there is a button called “Modify Flights” you can use to filter and sort the flights.
* This works for both one-way trip flights and round-trip flights except there are some differences in the way that they filter and sort because round-trip contains two flights.
* Flights that were reserved by the user will show up on the user profile under “ongoing ____”.


Browse Questions
* On the Q&A page, there is an area to browse questions submitted by other users either by a keyword, or just by typing.
* You can also submit your own question on that page.
* The user profile will display the user’s answered and unanswered questions.


Waiting List:
* If the flight for the one-way trip is full or if the round-trip has either one or both of their flights full, then the user will be put into the corresponding waitlist for each flight. 
* Waitlisted flight tickets will show up on the user profile.
* Once the flight has an open spot and the user is at the top of the waitlist, there will be a button under their waitlisted ticket on the user profile that they can push in order to reserve their ticket.




Past Tickets:
* Can be viewed on the user profile.


Cancel Reservations:
* A delete button will show up on ongoing tickets (in the user profile) that are either first or business class.


_________________________________________________________________________


Files Included in This Submission:


   1. Demo.mp4: A video demonstration showcasing the key features and step-by-step functionality of the system.
   2. FlightSystem.zip: The zip file containing the complete source code of the project.
   3. schema.sql: The SQL file containing the database schema, exported from MySQL Workbench.
   4. ER Diagram: The Entity-Relationship diagram illustrating the database structure and relationships.
   5. ProjectChecklist.pdf: A checklist of all implemented features with marks for each completed task.
   6. README.txt: Detailed description of the project, including system features, admin and customer representative credentials, and how to use the system.


_________________________________________________________________________




Admin and Customer Representative Credentials:


   Admin Credentials:  
      Username: ccarly
      Password: Cchicken242


   Customer Representative Credentials**:  
      Username: hpatel 
      Password: testing
