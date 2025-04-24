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
            <button class="filter-btn active">To Do</button>
            <button class="filter-btn">In Progress</button>
            <button class="filter-btn">Completed</button>
            <button class="filter-btn">Overdue</button>
        </div>

        <div class="risk-indicators">
            <span class="risk-dot red"></span> High
            <span class="risk-dot yellow"></span> Medium
            <span class="risk-dot green"></span> Low
        </div>
    </div>
    <!-- Dynamic project cards from servlet -->
    <div class="project-grid">
        <jsp:include page="/fetch-projects" />
    </div>
</main>
</body>
</html>
