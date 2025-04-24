package controllers;

import java.io.IOException;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import main.ProjectDatabase;
import org.mindrot.jbcrypt.BCrypt;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        ProjectDatabase db = new ProjectDatabase();
        Connection conn = db.getConnection();

        try {
            PreparedStatement stmt = conn.prepareStatement("SELECT * FROM users WHERE Email = ?");
            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                String storedHash = rs.getString("PasswordHash");

                if (BCrypt.checkpw(password, storedHash)) {
                    // Create session and store user info
                    HttpSession session = request.getSession();
                    session.setAttribute("user", true);  // used to check login
                    session.setAttribute("userID", rs.getInt("UserID"));
                    session.setAttribute("userEmail", rs.getString("Email"));
                    session.setAttribute("userName", rs.getString("FirstName") + " " + rs.getString("LastName"));

                    String profilePic = rs.getString("ProfilePic");
                    if (profilePic == null || profilePic.isEmpty()) {
                        profilePic = "default.jpg";  // fallback
                    }
                    session.setAttribute("userAvatar", profilePic);

                    response.sendRedirect("pages/dashboard.jsp");
                    return;
                }
            }

            // If login failed
            response.sendRedirect("pages/login.html?error=invalid");

        } catch (SQLException e) {
            throw new ServletException("DB error during login", e);
        } finally {
            db.close();
        }
    }
}
