package com.grievanceportal.servlet;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.*;


public class LogoutServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        HttpSession session = request.getSession(false); // don't create if not exists
        if (session != null) {
            session.invalidate(); // destroy session
        }
        response.sendRedirect("login.jsp"); // back to login page
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response); // handle POST same as GET
    }
}
