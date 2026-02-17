# 🧠 Smart Inventory Pro

<div align="center">



![Java](https://img.shields.io/badge/Java-11-orange?style=for-the-badge&logo=java)




![MySQL](https://img.shields.io/badge/MySQL-8.0-blue?style=for-the-badge&logo=mysql)




![Tomcat](https://img.shields.io/badge/Tomcat-9.0-yellow?style=for-the-badge&logo=apachetomcat)




![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?style=for-the-badge&logo=docker)




![Bootstrap](https://img.shields.io/badge/Bootstrap-5.3-purple?style=for-the-badge&logo=bootstrap)




![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)



**A DSA-powered Inventory Management System built with Java EE, MySQL & Bootstrap 5**

[🚀 Live Demo](#) • [📖 Setup Guide](#-local-setup) • [☁️ Deploy](#️-deploy-to-cloud-free)

</div>

---

## ✨ Features

- 📦 **Full CRUD** — Add, edit, delete products in real time
- 🔐 **Role-based Auth** — Admin & Manager roles with BCrypt password hashing
- 📊 **Analytics Dashboard** — Sales trends, category breakdowns, KPI cards
- ⚠️ **Smart Alerts** — Auto-detects low stock using Segment Tree range queries
- ⚡ **LRU Cache** — Reduces DB hits with O(1) product lookups
- 🌊 **Sliding Window** — 7-day demand trend detection
- 🌲 **Fenwick Tree** — Frontend prefix-sum stock monitoring
- 🐳 **Docker Ready** — One-command deployment anywhere

---

## 🧠 DSA Implementations

| Algorithm | File | Use Case | Complexity |
|-----------|------|----------|------------|
| **LRU Cache** | `LRUCache.java` | Cache product lookups, avoid DB hits | O(1) get/put |
| **Segment Tree** | `SegmentTree.java` | Range-sum stock queries & low-stock alerts | O(log n) query |
| **Sliding Window** | `SlidingWindow.java` | 7-day moving average demand detection | O(n) |
| **Fenwick Tree** | `app.js` | Frontend prefix-sum stock monitoring | O(log n) |

---

## 🖥️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | JSP, Bootstrap 5, Chart.js |
| Backend | Java 11, Servlets, JSTL |
| Database | MySQL 8.0 |
| Server | Apache Tomcat 9 |
| Build | Maven |
| Deploy | Docker, Railway, Render |

---

## 📁 Project Structure
smart-inventory-pro/
├── WebContent/
│   ├── index.jsp
│   ├── login.jsp
│   ├── add-product.jsp
│   ├── analytics.jsp
│   ├── css/style.css
│   ├── js/app.js
│   └── WEB-INF/web.xml
├── src/
│   ├── controllers/
│   │   ├── InventoryServlet.java
│   │   ├── AuthServlet.java
│   │   └── AnalyticsServlet.java
│   ├── utils/
│   │   ├── DatabaseConnection.java
│   │   ├── LRUCache.java
│   │   ├── SegmentTree.java
│   │   └── SlidingWindow.java
│   └── models/
│       └── Product.java
├── database.sql
├── pom.xml
├── Dockerfile
├── docker-compose.yml
├── railway.toml
├── render.yaml
└── .gitignore
---

## 🔧 Prerequisites
- Java 11+
- Apache Tomcat 9.x
- MySQL 8.x
- Maven 3.6+

---

## 🚀 Local Setup

### 1. Database
```sql
mysql -u root -p < database.sql
2. Build WAR
mvn clean package
3. Deploy to Tomcat
cp target/smart-inventory-pro-1.0.war $TOMCAT_HOME/webapps/
Default credentials:
| Username | Password | Role |
|----------|----------|------|
| admin | admin123 | ADMIN |
| manager | admin123 | MANAGER |
☁️ Cloud Deployment
Environment Variables
DB_URL  = jdbc:mysql://your-host:3306/inventory_pro
DB_USER = your_db_username
DB_PASS = your_db_password
🔐 Security Notes
Passwords stored as BCrypt hashes
Session-based auth with 30-minute timeout
Prepared statements for all SQL queries
4. Tap **Commit changes** ✅

---