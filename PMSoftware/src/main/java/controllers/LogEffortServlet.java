package controllers;

import main.ProjectDatabase;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/log-effort")
public class LogEffortServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userID") == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        int userID = (int) session.getAttribute("userID");
        int requirementID = Integer.parseInt(request.getParameter("RequirementID"));
        Date loggedDate = Date.valueOf(request.getParameter("LoggedDate")); // required in form

        // ✅ Safe parse (default to 0.0 if blank)
        double analysis = parseHours(request, "AnalysisHours");
        double design = parseHours(request, "DesignHours");
        double coding = parseHours(request, "CodingHours");
        double testing = parseHours(request, "TestingHours");
        double management = parseHours(request, "ManagementHours");

        double totalHours = analysis + design + coding + testing + management;

        try (Connection conn = new ProjectDatabase().getConnection()) {

            conn.setAutoCommit(false); // Start transaction

            // Step 1: Insert into effort_tracking
            String logSql = """
                INSERT INTO effort_tracking (RequirementID, LoggedBy, EntryDate,
                                              AnalysisHours, DesignHours, CodingHours, TestingHours, ManagementHours)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """;
            try (PreparedStatement stmt = conn.prepareStatement(logSql)) {
                stmt.setInt(1, requirementID);
                stmt.setInt(2, userID);
                stmt.setDate(3, loggedDate);
                stmt.setDouble(4, analysis);
                stmt.setDouble(5, design);
                stmt.setDouble(6, coding);
                stmt.setDouble(7, testing);
                stmt.setDouble(8, management);
                stmt.executeUpdate();
            }

            // Step 2: Update project logged hours
            String updateSql = """
                UPDATE projects p
                JOIN requirements r ON r.ProjectID = p.ProjectID
                SET p.LoggedHours = p.LoggedHours + ?
                WHERE r.RequirementID = ?
            """;
            try (PreparedStatement stmt = conn.prepareStatement(updateSql)) {
                stmt.setDouble(1, totalHours);
                stmt.setInt(2, requirementID);
                stmt.executeUpdate();
            }

            // Step 3: Update requirements hours
            String updateReqSql = """
                UPDATE requirements
                SET LoggedRequirementHours = LoggedRequirementHours + ?
                WHERE RequirementID = ?
            """;
            try (PreparedStatement stmt = conn.prepareStatement(updateReqSql)) {
                stmt.setDouble(1, totalHours);
                stmt.setInt(2, requirementID);
                stmt.executeUpdate();
            }

            conn.commit(); // Commit all changes
            response.sendRedirect("pages/project_detail.jsp?id=" + request.getParameter("projectID"));

        } catch (SQLException e) {
            e.printStackTrace();
            throw new ServletException("Error logging effort and updating totals", e);
        }
    }

    private double parseHours(HttpServletRequest request, String param) {
        String val = request.getParameter(param);
        if (val == null || val.trim().isEmpty()) return 0.0;
        return Double.parseDouble(val);
    }
}
