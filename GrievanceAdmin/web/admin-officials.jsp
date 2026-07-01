<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*,java.util.*,com.grievanceportal.db.DBConnection" %>
<%@ page session="true" %>
<%
        String adminUser = (String) session.getAttribute("adminUser");
    if (session.getAttribute("adminUser") == null) {
        response.sendRedirect("admin-login.jsp");
        return;
    }

    String msg = "";

    // ✅ Add new official
    if ("POST".equalsIgnoreCase(request.getMethod()) && request.getParameter("addOfficial") != null) {
        String name = request.getParameter("name");
        String dept = request.getParameter("department");

        try (Connection con = DBConnection.getConnection()) {
            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO officials(name, department, password) VALUES (?, ?, ?)"
            );
            ps.setString(1, name);
            ps.setString(2, dept);
            ps.setString(3, "123"); // default password
            ps.executeUpdate();
            msg = "Official added successfully!";
        } catch (Exception e) {
            msg = "Error: " + e.getMessage();
        }
    }

    // ✅ Delete official
    if (request.getParameter("deleteId") != null) {
        try (Connection con = DBConnection.getConnection()) {
            PreparedStatement ps = con.prepareStatement("DELETE FROM officials WHERE id=?");
            ps.setInt(1, Integer.parseInt(request.getParameter("deleteId")));
            ps.executeUpdate();
            msg = "Official removed successfully!";
        } catch (Exception e) {
            msg = "Error deleting: " + e.getMessage();
        }
    }

    // ✅ Fetch officials into a list (safe from ResultSet closed error)
    class Official { int id; String name; String dept; }
    List<Official> officials = new ArrayList<>();

    try (Connection con = DBConnection.getConnection();
         Statement st = con.createStatement();
         ResultSet rs = st.executeQuery("SELECT * FROM officials ORDER BY id DESC")) {
        while (rs.next()) {
            Official o = new Official();
            o.id = rs.getInt("id");
            o.name = rs.getString("name");
            o.dept = rs.getString("department");
            officials.add(o);
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

 
  <div class="col-md-9 col-lg-10 p-4">
  <h3>Manage Officials</h3>
  <% if (!msg.isEmpty()) { %>
    <div class="alert alert-info"><%= msg %></div>
  <% } %>

  <!-- Add Official -->
  <form method="post" class="row g-3 mb-4">
    <input type="hidden" name="addOfficial" value="1">
    <div class="col-md-5">
      <input type="text" name="name" placeholder="Official Name" class="form-control" required>
    </div>
    <div class="col-md-5">
      <select name="department" class="form-select" required>
        <option value="">Select Department</option>
        <option>Municipal Corporation</option>
        <option>Public Works</option>
        <option>Health Department</option>
        <option>Education Department</option>
        <option>Police Department</option>
        <option>Fire Service</option>
        <option>Electricity Board</option>
        <option>Water Board</option>
        <option>Transport Department</option>
        <option>Environment Department</option>
      </select>
    </div>
    <div class="col-md-2">
      <button type="submit" class="btn btn-primary w-100">Add</button>
    </div>
  </form>

  <!-- Officials Table -->
  <table class="table table-bordered">
    <thead>
      <tr><th>ID</th><th>Name</th><th>Department</th><th>Action</th></tr>
    </thead>
    <tbody>
      <% if (officials.isEmpty()) { %>
        <tr><td colspan="4" class="text-center text-muted">No officials found</td></tr>
      <% } else {
           for (Official o : officials) { %>
        <tr>
          <td><%= o.id %></td>
          <td><%= o.name %></td>
          <td><%= o.dept %></td>
          <td>
            <a href="admin-officials.jsp?deleteId=<%= o.id %>" class="btn btn-sm btn-danger">Delete</a>
          </td>
        </tr>
      <% }} %>
    </tbody>
  </table>
</div>

    </div>
     
  </div> <jsp:include page="AdminFooter.jsp"/>
</body>
</html>