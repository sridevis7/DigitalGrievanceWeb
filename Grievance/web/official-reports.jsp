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

    // ✅ Grievance counts
    Map<String,Integer> statusCounts = new LinkedHashMap<>();
    Map<String,Integer> priorityCounts = new LinkedHashMap<>();
    Map<String,Integer> categoryCounts = new LinkedHashMap<>();

    // ✅ Recent grievances
    class Grievance {
        int id; String subject; String status; String priority; String category; Timestamp createdAt;
    }
    java.util.List<Grievance> recentList = new java.util.ArrayList<>();

    try (Connection con = DBConnection.getConnection()) {
        // Status count
        PreparedStatement ps1 = con.prepareStatement("SELECT status, COUNT(*) AS cnt FROM grievances WHERE department=? GROUP BY status");
        ps1.setString(1, department);
        ResultSet rs1 = ps1.executeQuery();
        while (rs1.next()) {
            statusCounts.put(rs1.getString("status"), rs1.getInt("cnt"));
        }

        // Priority count
        PreparedStatement ps2 = con.prepareStatement("SELECT priority, COUNT(*) AS cnt FROM grievances WHERE department=? GROUP BY priority");
        ps2.setString(1, department);
        ResultSet rs2 = ps2.executeQuery();
        while (rs2.next()) {
            priorityCounts.put(rs2.getString("priority"), rs2.getInt("cnt"));
        }

        // Category count
        PreparedStatement ps3 = con.prepareStatement("SELECT category, COUNT(*) AS cnt FROM grievances WHERE department=? GROUP BY category");
        ps3.setString(1, department);
        ResultSet rs3 = ps3.executeQuery();
        while (rs3.next()) {
            categoryCounts.put(rs3.getString("category"), rs3.getInt("cnt"));
        }

        // Recent 10 grievances
        PreparedStatement ps4 = con.prepareStatement(
            "SELECT id, subject, status, priority, category, created_at FROM grievances WHERE department=? ORDER BY created_at DESC LIMIT 10"
        );
        ps4.setString(1, department);
        ResultSet rs4 = ps4.executeQuery();
        while (rs4.next()) {
            Grievance g = new Grievance();
            g.id = rs4.getInt("id");
            g.subject = rs4.getString("subject");
            g.status = rs4.getString("status");
            g.priority = rs4.getString("priority");
            g.category = rs4.getString("category");
            g.createdAt = rs4.getTimestamp("created_at");
            recentList.add(g);
        }
    } catch (Exception e) { e.printStackTrace(); }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Reports - GrievancePortal</title>
  <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
  <style>
    body { background-color: #f8f9fa; }
    .sidebar { background: #fff; min-height: 100vh; border-right: 1px solid #ddd; }
    .sidebar .nav-link { color: #333; }
    .sidebar .nav-link.active { background: #0d6efd; color: #fff; }
    .chart-container { background: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 2px 6px rgba(0,0,0,.1); }
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
          <a class="nav-link active" href="official-reports.jsp"><i class="fas fa-chart-bar me-2"></i>Reports</a>
          
        </div>
      </div>

      <!-- Main Content -->
      <div class="col-md-9 col-lg-10 p-4">
        <h3 class="mb-4"><i class="fas fa-chart-bar me-2"></i>Reports & Analytics</h3>

        <!-- Charts Row -->
        <div class="row g-4 mb-4">
          <div class="col-md-4">
            <div class="chart-container">
              <h6>Status Distribution</h6>
              <canvas id="statusChart"></canvas>
            </div>
          </div>
          <div class="col-md-4">
            <div class="chart-container">
              <h6>Priority Distribution</h6>
              <canvas id="priorityChart"></canvas>
            </div>
          </div>
          <div class="col-md-4">
            <div class="chart-container">
              <h6>Category Distribution</h6>
              <canvas id="categoryChart"></canvas>
            </div>
          </div>
        </div>

        <!-- Tables -->
        <div class="row g-4">
          <div class="col-md-4">
            <div class="card shadow">
              <div class="card-header">Grievances by Status</div>
              <div class="card-body p-0">
                <table class="table table-bordered mb-0">
                  <tbody>
                  <% for (Map.Entry<String,Integer> e : statusCounts.entrySet()) { %>
                    <tr><td><%= e.getKey() %></td><td><%= e.getValue() %></td></tr>
                  <% } %>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
          <div class="col-md-4">
            <div class="card shadow">
              <div class="card-header">Grievances by Priority</div>
              <div class="card-body p-0">
                <table class="table table-bordered mb-0">
                  <tbody>
                  <% for (Map.Entry<String,Integer> e : priorityCounts.entrySet()) { %>
                    <tr><td><%= e.getKey() %></td><td><%= e.getValue() %></td></tr>
                  <% } %>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
          <div class="col-md-4">
            <div class="card shadow">
              <div class="card-header">Grievances by Category</div>
              <div class="card-body p-0">
                <table class="table table-bordered mb-0">
                  <tbody>
                  <% for (Map.Entry<String,Integer> e : categoryCounts.entrySet()) { %>
                    <tr><td><%= e.getKey() %></td><td><%= e.getValue() %></td></tr>
                  <% } %>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>

        <!-- Recent Grievances -->
        <div class="card shadow mt-4">
          <div class="card-header">Recent Grievances</div>
          <div class="card-body p-0">
            <table class="table table-striped mb-0">
              <thead class="table-light">
                <tr>
                  <th>ID</th>
                  <th>Subject</th>
                  <th>Status</th>
                  <th>Priority</th>
                  <th>Category</th>
                  <th>Date</th>
                </tr>
              </thead>
              <tbody>
              <% for (Grievance g : recentList) { %>
                <tr>
                  <td>#GRV<%= g.id %></td>
                  <td><%= g.subject %></td>
                  <td><%= g.status %></td>
                  <td><%= g.priority %></td>
                  <td><%= g.category %></td>
                  <td><%= g.createdAt %></td>
                </tr>
              <% } %>
              </tbody>
            </table>
          </div>
        </div>

      </div>
    </div>
  </div>

  <!-- Charts JS -->
  <script>
    // Status Chart
    new Chart(document.getElementById("statusChart"), {
      type: 'pie',
      data: {
        labels: [<% for(String k : statusCounts.keySet()){ %> "<%= k %>", <% } %>],
        datasets: [{
          data: [<% for(int v : statusCounts.values()){ %> <%= v %>, <% } %>],
          backgroundColor: ['#ffc107','#0dcaf0','#198754','#dc3545']
        }]
      }
    });

    // Priority Chart
    new Chart(document.getElementById("priorityChart"), {
      type: 'bar',
      data: {
        labels: [<% for(String k : priorityCounts.keySet()){ %> "<%= k %>", <% } %>],
        datasets: [{
          label: "Count",
          data: [<% for(int v : priorityCounts.values()){ %> <%= v %>, <% } %>],
          backgroundColor: '#0d6efd'
        }]
      }
    });

    // Category Chart
    new Chart(document.getElementById("categoryChart"), {
      type: 'doughnut',
      data: {
        labels: [<% for(String k : categoryCounts.keySet()){ %> "<%= k %>", <% } %>],
        datasets: [{
          data: [<% for(int v : categoryCounts.values()){ %> <%= v %>, <% } %>],
          backgroundColor: ['#6610f2','#20c997','#fd7e14','#6c757d','#dc3545','#198754']
        }]
      }
    });
  </script>
   <footer class="py-4 text-center bg-dark">
    <p class="mb-0 text-white">&copy; 2025 Digital Grievance Platform</p>
  </footer>
</body>
</html>
