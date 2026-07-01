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

    String msg = "";

    // ✅ Handle grievance status update
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String grievanceId = request.getParameter("grievanceId");
        String newStatus = request.getParameter("status");

        if (grievanceId != null && newStatus != null) {
            try (Connection con = DBConnection.getConnection()) {
                PreparedStatement ps = con.prepareStatement(
                    "UPDATE grievances SET status=? WHERE id=? AND department=?"
                );
                ps.setString(1, newStatus);
                ps.setInt(2, Integer.parseInt(grievanceId));
                ps.setString(3, department);

                int updated = ps.executeUpdate();
                if (updated > 0) {
                    msg = "Grievance #" + grievanceId + " updated to " + newStatus;

                    PreparedStatement logPs = con.prepareStatement(
                        "INSERT INTO official_logs (official_name, department, action) VALUES (?,?,?)"
                    );
                    logPs.setString(1, officialName);
                    logPs.setString(2, department);
                    logPs.setString(3, "Updated grievance #" + grievanceId + " to " + newStatus);
                    logPs.executeUpdate();
                }
            } catch (Exception e) {
                msg = "Error updating grievance: " + e.getMessage();
                e.printStackTrace();
            }
        }
    }

    // ✅ Filters
    String filterStatus = request.getParameter("statusFilter");
    String filterPriority = request.getParameter("priorityFilter");

    // ✅ Load grievances
    class Grievance {
        int id; String subject; String category; String priority;
        String status; String userEmail; Timestamp createdAt;
        boolean hasAttachment;
    }
    List<Grievance> grievances = new ArrayList<>();

    try (Connection con = DBConnection.getConnection()) {
        StringBuilder sql = new StringBuilder(
            "SELECT id, subject, category, priority, status, user_email, created_at, attachment " +
            "FROM grievances WHERE department=?"
        );

        if (filterStatus != null && !filterStatus.isEmpty()) {
            sql.append(" AND status='").append(filterStatus).append("'");
        }
        if (filterPriority != null && !filterPriority.isEmpty()) {
            sql.append(" AND priority='").append(filterPriority).append("'");
        }
        sql.append(" ORDER BY created_at DESC");

        PreparedStatement ps = con.prepareStatement(sql.toString());
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
            g.hasAttachment = (rs.getBytes("attachment") != null);
            grievances.add(g);
        }
    } catch (Exception e) { e.printStackTrace(); }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Department Grievances - GrievancePortal</title>
  <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
  <style>
    body { background-color: #f8f9fa; }
    .sidebar { background: #fff; min-height: 100vh; border-right: 1px solid #ddd; }
    .sidebar .nav-link { color: #333; }
    .sidebar .nav-link.active { background: #0d6efd; color: #fff; }
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
          <a class="nav-link active" href="official-grievances.jsp"><i class="fas fa-list-alt me-2"></i>Department Grievances</a>
          <a class="nav-link" href="official-logs.jsp"><i class="fas fa-history me-2"></i>Logs</a>
          <a class="nav-link" href="official-reports.jsp"><i class="fas fa-chart-bar me-2"></i>Reports</a>
          
        </div>
      </div>

      <!-- Main Content -->
      <div class="col-md-9 col-lg-10 p-4">
        <h3 class="mb-3"><i class="fas fa-list-alt me-2"></i>Department Grievances</h3>

        <% if (!msg.isEmpty()) { %>
          <div class="alert alert-info"><%= msg %></div>
        <% } %>

        <!-- Filters -->
        <form method="get" class="row g-3 mb-3">
          <div class="col-md-4">
            <select name="statusFilter" class="form-select">
              <option value="">All Statuses</option>
              <option value="Pending" <%= "Pending".equals(filterStatus) ? "selected" : "" %>>Pending</option>
              <option value="Processing" <%= "Processing".equals(filterStatus) ? "selected" : "" %>>Processing</option>
              <option value="In Progress" <%= "In Progress".equals(filterStatus) ? "selected" : "" %>>In Progress</option>
              <option value="Resolved" <%= "Resolved".equals(filterStatus) ? "selected" : "" %>>Resolved</option>
            </select>
          </div>
          <div class="col-md-4">
            <select name="priorityFilter" class="form-select">
              <option value="">All Priorities</option>
              <option value="Low" <%= "Low".equals(filterPriority) ? "selected" : "" %>>Low</option>
              <option value="Medium" <%= "Medium".equals(filterPriority) ? "selected" : "" %>>Medium</option>
              <option value="High" <%= "High".equals(filterPriority) ? "selected" : "" %>>High</option>
              <option value="Urgent" <%= "Urgent".equals(filterPriority) ? "selected" : "" %>>Urgent</option>
            </select>
          </div>
          <div class="col-md-4 d-grid">
            <button type="submit" class="btn btn-primary"><i class="fas fa-filter me-2"></i>Apply Filters</button>
          </div>
        </form>

        <!-- Grievance Table -->
        <div class="card shadow">
          <div class="card-body table-responsive">
            <table class="table table-bordered table-hover">
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
</body>
</html>
