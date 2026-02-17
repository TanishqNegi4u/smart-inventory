package controllers;

import models.Product;
import utils.DatabaseConnection;
import utils.LRUCache;
import utils.SegmentTree;
import utils.SlidingWindow;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;
import java.util.*;

@SuppressWarnings("serial")
public class InventoryServlet extends HttpServlet {

    private LRUCache<Integer, Product> cache = new LRUCache<>(8);

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (req.getSession(false) == null || req.getSession(false).getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // CSV Export
        String export = req.getParameter("export");
        if ("csv".equals(export)) {
            exportCSV(req, resp);
            return;
        }

        // Search & Filter
        String search = req.getParameter("search") != null ? req.getParameter("search").trim() : "";
        String filterCategory = req.getParameter("category") != null ? req.getParameter("category").trim() : "";

        List<Product> products = new ArrayList<>();
        List<String> categories = new ArrayList<>();

        try (Connection conn = DatabaseConnection.getConnection()) {

            // Get all categories for filter dropdown
            ResultSet catRs = conn.createStatement().executeQuery(
                "SELECT DISTINCT category FROM products ORDER BY category");
            while (catRs.next()) categories.add(catRs.getString("category"));

            // Build dynamic query
            StringBuilder sql = new StringBuilder(
                "SELECT * FROM products WHERE 1=1");
            if (!search.isEmpty())
                sql.append(" AND name LIKE ?");
            if (!filterCategory.isEmpty())
                sql.append(" AND category = ?");
            sql.append(" ORDER BY sales_30d DESC");

            PreparedStatement ps = conn.prepareStatement(sql.toString());
            int idx = 1;
            if (!search.isEmpty())
                ps.setString(idx++, "%" + search + "%");
            if (!filterCategory.isEmpty())
                ps.setString(idx++, filterCategory);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Product p = new Product(
                    rs.getInt("id"),
                    rs.getString("name"),
                    rs.getString("category"),
                    rs.getInt("stock"),
                    rs.getDouble("price"),
                    rs.getInt("sales_30d")
                );
                products.add(p);
                cache.put(p.getId(), p);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        // DSA - Segment Tree & Sliding Window
        int[] stocks = products.stream().mapToInt(Product::getStock).toArray();
        int[] sales  = products.stream().mapToInt(Product::getSales30d).toArray();

        SegmentTree segTree = new SegmentTree(stocks);

        // FIX #1: SlidingWindow.analyze() takes a List<Integer>, not int[]
        List<Integer> salesList = new ArrayList<>();
        for (int s : sales) salesList.add(s);
        List<SlidingWindow.TrendResult> trends = SlidingWindow.analyze(salesList, 3);

        // Low stock alerts
        List<String> alerts = new ArrayList<>();
        for (Product p : products) {
            if (p.getStock() < 10) {
                alerts.add("⚠️ LOW STOCK: " + p.getName() + " has only " + p.getStock() + " units left!");
            }
        }

        req.setAttribute("products", products);
        req.setAttribute("categories", categories);
        req.setAttribute("trends", trends);
        req.setAttribute("alerts", alerts);
        req.setAttribute("cacheSize", cache.size());
        req.setAttribute("search", search);
        req.setAttribute("filterCategory", filterCategory);
        req.getRequestDispatcher("index.jsp").forward(req, resp);
    }

    private void exportCSV(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        resp.setContentType("text/csv;charset=UTF-8");
        resp.setHeader("Content-Disposition", "attachment; filename=\"inventory.csv\"");

        try (Connection conn = DatabaseConnection.getConnection();
             PrintWriter pw = resp.getWriter()) {

            pw.println("ID,Name,Category,Stock,Price,Sales(30d)");
            ResultSet rs = conn.createStatement().executeQuery(
                "SELECT * FROM products ORDER BY id");
            while (rs.next()) {
                pw.println(
                    rs.getInt("id") + "," +
                    "\"" + rs.getString("name") + "\"," +
                    rs.getString("category") + "," +
                    rs.getInt("stock") + "," +
                    rs.getDouble("price") + "," +
                    rs.getInt("sales_30d")
                );
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (req.getSession(false) == null || req.getSession(false).getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");
        String role = (String) req.getSession(false).getAttribute("role");

        try (Connection conn = DatabaseConnection.getConnection()) {

            if ("add".equals(action)) {
                String name     = req.getParameter("name");
                String category = req.getParameter("category");
                int    stock    = Integer.parseInt(req.getParameter("stock"));
                double price    = Double.parseDouble(req.getParameter("price"));

                PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO products (name, category, stock, price, sales_30d) VALUES (?,?,?,?,0)");
                ps.setString(1, name);
                ps.setString(2, category);
                ps.setInt(3, stock);
                ps.setDouble(4, price);
                ps.executeUpdate();

                // FIX #2: LRUCache has no clear() — rebuild cache by evicting all via put
                cache = new LRUCache<>(8);

            } else if ("update".equals(action)) {
                int    id       = Integer.parseInt(req.getParameter("id"));
                String name     = req.getParameter("name");
                String category = req.getParameter("category");
                int    stock    = Integer.parseInt(req.getParameter("stock"));
                double price    = Double.parseDouble(req.getParameter("price"));

                PreparedStatement ps = conn.prepareStatement(
                    "UPDATE products SET name=?, category=?, stock=?, price=? WHERE id=?");
                ps.setString(1, name);
                ps.setString(2, category);
                ps.setInt(3, stock);
                ps.setDouble(4, price);
                ps.setInt(5, id);
                ps.executeUpdate();

                // FIX #3 & #4: LRUCache has no remove(int) — evict by overwriting with null
                // then skip null values on read, or simply rebuild the cache
                cache.put(id, null);

            } else if ("delete".equals(action)) {
                if (!"ADMIN".equals(role)) {
                    resp.sendRedirect(req.getContextPath() + "/inventory?error=unauthorized");
                    return;
                }
                int id = Integer.parseInt(req.getParameter("id"));
                PreparedStatement ps = conn.prepareStatement(
                    "DELETE FROM products WHERE id=?");
                ps.setInt(1, id);
                ps.executeUpdate();

                // FIX #3 & #4: same — overwrite with null to invalidate cache entry
                cache.put(id, null);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        resp.sendRedirect(req.getContextPath() + "/inventory");
    }
}
