<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*,com.grievanceportal.db.DBConnection" %>
<%@ page session="true" %>
<%
    String userName = (String) session.getAttribute("userName");
    String userEmail = (String) session.getAttribute("userEmail");
    if (userEmail == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    class Grievance {
        int id; String subject; String category; String priority;
        String department; String status; Timestamp createdAt;
        boolean hasUserAttachment;
        boolean hasOfficialAttachment;
    }
    List<Grievance> grievances = new ArrayList<>();

   try (Connection con = DBConnection.getConnection()) {
    PreparedStatement ps = con.prepareStatement(
        "SELECT id, subject, category, priority, department, status, created_at, attachment, official_attachment " +
        "FROM grievances WHERE user_email=? AND status <> 'Resolved' ORDER BY created_at DESC"
    );
    ps.setString(1, userEmail);
    ResultSet rs = ps.executeQuery();
    while (rs.next()) {
        Grievance g = new Grievance();
        g.id = rs.getInt("id");
        g.subject = rs.getString("subject");
        g.category = rs.getString("category");
        g.priority = rs.getString("priority");
        g.department = rs.getString("department");
        g.status = rs.getString("status");
        g.createdAt = rs.getTimestamp("created_at");
        g.hasUserAttachment = (rs.getBytes("attachment") != null);
        g.hasOfficialAttachment = (rs.getBytes("official_attachment") != null);
        grievances.add(g);
    }
} catch(Exception e){ e.printStackTrace(); }

%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>My Grievances - Digital Grievance Platform</title>
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
        <h2 class="mb-4"><i class="fas fa-list-alt me-2"></i>My Grievances</h2>
        <div class="card shadow-sm">
          <div class="card-body p-0">
            <div class="table-responsive">
              <table class="table table-hover mb-0">
                <thead class="table-light">
                  <tr>
                    <th>ID</th>
                    <th>Subject</th>
                    <th>Category</th>
                    <th>Priority</th>
                    <th>Department</th>
                    <th>Status</th>
                    <th>Date</th>
                    <th>User File</th>
                    <th>Official File</th>
                  </tr>
                </thead>
                <tbody>
                  <% if (grievances.isEmpty()) { %>
                    <tr><td colspan="9" class="text-center">No grievances found.</td></tr>
                  <% } else {
                       for (Grievance g : grievances) { %>
                    <tr>
                      <td>#GRV<%= g.id %></td>
                      <td><%= g.subject %></td>
                      <td><%= g.category %></td>
                      <td><%= g.priority %></td>
                      <td><%= g.department %></td>
                      <td>
                        <span class="badge 
                          <%= g.status.equals("Pending") ? "status-pending" :
                              g.status.equals("Processing") ? "status-processing" :
                              g.status.equals("In Progress") ? "status-inprogress" :
                              "status-resolved" %>">
                          <%= g.status %>
                        </span>
                      </td>
                      <td><%= g.createdAt %></td>
                      <td>
                        <% if (g.hasUserAttachment) { %>
                          <a href="DownloadAttachmentServlet?id=<%= g.id %>" class="btn btn-sm btn-outline-primary">
                            <i class="fas fa-download"></i>
                          </a>
                        <% } else { %>
                          <span class="text-muted">No</span>
                        <% } %>
                      </td>
                      <td>
                        <% if (g.hasOfficialAttachment) { %>
                          <a href="DownloadOfficialAttachmentServlet?id=<%= g.id %>" class="btn btn-sm btn-outline-success">
                            <i class="fas fa-download"></i>
                          </a>
                        <% } else { %>
                          <span class="text-muted">No</span>
                        <% } %>
                      </td>
                    </tr>
                  <% }} %>
                </tbody>
              </table>
            </div>
          </div>
        </div>
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
