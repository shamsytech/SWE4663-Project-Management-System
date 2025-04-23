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
        String storedHash = db.getPasswordHashByEmail(email);
        db.close();

        if (storedHash != null && BCrypt.checkpw(password, storedHash)) {
            //Login success
            HttpSession session = request.getSession();
            session.setAttribute("userEmail", email);
            response.sendRedirect("dashboard.html"); // Replace with your actual landing page
        } else {
            //Invalid login
            response.sendRedirect("pages/login.html?error=invalid");

        }
    }
}
