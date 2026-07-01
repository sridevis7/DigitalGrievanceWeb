package com.grievanceportal.servlet;

import com.grievanceportal.db.DBConnection;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import org.mindrot.jbcrypt.BCrypt;


public class LoginServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        response.setContentType("text/html");
        PrintWriter out = response.getWriter();

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        try (Connection con = DBConnection.getConnection()) {
            String sql = "SELECT * FROM users WHERE email=?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                String storedHash = rs.getString("password");

                if (BCrypt.checkpw(password, storedHash)) {
                    // Create session
                    HttpSession session = request.getSession();
                    session.setAttribute("userName", rs.getString("fullname"));
                    session.setAttribute("userEmail", email);

                    response.sendRedirect("dashboard.jsp");
                } else {
                    out.println("<script>alert('Invalid email or password!'); window.location='login.jsp';</script>");
                }
            } else {
                out.println("<script>alert('User not found! Please register.'); window.location='register.jsp';</script>");
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<script>alert('Error: " + e.getMessage() + "'); window.location='login.jsp';</script>");
        }
    }
}
