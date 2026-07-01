<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*,java.util.*,com.grievanceportal.db.DBConnection" %>
<%@ page session="true" %>
<%
    String adminUser = (String) session.getAttribute("adminUser");
    if (adminUser == null) {
        response.sendRedirect("admin-login.jsp");
        return;
    }

    // ===== FEEDBACK SUMMARY BY DEPARTMENT =====
    class DeptSummary {
        String department;
        double avgRating;
        int totalFeedbacks;
    }
    List<DeptSummary> summaries = new ArrayList<>();

    try (Connection con = DBConnection.getConnection()) {
        PreparedStatement ps = con.prepareStatement(
            "SELECT g.department, AVG(f.rating) AS avg_rating, COUNT(*) AS total " +
            "FROM feedback f JOIN grievances g ON f.grievance_id=g.id " +
            "GROUP BY g.department ORDER BY avg_rating DESC"
        );
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            DeptSummary ds = new DeptSummary();
            ds.department = rs.getString("department");
            ds.avgRating = rs.getDouble("avg_rating");
            ds.totalFeedbacks = rs.getInt("total");
            summaries.add(ds);
        }
    } catch(Exception e){ e.printStackTrace(); }

    // ===== ALL FEEDBACKS =====
    class Feedback {
        int id, rating, grievanceId;
        String userEmail, comments, subject, department;
        Timestamp createdAt;
    }
    List<Feedback> feedbacks = new ArrayList<>();

    try (Connection con = DBConnection.getConnection()) {
        PreparedStatement ps = con.prepareStatement(
            "SELECT f.id, f.grievance_id, f.user_email, f.rating, f.comments, f.created_at, " +
            "       g.subject, g.department " +
            "FROM feedback f JOIN grievances g ON f.grievance_id=g.id " +
            "ORDER BY f.created_at DESC"
        );
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Feedback fb = new Feedback();
            fb.id = rs.getInt("id");
            fb.grievanceId = rs.getInt("grievance_id");
            fb.userEmail = rs.getString("user_email");
            fb.rating = rs.getInt("rating");
            fb.comments = rs.getString("comments");
            fb.createdAt = rs.getTimestamp("created_at");
            fb.subject = rs.getString("subject");
            fb.department = rs.getString("department");
            feedbacks.add(fb);
        }
    } catch(Exception e){ e.printStackTrace(); }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Admin - User Feedbacks</title>
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
        <h3><i class="fas fa-star me-2"></i>User Feedbacks</h3>

        <!-- Summary -->
        <div class="card shadow-sm mb-4">
          <div class="card-header bg-primary text-white fw-bold">Feedback Summary by Department</div>
          <div class="card-body table-responsive">
            <table class="table table-sm table-bordered">
              <thead class="table-light">
                <tr>
                  <th>Department</th>
                  <th>Average Rating</th>
                  <th>Total Feedbacks</th>
                </tr>
              </thead>
              <tbody>
                <% if (summaries.isEmpty()) { %>
                  <tr><td colspan="3" class="text-center">No feedback yet.</td></tr>
                <% } else {
                     for (DeptSummary ds : summaries) { %>
                  <tr>
                    <td><%= ds.department %></td>
                    <td>
                      <span class="stars">
                        <% for (int i=1; i<=Math.round(ds.avgRating); i++) { %>★<% } %>
                        <% for (int i=(int)Math.round(ds.avgRating)+1; i<=5; i++) { %>☆<% } %>
                      </span>
                      ( <%= String.format("%.2f", ds.avgRating) %> )
                    </td>
                    <td><%= ds.totalFeedbacks %></td>
                  </tr>
                <% }} %>
              </tbody>
            </table>
          </div>
        </div>

        <!-- All Feedbacks -->
        <div class="card shadow-sm">
          <div class="card-header bg-secondary text-white fw-bold">All Feedbacks</div>
          <div class="card-body table-responsive">
            <table class="table table-bordered table-hover">
              <thead class="table-light">
                <tr>
                  <th>ID</th>
                  <th>Grievance</th>
                  <th>Department</th>
                  <th>User Email</th>
                  <th>Rating</th>
                  <th>Comments</th>
                  <th>Date</th>
                </tr>
              </thead>
              <tbody>
                <% if (feedbacks.isEmpty()) { %>
                  <tr><td colspan="7" class="text-center">No feedback submitted yet.</td></tr>
                <% } else {
                     for (Feedback fb : feedbacks) { %>
                  <tr>
                    <td><%= fb.id %></td>
                    <td>#GRV<%= fb.grievanceId %> - <%= fb.subject %></td>
                    <td><%= fb.department %></td>
                    <td><%= fb.userEmail %></td>
                    <td>
                      <span class="stars">
                        <% for (int i=1; i<=fb.rating; i++) { %>★<% } %>
                        <% for (int i=fb.rating+1; i<=5; i++) { %>☆<% } %>
                      </span>
                    </td>
                    <td><%= fb.comments %></td>
                    <td><%= fb.createdAt %></td>
                  </tr>
                <% }} %>
              </tbody>
            </table>
          </div>
        </div>

      </div>
    </div>
  </div>
              <jsp:include page="AdminFooter.jsp"/>
</body>
</html>
