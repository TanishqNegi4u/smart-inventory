package utils;

import java.sql.*;

public class DatabaseInitializer {

    public static void initialize() {
        System.out.println(">>> DatabaseInitializer: Starting table setup...");
        try (Connection conn = DatabaseConnection.getConnection()) {

            Statement stmt = conn.createStatement();

            // Create users table
            stmt.executeUpdate(
                "CREATE TABLE IF NOT EXISTS users (" +
                "  id INT AUTO_INCREMENT PRIMARY KEY," +
                "  username VARCHAR(50) UNIQUE NOT NULL," +
                "  password VARCHAR(255) NOT NULL," +
                "  role ENUM('ADMIN','MANAGER') NOT NULL" +
                ")"
            );
            System.out.println(">>> users table ready.");

            // Create products table
            stmt.executeUpdate(
                "CREATE TABLE IF NOT EXISTS products (" +
                "  id INT AUTO_INCREMENT PRIMARY KEY," +
                "  name VARCHAR(100) NOT NULL," +
                "  category VARCHAR(50)," +
                "  stock INT DEFAULT 0," +
                "  price DECIMAL(10,2) DEFAULT 0.00," +
                "  sales_30d INT DEFAULT 0," +
                "  last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" +
                ")"
            );
            System.out.println(">>> products table ready.");

            // Insert default admin user if not exists
            // Password hash = admin123
            String adminHash = "$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy";
            stmt.executeUpdate(
                "INSERT IGNORE INTO users (username, password, role) VALUES " +
                "('admin', '" + adminHash + "', 'ADMIN')," +
                "('manager', '" + adminHash + "', 'MANAGER')"
            );
            System.out.println(">>> Default users inserted (if not already present).");

            // Insert sample products if table is empty
            ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM products");
            rs.next();
            if (rs.getInt(1) == 0) {
                stmt.executeUpdate(
                    "INSERT INTO products (name, category, stock, price, sales_30d) VALUES " +
                    "('iPhone 15', 'Electronics', 50, 79999, 120)," +
                    "('Laptop Dell', 'Electronics', 25, 65999, 80)," +
                    "('T-Shirt', 'Apparel', 200, 599, 450)," +
                    "('Samsung TV 55\"', 'Electronics', 15, 54999, 40)," +
                    "('Running Shoes', 'Footwear', 80, 3999, 200)," +
                    "('Coffee Maker', 'Appliances', 30, 4599, 60)," +
                    "('Wireless Headphones', 'Electronics', 45, 8999, 150)," +
                    "('Yoga Mat', 'Sports', 100, 1299, 300)"
                );
                System.out.println(">>> Sample products inserted.");
            }

            System.out.println(">>> DatabaseInitializer: All done!");

        } catch (SQLException e) {
            System.err.println(">>> DatabaseInitializer ERROR: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
