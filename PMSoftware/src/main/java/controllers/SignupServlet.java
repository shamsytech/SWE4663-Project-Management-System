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

        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        if (firstName == null || lastName == null || email == null || password == null ||
                firstName.isEmpty() || lastName.isEmpty() || email.isEmpty() || password.isEmpty()) {
            out.println("⚠ All fields are required.");
            return;
        }

        String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

        ProjectDatabase db = new ProjectDatabase();
        boolean success = db.createUser(firstName, lastName, email, hashedPassword);
        db.close();

        if (success) {
            response.sendRedirect("pages/login_page.html"); // Update to your actual login page path
        } else {
            out.println("❌ Signup failed. Email might already be registered.");
        }
    }
}
