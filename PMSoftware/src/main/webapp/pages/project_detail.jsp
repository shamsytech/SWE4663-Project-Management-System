<%@ page import="java.sql.*, main.ProjectDatabase" %>
<%@ page import="java.util.List, java.util.Map, java.util.HashMap, java.util.ArrayList" %>
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
      data-user-email="<%= session.getAttribute("userEmail") %>"
      data-project-id="<%= projectId %>">

<% request.setAttribute("pageTitle", "Project Details"); %>
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
        <% for (Map<String, Object> req : requirements) {
             String type = (String) req.get("Type");
             boolean isFunctional = "Functional".equalsIgnoreCase(type); // null-safe
             boolean isMet = req.get("isMet") != null && (Boolean) req.get("isMet");
        %>
    <div class="requirement-card <%= isFunctional ? "functional" : "non-functional" %>" data-id="<%= req.get("RequirementID") %>">
        <style="border: 1px solid #ddd; padding: 10px; margin: 10px; background: #fff;">
        <div class="card-header">
            <span class="requirement-type"><%= type %></span>
            <span class="requirement-hours">
                <img src="../icons/clock.svg" class="icon-inline" alt="Clock" />
                <%= ((Double) req.get("Hours")) %> hrs
            </span>
        </div>

        <h3 class="requirement-title"><%= req.get("Title") %></h3>
        <p class="requirement-desc"><%= req.get("Description") %></p>

        <div class="requirement-footer">
            <button class="log-btn"
              onclick="openLogModal(<%= req.get("RequirementID") %>, '<%= req.get("Title").toString().replace("'", "\\'") %>')">
              <img src="../icons/hourglass.svg" class="icon-inline" alt="Log" /> Log
            </button>
            <button class="edit-btn" onclick="openEditRequirementModal(this)">
              <img src="../icons/edit.svg" class="icon-inline" alt="Edit" /> Edit
            </button>
            <% if (isMet) { %>
                <span class="requirement-check">
                    <img src="../icons/check.svg" class="icon-inline" alt="Met" />
                </span>
            <% } %>
        </div>
    </div>
    <% } %>
  </div>
</main>

<!-- Edit Requirement Modal -->
<div id="editRequirementModal" class="modal">
  <div class="modal-content">
    <span class="close" onclick="closeEditModal()">&times;</span>
    <h2>Edit Requirement</h2>
    <form id="editRequirementForm" method="post" action="../edit-requirement">
      <input type="hidden" name="RequirementID" id="editRequirementID" />
      <input type="hidden" name="ProjectID" id="editProjectID" />

      <label for="editRequirementTitle">Title</label>
      <input type="text" name="Title" id="editRequirementTitle" required />

      <label for="editRequirementDesc">Description</label>
      <textarea name="Description" id="editRequirementDesc" required></textarea>

      <label for="editRequirementType">Type</label>
      <select name="Type" id="editRequirementType">
        <option value="Functional">Functional</option>
        <option value="Non-Functional">Non-Functional</option>
      </select>

      <label>
        <input type="Hidden" name="IsMet" id="editRequirementIsMet" />
      </label>

      <button type="submit">Update</button>
    </form>
  </div>
</div>


<!-- Log Effort Modal -->
<div id="logModal" class="modal">
  <div class="modal-content">
    <span class="close" onclick="closeLogModal()">&times;</span>
    <h2>Log Effort for <span id="logRequirementName">Requirement</span></h2>

    <form action="../log-effort" method="post">
        <input type="hidden" name="RequirementID" id="logRequirementID" />
        <input type="hidden" name="projectID" value="<%= projectId %>" />

         <label for="LoggedDate">Date of Work</label>
         <input type="date" name="LoggedDate" id="LoggedDate" required />

        <label for="AnalysisHours">Requirements Analysis (hrs)</label>
        <input type="number" step="0.1" min="0" name="AnalysisHours" />

        <label for="DesignHours">Designing (hrs)</label>
        <input type="number" step="0.1" min="0" name="DesignHours" />

        <label for="CodingHours">Coding (hrs)</label>
        <input type="number" step="0.1" min="0" name="CodingHours" />

        <label for="TestingHours">Testing (hrs)</label>
        <input type="number" step="0.1" min="0" name="TestingHours" />

        <label for="ManagementHours">Project Management (hrs)</label>
        <input type="number" step="0.1" min="0" name="ManagementHours" />

        <button type="submit" class="submit-btn">Submit Log</button>

    </form>
  </div>
</div>

<!-- Add Requirement Modal -->
<div id="requirementModal" class="modal">
  <div class="modal-content">
    <span class="close" onclick="closeRequirementModal()">&times;</span>
    <h2>Add New Requirement</h2>
    <form id="addRequirementForm" action="../add-requirement" method="post">
      <input type="hidden" name="ProjectID" value="<%= projectId %>" />

      <label for="newTitle">Title</label>
      <input type="text" name="Title" id="newTitle" required />

      <label for="newDescription">Description</label>
      <textarea name="Description" id="newDescription" required></textarea>

      <label for="newType">Type</label>
      <select name="Type" id="newType">
        <option value="Functional">Functional</option>
        <option value="Non-Functional">Non-Functional</option>
      </select>

      <button type="submit">Add Requirement</button>
    </form>
  </div>
</div>
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
    document.getElementById("requirementModal").style.display = "flex";
  }

  function closeRequirementModal() {
    document.getElementById("requirementModal").style.display = "none";
  }

  function openLogModal(reqId, reqTitle) {
    document.getElementById("logRequirementID").value = reqId;
    document.getElementById("logRequirementName").innerText = reqTitle;
    document.getElementById("logModal").style.display = "flex";
  }

  function closeModal(modalId) {
    document.getElementById(modalId).style.display = "none";
  }

    function closeLogModal() {
      document.getElementById("logModal").style.display = "none";
    }

  function closeEditModal() {
    document.getElementById("editRequirementModal").style.display = "none";
  }

  function openEditRequirementModal(button) {
    const card = button.closest('.requirement-card');
    if (!card) return;

    const id = card.dataset.id || "";
    const titleElem = card.querySelector(".requirement-title");
    const descElem = card.querySelector(".requirement-desc");

    const title = titleElem ? titleElem.textContent.split(" ").slice(1).join(" ") : "";
    const desc = descElem ? descElem.textContent : "";
    const type = card.classList.contains("functional") ? "Functional" : "Non-Functional";
    const isMet = card.querySelector(".requirement-check") !== null;
    const projectId = document.body.dataset.projectId;

    document.getElementById("editRequirementID").value = id;
    console.log("Setting RequirementID:", id);
    document.getElementById("editProjectID").value = projectId;
    document.getElementById("editRequirementTitle").value = title.trim();
    document.getElementById("editRequirementDesc").value = desc.trim();
    document.getElementById("editRequirementType").value = type;
    document.getElementById("editRequirementIsMet").checked = isMet;

    document.getElementById("editRequirementModal").style.display = "flex";
  }



  window.onclick = function(event) {
    ["logModal", "editRequirementModal"].forEach(id => {
      const modal = document.getElementById(id);
      if (event.target === modal) modal.style.display = "none";
    });
  }
</script>

