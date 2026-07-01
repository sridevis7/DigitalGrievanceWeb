<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>
<%@ page session="true" %>
<%
    String userName = (String) session.getAttribute("userName");
    if (userName == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>File Grievance - Digital Grievance Platform</title>
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
        <h2 class="mb-4"><i class="fas fa-edit me-2"></i>File a Grievance</h2>

        <!-- Grievance Form -->
        <div class="row">
          <div class="col-lg-8">
            <div class="card shadow-sm">
              <div class="card-header">
                <h5 class="mb-0"><i class="fas fa-edit me-2"></i>Grievance Details</h5>
              </div>
              <div class="card-body">
                <form action="FileGrievanceServlet" method="POST" enctype="multipart/form-data" novalidate>
                  <!-- Subject -->
                  <div class="mb-3">
                    <label for="subject" class="form-label">Subject <span class="text-danger">*</span></label>
                    <input type="text" class="form-control" id="subject" name="subject" placeholder="Brief description of your grievance" required maxlength="200">
                    <div class="form-text">Be specific and concise (max 200 characters)</div>
                  </div>

                  <!-- Category & Priority -->
                  <div class="row">
                    <div class="col-md-6 mb-3">
                      <label for="category" class="form-label">Category <span class="text-danger">*</span></label>
                      <select class="form-select" id="category" name="category" required>
                        <option value="">Select Category</option>
                        <option value="Infrastructure">Infrastructure</option>
                        <option value="Public Safety">Public Safety</option>
                        <option value="Sanitation">Sanitation & Hygiene</option>
                        <option value="Roads">Roads & Transportation</option>
                        <option value="Water Supply">Water Supply</option>
                        <option value="Electricity">Electricity</option>
                        <option value="Healthcare">Healthcare</option>
                        <option value="Education">Education</option>
                        <option value="Environment">Environment</option>
                        <option value="Corruption">Anti-Corruption</option>
                        <option value="Other">Other</option>
                      </select>
                    </div>
                    <div class="col-md-6 mb-3">
                      <label for="priority" class="form-label">Priority <span class="text-danger">*</span></label>
                      <select class="form-select" id="priority" name="priority" required>
                        <option value="">Select Priority</option>
                        <option value="Low">Low</option>
                        <option value="Medium">Medium</option>
                        <option value="High">High</option>
                        <option value="Urgent">Urgent</option>
                      </select>
                    </div>
                  </div>

                  <!-- Department -->
                  <div class="mb-3">
                    <label for="department" class="form-label">Department <span class="text-danger">*</span></label>
                    <select class="form-select" id="department" name="department" required>
                      <option value="">Select Department</option>
                      <option value="Municipal Corporation">Municipal Corporation</option>
                      <option value="Public Works Department">Public Works Department</option>
                      <option value="Health Department">Health Department</option>
                      <option value="Education Department">Education Department</option>
                      <option value="Police Department">Police Department</option>
                      <option value="Fire Service">Fire Service</option>
                      <option value="Electricity Board">Electricity Board</option>
                      <option value="Water Board">Water Board</option>
                      <option value="Transport Department">Transport Department</option>
                      <option value="Environment Department">Environment Department</option>
                    </select>
                  </div>

                  <!-- Location -->
                  <div class="row">
                    <div class="col-md-6 mb-3">
                      <label for="state" class="form-label">State <span class="text-danger">*</span></label>
                      <select class="form-select" id="state" name="state" required>
                        <option value="">Select State</option>
                        <option value="TN">Tamil Nadu</option>
                        <option value="AP">Andhra Pradesh</option>
                        <option value="KA">Karnataka</option>
                        <option value="KL">Kerala</option>
                        <option value="MH">Maharashtra</option>
                        <option value="GJ">Gujarat</option>
                        <option value="RJ">Rajasthan</option>
                        <option value="UP">Uttar Pradesh</option>
                        <option value="MP">Madhya Pradesh</option>
                        <option value="WB">West Bengal</option>
                      </select>
                    </div>
                    <div class="col-md-6 mb-3">
                      <label for="district" class="form-label">District <span class="text-danger">*</span></label>
                      <input type="text" class="form-control" id="district" name="district" placeholder="Enter district name" required>
                    </div>
                  </div>

                  <div class="mb-3">
                    <label for="location" class="form-label">Specific Location <span class="text-danger">*</span></label>
                    <textarea class="form-control" id="location" name="location" rows="2" required></textarea>
                  </div>

                  <!-- Description -->
                  <div class="mb-3">
                    <label for="description" class="form-label">Detailed Description <span class="text-danger">*</span></label>
                    <textarea class="form-control" id="description" name="description" rows="6" required></textarea>
                  </div>

                  <!-- Expected Resolution -->
                  <div class="mb-3">
                    <label for="expectedResolution" class="form-label">Expected Resolution</label>
                    <textarea class="form-control" id="expectedResolution" name="expectedResolution" rows="3"></textarea>
                  </div>

                  <!-- File Attachments -->
                  <div class="mb-3">
                    <label for="attachments" class="form-label">Attachments</label>
                    <input type="file" class="form-control" id="attachments" name="attachments" multiple>
                  </div>

                  <!-- Terms -->
                  <div class="form-check mb-3">
                    <input class="form-check-input" type="checkbox" id="terms" name="terms" required>
                    <label class="form-check-label" for="terms">
                      I confirm that the information provided is accurate and agree to the <a href="#">Terms of Service</a>
                    </label>
                  </div>

                  <!-- Submit Buttons -->
                  <div class="d-flex justify-content-between">
                    <a href="dashboard.jsp" class="btn btn-outline-secondary"><i class="fas fa-arrow-left me-2"></i>Cancel</a>
                    <button type="submit" class="btn btn-primary"><i class="fas fa-paper-plane me-2"></i>Submit Grievance</button>
                  </div>
                </form>
              </div>
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
