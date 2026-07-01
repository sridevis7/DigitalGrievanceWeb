<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*,com.grievanceportal.db.DBConnection" %>
<%@ page session="true" %>
<%
    String msg = "";
   if ("POST".equalsIgnoreCase(request.getMethod())) {
    String name = request.getParameter("name");
    String department = request.getParameter("department");
    String password = request.getParameter("password");

    boolean validOfficial = false;
    int officialId = 0;

    try (Connection con = DBConnection.getConnection()) {
        PreparedStatement ps = con.prepareStatement(
            "SELECT id FROM officials WHERE name=? AND department=? AND password=?"
        );
        ps.setString(1, name);
        ps.setString(2, department);
        ps.setString(3, password);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            validOfficial = true;
            officialId = rs.getInt("id");
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    if (validOfficial) {
        session.setAttribute("officialId", officialId);
        session.setAttribute("officialName", name);
        session.setAttribute("department", department);

        try (Connection con = DBConnection.getConnection()) {
            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO official_logs (official_name, department, action) VALUES (?,?,?)"
            );
            ps.setString(1, name);
            ps.setString(2, department);
            ps.setString(3, "Logged in");
            ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }

        response.sendRedirect("official-dashboard.jsp");
        return;
    } else {
        msg = "Invalid login. Please check your name, department, and password.";
    }
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Official Login - GrievancePortal</title>
  <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
 <style>
    :root { --bg: #ffffff; --text: #212529; --card-bg: #ffffff; --card-text: #212529; --footer-bg: #111; --footer-text: #ccc; }
    body.dark { --bg: #181818; --text: #f1f1f1; --card-bg: #242424; --card-text: #f1f1f1; --footer-bg: #000; --footer-text: #999; }
    body { background-color: var(--bg); color: var(--text); transition: all 0.3s; }
    .card { background: var(--card-bg); color: var(--card-text); }
    footer { background: var(--footer-bg); color: var(--footer-text); }
    .theme-toggle { border: none; background: transparent; color: white; font-size: 1.2rem; cursor: pointer; transition: 0.3s; }
    .theme-toggle:hover { color: #ffc107; }
  </style>
</head>
<body>
 <jsp:include page="indexNav.jsp"/>

  <section class="d-flex align-items-center justify-content-center" style="padding:120px 0;">
    <div class="container" style="max-width: 450px;">
      <div class="card shadow rounded-4 p-4">
        <h3 class="text-center fw-bold mb-4">Official Login</h3>
        <% if (!msg.isEmpty()) { %>
          <div class="alert alert-danger"><%= msg %></div>
        <% } %>
        <form method="post">
          <!-- Name -->
          <div class="mb-3">
            <label class="form-label">Name</label>
            <input type="text" class="form-control" name="name" placeholder="Enter your name" required>
          </div>
          <!-- Department -->
          <div class="mb-3">
            <label class="form-label">Department</label>
            <select class="form-select" name="department" required>
              <option value="">Select Department</option>
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
          <!-- Password -->
          <div class="mb-3">
            <label class="form-label">Password</label>
            <input type="password" class="form-control" name="password" placeholder="Enter password" required>
          </div>
          <button type="submit" class="btn btn-primary w-100">
            <i class="fas fa-sign-in-alt me-2"></i>Login
          </button>
        </form>
      </div>
    </div>
  </section>

  <!-- Footer -->
  <footer class="py-4 text-center">
    <p class="mb-0">&copy; 2025 Digital Grievance Platform</p>
  </footer>

  <script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/js/bootstrap.bundle.min.js"></script>
  <script>
    const toggleBtn = document.getElementById("themeToggle");
    const body = document.body;
    if(localStorage.getItem("theme") === "dark"){ body.classList.add("dark"); toggleBtn.innerHTML = '<i class="fas fa-sun"></i>'; }
    toggleBtn.addEventListener("click", () => { body.classList.toggle("dark"); if(body.classList.contains("dark")){ localStorage.setItem("theme","dark"); toggleBtn.innerHTML = '<i class="fas fa-sun"></i>'; } else { localStorage.setItem("theme","light"); toggleBtn.innerHTML = '<i class="fas fa-moon"></i>'; } });
  </script>
</body>
</html>
