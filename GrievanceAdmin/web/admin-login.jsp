<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page session="true" %>
<%
    String msg = "";
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        // Default Admin credentials
        if ("admin".equals(username) && "admin".equals(password)) {
            session.setAttribute("adminUser", username);
            response.sendRedirect("admin-dashboard.jsp");
            return;
        } else {
            msg = "Invalid username or password!";
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Admin Login - GrievancePortal</title>
  <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
</head>
<body>
  <section class="d-flex align-items-center justify-content-center" style="padding:120px 0;">
    <div class="container" style="max-width: 450px;">
      <div class="card shadow rounded-4 p-4">
        <h3 class="text-center fw-bold mb-4">Admin Login</h3>
        <% if (!msg.isEmpty()) { %>
          <div class="alert alert-danger"><%= msg %></div>
        <% } %>
        <form method="post">
          <div class="mb-3">
            <label class="form-label">Username</label>
            <input type="text" class="form-control" name="username" placeholder="Enter admin username" required>
          </div>
          <div class="mb-3">
            <label class="form-label">Password</label>
            <input type="password" class="form-control" name="password" placeholder="Enter admin password" required>
          </div>
          <button type="submit" class="btn btn-primary w-100">
            <i class="fas fa-sign-in-alt me-2"></i>Login
          </button>
        </form>
      </div>
    </div>
  </section>
</body>
</html>

