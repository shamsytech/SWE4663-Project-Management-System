package controllers;

import main.ProjectDatabase;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import java.io.*;
import java.sql.*;
import org.json.JSONObject;

@WebServlet("/get-project")
public class GetProjectServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String idParam = request.getParameter("id");

        if (idParam == null || idParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing or empty project ID");
            return;
        }
        ProjectDatabase db = new ProjectDatabase();
        try (Connection conn = db.getConnection()) {
            int id = Integer.parseInt(idParam);
            PreparedStatement stmt = conn.prepareStatement("SELECT * FROM projects WHERE ProjectID = ?");
            stmt.setInt(1, id);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                JSONObject obj = new JSONObject();
                obj.put("ProjectName", rs.getString("ProjectName"));
                obj.put("Description", rs.getString("Description"));
                obj.put("Status", rs.getString("Status"));
                obj.put("RiskLevel", rs.getString("RiskLevel"));
                obj.put("DueDate", rs.getString("DueDate"));

                response.setContentType("application/json");
                response.getWriter().write(obj.toString());
            }
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid project ID format");
        } catch (Exception e) {
            e.printStackTrace();  // <-- This will print the cause in your server logs
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Failed to fetch project data");
        }
    }
}
