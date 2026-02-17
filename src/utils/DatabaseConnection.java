package utils;

import java.sql.*;

public class DatabaseConnection {
    private static final String URL;
    private static final String USER;
    private static final String PASS;

    static {
        // Supports environment variables for cloud deployment
        String envUrl = System.getenv("DB_URL");
        String envUser = System.getenv("DB_USER");
        String envPass = System.getenv("DB_PASS");

        URL  = (envUrl  != null) ? envUrl  : "jdbc:mysql://localhost:3306/inventory_pro?useSSL=false&serverTimezone=UTC";
        USER = (envUser != null) ? envUser : "root";
        PASS = (envPass != null) ? envPass : "";
    }

    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("MySQL Driver not found", e);
        }
        return DriverManager.getConnection(URL, USER, PASS);
    }
}