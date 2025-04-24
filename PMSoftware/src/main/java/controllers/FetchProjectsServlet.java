package controllers;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import java.io.*;
import java.sql.*;

@WebServlet("/fetch-projects")
public class FetchProjectsServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userID") == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        int userId = (Integer) session.getAttribute("userID");

        response.setContentType("text/html");
        PrintWriter out = response.getWriter();

        try (Connection conn = new main.ProjectDatabase().getConnection()) {
            String sql = "SELECT * FROM projects WHERE OwnerID = ?";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                int projectId = rs.getInt("ProjectID");
                String title = rs.getString("ProjectName");
                String description = rs.getString("Description");
                int hours = rs.getInt("LoggedHours");
                String due = rs.getString("DueDate");

                // Safely handle nulls and normalize values
                String risk = rs.getString("RiskLevel");
                risk = (risk != null && !risk.isEmpty()) ? risk.toLowerCase() : "low";

                String status = rs.getString("Status");
                status = (status != null) ? status.toLowerCase() : "to do";

                // Capitalize risk for display
                String displayRisk = risk.substring(0, 1).toUpperCase() + risk.substring(1);

                out.println("<div class='project-card " + risk + "' data-status='" + status + "' data-risk='" + risk + "' data-id='" + projectId + "'>");

                out.println("  <div class='card-header'>");
                out.println("    <span class='risk-label " + risk + "'>" + displayRisk + " Risk</span>");
                out.println("    <div class='card-actions'>");
                out.println("      <button class='action-btn invite-btn'><img src='../icons/invite.svg' alt='Invite' /> Invite</button>");
                out.println("      <button class='edit-btn' onclick='openEditModal(this, " + projectId + ")'><img src=\"../icons/edit.svg\" alt=\"Edit\" /> Edit</button>");
                out.println("    </div>");
                out.println("  </div>");

                out.println("  <h3>" + title + "</h3>");
                out.println("  <p class='description'>" + description + "</p>");
                out.println("  <p class='hours'><img src='../icons/clock.svg' class='icon-inline' alt='Clock' /> " + hours + " hrs</p>");
                out.println("  <p class='due'><img src='../icons/calendar.svg' class='icon-inline' alt='Calendar' /> Due: " + due + "</p>");

                out.println("</div>");

            }
        } catch (SQLException e) {
            out.println("<p>Error loading projects.</p>");
            e.printStackTrace(out);
        }
    }

    private String capitalize(String input) {
        if (input == null || input.isEmpty()) return input;
        return input.substring(0, 1).toUpperCase() + input.substring(1);
    }
}
