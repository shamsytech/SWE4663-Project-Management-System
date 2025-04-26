package controllers;

import main.ProjectDatabase;
import com.google.gson.Gson;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.util.*;

@WebServlet("/fetch-team-members")
public class FetchTeamMembersServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Validate session
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userID") == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        // Get project ID from query parameter
        System.out.println("Received projectID param: " + request.getParameter("projectID"));
        String projectIdParam = request.getParameter("projectID");
        if (projectIdParam == null || projectIdParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing projectID");
            return;
        }

        int projectId;
        try {
            projectId = Integer.parseInt(projectIdParam);
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid projectID");
            return;
        }

        // Prepare response
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        List<Map<String, String>> team = new ArrayList<>();

        try (Connection conn = new ProjectDatabase().getConnection()) {
            String sql = "SELECT CONCAT(u.FirstName, ' ', u.LastName) AS FullName, tm.Role " +
                    "FROM team_members tm " +
                    "JOIN users u ON tm.UserID = u.UserID " +
                    "WHERE tm.ProjectID = ?";

            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, projectId);
                ResultSet rs = stmt.executeQuery();

                while (rs.next()) {
                    Map<String, String> member = new HashMap<>();
                    member.put("name", rs.getString("FullName"));
                    member.put("role", rs.getString("Role"));
                    team.add(member);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            throw new ServletException("Error fetching team members", e);
        }

        // Send response as JSON
        PrintWriter out = response.getWriter();
        out.print(new Gson().toJson(team));
        out.flush();
    }
}
