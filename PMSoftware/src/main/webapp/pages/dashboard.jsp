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

<% request.setAttribute("pageTitle", "Dashboard"); %>
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
          <button class="risk-filter-btn" data-risk="high">
            <span class="risk-dot red"></span> High
          </button>
          <button class="risk-filter-btn" data-risk="medium">
            <span class="risk-dot yellow"></span> Medium
          </button>
          <button class="risk-filter-btn" data-risk="low">
            <span class="risk-dot green"></span> Low
          </button>
        </div>
        <button class="add-project-btn" onclick="openProjectModal()">
          <img src="../icons/plus.svg" alt="Add" class="plus-icon" />
          Add Project
        </button>
    </div>
    <!-- Dynamic project cards from servlet -->
    <div class="project-grid">
        <jsp:include page="/fetch-projects" />
    </div>
</main>
<div id="projectModal" class="modal">
  <div class="modal-content">
    <span class="close" onclick="closeProjectModal()">&times;</span>
    <h2>New Project</h2>
        <form id="projectForm" action="../add-project" method="post">
          <input type="text" name="projectName" placeholder="Project Name" required />
          <textarea name="description" placeholder="Project Description" required></textarea>
          <select name="status">
            <option>To Do</option>
            <option>In Progress</option>
            <option>Completed</option>
            <option>Overdue</option>
          </select>
          <select name="riskLevel">
            <option>Low</option>
            <option>Medium</option>
            <option>High</option>
          </select>
          <input type="date" name="dueDate" required />
          <button type="submit">Add Project</button>
        </form>
  </div>
</div>

<div id="editProjectModal" class="modal">
  <div class="modal-content">
    <span class="close" onclick="closeEditModal()">&times;</span>
    <h2>Edit Project</h2>
    <form id="editProjectForm" method="post" action="../update-project">
      <input type="hidden" name="ProjectID" id="editProjectID" />
      <input type="text" name="ProjectName" id="editProjectName" required />
      <textarea name="Description" id="editDescription" required></textarea>
      <select name="Status" id="editStatus">
        <option>To Do</option>
        <option>In Progress</option>
        <option>Completed</option>
        <option>Overdue</option>
      </select>
      <select name="RiskLevel" id="editRiskLevel">
        <option>Low</option>
        <option>Medium</option>
        <option>High</option>
      </select>
      <input type="date" name="DueDate" id="editDueDate" required />
      <button type="submit">Update Project</button>
    </form>
  </div>
</div>

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
    // Risk filter buttons (toggle behavior with class)
    const riskButtons = document.querySelectorAll(".risk-filter-btn");
    riskButtons.forEach(button => {
      button.addEventListener("click", () => {
        // Toggle the active class
        button.classList.toggle("active");

        // Collect all selected risks
        const selectedRisks = Array.from(riskButtons)
          .filter(btn => btn.classList.contains("active"))
          .map(btn => btn.dataset.risk);

        // Update filtering logic
        cards.forEach(card => {
          const title = card.querySelector("h3")?.textContent.toLowerCase() || "";
          const desc = card.querySelector(".description")?.textContent.toLowerCase() || "";
          const status = card.dataset.status;
          const risk = card.dataset.risk;

          const matchesSearch = title.includes(searchInput.value.toLowerCase()) || desc.includes(searchInput.value.toLowerCase());
          const matchesStatus = currentStatus === "all" || status === currentStatus;
          const matchesRisk = selectedRisks.length === 0 || selectedRisks.includes(risk);

          card.style.display = (matchesSearch && matchesStatus && matchesRisk) ? "block" : "none";
        });
      });
    });
  });

  function openProjectModal() {
    const modal = document.getElementById("projectModal");
    modal.style.display = "flex"; // Use 'flex' for vertical centering
   }

  function closeProjectModal() {
    document.getElementById("projectModal").style.display = "none";
  }

  function openEditModal(button) {
    const card = button.closest('.project-card');
    const editProjectModal = document.getElementById("editProjectModal");
    const id = card?.getAttribute('data-id');
    editProjectModal.style.display = "flex"; // Use 'flex' for vertical centering
    if (!id) return;

    fetch('../get-project?id=' + id)
      .then(res => res.json())
      .then(data => {
        const form = document.getElementById("editProjectForm");
        form.elements["ProjectID"].value = id;
        form.elements["ProjectName"].value = data.ProjectName;
        form.elements["Description"].value = data.Description;
        form.elements["Status"].value = data.Status;
        form.elements["RiskLevel"].value = data.RiskLevel;
        form.elements["DueDate"].value = data.DueDate;

        document.getElementById("editProjectModal").style.display = "flex";
      });
  }

  function closeEditModal() {
    const modal = document.getElementById("editProjectModal");
    if (modal) {
      modal.style.display = "none";
    }
  }
</script>

