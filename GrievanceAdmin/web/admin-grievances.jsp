<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*,java.util.*,com.grievanceportal.db.DBConnection" %>
<%@ page session="true" %>
<%
    String adminUser = (String) session.getAttribute("adminUser");
    if (adminUser == null) {
        response.sendRedirect("admin-login.jsp");
        return;
    }

    String msg = "";

    // ✅ Handle status update
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String grievanceId = request.getParameter("grievanceId");
        String newStatus = request.getParameter("status");

        if (grievanceId != null && newStatus != null) {
            try (Connection con = DBConnection.getConnection()) {
                PreparedStatement ps = con.prepareStatement(
                    "UPDATE grievances SET status=? WHERE id=?"
                );
                ps.setString(1, newStatus);
                ps.setInt(2, Integer.parseInt(grievanceId));
                int updated = ps.executeUpdate();
                if (updated > 0) {
                    msg = "Grievance #" + grievanceId + " updated to " + newStatus;
                }
            } catch (Exception e) {
                msg = "Error updating grievance: " + e.getMessage();
                e.printStackTrace();
            }
        }
    }

    // ✅ Filters
    String filterDept = request.getParameter("departmentFilter");
    String filterStatus = request.getParameter("statusFilter");
    String filterPriority = request.getParameter("priorityFilter");

    // ✅ Load grievances
    class Grievance {
        int id; String subject; String category; String priority;
        String status; String userEmail; String department; Timestamp createdAt;
        boolean hasAttachment;
    }
    List<Grievance> grievances = new ArrayList<>();

    try (Connection con = DBConnection.getConnection()) {
        StringBuilder sql = new StringBuilder(
            "SELECT id, subject, category, priority, status, user_email, department, created_at, attachment " +
            "FROM grievances WHERE 1=1"
        );

        if (filterDept != null && !filterDept.isEmpty()) {
            sql.append(" AND department='").append(filterDept).append("'");
        }
        if (filterStatus != null && !filterStatus.isEmpty()) {
            sql.append(" AND status='").append(filterStatus).append("'");
        }
        if (filterPriority != null && !filterPriority.isEmpty()) {
            sql.append(" AND priority='").append(filterPriority).append("'");
        }
        sql.append(" ORDER BY created_at DESC");

        PreparedStatement ps = con.prepareStatement(sql.toString());
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Grievance g = new Grievance();
            g.id = rs.getInt("id");
            g.subject = rs.getString("subject");
            g.category = rs.getString("category");
            g.priority = rs.getString("priority");
            g.status = rs.getString("status");
            g.userEmail = rs.getString("user_email");
            g.department = rs.getString("department");
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

      <!-- Main Content -->
      <div class="col-md-9 col-lg-10 p-4">
        <h3 class="mb-3"><i class="fas fa-list-alt me-2"></i>All Grievances</h3>

        <% if (!msg.isEmpty()) { %>
          <div class="alert alert-info"><%= msg %></div>
        <% } %>

        <!-- Filters -->
        <form method="get" class="row g-3 mb-3">
          <div class="col-md-3">
            <select name="departmentFilter" class="form-select">
              <option value="">All Departments</option>
              <option value="Municipal Corporation">Municipal Corporation</option>
              <option value="Public Works">Public Works</option>
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
          <div class="col-md-3">
            <select name="statusFilter" class="form-select">
              <option value="">All Statuses</option>
              <option value="Pending">Pending</option>
              <option value="Processing">Processing</option>
              <option value="In Progress">In Progress</option>
              <option value="Resolved">Resolved</option>
            </select>
          </div>
          <div class="col-md-3">
            <select name="priorityFilter" class="form-select">
              <option value="">All Priorities</option>
              <option value="Low">Low</option>
              <option value="Medium">Medium</option>
              <option value="High">High</option>
              <option value="Urgent">Urgent</option>
            </select>
          </div>
          <div class="col-md-3 d-grid">
            <button type="submit" class="btn btn-primary"><i class="fas fa-filter me-2"></i>Apply Filters</button>
          </div>
        </form>

        <!-- Table -->
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
                  <th>Department</th>
                  <th>Date</th>
                  <th>Attachment</th>
                  <th>Action</th>
                </tr>
              </thead>
              <tbody>
                <% if (grievances.isEmpty()) { %>
                  <tr><td colspan="10" class="text-center">No grievances found.</td></tr>
                <% } else {
                     for (Grievance g : grievances) { %>
                  <tr>
                    <td>#GRV<%= g.id %></td>
                    <td><%= g.subject %></td>
                    <td><%= g.category %></td>
                    <td><%= g.priority %></td>
                    <td><%= g.status %></td>
                    <td><%= g.userEmail %></td>
                    <td><%= g.department %></td>
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
                      <form method="post" class="d-flex">
                        <input type="hidden" name="grievanceId" value="<%= g.id %>">
                        <select name="status" class="form-select form-select-sm me-2" required>
                          <option <%= g.status.equals("Pending") ? "selected" : "" %>>Pending</option>
                          <option <%= g.status.equals("Processing") ? "selected" : "" %>>Processing</option>
                          <option <%= g.status.equals("In Progress") ? "selected" : "" %>>In Progress</option>
                          <option <%= g.status.equals("Resolved") ? "selected" : "" %>>Resolved</option>
                        </select>
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
              <jsp:include page="AdminFooter.jsp"/>
</body>
</html>
