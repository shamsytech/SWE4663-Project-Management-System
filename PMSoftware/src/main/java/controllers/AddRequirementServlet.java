package controllers;

import main.ProjectDatabase;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;


@WebServlet("/add-requirement")
public class AddRequirementServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Validate session
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("pages/login.html");
            return;
        }

        int projectId = Integer.parseInt(request.getParameter("ProjectID"));
        String title = request.getParameter("Title");
        String description = request.getParameter("Description");
        String type = request.getParameter("Type");

        try (Connection conn = new ProjectDatabase().getConnection()) {
            String sql = "INSERT INTO requirements (ProjectID, Title, Description, Type, LoggedRequirementHours, IsMet) VALUES (?, ?, ?, ?, 0, false)";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, projectId);
                stmt.setString(2, title);
                stmt.setString(3, description);
                stmt.setString(4, type);
                stmt.executeUpdate();
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw new ServletException("Error inserting requirement", e);
        }

        response.sendRedirect("pages/project_detail.jsp?id=" + projectId);
    }
}
