# 🧠 Smart Inventory Pro

<div align="center">

![Java](https://img.shields.io/badge/Java-11-orange?style=for-the-badge&logo=java)
![MySQL](https://img.shields.io/badge/MySQL-8.0-blue?style=for-the-badge&logo=mysql)
![Tomcat](https://img.shields.io/badge/Tomcat-9.0-yellow?style=for-the-badge&logo=apachetomcat)
![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?style=for-the-badge&logo=docker)
![Bootstrap](https://img.shields.io/badge/Bootstrap-5.3-purple?style=for-the-badge&logo=bootstrap)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**A DSA-powered Inventory Management System built with Java EE, MySQL & Bootstrap 5**

[🚀 Live Demo](https://smart-inventory-pro-production-d548.up.railway.app/) • [📖 Setup Guide](#-local-setup) • [☁️ Deploy](#️-deploy-to-cloud)

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

> What makes this project stand out — real Data Structures & Algorithms applied to solve real backend problems.

| Algorithm | File | Use Case | Complexity |
|-----------|------|----------|------------|
| **LRU Cache** | `LRUCache.java` | Cache product lookups, avoid repeated DB hits | O(1) get/put |
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

```
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
```

---

## 🔧 Prerequisites

- Java 11+
- Apache Tomcat 9.x
- MySQL 8.x
- Maven 3.6+

---

## 🚀 Local Setup

### 1. Clone the Repository

```bash
git clone https://github.com/tanishqnegi/smart-inventory-pro.git
cd smart-inventory-pro
```

### 2. Set Up the Database

```sql
mysql -u root -p < database.sql
```

### 3. Build the WAR File

```bash
mvn clean package
```

### 4. Deploy to Tomcat

```bash
cp target/smart-inventory-pro-1.0.war $TOMCAT_HOME/webapps/
```

Then open: `http://localhost:8080/smart-inventory-pro`

### Default Login Credentials

| Username | Password | Role |
|----------|----------|------|
| admin | admin123 | ADMIN |
| manager | admin123 | MANAGER |

---

## 🐳 Run with Docker

```bash
# Build and run with Docker Compose (recommended)
docker-compose up --build

# OR manually
docker build -t smart-inventory-pro .
docker run -p 8080:8080 smart-inventory-pro
```

---

## ☁️ Deploy to Cloud

This project includes ready-to-use config files for both Railway and Render.

### Environment Variables (set these in your cloud dashboard)

```env
DB_URL  = jdbc:mysql://your-host:3306/inventory_pro
DB_USER = your_db_username
DB_PASS = your_db_password
```

| Platform | Config File | Steps |
|----------|-------------|-------|
| Railway | `railway.toml` | Connect repo → set env vars → deploy |
| Render | `render.yaml` | Connect repo → set env vars → deploy |

---

## 🔐 Security

- Passwords stored as **BCrypt hashes** — never plain text
- **Session-based authentication** with 30-minute timeout
- **Prepared statements** for all SQL queries — protected against SQL injection

---

## 👨‍💻 Author

**Tanishq Negi**
- 📧 [tanishqn8@gmail.com](mailto:tanishqn8@gmail.com)
- 🌍 Saharanpur, Uttar Pradesh, India
- 🎓 MCA Student — Uttaranchal University, Dehradun (2025–2027)

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

<div align="center">

⭐ **Star this repo if you found it useful — it really helps!** ⭐

</div>
