package controllers;

import utils.*;
import models.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;
import java.util.*;

@WebServlet("/inventory")
@SuppressWarnings("serial")
public class InventoryServlet extends HttpServlet {

    private static final LRUCache<Integer, Product> cache = new LRUCache<>(100);

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        List<Product> products = new ArrayList<>();

        try (Connection conn = DatabaseConnection.getConnection()) {
            Statement stmt = conn.createStatement();
            ResultSet rs   = stmt.executeQuery(
                "SELECT * FROM products ORDER BY stock ASC");

            while (rs.next()) {
                int id = rs.getInt("id");
                Product p = cache.get(id);
                if (p == null) {
                    p = new Product(id,
                        rs.getString("name"),
                        rs.getString("category"),
                        rs.getInt("stock"),
                        rs.getDouble("price"),
                        rs.getInt("sales_30d"));
                    cache.put(id, p);
                }
                products.add(p);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            req.setAttribute("error", "Database error: " + e.getMessage());
        }

        // ── DSA: Segment Tree low-stock alert ────────────
        List<String> alerts = getLowStockAlerts(products);

        // ── DSA: Sliding Window trend detection ──────────
        int[] sales = products.stream().mapToInt(Product::getSales30d).toArray();
        List<SlidingWindow.TrendResult> trends =
            SlidingWindow.detectTrends(sales, SlidingWindow.DEFAULT_WINDOW, 100, 30);

        req.setAttribute("products", products);
        req.setAttribute("alerts",   alerts);
        req.setAttribute("trends",   trends);
        req.setAttribute("cacheSize", cache.size());
        req.getRequestDispatcher("index.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        if (action == null) { resp.sendRedirect("inventory"); return; }

        try (Connection conn = DatabaseConnection.getConnection()) {
            switch (action) {
                case "add":    addProduct(req, conn);    break;
                case "update": updateProduct(req, conn); break;
                case "delete": deleteProduct(req, conn); break;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        resp.sendRedirect("inventory");
    }

    // ── CRUD helpers ─────────────────────────────────────

    private void addProduct(HttpServletRequest req, Connection conn) throws SQLException {
        String sql = "INSERT INTO products(name,category,stock,price,sales_30d) VALUES(?,?,?,?,?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, req.getParameter("name"));
            ps.setString(2, req.getParameter("category"));
            ps.setInt   (3, Integer.parseInt(req.getParameter("stock")));
            ps.setDouble(4, Double.parseDouble(req.getParameter("price")));
            ps.setInt   (5, 0);
            ps.executeUpdate();
        }
    }

    private void updateProduct(HttpServletRequest req, Connection conn) throws SQLException {
        int id = Integer.parseInt(req.getParameter("id"));
        String sql = "UPDATE products SET name=?,category=?,stock=?,price=? WHERE id=?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, req.getParameter("name"));
            ps.setString(2, req.getParameter("category"));
            ps.setInt   (3, Integer.parseInt(req.getParameter("stock")));
            ps.setDouble(4, Double.parseDouble(req.getParameter("price")));
            ps.setInt   (5, id);
            ps.executeUpdate();
            cache.invalidate(id);
        }
    }

    private void deleteProduct(HttpServletRequest req, Connection conn) throws SQLException {
        int id = Integer.parseInt(req.getParameter("id"));
        try (PreparedStatement ps = conn.prepareStatement("DELETE FROM products WHERE id=?")) {
            ps.setInt(1, id);
            ps.executeUpdate();
            cache.invalidate(id);
        }
    }

    // ── DSA: Segment Tree low-stock detection ────────────
    private List<String> getLowStockAlerts(List<Product> products) {
        List<String> alerts = new ArrayList<>();
        if (products.isEmpty()) return alerts;

        int[] stocks = products.stream().mapToInt(Product::getStock).toArray();
        SegmentTree st = new SegmentTree(stocks);

        int window = Math.min(7, stocks.length);
        for (int i = 0; i <= stocks.length - window; i++) {
            if (st.query(i, i + window - 1) < 50) {
                alerts.add("⚠ Low stock window at products " + i + "–" + (i + window - 1));
            }
        }
        for (Product p : products) {
            if (p.getStock() < 10) {
                alerts.add("🔴 Critical: " + p.getName() + " has only " + p.getStock() + " units left!");
            }
        }
        return alerts;
    }
}