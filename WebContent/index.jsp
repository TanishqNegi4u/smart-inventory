<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
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
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard — Smart Inventory Pro</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>

<nav class="navbar navbar-dark bg-dark px-3">
    <span class="navbar-brand fw-bold">🧠 Smart Inventory Pro</span>
    <div class="d-flex align-items-center gap-3">
        <span class="badge bg-success">LRU Cache: ${cacheSize} items</span>
        <a href="analytics" class="btn btn-outline-light btn-sm">📊 Analytics</a>
        <span class="text-white-50">${sessionScope.user} (${sessionScope.role})</span>
        <a href="logout" class="btn btn-outline-danger btn-sm">Logout</a>
    </div>
</nav>

<div class="container-fluid mt-4">

    <%-- Alerts row --%>
    <c:if test="${not empty alerts}">
    <div class="row mb-3">
        <div class="col">
            <c:forEach var="alert" items="${alerts}">
                <div class="alert alert-warning py-2 mb-1">${alert}</div>
            </c:forEach>
        </div>
    </div>
    </c:if>

    <div class="row">

        <%-- Product Table --%>
        <div class="col-md-8">
            <div class="card shadow-sm">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h5 class="mb-0">📦 Products <small class="text-muted fs-6">(LRU Cache Optimized)</small></h5>
                    <button class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#addModal">+ Add Product</button>
                </div>
                <div class="card-body p-0">
                    <table class="table table-hover mb-0">
                        <thead class="table-dark">
                            <tr><th>ID</th><th>Name</th><th>Category</th><th>Stock</th><th>Price</th><th>Sales(30d)</th><th>Actions</th></tr>
                        </thead>
                        <tbody>
                            <c:forEach var="p" items="${products}">
                            <tr>
                                <td>${p.id}</td>
                                <td>${p.name}</td>
                                <td><span class="badge bg-secondary">${p.category}</span></td>
                                <td class="${p.stock < 20 ? 'text-danger fw-bold' : p.stock < 50 ? 'text-warning' : 'text-success'}">
                                    ${p.stock}
                                    <c:if test="${p.stock < 10}"> 🔴</c:if>
                                </td>
                                <td>₹<fmt:formatNumber value="${p.price}" pattern="#,##0.00"/></td>
                                <td>${p.sales30d}</td>
                                <td>
                                    <button class="btn btn-sm btn-warning"
                                        onclick="openEdit(${p.id},'${p.name}','${p.category}',${p.stock},${p.price})">Edit</button>
                                    <form action="inventory" method="post" style="display:inline"
                                          onsubmit="return confirm('Delete ${p.name}?')">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="id" value="${p.id}">
                                        <button class="btn btn-sm btn-danger">Del</button>
                                    </form>
                                </td>
                            </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <%-- Side Panel --%>
        <div class="col-md-4">
            <div class="card shadow-sm mb-3">
                <div class="card-header">📈 Stock Distribution <small class="text-muted">(Segment Tree)</small></div>
                <div class="card-body"><canvas id="stockChart" height="200"></canvas></div>
            </div>
            <div class="card shadow-sm">
                <div class="card-header">🌊 Trend Detection <small class="text-muted">(Sliding Window)</small></div>
                <div id="trendsPanel" class="card-body" style="max-height:220px;overflow-y:auto">
                    <c:choose>
                        <c:when test="${empty trends}">
                            <p class="text-muted">Not enough data for trend analysis.</p>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="t" items="${trends}">
                                <div class="d-flex justify-content-between small border-bottom py-1">
                                    <span>Window ${t.windowIndex}</span>
                                    <span class="${t.trend == 'HIGH_DEMAND' ? 'text-success fw-bold' : t.trend == 'LOW_DEMAND' ? 'text-danger' : 'text-muted'}">
                                        ${t.trend} (<fmt:formatNumber value="${t.average}" pattern="0.0"/>)
                                    </span>
                                </div>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>
</div>

<%-- Add Product Modal --%>
<div class="modal fade" id="addModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header"><h5 class="modal-title">Add Product</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
            <form action="inventory" method="post">
                <input type="hidden" name="action" value="add">
                <div class="modal-body">
                    <div class="mb-2"><label class="form-label">Name</label>
                        <input type="text" name="name" class="form-control" required></div>
                    <div class="mb-2"><label class="form-label">Category</label>
                        <input type="text" name="category" class="form-control" required></div>
                    <div class="mb-2"><label class="form-label">Stock</label>
                        <input type="number" name="stock" class="form-control" min="0" required></div>
                    <div class="mb-2"><label class="form-label">Price (₹)</label>
                        <input type="number" name="price" class="form-control" step="0.01" min="0" required></div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">Add</button>
                </div>
            </form>
        </div>
    </div>
</div>

<%-- Edit Product Modal --%>
<div class="modal fade" id="editModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header"><h5 class="modal-title">Edit Product</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
            <form action="inventory" method="post">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="id" id="editId">
                <div class="modal-body">
                    <div class="mb-2"><label class="form-label">Name</label>
                        <input type="text" name="name" id="editName" class="form-control" required></div>
                    <div class="mb-2"><label class="form-label">Category</label>
                        <input type="text" name="category" id="editCategory" class="form-control" required></div>
                    <div class="mb-2"><label class="form-label">Stock</label>
                        <input type="number" name="stock" id="editStock" class="form-control" min="0" required></div>
                    <div class="mb-2"><label class="form-label">Price (₹)</label>
                        <input type="number" name="price" id="editPrice" class="form-control" step="0.01" min="0" required></div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-warning">Update</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="js/app.js"></script>
<script>
    const labels  = [<c:forEach var="p" items="${products}" varStatus="s">'${p.name}'<c:if test="${!s.last}">,</c:if></c:forEach>];
    const stocks  = [<c:forEach var="p" items="${products}" varStatus="s">${p.stock}<c:if test="${!s.last}">,</c:if></c:forEach>];
    const sales   = [<c:forEach var="p" items="${products}" varStatus="s">${p.sales30d}<c:if test="${!s.last}">,</c:if></c:forEach>];
    initStockChart('stockChart', labels, stocks, sales);

    function openEdit(id, name, category, stock, price) {
        document.getElementById('editId').value       = id;
        document.getElementById('editName').value     = name;
        document.getElementById('editCategory').value = category;
        document.getElementById('editStock').value    = stock;
        document.getElementById('editPrice').value    = price;
        new bootstrap.Modal(document.getElementById('editModal')).show();
    }
</script>
</body>
</html>