package controllers;

import com.google.gson.Gson;
import main.ProjectDatabase;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/fetch-users")
public class FetchUsersServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        List<Map<String, String>> users = new ArrayList<>();

        try (Connection conn = new ProjectDatabase().getConnection()) {
            PreparedStatement stmt = conn.prepareStatement("SELECT UserID, FirstName, LastName FROM users");
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Map<String, String> user = new HashMap<>();
                user.put("id", String.valueOf(rs.getInt("UserID")));
                user.put("name", rs.getString("FirstName") + " " + rs.getString("LastName"));
                users.add(user);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        PrintWriter out = response.getWriter();
        out.print(new Gson().toJson(users));
        out.flush();
    }
}
