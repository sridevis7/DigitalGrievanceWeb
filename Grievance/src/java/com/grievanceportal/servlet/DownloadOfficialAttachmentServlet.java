package com.grievanceportal.servlet;

import com.grievanceportal.db.DBConnection;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.http.*;


public class DownloadOfficialAttachmentServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int grievanceId = Integer.parseInt(request.getParameter("id"));

        try (Connection con = DBConnection.getConnection()) {
            PreparedStatement ps = con.prepareStatement(
                "SELECT official_attachment FROM grievances WHERE id=?"
            );
            ps.setInt(1, grievanceId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                Blob blob = rs.getBlob("official_attachment");

                if (blob != null) {
                    // Default filename — you can improve this by storing original filename separately
                    String fileName = "official_attachment_" + grievanceId + ".jpeg";

                    response.setContentType("application/octet-stream");
                    response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");

                    try (InputStream in = blob.getBinaryStream();
                         OutputStream out = response.getOutputStream()) {
                        byte[] buffer = new byte[4096];
                        int bytesRead;
                        while ((bytesRead = in.read(buffer)) != -1) {
                            out.write(buffer, 0, bytesRead);
                        }
                    }
                } else {
                    response.setContentType("text/plain");
                    response.getWriter().write("No official attachment found for this grievance.");
                }
            } else {
                response.setContentType("text/plain");
                response.getWriter().write("Invalid grievance ID.");
            }

            rs.close();
            ps.close();
        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("text/plain");
            response.getWriter().write("Error retrieving official attachment: " + e.getMessage());
        }
    }
}
