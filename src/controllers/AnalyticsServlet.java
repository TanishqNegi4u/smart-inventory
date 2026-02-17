package controllers;

import utils.*;
import models.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;
import java.util.*;

@SuppressWarnings("serial")
public class AnalyticsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // FIX: add auth check — missing before, caused HTTP error for logged-out users
        if (req.getSession(false) == null || req.getSession(false).getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        List<Product>        products        = new ArrayList<>();
        Map<String, Integer> salesByCategory = new LinkedHashMap<>();
        Map<String, Integer> stockByCategory = new LinkedHashMap<>();

        try (Connection conn = DatabaseConnection.getConnection()) {
            // All products for DSA processing
            ResultSet rs = conn.createStatement().executeQuery(
                "SELECT * FROM products ORDER BY sales_30d DESC");
            while (rs.next()) {
                products.add(new Product(
                    rs.getInt("id"), rs.getString("name"),
                    rs.getString("category"), rs.getInt("stock"),
                    rs.getDouble("price"), rs.getInt("sales_30d")));
            }

            // Aggregated by category
            ResultSet catRs = conn.createStatement().executeQuery(
                "SELECT category, SUM(sales_30d) AS total_sales, SUM(stock) AS total_stock " +
                "FROM products GROUP BY category ORDER BY total_sales DESC");
            while (catRs.next()) {
                salesByCategory.put(catRs.getString("category"), catRs.getInt("total_sales"));
                stockByCategory.put(catRs.getString("category"), catRs.getInt("total_stock"));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        // DSA: Segment Tree — top-5 sales range query
        int[] sales    = products.stream().mapToInt(Product::getSales30d).toArray();
        SegmentTree st = new SegmentTree(sales);
        int top5Sales  = sales.length == 0 ? 0
                       : (sales.length >= 5) ? st.query(0, 4)
                       : st.query(0, sales.length - 1);

        // DSA: Sliding Window trends — use detectTrends() with correct signature
        List<SlidingWindow.TrendResult> trends =
            SlidingWindow.detectTrends(sales, SlidingWindow.DEFAULT_WINDOW, 100, 30);

        req.setAttribute("products",        products);
        req.setAttribute("salesByCategory", salesByCategory);
        req.setAttribute("stockByCategory", stockByCategory);
        req.setAttribute("top5Sales",       top5Sales);
        req.setAttribute("trends",          trends);
        req.getRequestDispatcher("analytics.jsp").forward(req, resp);
    }
}