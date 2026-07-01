<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*,java.util.*,com.grievanceportal.db.DBConnection" %>
<%@ page session="true" %>
<%
    String adminUser = (String) session.getAttribute("adminUser");
    if (adminUser == null) {
        response.sendRedirect("admin-login.jsp");
        return;
    }

    // ✅ Maps to hold counts
    Map<String,Integer> deptCounts = new LinkedHashMap<>();
    Map<String,Integer> statusCounts = new LinkedHashMap<>();
    Map<String,Integer> priorityCounts = new LinkedHashMap<>();

    // ✅ Recent grievances
    class Grievance {
        int id; String subject; String dept; String status; String priority; Timestamp createdAt;
    }
    java.util.List<Grievance> recentList = new java.util.ArrayList<>();

    try (Connection con = DBConnection.getConnection()) {
        // Department count
        Statement st1 = con.createStatement();
        ResultSet rs1 = st1.executeQuery("SELECT department, COUNT(*) AS cnt FROM grievances GROUP BY department");
        while (rs1.next()) {
            deptCounts.put(rs1.getString("department"), rs1.getInt("cnt"));
        }

        // Status count
        Statement st2 = con.createStatement();
        ResultSet rs2 = st2.executeQuery("SELECT status, COUNT(*) AS cnt FROM grievances GROUP BY status");
        while (rs2.next()) {
            statusCounts.put(rs2.getString("status"), rs2.getInt("cnt"));
        }

        // Priority count
        Statement st3 = con.createStatement();
        ResultSet rs3 = st3.executeQuery("SELECT priority, COUNT(*) AS cnt FROM grievances GROUP BY priority");
        while (rs3.next()) {
            priorityCounts.put(rs3.getString("priority"), rs3.getInt("cnt"));
        }

        // Recent grievances
        Statement st4 = con.createStatement();
        ResultSet rs4 = st4.executeQuery("SELECT id, subject, department, status, priority, created_at FROM grievances ORDER BY created_at DESC LIMIT 10");
        while (rs4.next()) {
            Grievance g = new Grievance();
            g.id = rs4.getInt("id");
            g.subject = rs4.getString("subject");
            g.dept = rs4.getString("department");
            g.status = rs4.getString("status");
            g.priority = rs4.getString("priority");
            g.createdAt = rs4.getTimestamp("created_at");
            recentList.add(g);
        }
    } catch (Exception e) { e.printStackTrace(); }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Reports - Admin Panel</title>
 <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
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
        <h3 class="mb-4"><i class="fas fa-chart-bar me-2"></i>Reports & Analytics</h3>

        <!-- Charts -->
        <div class="row g-4 mb-4">
          <div class="col-md-6">
            <div class="chart-container">
              <h6>Department Distribution</h6>
              <canvas id="deptChart"></canvas>
            </div>
          </div>
          <div class="col-md-6">
            <div class="chart-container">
              <h6>Status Distribution</h6>
              <canvas id="statusChart"></canvas>
            </div>
          </div>
          <div class="col-md-6">
            <div class="chart-container">
              <h6>Priority Distribution</h6>
              <canvas id="priorityChart"></canvas>
            </div>
          </div>
        </div>

        <!-- Tables -->
        <div class="row g-4">
          <div class="col-md-4">
            <div class="card shadow">
              <div class="card-header">By Department</div>
              <div class="card-body p-0">
                <table class="table table-bordered mb-0">
                  <tbody>
                  <% for (Map.Entry<String,Integer> e : deptCounts.entrySet()) { %>
                    <tr><td><%= e.getKey() %></td><td><%= e.getValue() %></td></tr>
                  <% } %>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
          <div class="col-md-4">
            <div class="card shadow">
              <div class="card-header">By Status</div>
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
              <div class="card-header">By Priority</div>
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
                  <th>Department</th>
                  <th>Status</th>
                  <th>Priority</th>
                  <th>Date</th>
                </tr>
              </thead>
              <tbody>
              <% for (Grievance g : recentList) { %>
                <tr>
                  <td>#GRV<%= g.id %></td>
                  <td><%= g.subject %></td>
                  <td><%= g.dept %></td>
                  <td><%= g.status %></td>
                  <td><%= g.priority %></td>
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
    // Department Chart
    new Chart(document.getElementById("deptChart"), {
      type: 'bar',
      data: {
        labels: [<% for(String k : deptCounts.keySet()){ %> "<%= k %>", <% } %>],
        datasets: [{
          label: "Grievances",
          data: [<% for(int v : deptCounts.values()){ %> <%= v %>, <% } %>],
          backgroundColor: '#0d6efd'
        }]
      }
    });

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
      type: 'doughnut',
      data: {
        labels: [<% for(String k : priorityCounts.keySet()){ %> "<%= k %>", <% } %>],
        datasets: [{
          data: [<% for(int v : priorityCounts.values()){ %> <%= v %>, <% } %>],
          backgroundColor: ['#198754','#0d6efd','#fd7e14','#dc3545']
        }]
      }
    });
  </script>
  <jsp:include page="AdminFooter.jsp"/>
</body>
</html>
