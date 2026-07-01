<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Register - Digital Grievance Platform</title>
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

  <!-- Registration Section -->
  <section class="d-flex align-items-center justify-content-center" style="padding:120px 0;">
    <div class="container" style="max-width: 600px;">
      <div class="card shadow rounded-4 p-4">
        <h3 class="text-center fw-bold mb-4">Create Account</h3>
        <form action="RegisterServlet" method="post">
          <div class="mb-3">
            <label class="form-label">Full Name</label>
            <input type="text" class="form-control" name="fullname" placeholder="Enter full name" required>
          </div>
          <div class="mb-3">
            <label class="form-label">Email Address</label>
            <input type="email" class="form-control" name="email" placeholder="Enter email" required>
          </div>
          <div class="mb-3">
            <label class="form-label">Phone Number</label>
            <input type="text" class="form-control" name="phone" placeholder="Enter phone number" required>
          </div>
          <div class="mb-3">
            <label class="form-label">Password</label>
            <input type="password" class="form-control" name="password" placeholder="Enter password" required>
          </div>
          <div class="mb-3">
            <label class="form-label">Confirm Password</label>
            <input type="password" class="form-control" name="confirmPassword" placeholder="Confirm password" required>
          </div>
          <button type="submit" class="btn btn-warning w-100"><i class="fas fa-user-plus me-2"></i>Register</button>
        </form>
        <p class="text-center mt-3">Already have an account? <a href="login.jsp">Login</a></p>
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
