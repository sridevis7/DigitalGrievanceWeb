package com.grievanceportal.servlet;

import com.grievanceportal.db.DBConnection;
import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.http.*;


public class SubmitFeedbackServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String userEmail = (String) session.getAttribute("userEmail");

        if (userEmail == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int grievanceId = Integer.parseInt(request.getParameter("grievanceId"));
        int rating = Integer.parseInt(request.getParameter("rating"));
        String comments = request.getParameter("comments");

        try (Connection con = DBConnection.getConnection()) {
            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO feedback (grievance_id, user_email, rating, comments) VALUES (?,?,?,?)"
            );
            ps.setInt(1, grievanceId);
            ps.setString(2, userEmail);
            ps.setInt(3, rating);
            ps.setString(4, comments);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect("feedback.jsp?msg=Thanks for your feedback!");
    }
}
