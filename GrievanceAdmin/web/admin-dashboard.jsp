<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page session="true" %>
<%
    String adminUser = (String) session.getAttribute("adminUser");
    if (adminUser == null) {
        response.sendRedirect("admin-login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Admin Dashboard - GrievancePortal</title>
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

      <!-- Main Content -->
      <div class="col-md-9 col-lg-10 p-4">
        <h3 class="mb-4"><i class="fas fa-tachometer-alt me-2"></i>Admin Dashboard</h3>

        <div class="row g-4">
          <div class="col-md-4">
            <div class="card shadow text-center">
              <div class="card-body">
                <i class="fas fa-user-tie fa-2x text-primary mb-2"></i>
                <h5>Manage Officials</h5>
                <p class="text-muted small">Add, view, and remove department officials.</p>
                <a href="admin-officials.jsp" class="btn btn-primary btn-sm mt-2">Open</a>
              </div>
            </div>
          </div>
          <div class="col-md-4">
            <div class="card shadow text-center">
              <div class="card-body">
                <i class="fas fa-users fa-2x text-success mb-2"></i>
                <h5>Manage Users</h5>
                <p class="text-muted small">View and control registered citizen users.</p>
                <a href="admin-users.jsp" class="btn btn-success btn-sm mt-2">Open</a>
              </div>
            </div>
          </div>
          <div class="col-md-4">
            <div class="card shadow text-center">
              <div class="card-body">
                <i class="fas fa-list-alt fa-2x text-warning mb-2"></i>
                <h5>All Grievances</h5>
                <p class="text-muted small">View grievances across all departments.</p>
                <a href="admin-grievances.jsp" class="btn btn-warning btn-sm mt-2">Open</a>
              </div>
            </div>
          </div>
          <div class="col-md-4">
            <div class="card shadow text-center">
              <div class="card-body">
                <i class="fas fa-chart-pie fa-2x text-info mb-2"></i>
                <h5>Department Reports</h5>
                <p class="text-muted small">Analytics of grievances across departments.</p>
                <a href="admin-reports.jsp" class="btn btn-info btn-sm mt-2">Open</a>
              </div>
            </div>
          </div>
          <div class="col-md-4">
            <div class="card shadow text-center">
              <div class="card-body">
                <i class="fas fa-history fa-2x text-danger mb-2"></i>
                <h5>Activity Logs</h5>
                <p class="text-muted small">Track official login & grievance updates.</p>
                <a href="admin-logs.jsp" class="btn btn-danger btn-sm mt-2">Open</a>
              </div>
            </div>
          </div>
          <div class="col-md-4">
            <div class="card shadow text-center">
              <div class="card-body">
                <i class="fas fa-envelope fa-2x text-secondary mb-2"></i>
                <h5>Citizens Feedbacks</h5>
                <p class="text-muted small">System feedback and ratting information.</p>
                <a href="admin-help.jsp" class="btn btn-secondary btn-sm mt-2">Open</a>
              </div>
            </div>
          </div>
        </div>

      </div>
    </div>
  </div>
</body>
<jsp:include page="AdminFooter.jsp"/>
</html>
