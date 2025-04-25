<%@ page import="java.sql.*, main.ProjectDatabase" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page session="true" %>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect("login.html");
        return;
    }

    String projectId = request.getParameter("id");
    if (projectId == null || projectId.isEmpty()) {
        response.sendRedirect("dashboard.jsp");
        return;
    }

    DecimalFormat df = new DecimalFormat("#.##");
    String projectName = "", description = "", status = "", risk = "", due = "";
    double loggedHours = 0.0;

    List<Map<String, Object>> requirements = new ArrayList<>();

    try (Connection conn = new ProjectDatabase().getConnection()) {

        // Fetch Project Overview Info
        String sql = "SELECT ProjectName, Description, Status, RiskLevel, DueDate, LoggedHours FROM projects WHERE ProjectID = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, Integer.parseInt(projectId));
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                projectName = rs.getString("ProjectName");
                description = rs.getString("Description");
                status = rs.getString("Status");
                risk = rs.getString("RiskLevel");
                due = rs.getString("DueDate");
                loggedHours = rs.getDouble("LoggedHours");
            }
        }

        // Fetch Requirements for this Project
        sql = "SELECT RequirementID, Title, Description, Type, LoggedRequirementHours, IsMet FROM requirements WHERE ProjectID = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, Integer.parseInt(projectId));
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Map<String, Object> req = new HashMap<>();
                req.put("RequirementID", rs.getInt("RequirementID"));
                req.put("Title", rs.getString("Title"));
                req.put("Description", rs.getString("Description"));
                req.put("Type", rs.getString("Type"));
                req.put("Hours", rs.getDouble("LoggedRequirementHours"));
                req.put("IsMet", rs.getBoolean("IsMet"));
                requirements.add(req);
            }
        }

    } catch (Exception e) {
        e.printStackTrace();
    }
%>


<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Project Details</title>
  <link rel="stylesheet" href="../css/style.css" />
</head>
<body data-title="Project Details"
      data-avatar="<%= session.getAttribute("userAvatar") %>"
      data-user-name="<%= session.getAttribute("userName") %>"
      data-user-email="<%= session.getAttribute("userEmail") %>">

<jsp:include page="../components/header.jsp" />

<main class="dashboard-main">

<div class="project-overview">
  <h2>Project Overview</h2>
  <h3 class="project-name"><%= projectName %></h3>
  <p><strong>Status:</strong> <%= status %></p>
  <p><strong>Risk Level:</strong> <%= risk %></p>
  <p><strong>Due Date:</strong> <%= due %></p>
  <p><strong>Total Logged Hours:</strong> <%= df.format(loggedHours) %> hrs</p>
  <p><strong>Description:</strong> <%= description %></p>
</div>

<div class="requirement-controls">
  <input type="text" id="searchRequirement" class="search-input" placeholder="Search requirements..." />

  <div class="filter-buttons">
    <button class="filter-btn active" data-type="all">All</button>
    <button class="filter-btn" data-type="functional">Functional</button>
    <button class="filter-btn" data-type="non-functional">Non-Functional</button>
  </div>

  <button class="add-project-btn" onclick="openRequirementModal()">
    <img src="../icons/plus.svg" alt="Add" class="plus-icon" />
    Add Requirement
  </button>
</div>

  <!-- Requirements Grid -->
  <div class="requirement-grid">

    <!-- Functional Requirement Card -->
    <div class="requirement-card functional">
      <div class="card-header">
        <span class="requirement-type">Functional</span>
        <span class="requirement-hours">🕒 12 hrs</span>
      </div>
      <h3 class="requirement-title">#1 User Login</h3>
      <p class="requirement-desc">Enable users to securely log in using email and password.</p>
      <div class="requirement-footer">
        <button class="log-btn">⏳ Log</button>
        <button class="edit-btn">✏️ Edit</button>
        <span class="requirement-check">✅</span>
      </div>
    </div>

    <!-- Non-Functional Requirement Card -->
    <div class="requirement-card non-functional">
      <div class="card-header">
        <span class="requirement-type">Non-Functional</span>
        <span class="requirement-hours">🕒 5 hrs</span>
      </div>
      <h3 class="requirement-title">#2 Performance</h3>
      <p class="requirement-desc">System should respond to requests within 2 seconds.</p>
      <div class="requirement-footer">
        <button class="log-btn">⏳ Log</button>
        <button class="edit-btn">✏️ Edit</button>
      </div>
    </div>
  </div>
</main>
</body>
</html>

<script>
  document.addEventListener("DOMContentLoaded", () => {
    const searchInput = document.getElementById("searchRequirement");
    const filterButtons = document.querySelectorAll(".filter-btn");
    const cards = document.querySelectorAll(".requirement-card");

    let currentType = "all";

    function filterRequirements() {
      const query = searchInput.value.toLowerCase();

      cards.forEach(card => {
        const type = card.dataset.type.toLowerCase();
        const title = card.querySelector(".req-title")?.textContent.toLowerCase() || "";
        const desc = card.querySelector(".req-desc")?.textContent.toLowerCase() || "";

        const matchesSearch = title.includes(query) || desc.includes(query);
        const matchesType = currentType === "all" || type === currentType;

        card.style.display = (matchesSearch && matchesType) ? "block" : "none";
      });
    }

    searchInput.addEventListener("input", filterRequirements);

    filterButtons.forEach(btn => {
      btn.addEventListener("click", () => {
        filterButtons.forEach(b => b.classList.remove("active"));
        btn.classList.add("active");
        currentType = btn.dataset.type;
        filterRequirements();
      });
    });
  });

  function openRequirementModal() {
    // Show your modal for adding requirement
    document.getElementById("requirementModal").style.display = "block";
  }
</script>

