package com.grievanceportal.servlet;

import com.grievanceportal.db.DBConnection;
import java.io.OutputStream;
import java.sql.*;

import javax.servlet.ServletException;
import javax.servlet.http.*;


public class DownloadAttachmentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, java.io.IOException {

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.getWriter().println("Invalid grievance ID.");
            return;
        }

        int grievanceId = Integer.parseInt(idParam);

        try (Connection con = DBConnection.getConnection()) {
            String sql = "SELECT attachment FROM grievances WHERE id=?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, grievanceId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                Blob blob = rs.getBlob("attachment");

                if (blob != null) {
                    response.setContentType("image/jpeg");
                    response.setHeader("Content-Disposition", "attachment; filename=grievance_" + grievanceId + ".jpeg");

                    try (OutputStream os = response.getOutputStream()) {
                        byte[] buffer = new byte[4096];
                        int bytesRead;
                        try (java.io.InputStream is = blob.getBinaryStream()) {
                            while ((bytesRead = is.read(buffer)) != -1) {
                                os.write(buffer, 0, bytesRead);
                            }
                        }
                        os.flush();
                    }
                } else {
                    response.getWriter().println("No attachment found for grievance #" + grievanceId);
                }
            } else {
                response.getWriter().println("Grievance not found.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Error: " + e.getMessage());
        }
    }
}
