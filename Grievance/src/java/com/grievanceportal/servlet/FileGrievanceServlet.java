package com.grievanceportal.servlet;

import com.grievanceportal.db.DBConnection;
import java.io.InputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.*;


@MultipartConfig(maxFileSize = 1024 * 1024 * 10) // 10MB
public class FileGrievanceServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);
        String userEmail = (String) session.getAttribute("userEmail");

        if (userEmail == null) {
            response.sendRedirect("login.html");
            return;
        }

        // Form fields
        String subject = request.getParameter("subject");
        String category = request.getParameter("category");
        String priority = request.getParameter("priority");
        String department = request.getParameter("department");
        String state = request.getParameter("state");
        String district = request.getParameter("district");
        String location = request.getParameter("location");
        String description = request.getParameter("description");
        String expectedResolution = request.getParameter("expectedResolution");

        // File upload as InputStream
        Part filePart = request.getPart("attachments");
        InputStream fileContent = null;
        if (filePart != null && filePart.getSize() > 0) {
            fileContent = filePart.getInputStream();
        }

        try (Connection con = DBConnection.getConnection()) {
            String sql = "INSERT INTO grievances (user_email, subject, category, priority, department, state, district, location, description, expected_resolution, attachment, status) "
                       + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'Pending')";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, userEmail);
            ps.setString(2, subject);
            ps.setString(3, category);
            ps.setString(4, priority);
            ps.setString(5, department);
            ps.setString(6, state);
            ps.setString(7, district);
            ps.setString(8, location);
            ps.setString(9, description);
            ps.setString(10, expectedResolution);

            if (fileContent != null) {
                ps.setBlob(11, fileContent);
            } else {
                ps.setNull(11, Types.BLOB);
            }

            int result = ps.executeUpdate();
            if (result > 0) {
                out.println("<script>alert('Grievance submitted successfully!'); window.location='my-grievances.jsp';</script>");
            } else {
                out.println("<script>alert('Failed to submit grievance. Try again.'); window.location='file-grievance.jsp';</script>");
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<script>alert('Error: " + e.getMessage() + "'); window.location='file-grievance.jsp';</script>");
        }
    }
}
