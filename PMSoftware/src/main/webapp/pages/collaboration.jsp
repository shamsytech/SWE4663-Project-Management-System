<%@ page import="java.sql.*, java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    if (session == null || session.getAttribute("userID") == null) {
        response.sendRedirect("login.html");
        return;
    }

    int userId = (Integer) session.getAttribute("userID");

    List<Map<String, Object>> managerProjects = new ArrayList<>();

    try (Connection conn = new main.ProjectDatabase().getConnection()) {
        String sql = "SELECT p.ProjectID, p.ProjectName, p.Description, p.DueDate, p.RiskLevel, p.LoggedHours, p.Status " +
                     "FROM projects p " +
                     "LEFT JOIN team_members tm ON tm.ProjectID = p.ProjectID " +
                     "WHERE (tm.UserID = ? AND tm.Role = 'manager') OR (p.OwnerID = ?)";


        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setInt(2, userId);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Map<String, Object> project = new HashMap<>();
                project.put("id", rs.getInt("ProjectID"));
                project.put("name", rs.getString("ProjectName"));
                project.put("description", rs.getString("Description"));
                project.put("due", rs.getString("DueDate"));
                project.put("risk", rs.getString("RiskLevel"));
                project.put("status", rs.getString("Status"));
                project.put("hours", rs.getDouble("LoggedHours"));
                managerProjects.add(project);
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Collaboration Projects</title>
  <link rel="stylesheet" href="../css/style.css" />
</head>

<body data-title="Collaboration"
      data-avatar="${userAvatar}"
      data-user-name="${userName}"
      data-user-email="${userEmail}">

<% request.setAttribute("pageTitle", "Collaboration"); %>
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
    </div>
  <div class="project-grid">
    <% for (Map<String, Object> proj : managerProjects) {
        String risk = ((String) proj.get("risk")).toLowerCase();
        String displayRisk = risk.substring(0, 1).toUpperCase() + risk.substring(1);
        String status = ((String) proj.get("status")).toLowerCase();
    %>
    <div class="project-card <%= risk %>" data-id="<%= proj.get("id") %>" data-status="<%= status %>" data-risk="<%= risk %>">
      <div class="card-header">
        <span class="risk-label <%= risk %>"><%= displayRisk %> Risk</span>
        <div class="card-actions">
          <button class="view-btn" onclick="openTeamModal(this)">
            <img src="../icons/eye.svg" class="icon-inline" alt="View" /> View
          </button>
        </div>
      </div>
      <a href="project_detail.jsp?id=<%= proj.get("id") %>" class="project-card-link">
        <h3><%= proj.get("name") %></h3>
        <p class="description"><%= proj.get("description") %></p>
        <p class="hours">
          <img src="../icons/clock.svg" class="icon-inline" alt="Clock" />
          <%= proj.get("hours") %> hrs
        </p>
        <p class="due">
          <img src="../icons/calendar.svg" class="icon-inline" alt="Calendar" />
          Due: <%= proj.get("due") %>
        </p>
      </a>
    </div>
    <% } %>
  </div>
</main>
</body>

<div id="teamModal" class="modal">
  <div class="modal-content">
    <div class="modal-header">
      <h2>Team Members</h2>
      <button class="add-member-btn" onclick="openAddMemberModal()">Add Member</button>
      <span class="close" onclick="closeTeamModal()">&times;</span>
    </div>
    <div id="teamList">
      <!-- Team members will be loaded here dynamically -->
    </div>
  </div>
</div>

<div id="addMemberModal" class="modal">
  <div class="modal-content">
    <div class="modal-header">
      <h2>Add Member</h2>
      <span class="close" onclick="closeAddMemberModal()">&times;</span>
    </div>
    <form id="addMemberForm" method="post" action="../add-team-member">
      <input type="hidden" name="ProjectID" id="addProjectID" />
      <label for="UserID">Select User:</label>
      <select name="UserID" id="userDropdown" required>
        <!-- Options will be populated dynamically -->
      </select>

      <label for="Role">Role:</label>
      <select name="Role" required>
        <option value="manager">Manager</option>
        <option value="editor">Editor</option>
      </select>

      <button type="submit">Add</button>
    </form>
  </div>
</div>

</html>

<script>
function openTeamModal(button) {
  const card = button.closest('.project-card');
  const projectId = card.dataset.id;

  console.log("Opening modal for project ID:", projectId);

  // Show the modal
  document.getElementById("teamModal").style.display = "flex";

  // Fetch team members from server
  fetch(`../fetch-team-members?projectID=${projectId}`)
    .then(response => {
      console.log("Fetch response status:", response.status);
      return response.json();
    })
    .then(data => {
      console.log("Fetched team data:", data);

      const teamList = document.getElementById("teamList");
      teamList.innerHTML = ""; // Clear previous entries

      data.forEach(member => {
        const item = document.createElement("div");
        item.className = "team-member";
        item.innerHTML = `<p><strong>${member.name}</strong> - ${member.role}</p>`;
        teamList.appendChild(item);
      });
    })
    .catch(error => {
      console.error("Error loading team members:", error);
    });
}




  function closeTeamModal() {
    document.getElementById("teamModal").style.display = "none";
  }

function openAddMemberModal(projectId) {
  document.getElementById("addProjectID").value = projectId;
  document.getElementById("addMemberModal").style.display = "flex";

  // Fetch users
  fetch('../fetch-users') // You’ll need to create this servlet
    .then(response => response.json())
    .then(users => {
      const dropdown = document.getElementById("userDropdown");
      dropdown.innerHTML = "";
      users.forEach(user => {
        const option = document.createElement("option");
        option.value = user.id;
        option.text = user.name;
        dropdown.appendChild(option);
      });
    })
    .catch(err => console.error("Error loading users:", err));
}

function closeAddMemberModal() {
  document.getElementById("addMemberModal").style.display = "none";
}


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
</script>
