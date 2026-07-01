
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Digital Grievance Platform</title>
  <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
  <style>
    /* Theme Variables */
    :root {
      --bg: #ffffff;
      --text: #212529;
      --card-bg: #ffffff;
      --card-text: #212529;
      --footer-bg: #111;
      --footer-text: #ccc;
    }
    body.dark {
      --bg: #181818;
      --text: #f1f1f1;
      --card-bg: #242424;
      --card-text: #f1f1f1;
      --footer-bg: #000;
      --footer-text: #999;
    }

    body {
      background-color: var(--bg);
      color: var(--text);
      transition: all 0.3s;
    }

    .feature-card {
      background: var(--card-bg);
      color: var(--card-text);
    }

    footer {
      background: var(--footer-bg);
      color: var(--footer-text);
    }

    /* Toggle Button */
    .theme-toggle {
      border: none;
      background: transparent;
      color: white;
      font-size: 1.2rem;
      cursor: pointer;
      transition: 0.3s;
    }
    .theme-toggle:hover {
      color: #ffc107;
    }
  </style>
</head>
<body>
  <!-- Navbar -->
  <jsp:include page="indexNav.jsp"/>

  <!-- Hero -->
  <section class="hero-section d-flex align-items-center text-center text-white" style="background: linear-gradient(135deg,#007bff,#6610f2);padding:120px 0;">
    <div class="container">
      <h1 class="display-4 fw-bold mb-4">Digital Platform for <span class="text-warning">Grievance Filing</span> & Tracking</h1>
      <p class="lead mb-4">Streamline complaint registration, improve transparency, and ensure systematic handling with real-time tracking.</p>
      <div class="d-flex justify-content-center gap-3">
        <a href="register.jsp" class="btn btn-warning btn-lg"><i class="fas fa-user-plus me-2"></i>Get Started</a>
        <a href="login.jsp" class="btn btn-outline-light btn-lg"><i class="fas fa-sign-in-alt me-2"></i>Login</a>
      </div>
    </div>
  </section>

  <!-- Features -->
  <section id="features" class="py-5">
    <div class="container">
      <div class="text-center mb-5">
        <h2 class="fw-bold">Key Features</h2>
        <p class="text-muted">Everything you need for effective grievance management</p>
      </div>
      <div class="row g-4">
        <div class="col-md-4"><div class="feature-card p-4 text-center rounded shadow"><i class="fas fa-file-alt fa-2x mb-3 text-primary"></i><h5>Easy Filing</h5><p>Quick grievance submission with file attachments.</p></div></div>
        <div class="col-md-4"><div class="feature-card p-4 text-center rounded shadow"><i class="fas fa-eye fa-2x mb-3 text-info"></i><h5>Real-time Tracking</h5><p>Track your complaint status instantly.</p></div></div>
        <div class="col-md-4"><div class="feature-card p-4 text-center rounded shadow"><i class="fas fa-bell fa-2x mb-3 text-warning"></i><h5>Notifications</h5><p>Get instant updates via email/SMS.</p></div></div>
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

    // Load saved theme
    if(localStorage.getItem("theme") === "dark"){
      body.classList.add("dark");
      toggleBtn.innerHTML = '<i class="fas fa-sun"></i>';
    }

    toggleBtn.addEventListener("click", () => {
      body.classList.toggle("dark");
      if(body.classList.contains("dark")){
        localStorage.setItem("theme","dark");
        toggleBtn.innerHTML = '<i class="fas fa-sun"></i>';
      } else {
        localStorage.setItem("theme","light");
        toggleBtn.innerHTML = '<i class="fas fa-moon"></i>';
      }
    });
  </script>
</body>
</html>
