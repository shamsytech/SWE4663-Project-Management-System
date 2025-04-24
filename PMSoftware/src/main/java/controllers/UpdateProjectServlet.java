package controllers;

import main.ProjectDatabase;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import java.io.*;
import java.sql.*;

@WebServlet("/update-project")
public class UpdateProjectServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int id = Integer.parseInt(request.getParameter("ProjectID"));
        String name = request.getParameter("ProjectName");
        String description = request.getParameter("Description");
        String status = request.getParameter("Status");
        String risk = request.getParameter("RiskLevel");
        String dueDate = request.getParameter("DueDate");

        ProjectDatabase db = new ProjectDatabase();
        Connection conn = db.getConnection();

        try {
            PreparedStatement stmt = conn.prepareStatement("UPDATE projects SET ProjectName=?, Description=?, Status=?, RiskLevel=?, DueDate=? WHERE ProjectID=?");
            stmt.setString(1, name);
            stmt.setString(2, description);
            stmt.setString(3, status);
            stmt.setString(4, risk);
            stmt.setString(5, dueDate);
            stmt.setInt(6, id);
            stmt.executeUpdate();

            response.sendRedirect("pages/dashboard.jsp");
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            db.close();
        }
    }
}
