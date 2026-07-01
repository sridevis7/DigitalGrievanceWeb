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

    // ✅ Load logs for this official
    class LogEntry {
        int id; String action; Timestamp logTime;
    }
    List<LogEntry> logs = new ArrayList<>();

    try (Connection con = DBConnection.getConnection()) {
        PreparedStatement ps = con.prepareStatement(
            "SELECT id, action, log_time FROM official_logs WHERE official_name=? AND department=? ORDER BY log_time DESC"
        );
        ps.setString(1, officialName);
        ps.setString(2, department);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            LogEntry log = new LogEntry();
            log.id = rs.getInt("id");
            log.action = rs.getString("action");
            log.logTime = rs.getTimestamp("log_time");
            logs.add(log);
        }
    } catch (Exception e) { e.printStackTrace(); }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>My Logs - GrievancePortal</title>
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
          <a class="nav-link" href="official-grievances.jsp"><i class="fas fa-list-alt me-2"></i>Department Grievances</a>
          <a class="nav-link" href="official-logs.jsp"><i class="fas fa-history me-2"></i>Logs</a>
          <a class="nav-link" href="official-reports.jsp"><i class="fas fa-chart-bar me-2"></i>Reports</a>
          
        </div>
      </div>

      <!-- Main Content -->
      <div class="col-md-9 col-lg-10 p-4">
        <h3 class="mb-3"><i class="fas fa-history me-2"></i>My Activity Logs</h3>

        <div class="card shadow">
          <div class="card-body table-responsive">
            <table class="table table-bordered table-hover">
              <thead class="table-light">
                <tr>
                  <th>Log ID</th>
                  <th>Action</th>
                  <th>Time</th>
                </tr>
              </thead>
              <tbody>
                <% if (logs.isEmpty()) { %>
                  <tr><td colspan="3" class="text-center">No logs found.</td></tr>
                <% } else {
                     for (LogEntry log : logs) { %>
                  <tr>
                    <td><%= log.id %></td>
                    <td><%= log.action %></td>
                    <td><%= log.logTime %></td>
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
