package controllers;

import main.ProjectDatabase;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

@WebServlet("/add-team-member")
public class AddTeamMemberServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int userID = Integer.parseInt(request.getParameter("UserID"));
        int projectID = Integer.parseInt(request.getParameter("ProjectID"));
        String role = request.getParameter("Role");

        try (Connection conn = new ProjectDatabase().getConnection()) {
            PreparedStatement stmt = conn.prepareStatement(
                    "INSERT INTO team_members (ProjectID, UserID, Role) VALUES (?, ?, ?)"
            );
            stmt.setInt(1, projectID);
            stmt.setInt(2, userID);
            stmt.setString(3, role);
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            throw new ServletException("Failed to add team member", e);
        }

        response.sendRedirect("pages/collaboration.jsp");
    }
}