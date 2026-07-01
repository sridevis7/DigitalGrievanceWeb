<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*,java.util.*,com.grievanceportal.db.DBConnection" %>
<%@ page session="true" %>
<%
    String officialName = (String) session.getAttribute("officialName");
    String department = (String) session.getAttribute("department");

    if (officialName == null) {
        response.sendRedirect("official-login.jsp");
        return;
    }

    // Load grievances for this department
    class Grievance {
        int id; String subject; String category; String priority;
        String status; String userEmail; Timestamp createdAt;
        boolean hasAttachment;
    }
    List<Grievance> grievances = new ArrayList<>();

    try (Connection con = DBConnection.getConnection()) {
        PreparedStatement ps = con.prepareStatement(
            "SELECT id, subject, category, priority, status, user_email, created_at, official_attachment " +
            "FROM grievances WHERE department=? AND status <> 'Resolved' ORDER BY created_at DESC"
        );
        ps.setString(1, department);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Grievance g = new Grievance();
            g.id = rs.getInt("id");
            g.subject = rs.getString("subject");
            g.category = rs.getString("category");
            g.priority = rs.getString("priority");
            g.status = rs.getString("status");
            g.userEmail = rs.getString("user_email");
            g.createdAt = rs.getTimestamp("created_at");
            g.hasAttachment = (rs.getString("official_attachment") != null);
            grievances.add(g);
        }
    } catch (Exception e) { e.printStackTrace(); }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Official Dashboard - GrievancePortal</title>
  <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
  <style>
    body { background-color: #f8f9fa; }
    .sidebar { background: #fff; min-height: 100vh; border-right: 1px solid #ddd; }
    .sidebar .nav-link { color: #333; }
    .sidebar .nav-link.active { background: #0d6efd; color: #fff; }
    textarea { resize: vertical; }
  </style>
</head>
<body>
  <!-- Navbar -->
  <nav class="navbar navbar-dark bg-danger">
    <div class="container-fluid">
      <a class="navbar-brand fw-bold"><i class="fas fa-user-tie me-2"></i>Official Portal</a>
      <span class="text-white">Welcome, <%= officialName %> (<%= department %>)</span>
      <a href="logout.jsp" class="btn btn-outline-light btn-sm ms-3"><i class="fas fa-sign-out-alt"></i> Logout</a>
    </div>
  </nav>

  <div class="container-fluid">
    <div class="row">
      <!-- Sidebar -->
      <div class="col-md-3 col-lg-2 sidebar p-3">
        <div class="nav flex-column nav-pills">
          <a class="nav-link" href="official-dashboard.jsp"><i class="fas fa-home me-2"></i>Dashboard</a>
          <a class="nav-link" href="official-grievances.jsp"><i class="fas fa-list-alt me-2"></i>Department Grievances</a>
          <a class="nav-link" href="official-logs.jsp"><i class="fas fa-history me-2"></i>Logs</a>
          <a class="nav-link" href="official-reports.jsp"><i class="fas fa-chart-bar me-2"></i>Reports</a>
          
        </div>
      </div>

      <!-- Main Content -->
      <div class="col-md-9 col-lg-10 p-4">
        <h3 class="mb-3"><i class="fas fa-briefcase me-2"></i>Department Grievances</h3>

        <% String msg = request.getParameter("msg");
           if (msg != null) { %>
          <div class="alert alert-info"><%= msg %></div>
        <% } %>

        <div class="card shadow">
          <div class="card-body table-responsive">
            <table class="table table-bordered table-hover align-middle">
              <thead class="table-light">
                <tr>
                  <th>ID</th>
                  <th>Subject</th>
                  <th>Category</th>
                  <th>Priority</th>
                  <th>Status</th>
                  <th>User</th>
                  <th>Date</th>
                  <th>Attachment</th>
                  <th style="width:250px;">Action</th>
                </tr>
              </thead>
              <tbody>
                <% if (grievances.isEmpty()) { %>
                  <tr><td colspan="9" class="text-center">No grievances found for your department.</td></tr>
                <% } else {
                     for (Grievance g : grievances) { %>
                  <tr>
                    <td>#GRV<%= g.id %></td>
                    <td><%= g.subject %></td>
                    <td><%= g.category %></td>
                    <td><%= g.priority %></td>
                    <td><%= g.status %></td>
                    <td><%= g.userEmail %></td>
                    <td><%= g.createdAt %></td>
                    <td>
                      <% if (g.hasAttachment) { %>
                        <a href="DownloadAttachmentServlet?id=<%= g.id %>" class="btn btn-sm btn-outline-primary">
                          <i class="fas fa-file-download"></i> View
                        </a>
                      <% } else { %>
                        <span class="text-muted">No</span>
                      <% } %>
                    </td>
                    <td>
                      <form action="UpdateGrievanceServlet" method="post" enctype="multipart/form-data" class="d-flex flex-column">
                        <input type="hidden" name="grievanceId" value="<%= g.id %>">

                        <select name="status" class="form-select form-select-sm mb-2" required>
                          <option <%= g.status.equals("Pending") ? "selected" : "" %>>Pending</option>
                          <option <%= g.status.equals("Processing") ? "selected" : "" %>>Processing</option>
                          <option <%= g.status.equals("In Progress") ? "selected" : "" %>>In Progress</option>
                          <option <%= g.status.equals("Resolved") ? "selected" : "" %>>Resolved</option>
                        </select>

                        <textarea  name="remark" class="form-control form-control-sm mb-2" placeholder="Enter remark..." required=""></textarea>

                        <input type="file" name="attachment" class="form-control form-control-sm mb-2">

                        <button type="submit" class="btn btn-sm btn-primary">Update</button>
                      </form>
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
              <!-- Footer -->
  <footer class="py-4 text-center bg-dark">
    <p class="mb-0 text-white">&copy; 2025 Digital Grievance Platform</p>
  </footer>
</body>
</html>