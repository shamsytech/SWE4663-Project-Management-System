package controllers;

import main.ProjectDatabase;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

@WebServlet("/edit-requirement")
public class EditRequirementServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Validate session
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("pages/login.html");
            return;
        }

        String idParam = request.getParameter("RequirementID");
        System.out.println("Received RequirementID: " + idParam);

        try {
            int requirementID = Integer.parseInt(request.getParameter("RequirementID"));
            int projectID = Integer.parseInt(request.getParameter("ProjectID"));
            String title = request.getParameter("Title");
            String description = request.getParameter("Description");
            String type = request.getParameter("Type");
            boolean isMet = request.getParameter("IsMet") != null;

            try (Connection conn = new ProjectDatabase().getConnection()) {
                String sql = "UPDATE requirements SET Title = ?, Description = ?, Type = ?, IsMet = ? WHERE RequirementID = ?";
                try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                    stmt.setString(1, title);
                    stmt.setString(2, description);
                    stmt.setString(3, type);
                    stmt.setBoolean(4, isMet);
                    stmt.setInt(5, requirementID);
                    stmt.executeUpdate();
                }
            }

            // Redirect back to the project detail page
            response.sendRedirect("pages/project_detail.jsp?id=" + projectID);

        } catch (Exception e) {
            throw new ServletException("Invalid RequirementID: " + idParam, e);
        }
    }
}
