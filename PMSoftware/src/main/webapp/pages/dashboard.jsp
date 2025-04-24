<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page session="true" %>
<%
    if (session.getAttribute("userEmail") == null) {
        response.sendRedirect("login.html");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Projects</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body data-title="Projects"
      data-avatar="${userAvatar}"
      data-user-name="${userName}"
      data-user-email="${userEmail}">

<jsp:include page="../components/header.jsp" />

<main class="dashboard-main">
    <div class="dashboard-controls">
        <input type="text" placeholder="Search project..." class="search-input" />

<div class="status-filters">
    <button class="filter-btn active" data-status="all">All</button>
    <button class="filter-btn" data-status="to do">To Do</button>
    <button class="filter-btn" data-status="in progress">In Progress</button>
    <button class="filter-btn" data-status="completed">Completed</button>
    <button class="filter-btn" data-status="overdue">Overdue</button>
</div>

<div class="risk-indicators">
    <span class="risk-filter" data-risk="high"><span class="risk-dot red"></span> High</span>
    <span class="risk-filter" data-risk="medium"><span class="risk-dot yellow"></span> Medium</span>
    <span class="risk-filter" data-risk="low"><span class="risk-dot green"></span> Low</span>
</div>

    </div>
    <!-- Dynamic project cards from servlet -->
    <div class="project-grid">
        <jsp:include page="/fetch-projects" />
    </div>
</main>
</body>
</html>

<script>
  document.addEventListener("DOMContentLoaded", () => {
    const searchInput = document.querySelector(".search-input");
    const filterButtons = document.querySelectorAll(".filter-btn");
    const riskFilters = document.querySelectorAll(".risk-filter");
    const cards = document.querySelectorAll(".project-card");

    let currentStatus = "all";
    let currentRisk = null;

    function filterCards() {
      const query = searchInput.value.toLowerCase();

      cards.forEach(card => {
        const title = card.querySelector("h3")?.textContent.toLowerCase() || "";
        const desc = card.querySelector(".description")?.textContent.toLowerCase() || "";
        const status = card.dataset.status;
        const risk = card.dataset.risk;

        const matchesSearch = title.includes(query) || desc.includes(query);
        const matchesStatus = currentStatus === "all" || status === currentStatus;
        const matchesRisk = !currentRisk || risk === currentRisk;

        if (matchesSearch && matchesStatus && matchesRisk) {
          card.style.display = "block";
        } else {
          card.style.display = "none";
        }
      });
    }

    // Search
    searchInput.addEventListener("input", filterCards);

    // Status filter
    filterButtons.forEach(btn => {
      btn.addEventListener("click", () => {
        filterButtons.forEach(b => b.classList.remove("active"));
        btn.classList.add("active");
        currentStatus = btn.dataset.status;
        filterCards();
      });
    });

    // Risk filter
    riskFilters.forEach(filter => {
      filter.addEventListener("click", () => {
        const selected = filter.dataset.risk;
        currentRisk = (currentRisk === selected) ? null : selected; // toggle
        filterCards();
      });
    });
  });
</script>

