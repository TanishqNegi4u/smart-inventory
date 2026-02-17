package controllers;

import utils.DatabaseConnection;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;
import org.mindrot.jbcrypt.BCrypt;

@WebServlet({"/login", "/logout"})
@SuppressWarnings("serial")
public class AuthServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String path = req.getServletPath();
        if ("/logout".equals(path)) {
            HttpSession session = req.getSession(false);
            if (session != null) session.invalidate();
            resp.sendRedirect(req.getContextPath() + "/login");
        } else {
            // Already logged in → redirect to dashboard
            HttpSession session = req.getSession(false);
            if (session != null && session.getAttribute("user") != null) {
                resp.sendRedirect(req.getContextPath() + "/inventory");
            } else {
                req.getRequestDispatcher("login.jsp").forward(req, resp);
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String username = req.getParameter("username");
        String password = req.getParameter("password");

        if (username == null || password == null || username.trim().isEmpty()) {
            req.setAttribute("error", "Please enter username and password.");
            req.getRequestDispatcher("login.jsp").forward(req, resp);
            return;
        }

        try (Connection conn = DatabaseConnection.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(
                "SELECT id, username, password, role FROM users WHERE username = ?");
            ps.setString(1, username.trim());
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                String storedHash = rs.getString("password");
                boolean valid;
                try {
                    valid = BCrypt.checkpw(password, storedHash);
                } catch (Exception e) {
                    // Fallback plain-text comparison for dev/testing
                    valid = password.equals(storedHash);
                }

                if (valid) {
                    HttpSession session = req.getSession(true);
                    session.setAttribute("user", rs.getString("username"));
                    session.setAttribute("role", rs.getString("role"));
                    session.setAttribute("userId", rs.getInt("id"));
                    session.setMaxInactiveInterval(30 * 60); // 30 min
                    resp.sendRedirect(req.getContextPath() + "/inventory");
                    return;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            req.setAttribute("error", "Database error. Please try again.");
            req.getRequestDispatcher("login.jsp").forward(req, resp);
            return;
        }

        req.setAttribute("error", "Invalid username or password.");
        req.getRequestDispatcher("login.jsp").forward(req, resp);
    }
}