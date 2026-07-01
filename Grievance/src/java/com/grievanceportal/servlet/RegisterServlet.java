package com.grievanceportal.servlet;

import com.grievanceportal.db.DBConnection;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import org.mindrot.jbcrypt.BCrypt;


public class RegisterServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        response.setContentType("text/html");
        PrintWriter out = response.getWriter();

        String fullname = request.getParameter("fullname");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        if (!password.equals(confirmPassword)) {
            out.println("<script>alert('Passwords do not match!'); window.location='register.jsp';</script>");
            return;
        }

        try (Connection con = DBConnection.getConnection()) {
            // Hash the password
            String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

            String sql = "INSERT INTO users(fullname, email, phone, password) VALUES(?, ?, ?, ?)";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, fullname);
            ps.setString(2, email);
            ps.setString(3, phone);
            ps.setString(4, hashedPassword);

            int result = ps.executeUpdate();
            if (result > 0) {
                out.println("<script>alert('Registration successful! Please login.'); window.location='login.jsp';</script>");
            } else {
                out.println("<script>alert('Registration failed. Try again.'); window.location='register.jsp';</script>");
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<script>alert('Error: " + e.getMessage() + "'); window.location='register.jsp';</script>");
        }
    }
}
