
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"  prefix="fmt" %>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Analytics — Smart Inventory Pro</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<nav class="navbar navbar-dark bg-dark px-3">
    <span class="navbar-brand fw-bold">🧠 Smart Inventory Pro — Analytics</span>
    <a href="inventory" class="btn btn-outline-light btn-sm">← Dashboard</a>
</nav>

<div class="container-fluid mt-4">

    <%-- KPI Row --%>
    <div class="row g-3 mb-4">
        <div class="col-md-3">
            <div class="card text-white bg-primary shadow-sm">
                <div class="card-body">
                    <h6>Total Products</h6>
                    <h2>${products.size()}</h2>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card text-white bg-success shadow-sm">
                <div class="card-body">
                    <h6>Top-5 Sales (Segment Tree)</h6>
                    <h2>${top5Sales}</h2>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card text-white bg-warning shadow-sm">
                <div class="card-body">
                    <h6>Trend Windows Detected</h6>
                    <h2>${trends.size()}</h2>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card text-white bg-info shadow-sm">
                <div class="card-body">
                    <h6>Categories</h6>
                    <h2>${salesByCategory.size()}</h2>
                </div>
            </div>
        </div>
    </div>

    <div class="row g-3">
        <%-- Sales by Category Chart --%>
        <div class="col-md-6">
            <div class="card shadow-sm">
                <div class="card-header">📊 Sales by Category (30 days)</div>
                <div class="card-body"><canvas id="categoryChart" height="250"></canvas></div>
            </div>
        </div>

        <%-- Top Products Table --%>
        <div class="col-md-6">
            <div class="card shadow-sm">
                <div class="card-header">🏆 Top Products by Sales</div>
                <div class="card-body p-0">
                    <table class="table table-hover mb-0">
                        <thead class="table-dark"><tr><th>#</th><th>Product</th><th>Sales(30d)</th><th>Stock</th></tr></thead>
                        <tbody>
                        <c:forEach var="p" items="${products}" varStatus="s">
                            <c:if test="${s.index < 8}">
                            <tr>
                                <td>${s.index + 1}</td>
                                <td>${p.name}</td>
                                <td><span class="badge bg-success">${p.sales30d}</span></td>
                                <td class="${p.stock < 20 ? 'text-danger' : ''}">${p.stock}</td>
                            </tr>
                            </c:if>
                        </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <%-- Sliding Window Trends --%>
        <div class="col-12">
            <div class="card shadow-sm">
                <div class="card-header">🌊 Sliding Window Trend Analysis (Window Size: 7)</div>
                <div class="card-body">
                    <c:choose>
                        <c:when test="${empty trends}">
                            <p class="text-muted">Add more products to see trend analysis.</p>
                        </c:when>
                        <c:otherwise>
                            <div class="row g-2">
                            <c:forEach var="t" items="${trends}">
                                <div class="col-md-2">
                                    <div class="card text-center p-2 ${t.trend == 'HIGH_DEMAND' ? 'border-success' : t.trend == 'LOW_DEMAND' ? 'border-danger' : 'border-secondary'}">
                                        <small class="text-muted">W${t.windowIndex}</small>
                                        <div class="fw-bold ${t.trend == 'HIGH_DEMAND' ? 'text-success' : t.trend == 'LOW_DEMAND' ? 'text-danger' : 'text-secondary'}">
                                            ${t.trend}
                                        </div>
                                        <small><fmt:formatNumber value="${t.average}" pattern="0.0"/> avg</small>
                                    </div>
                                </div>
                            </c:forEach>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
    const catLabels = [<c:forEach var="e" items="${salesByCategory}" varStatus="s">'${e.key}'<c:if test="${!s.last}">,</c:if></c:forEach>];
    const catSales  = [<c:forEach var="e" items="${salesByCategory}" varStatus="s">${e.value}<c:if test="${!s.last}">,</c:if></c:forEach>];

    new Chart(document.getElementById('categoryChart'), {
        type: 'bar',
        data: {
            labels: catLabels,
            datasets: [{
                label: 'Sales (30d)',
                data: catSales,
                backgroundColor: ['#0d6efd','#198754','#ffc107','#dc3545','#0dcaf0','#6f42c1','#fd7e14'],
                borderRadius: 6
            }]
        },
        options: { responsive: true, plugins: { legend: { display: false } },
                   scales: { y: { beginAtZero: true } } }
    });
</script>
</body>
</html>