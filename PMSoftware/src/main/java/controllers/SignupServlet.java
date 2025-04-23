package controllers;

import java.io.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import main.ProjectDatabase;
import org.mindrot.jbcrypt.BCrypt;

@WebServlet("/signup")
public class SignupServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String firstName = request.getParameter("first-name");
        String lastName = request.getParameter("last-name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if (firstName == null || lastName == null || email == null || password == null ||
                firstName.isEmpty() || lastName.isEmpty() || email.isEmpty() || password.isEmpty()) {
            response.sendRedirect("pages/sign_up.html?error=missing");
            return;
        }

        String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

        ProjectDatabase db = new ProjectDatabase();
        boolean success = db.createUser(firstName, lastName, email, hashedPassword);
        db.close();

        if (success) {
            response.sendRedirect("pages/landing_page.html");
        } else {
            response.sendRedirect("pages/sign_up.html?error=exists");
        }
    }
}
