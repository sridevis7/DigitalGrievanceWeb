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
    if (request.getParameter("deleteUser") != null) {
        try (Connection con = DBConnection.getConnection()) {
            PreparedStatement ps = con.prepareStatement("DELETE FROM users WHERE id=?");
            ps.setInt(1, Integer.parseInt(request.getParameter("deleteUser")));
            ps.executeUpdate();
            msg = "User removed successfully!";
        } catch (Exception e) { msg = "Error: " + e.getMessage(); }
    }

    List<Map<String,String>> users = new ArrayList<>();
    try (Connection con = DBConnection.getConnection()) {
        Statement st = con.createStatement();
        ResultSet rs = st.executeQuery("SELECT * FROM users");
        while (rs.next()) {
            Map<String,String> u = new HashMap<>();
            u.put("id", String.valueOf(rs.getInt("id")));
            u.put("name", rs.getString("fullname"));
            u.put("email", rs.getString("email"));
            users.add(u);
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
    margin-bottom: 0.3rem;
    transition: background-color 0.2s, color 0.2s;
    display: block;
}

.sidebar .nav-link:hover {
    background-color: #e9ecef; /* light gray hover background */
    color: #0d6efd;           /* blue text on hover */
}

.sidebar .nav-link.active { 
    background: #0d6efd; 
    color: #fff; 
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
  <h3>Manage Users</h3>
  <% if (!msg.isEmpty()) { %><div class="alert alert-info"><%= msg %></div><% } %>
  <table class="table table-bordered">
    <thead><tr><th>ID</th><th>Name</th><th>Email</th><th>Action</th></tr></thead>
    <tbody>
    <% for (Map<String,String> u : users) { %>
      <tr>
        <td><%= u.get("id") %></td>
        <td><%= u.get("name") %></td>
        <td><%= u.get("email") %></td>
        <td><a href="admin-users.jsp?deleteUser=<%= u.get("id") %>" class="btn btn-sm btn-danger">Delete</a></td>
      </tr>
    <% } %>
    </tbody>
  </table>
</div>
    <jsp:include page="AdminFooter.jsp"/>
</body></html>
