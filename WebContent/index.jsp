
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
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
    <link rel="stylesheet" href="css/style.css">
    <style>
        .navbar-brand { font-size: 1rem; }
        .table th, .table td { vertical-align: middle; font-size: 0.85rem; }
        @media (max-width: 768px) {
            .side-panel { margin-top: 1.5rem; }
            .navbar .d-flex { flex-wrap: wrap; gap: 6px !important; }
            .badge.bg-success { font-size: 0.7rem; }
        }
    </style>
</head>
<body class="bg-light">

<%-- ── Navbar ── --%>
<nav class="navbar navbar-dark bg-dark px-3 py-2">
    <span class="navbar-brand fw-bold mb-0">🧠 Smart Inventory Pro</span>
    <div class="d-flex align-items-center flex-wrap gap-2">
        <span class="badge bg-success">LRU Cache: ${cacheSize} items</span>
        <a href="analytics" class="btn btn-outline-light btn-sm">📊 Analytics</a>
        <span class="text-white-50 small">${sessionScope.user} (${sessionScope.role})</span>
        <a href="logout" class="btn btn-outline-danger btn-sm">Logout</a>
    </div>
</nav>

<div class="container-fluid mt-3 px-3">

    <%-- Low Stock Alerts --%>
    <c:if test="${not empty alerts}">
        <c:forEach var="alert" items="${alerts}">
            <div class="alert alert-danger py-2 mb-2 small">${alert}</div>
        </c:forEach>
    </c:if>

    <%-- Unauthorized error --%>
    <c:if test="${param.error == 'unauthorized'}">
        <div class="alert alert-danger small">❌ Only ADMIN can delete products.</div>
    </c:if>

    <%-- Search & Filter Bar --%>
    <div class="card shadow-sm mb-3">
        <div class="card-body py-2">
            <form action="inventory" method="get">
                <div class="row g-2 align-items-center">
                    <div class="col-12 col-sm-4">
                        <input type="text" name="search" class="form-control form-control-sm"
                               placeholder="🔍 Search products..." value="${search}">
                    </div>
                    <div class="col-12 col-sm-3">
                        <select name="category" class="form-select form-select-sm">
                            <option value="">All Categories</option>
                            <c:forEach var="cat" items="${categories}">
                                <option value="${cat}" ${filterCategory == cat ? 'selected' : ''}>${cat}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-6 col-sm-2">
                        <button type="submit" class="btn btn-primary btn-sm w-100">Search</button>
                    </div>
                    <div class="col-6 col-sm-2">
                        <a href="inventory" class="btn btn-secondary btn-sm w-100">Clear</a>
                    </div>
                    <div class="col-12 col-sm-1">
                        <a href="inventory?export=csv" class="btn btn-success btn-sm w-100">⬇ CSV</a>
                    </div>
                </div>
            </form>
        </div>
    </div>

    <%-- Main Content Row --%>
    <div class="row g-3">

        <%-- ── Product Table ── --%>
        <div class="col-12 col-lg-8">
            <div class="card shadow-sm h-100">
                <div class="card-header d-flex justify-content-between align-items-center py-2">
                    <h6 class="mb-0">📦 Products <small class="text-muted">(LRU Cache Optimized)</small></h6>
                    <button class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#addModal">+ Add Product</button>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover mb-0">
                            <thead class="table-dark">
                                <tr>
                                    <th>ID</th><th>Name</th><th>Category</th>
                                    <th>Stock</th><th>Price</th><th>Sales(30d)</th><th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="p" items="${products}">
                                <tr class="${p.stock < 10 ? 'table-danger' : ''}">
                                    <td>${p.id}</td>
                                    <td>${p.name}</td>
                                    <td><span class="badge bg-secondary">${p.category}</span></td>
                                    <td class="${p.stock < 10 ? 'text-danger fw-bold' : p.stock < 50 ? 'text-warning' : 'text-success'}">
                                        ${p.stock}<c:if test="${p.stock < 10}"> 🔴</c:if>
                                    </td>
                                    <td>₹<fmt:formatNumber value="${p.price}" pattern="#,##0.00"/></td>
                                    <td>${p.sales30d}</td>
                                    <td style="white-space:nowrap">
                                        <button class="btn btn-sm btn-warning me-1"
                                            onclick="openEdit(${p.id},'${p.name}','${p.category}',${p.stock},${p.price},${p.sales30d})">Edit</button>
                                        <c:if test="${sessionScope.role == 'ADMIN'}">
                                        <form action="inventory" method="post" style="display:inline"
                                              onsubmit="return confirm('Delete ${p.name}?')">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="id" value="${p.id}">
                                            <button type="submit" class="btn btn-sm btn-danger">Del</button>
                                        </form>
                                        </c:if>
                                    </td>
                                </tr>
                                </c:forEach>
                                <c:if test="${empty products}">
                                    <tr><td colspan="7" class="text-center text-muted py-4">No products found.</td></tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
                <div class="card-footer text-muted small py-1">
                    Showing ${products.size()} product(s)
                    <c:if test="${not empty search}"> for "<strong>${search}</strong>"</c:if>
                    <c:if test="${not empty filterCategory}"> in <strong>${filterCategory}</strong></c:if>
                </div>
            </div>
        </div>

        <%-- ── Side Panel ── --%>
        <div class="col-12 col-lg-4 side-panel">

            <%-- Stock Chart --%>
            <div class="card shadow-sm mb-3">
                <div class="card-header py-2">
                    <span class="small fw-bold">📈 Stock Distribution</span>
                    <small class="text-muted"> (Segment Tree)</small>
                </div>
                <div class="card-body p-2">
                    <canvas id="stockChart" height="180"></canvas>
                </div>
            </div>

            <%-- Trend Detection --%>
            <div class="card shadow-sm">
                <div class="card-header py-2">
                    <span class="small fw-bold">🌊 Trend Detection</span>
                    <small class="text-muted"> (Sliding Window)</small>
                </div>
                <div class="card-body p-2" style="max-height:220px;overflow-y:auto">
                    <c:choose>
                        <c:when test="${empty trends}">
                            <p class="text-muted small mb-0">Not enough data for trend analysis.</p>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="t" items="${trends}">
                                <div class="d-flex justify-content-between small border-bottom py-1">
                                    <span class="text-muted">Window ${t.windowIndex}</span>
                                    <span class="fw-bold ${t.trend == 'HIGH_DEMAND' ? 'text-success' : t.trend == 'LOW_DEMAND' ? 'text-danger' : 'text-secondary'}">
                                        ${t.trend} (<fmt:formatNumber value="${t.average}" pattern="0.0"/>)
                                    </span>
                                </div>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

        </div><%-- end side panel --%>
    </div><%-- end row --%>
</div><%-- end container --%>

<%-- ── Add Product Modal ── --%>
<div class="modal fade" id="addModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">➕ Add Product</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form action="inventory" method="post">
                <input type="hidden" name="action" value="add">
                <div class="modal-body">
                    <div class="mb-2">
                        <label class="form-label fw-semibold">Name *</label>
                        <input type="text" name="name" class="form-control" placeholder="e.g. iPhone 15 Pro" required>
                    </div>
                    <div class="mb-2">
                        <label class="form-label fw-semibold">Category *</label>
                        <select name="category" class="form-select" required>
                            <option value="">— Select —</option>
                            <option>Electronics</option>
                            <option>Apparel</option>
                            <option>Footwear</option>
                            <option>Appliances</option>
                            <option>Sports</option>
                            <option>Books</option>
                            <option>Other</option>
                        </select>
                    </div>
                    <div class="row g-2">
                        <div class="col-6">
                            <label class="form-label fw-semibold">Stock *</label>
                            <input type="number" name="stock" class="form-control" min="0" placeholder="0" required>
                        </div>
                        <div class="col-6">
                            <label class="form-label fw-semibold">Price (₹) *</label>
                            <input type="number" name="price" class="form-control" step="0.01" min="0" placeholder="0.00" required>
                        </div>
                    </div>
                    <div class="mt-2">
                        <label class="form-label fw-semibold">Sales Last 30 Days</label>
                        <input type="number" name="sales30d" class="form-control" min="0" placeholder="0">
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">Add Product</button>
                </div>
            </form>
        </div>
    </div>
</div>

<%-- ── Edit Product Modal ── --%>
<div class="modal fade" id="editModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">✏️ Edit Product</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form action="inventory" method="post">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="id" id="editId">
                <div class="modal-body">
                    <div class="mb-2">
                        <label class="form-label fw-semibold">Name</label>
                        <input type="text" name="name" id="editName" class="form-control" required>
                    </div>
                    <div class="mb-2">
                        <label class="form-label fw-semibold">Category</label>
                        <input type="text" name="category" id="editCategory" class="form-control" required>
                    </div>
                    <div class="row g-2">
                        <div class="col-6">
                            <label class="form-label fw-semibold">Stock</label>
                            <input type="number" name="stock" id="editStock" class="form-control" min="0" required>
                        </div>
                        <div class="col-6">
                            <label class="form-label fw-semibold">Price (₹)</label>
                            <input type="number" name="price" id="editPrice" class="form-control" step="0.01" min="0" required>
                        </div>
                    </div>
                    <div class="mt-2">
                        <label class="form-label fw-semibold">Sales Last 30 Days</label>
                        <input type="number" name="sales30d" id="editSales30d" class="form-control" min="0">
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-warning">Update</button>
                </div>
            </form>
        </div>
    </div>
</div>

<%-- Bootstrap JS → Chart.js → app.js  (order matters!) --%>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script src="js/app.js"></script>
<script>
    const labels = [<c:forEach var="p" items="${products}" varStatus="s">'${p.name}'<c:if test="${!s.last}">,</c:if></c:forEach>];
    const stocks = [<c:forEach var="p" items="${products}" varStatus="s">${p.stock}<c:if test="${!s.last}">,</c:if></c:forEach>];
    const sales  = [<c:forEach var="p" items="${products}" varStatus="s">${p.sales30d}<c:if test="${!s.last}">,</c:if></c:forEach>];
    initStockChart('stockChart', labels, stocks, sales);

    function openEdit(id, name, category, stock, price, sales30d) {
        document.getElementById('editId').value       = id;
        document.getElementById('editName').value     = name;
        document.getElementById('editCategory').value = category;
        document.getElementById('editStock').value    = stock;
        document.getElementById('editPrice').value    = price;
        document.getElementById('editSales30d').value = sales30d;
        new bootstrap.Modal(document.getElementById('editModal')).show();
    }
</script>
</body>
</html>