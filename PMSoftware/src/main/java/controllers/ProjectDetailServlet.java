package controllers;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.*;
import java.sql.*;
import main.ProjectDatabase;

@WebServlet("/project-detail")
public class ProjectDetailServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.getWriter().println("<p class='error-msg'>Invalid project ID.</p>");
            return;
        }

        int projectId = Integer.parseInt(idParam);
        try (Connection conn = new ProjectDatabase().getConnection()) {
            PrintWriter out = response.getWriter();

            // Fetch project info
            PreparedStatement ps = conn.prepareStatement("SELECT * FROM projects WHERE ProjectID = ?");
            ps.setInt(1, projectId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                out.println("<div class='project-info'>");
                out.println("<h3>" + rs.getString("ProjectName") + "</h3>");
                out.println("<p><strong>Status:</strong> " + rs.getString("Status") + "</p>");
                out.println("<p><strong>Risk Level:</strong> " + rs.getString("RiskLevel") + "</p>");
                out.println("<p><strong>Due Date:</strong> " + rs.getString("DueDate") + "</p>");
                out.println("<p><strong>Description:</strong><br>" + rs.getString("Description") + "</p>");
                out.println("</div>");
            } else {
                out.println("<p class='error-msg'>Project not found.</p>");
            }

            // TODO: requirements, tasks, effort logs...

        } catch (Exception e) {
            e.printStackTrace(response.getWriter());
        }
    }
}
