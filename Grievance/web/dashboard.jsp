<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,javax.servlet.http.*,javax.servlet.*" %>
<%@ page import="com.grievanceportal.db.DBConnection" %>
<%@ page session="true" %>
<%@ page import="java.util.*,java.sql.*,com.grievanceportal.db.DBConnection" %>
<%
    String userEmail = (String) session.getAttribute("userEmail");
    String userName = (String) session.getAttribute("userName");
    if (userEmail == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    class Grievance {
        int id; String subject; String category; String status; Timestamp createdAt;
    }
    List<Grievance> grievances = new ArrayList<>();

    int total = 0, pending = 0, processing = 0, inProgress = 0, resolved = 0;

    try (Connection con = DBConnection.getConnection()) {
        Statement st = con.createStatement();
        ResultSet rs;

        rs = st.executeQuery("SELECT COUNT(*) c FROM grievances WHERE user_email='" + userEmail + "'");
        if (rs.next()) total = rs.getInt("c");

        rs = st.executeQuery("SELECT COUNT(*) c FROM grievances WHERE user_email='" + userEmail + "' AND status='Pending'");
        if (rs.next()) pending = rs.getInt("c");

        rs = st.executeQuery("SELECT COUNT(*) c FROM grievances WHERE user_email='" + userEmail + "' AND status='Processing'");
        if (rs.next()) processing = rs.getInt("c");

        rs = st.executeQuery("SELECT COUNT(*) c FROM grievances WHERE user_email='" + userEmail + "' AND status='In Progress'");
        if (rs.next()) inProgress = rs.getInt("c");

        rs = st.executeQuery("SELECT COUNT(*) c FROM grievances WHERE user_email='" + userEmail + "' AND status='Resolved'");
        if (rs.next()) resolved = rs.getInt("c");

        PreparedStatement ps = con.prepareStatement(
          "SELECT id, subject, category, status, created_at FROM grievances WHERE user_email=? ORDER BY created_at DESC LIMIT 5");
        ps.setString(1, userEmail);
        rs = ps.executeQuery();
        while (rs.next()) {
            Grievance g = new Grievance();
            g.id = rs.getInt("id");
            g.subject = rs.getString("subject");
            g.category = rs.getString("category");
            g.status = rs.getString("status");
            g.createdAt = rs.getTimestamp("created_at");
            grievances.add(g);
        }
    } catch(Exception e){ e.printStackTrace(); }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Dashboard - Digital Grievance Platform</title>
  <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
  <style>
    :root { --bg: #ffffff; --text: #212529; --card-bg: #ffffff; --card-text: #212529; --footer-bg: #111; --footer-text: #ccc; }
    body.dark { --bg: #181818; --text: #f1f1f1; --card-bg: #242424; --card-text: #f1f1f1; --footer-bg: #000; --footer-text: #999; }
    body { background-color: var(--bg); color: var(--text); transition: all 0.3s; }
    .card, .stats-card { background: var(--card-bg); color: var(--card-text); }
    .sidebar { background: var(--card-bg); height: 100vh; border-right: 1px solid #ddd; }
    .sidebar .nav-link.active { background: #0d6efd; color: #fff; }
    .stats-card { padding: 1.5rem; border-radius: 1rem; box-shadow: 0 2px 6px rgba(0,0,0,0.1); }
    .badge.status-pending { background-color: #ffc107; }
    .badge.status-processing { background-color: #0dcaf0; }
    .badge.status-inprogress { background-color: #17a2b8; }
    .badge.status-resolved { background-color: #28a745; }
    footer { background: var(--footer-bg); color: var(--footer-text); }
  </style>
</head>
<body>
  <!-- Navbar -->
  <nav class="navbar navbar-expand-lg navbar-dark bg-primary fixed-top shadow-sm">
    <div class="container-fluid">
      <a class="navbar-brand fw-bold" href="dashboard.jsp"><i class="fas fa-balance-scale me-2"></i> GrievancePortal</a>
      <button class="navbar-toggler" data-bs-toggle="collapse" data-bs-target="#navbarNav"><span class="navbar-toggler-icon"></span></button>
      <div class="collapse navbar-collapse" id="navbarNav">
        <ul class="navbar-nav ms-auto align-items-center">
          <li class="nav-item dropdown">
            <a class="nav-link dropdown-toggle" href="#" data-bs-toggle="dropdown"><i class="fas fa-user-circle me-2"></i><%= userName %></a>
            <ul class="dropdown-menu dropdown-menu-end">
              <li><a class="dropdown-item" href="#"><i class="fas fa-user me-2"></i>Profile</a></li>
              <li><a class="dropdown-item" href="#"><i class="fas fa-cog me-2"></i>Settings</a></li>
              <li><hr class="dropdown-divider"></li>
              <li><a class="dropdown-item" href="logout.jsp"><i class="fas fa-sign-out-alt me-2"></i>Logout</a></li>
            </ul>
          </li>
        </ul>
      </div>
    </div>
  </nav>

  <!-- Layout -->
  <div class="container-fluid" style="padding-top:80px;">
    <div class="row">
      <!-- Sidebar -->
      <div class="col-md-3 col-lg-2 sidebar p-3">
        <div class="nav flex-column nav-pills">
          <a class="nav-link " href="dashboard.jsp"><i class="fas fa-tachometer-alt me-2"></i>Dashboard</a>
          <a class="nav-link" href="file-grievance.jsp"><i class="fas fa-plus-circle me-2"></i>File Grievance</a>
          <a class="nav-link" href="my-grievances.jsp"><i class="fas fa-list-alt me-2"></i>My Grievances</a>
          <a class="nav-link" href="resolved-grievances.jsp"><i class="fas fa-list-alt me-2"></i>Resoloved Grievances</a>
          <a class="nav-link" href="track-status.jsp"><i class="fas fa-search me-2"></i>Track Status</a>
          <a class="nav-link" href="feedback.jsp"><i class="fas fa-star me-2"></i>Feedback</a>
        </div>
      </div>

      <!-- Main Content -->
      <div class="col-md-9 col-lg-10 p-4">
        <h2 class="mb-4">Welcome back, <%= userName %>!</h2>

        <!-- Stats -->
        <div class="row g-4 mb-4">
          <div class="col-sm-6 col-lg-3"><div class="stats-card"><h6>Total Grievances</h6><h3 class="text-primary"><%= total %></h3></div></div>
          <div class="col-sm-6 col-lg-3"><div class="stats-card"><h6>Pending</h6><h3 class="text-warning"><%= pending %></h3></div></div>
          <div class="col-sm-6 col-lg-3"><div class="stats-card"><h6>Processing</h6><h3 class="text-info"><%= processing %></h3></div></div>
          <div class="col-sm-6 col-lg-3"><div class="stats-card"><h6>Resolved</h6><h3 class="text-success"><%= resolved %></h3></div></div>
        </div>

        <!-- Recent Grievances -->
        <div class="card">
          <div class="card-header"><i class="fas fa-history me-2"></i>Recent Grievances</div>
          <div class="card-body p-0">
            <table class="table table-hover mb-0">
              <thead><tr><th>ID</th><th>Subject</th><th>Category</th><th>Status</th><th>Date</th></tr></thead>
              <tbody>
<% if (grievances.isEmpty()) { %>
    <tr><td colspan="5" class="text-center">No grievances found.</td></tr>
<% } else { 
   for (Grievance g : grievances) { %>
    <tr>
      <td>#GRV<%= g.id %></td>
      <td><%= g.subject %></td>
      <td><%= g.category %></td>
      <td>
        <span class="badge 
          <%= g.status.equals("Pending") ? "status-pending" :
              g.status.equals("Processing") ? "status-processing" :
              g.status.equals("In Progress") ? "status-inprogress" :
              "status-resolved" %>"><%= g.status %></span>
      </td>
      <td><%= g.createdAt %></td>
    </tr>
<% }} %>
</tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>

   <footer class="py-4 text-center bg-dark">
    <p class="mb-0 text-white">&copy; 2025 Digital Grievance Platform</p>
  </footer>

  <script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/js/bootstrap.bundle.min.js"></script>
</body>
</html>
