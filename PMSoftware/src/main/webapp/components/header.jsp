<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page session="true" %>
<link rel="stylesheet" href="../css/style.css" />

<!-- Sidebar -->
<div class="sidebar" id="sidebar">
  <div class="sidebar-header">
    <button class="close-sidebar-btn">
      <img src="../icons/close_button.svg" alt="Close Menu" class="menu-icon" />
    </button>
  </div>

  <div class="sidebar-user-info">
    <p class="user-name">Hello ${userName}</p>
    <p class="user-email">${userEmail}</p>
  </div>

  <div class="sidebar-menu">
    <p class="menu-label">Menu</p>
    <a href="<%= request.getContextPath() %>/pages/dashboard.jsp">
      <img src="../icons/dashboard.svg" alt="Dashboard Icon" /> Dashboard
    </a>
    <a href="<%= request.getContextPath() %>/pages/collaboration.jsp">
      <img src="../icons/dashboard.svg" alt="Collaboration Icon" /> Collaboration
    </a>
    <a href="<%= request.getContextPath() %>/pages/reports.jsp">
      <img src="../icons/dashboard.svg" alt="Reports Icon" /> Reports
    </a>
    <p class="menu-label">Settings</p>
    <a href="<%= request.getContextPath() %>/logout">
      <img src="../icons/dashboard.svg" alt="Logout Icon" /> Logout
    </a>
  </div>
</div>

<!-- Top Header -->
<header class="top-header">
  <div class="left-section">
    <button class="menu-btn">
      <img src="../icons/menu_button.svg" alt="Menu" />
    </button>
  </div>

  <h1 class="page-title" id="dynamic-page-title"><%= request.getAttribute("pageTitle") %></h1>

  <div class="right">
    <button class="icon-btn">
      <img src="../icons/bell.svg" alt="Notifications" class="icon" />
    </button>
    <div class="profile-wrapper">
      <img id="user-avatar" src="../images/profile/${userAvatar}" alt="User" class="profile-pic" />
      <img src="../icons/drop_down_arrow.svg" alt="Dropdown" class="dropdown-icon" />
    </div>
  </div>
</header>

<!-- Sidebar Toggle Script -->
<script>
  document.addEventListener("DOMContentLoaded", () => {
    const sidebar = document.getElementById("sidebar");
    const openBtn = document.querySelector(".menu-btn");
    const closeBtn = document.querySelector(".close-sidebar-btn");

    if (openBtn && sidebar) {
      openBtn.addEventListener("click", () => {
        sidebar.classList.add("show");
        document.body.classList.add("sidebar-open");
      });
    }

    if (closeBtn && sidebar) {
      closeBtn.addEventListener("click", () => {
        sidebar.classList.remove("show");
        document.body.classList.remove("sidebar-open");
      });
    }
  });
</script>
