<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,com.grievanceportal.db.DBConnection" %>
<%@ page session="true" %>
<%
    String userName = (String) session.getAttribute("userName");
    String userEmail = (String) session.getAttribute("userEmail");
    if (userEmail == null) {
        response.sendRedirect("login.html");
        return;
    }

    // Variables for result
    boolean searched = false;
    boolean found = false;
    int id = 0;
    String subject = "", category = "", department = "", status = "";
    Timestamp createdAt = null;

    String grievanceId = request.getParameter("grievanceId");
    if (grievanceId != null && !grievanceId.trim().isEmpty()) {
        searched = true;
        try (Connection con = DBConnection.getConnection()) {
            // Remove "GRV" prefix if user types it
            grievanceId = grievanceId.replace("#GRV", "").trim();
            PreparedStatement ps = con.prepareStatement(
                "SELECT id, subject, category, department, status, created_at " +
                "FROM grievances WHERE id=? AND user_email=?"
            );
            ps.setInt(1, Integer.parseInt(grievanceId));
            ps.setString(2, userEmail);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                found = true;
                id = rs.getInt("id");
                subject = rs.getString("subject");
                category = rs.getString("category");
                department = rs.getString("department");
                status = rs.getString("status");
                createdAt = rs.getTimestamp("created_at");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Track Status - Digital Grievance Platform</title>
  <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
  <style>
    :root { --bg: #ffffff; --text: #212529; --card-bg: #ffffff; --card-text: #212529; --footer-bg: #111; --footer-text: #ccc; }
    body.dark { --bg: #181818; --text: #f1f1f1; --card-bg: #242424; --card-text: #f1f1f1; --footer-bg: #000; --footer-text: #999; }
    body { background-color: var(--bg); color: var(--text); transition: all 0.3s; }
    .card { background: var(--card-bg); color: var(--card-text); }
    .sidebar { background: var(--card-bg); height: 100vh; border-right: 1px solid #ddd; }
    .sidebar .nav-link.active { background: #0d6efd; color: #fff; }
    footer { background: var(--footer-bg); color: var(--footer-text); }
    .badge.status-pending { background-color: #ffc107; }
    .badge.status-processing { background-color: #0dcaf0; }
    .badge.status-inprogress { background-color: #17a2b8; }
    .badge.status-resolved { background-color: #28a745; }
    .theme-toggle { border: none; background: transparent; color: white; font-size: 1.2rem; cursor: pointer; }
  </style>
</head>
<body>
  <!-- Navbar -->
  <nav class="navbar navbar-expand-lg navbar-dark bg-primary fixed-top shadow-sm">
    <div class="container-fluid">
      <a class="navbar-brand fw-bold" href="dashboard.jsp"><i class="fas fa-balance-scale me-2"></i>GrievancePortal</a>
      <button class="navbar-toggler" data-bs-toggle="collapse" data-bs-target="#navbarNav"><span class="navbar-toggler-icon"></span></button>
      <div class="collapse navbar-collapse" id="navbarNav">
        <ul class="navbar-nav ms-auto align-items-center">
          <li class="nav-item dropdown">
            <a class="nav-link dropdown-toggle" href="#" data-bs-toggle="dropdown">
              <i class="fas fa-user-circle me-2"></i><%= userName %>
            </a>
            <ul class="dropdown-menu dropdown-menu-end">
              <li><a class="dropdown-item" href="#"><i class="fas fa-user me-2"></i>Profile</a></li>
              <li><a class="dropdown-item" href="#"><i class="fas fa-cog me-2"></i>Settings</a></li>
              <li><hr class="dropdown-divider"></li>
              <li><a class="dropdown-item" href="logout.jsp"><i class="fas fa-sign-out-alt me-2"></i>Logout</a></li>
            </ul>
          </li>
          <li class="nav-item ms-3"><button id="themeToggle" class="theme-toggle"><i class="fas fa-moon"></i></button></li>
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
        <h2 class="mb-4"><i class="fas fa-search me-2"></i>Track Grievance Status</h2>

        <!-- Search Form -->
        <div class="card mb-4 shadow-sm">
          <div class="card-body">
            <form method="GET" action="track-status.jsp" class="row g-3">
              <div class="col-md-8">
                <input type="text" class="form-control" name="grievanceId" placeholder="Enter Grievance ID (e.g. #GRV123)" required>
              </div>
              <div class="col-md-4 d-grid">
                <button type="submit" class="btn btn-primary"><i class="fas fa-search me-2"></i>Check Status</button>
              </div>
            </form>
          </div>
        </div>

        <!-- Results -->
        <% if (searched) { %>
          <% if (found) { %>
            <div class="card shadow-sm">
              <div class="card-header"><i class="fas fa-info-circle me-2"></i>Grievance Details</div>
              <div class="card-body">
                <p><strong>ID:</strong> #GRV<%= id %></p>
                <p><strong>Subject:</strong> <%= subject %></p>
                <p><strong>Category:</strong> <%= category %></p>
                <p><strong>Department:</strong> <%= department %></p>
                <p><strong>Status:</strong> 
                  <span class="badge 
                    <%= status.equals("Pending") ? "status-pending" :
                        status.equals("Processing") ? "status-processing" :
                        status.equals("In Progress") ? "status-inprogress" :
                        "status-resolved" %>"><%= status %></span>
                </p>
                <p><strong>Date Submitted:</strong> <%= createdAt %></p>
              </div>
            </div>
          <% } else { %>
            <div class="alert alert-danger"><i class="fas fa-times-circle me-2"></i>No grievance found with that ID.</div>
          <% } %>
        <% } %>

      </div>
    </div>
  </div>

  <!-- Footer -->
  <footer class="py-3 text-center mt-4">
    <p class="mb-0">&copy; 2025 Digital Grievance Platform</p>
  </footer>

  <script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/js/bootstrap.bundle.min.js"></script>
  <script>
    const toggleBtn = document.getElementById("themeToggle");
    const body = document.body;
    if(localStorage.getItem("theme") === "dark"){ body.classList.add("dark"); toggleBtn.innerHTML = '<i class="fas fa-sun"></i>'; }
    toggleBtn.addEventListener("click", () => {
      body.classList.toggle("dark");
      if(body.classList.contains("dark")){ localStorage.setItem("theme","dark"); toggleBtn.innerHTML = '<i class="fas fa-sun"></i>'; }
      else { localStorage.setItem("theme","light"); toggleBtn.innerHTML = '<i class="fas fa-moon"></i>'; }
    });
  </script>
</body>
</html>
