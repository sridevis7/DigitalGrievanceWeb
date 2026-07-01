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
        int id; String subject; String department; Timestamp createdAt;
        boolean feedbackGiven;
    }
    List<Grievance> grievances = new ArrayList<>();

    try (Connection con = DBConnection.getConnection()) {
        PreparedStatement ps = con.prepareStatement(
            "SELECT g.id, g.subject, g.department, g.created_at, " +
            "       (SELECT COUNT(*) FROM feedback f WHERE f.grievance_id=g.id) AS has_feedback " +
            "FROM grievances g WHERE g.user_email=? AND g.status='Resolved' ORDER BY g.created_at DESC"
        );
        ps.setString(1, userEmail);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Grievance g = new Grievance();
            g.id = rs.getInt("id");
            g.subject = rs.getString("subject");
            g.department = rs.getString("department");
            g.createdAt = rs.getTimestamp("created_at");
            g.feedbackGiven = rs.getInt("has_feedback") > 0;
            grievances.add(g);
        }
    } catch(Exception e){ e.printStackTrace(); }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Feedback - GrievancePortal</title>
  <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
  <style>
    body { background-color: #f8f9fa; }
    .sidebar { background: #fff; min-height: 100vh; border-right: 1px solid #ddd; }
    .sidebar .nav-link.active { background: #0d6efd; color: #fff; }
    .star-rating input { display: none; }
    .star-rating label { font-size: 1.2rem; color: #ccc; cursor: pointer; }
    .star-rating input:checked ~ label, 
    .star-rating label:hover, 
    .star-rating label:hover ~ label { color: #f39c12; }
  </style>
</head>
<body>
  <!-- Navbar -->
  <nav class="navbar navbar-expand-lg navbar-dark bg-primary fixed-top shadow-sm">
    <div class="container-fluid">
      <a class="navbar-brand fw-bold" href="dashboard.jsp"><i class="fas fa-balance-scale me-2"></i>GrievancePortal</a>
      <span class="text-white">Welcome, <%= userName %></span>
      <a href="logout.jsp" class="btn btn-outline-light btn-sm ms-3"><i class="fas fa-sign-out-alt"></i> Logout</a>
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
        <h2 class="mb-4"><i class="fas fa-star me-2"></i>Give Feedback</h2>

        <div class="card shadow-sm">
          <div class="card-body">
            <% if (grievances.isEmpty()) { %>
              <div class="alert alert-info">No resolved grievances available for feedback.</div>
            <% } else { %>
              <table class="table table-hover">
                <thead class="table-light">
                  <tr>
                    <th>ID</th>
                    <th>Subject</th>
                    <th>Department</th>
                    <th>Date</th>
                    <th>Feedback</th>
                  </tr>
                </thead>
                <tbody>
                  <% for (Grievance g : grievances) { %>
                  <tr>
                    <td>#GRV<%= g.id %></td>
                    <td><%= g.subject %></td>
                    <td><%= g.department %></td>
                    <td><%= g.createdAt %></td>
                    <td>
                      <% if (g.feedbackGiven) { %>
                        <span class="text-success"><i class="fas fa-check-circle"></i> Submitted</span>
                      <% } else { %>
                        <form action="SubmitFeedbackServlet" method="post" class="d-flex flex-column">
                          <input type="hidden" name="grievanceId" value="<%= g.id %>">
                          <div class="star-rating mb-2">
                            <input type="radio" id="star5_<%= g.id %>" name="rating" value="5"><label for="star5_<%= g.id %>">&#9733;</label>
                            <input type="radio" id="star4_<%= g.id %>" name="rating" value="4"><label for="star4_<%= g.id %>">&#9733;</label>
                            <input type="radio" id="star3_<%= g.id %>" name="rating" value="3"><label for="star3_<%= g.id %>">&#9733;</label>
                            <input type="radio" id="star2_<%= g.id %>" name="rating" value="2"><label for="star2_<%= g.id %>">&#9733;</label>
                            <input type="radio" id="star1_<%= g.id %>" name="rating" value="1"><label for="star1_<%= g.id %>">&#9733;</label>
                          </div>
                          <textarea name="comments" class="form-control form-control-sm mb-2" placeholder="Write your feedback..."></textarea>
                          <button type="submit" class="btn btn-sm btn-primary">Submit</button>
                        </form>
                      <% } %>
                    </td>
                  </tr>
                  <% } %>
                </tbody>
              </table>
            <% } %>
          </div>
        </div>
      </div>
    </div>
  </div>
            <!-- Footer -->
  <footer class="py-3 text-center mt-4">
    <p class="mb-0">&copy; 2025 Digital Grievance Platform</p>
  </footer>
</body>
</html>
