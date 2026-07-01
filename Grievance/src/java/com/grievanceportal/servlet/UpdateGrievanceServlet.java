package com.grievanceportal.servlet;

import com.grievanceportal.db.DBConnection;
import com.grievanceportal.util.MailUtil;
import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.*;

@MultipartConfig(maxFileSize = 1024 * 1024 * 20) // 20MB
public class UpdateGrievanceServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String officialName = (String) session.getAttribute("officialName");
        String department = (String) session.getAttribute("department");

        if (officialName == null) {
            response.sendRedirect("official-login.jsp");
            return;
        }

        int grievanceId = Integer.parseInt(request.getParameter("grievanceId"));
        String status = request.getParameter("status");
        String remark = request.getParameter("remark");

        Part filePart = request.getPart("attachment");
        byte[] fileBytes = null;
        String fileName = null;

        if (filePart != null && filePart.getSize() > 0) {
            fileBytes = filePart.getInputStream().readAllBytes();
            fileName = filePart.getSubmittedFileName();
        }

        try (Connection con = DBConnection.getConnection()) {
            PreparedStatement ps = con.prepareStatement(
                "UPDATE grievances SET status=?, official_remark=?, official_attachment=? WHERE id=? AND department=?"
            );
            ps.setString(1, status);
            ps.setString(2, remark);

            if (fileBytes != null) {
                ps.setBytes(3, fileBytes);
            } else {
                ps.setNull(3, Types.BLOB);
            }

            ps.setInt(4, grievanceId);
            ps.setString(5, department);
            int updated = ps.executeUpdate();
            ps.close();

            if (updated > 0) {
                // Log action
                PreparedStatement logPs = con.prepareStatement(
                    "INSERT INTO official_logs (official_name, department, action) VALUES (?,?,?)"
                );
                logPs.setString(1, officialName);
                logPs.setString(2, department);
                logPs.setString(3, "Updated grievance #" + grievanceId + " to " + status);
                logPs.executeUpdate();
                logPs.close();

                // Get user email
                PreparedStatement userPs = con.prepareStatement("SELECT user_email FROM grievances WHERE id=?");
                userPs.setInt(1, grievanceId);
                ResultSet rs = userPs.executeQuery();
                String userEmail = null;
                if (rs.next()) {
                    userEmail = rs.getString("user_email");
                }
                rs.close();
                userPs.close();

                if (userEmail != null) {
                    String subject = "Update on Grievance #" + grievanceId;
                    String body = "Your grievance #" + grievanceId + " has been updated.\n\n"
                                + "Status: " + status + "\n"
                                + "Remark: " + (remark == null ? "—" : remark);

                    if (fileBytes != null) {
                        MailUtil.sendEmailWithAttachment(userEmail, subject, body, fileBytes, fileName);
                    } else {
                        MailUtil.sendSimpleEmail(userEmail, subject, body);
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect("official-dashboard.jsp?msg=Updated");
    }
}
