<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*,com.grievanceportal.db.DBConnection" %>
<%@ page session="true" %>
<%
    String adminUser = (String) session.getAttribute("adminUser");
    if (session.getAttribute("adminUser") == null) {
        response.sendRedirect("admin-login.jsp");
        return;
    }

    // Create a structure to hold logs
    class LogEntry {
        int id; String name; String dept; String action; Timestamp time;
    }
    List<LogEntry> logs = new ArrayList<>();

    try (Connection con = DBConnection.getConnection();
         Statement st = con.createStatement();
         ResultSet rs = st.executeQuery("SELECT * FROM official_logs ORDER BY log_time DESC LIMIT 50")) {

        while (rs.next()) {
            LogEntry log = new LogEntry();
            log.id = rs.getInt("id");
            log.name = rs.getString("official_name");
            log.dept = rs.getString("department");
            log.action = rs.getString("action");
            log.time = rs.getTimestamp("log_time");
            logs.add(log);
        }
    } catch(Exception e) { e.printStackTrace(); }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>All Grievances - Admin Panel</title>
  <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
body { background-color: #f8f9fa; }

.sidebar {
    background: #fff;
    min-height: 100vh;
    border-right: 1px solid #ddd;
    padding: 1rem;
}

.sidebar .menu-box {
    background: #fff;
    border: 1px solid #ddd;
    border-radius: 0.5rem;
    box-shadow: 0 2px 6px rgba(0,0,0,0.08);
    padding: 0.5rem;
}

.sidebar .nav-link { 
    color: #333; 
    border-radius: 0.375rem;
    padding: 0.5rem 0.75rem;
    margin-bottom: 0.4rem;
    transition: all 0.25s ease;
    display: block;
}

.sidebar .nav-link:hover {
    background-color: #fff;              /* keep box white */
    color: #0d6efd;                      /* blue text */
    box-shadow: 0 2px 8px rgba(0,0,0,0.15); /* shadow effect */
    transform: scale(1.02);              /* slight zoom */
    border: 1px solid #0d6efd;           /* blue border */
}

.sidebar .nav-link.active { 
    background: #0d6efd; 
    color: #fff; 
    font-weight: 600;
    box-shadow: 0 2px 8px rgba(13,110,253,0.5);
}

  </style>
</head>
<body>
  <!-- Navbar -->
  <nav class="navbar navbar-dark bg-dark">
    <div class="container-fluid">
      <a class="navbar-brand fw-bold"><i class="fas fa-user-shield me-2"></i>Admin Panel</a>
      <span class="text-white">Welcome, <%= adminUser %></span>
      <a href="logout.jsp" class="btn btn-outline-light btn-sm ms-3"><i class="fas fa-sign-out-alt"></i> Logout</a>
    </div>
  </nav>

  <div class="container-fluid">
    <div class="row">
      <!-- Sidebar -->
          <jsp:include page="adminNav.jsp"/>

 
  <div class="col-md-9 col-lg-10 p-4">
  <h3>Recent Official Activity Logs</h3>
  <table class="table table-striped">
    <thead><tr><th>ID</th><th>Official</th><th>Department</th><th>Action</th><th>Time</th></tr></thead>
    <tbody>
    <% if (logs.isEmpty()) { %>
        <tr><td colspan="5" class="text-center text-muted">No logs found</td></tr>
      <% } else {
           for (LogEntry log : logs) { %>
        <tr>
          <td><%= log.id %></td>
          <td><%= log.name %></td>
          <td><%= log.dept %></td>
          <td><%= log.action %></td>
          <td><%= log.time %></td>
        </tr>
      <% }} %>
    </tbody>
  </table>
</div>
       </div>
  </div>
    <jsp:include page="AdminFooter.jsp"/>

</body></html>
