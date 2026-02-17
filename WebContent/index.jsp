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
</head>
<body>

<%-- ── Navbar ── --%>
<nav class="navbar navbar-dark px-3 py-2">
    <span class="navbar-brand fw-bold mb-0">⬡ Smart Inventory Pro</span>
    <div class="d-flex align-items-center flex-wrap gap-2">
        <span class="badge bg-success">⚡ LRU Cache: ${cacheSize} items</span>
        <a href="analytics" class="btn btn-outline-light btn-sm">📊 Analytics</a>
        <span class="text-white-50 small">${sessionScope.user}
            <span class="badge bg-secondary ms-1">${sessionScope.role}</span>
        </span>
        <a href="logout" class="btn btn-outline-danger btn-sm">Logout</a>
    </div>
</nav>

<div class="container-fluid mt-3 px-3">

    <%-- Low Stock Alerts --%>
    <c:if test="${not empty alerts}">
        <c:forEach var="alert" items="${alerts}">
            <div class="alert alert-danger py-2 mb-2 small d-flex align-items-center gap-2">
                <span>🔴</span> ${alert}
            </div>
        </c:forEach>
    </c:if>

    <c:if test="${param.error == 'unauthorized'}">
        <div class="alert alert-danger small">❌ Only ADMIN can delete products.</div>
    </c:if>

    <%-- Search & Filter Bar --%>
    <div class="card shadow-sm mb-3">
        <div class="card-body py-2 px-3">
            <form action="inventory" method="get" id="filterForm">
                <div class="row g-2 align-items-center">
                    <div class="col-12 col-sm-4">
                        <input type="text" name="search" id="searchInput"
                               class="form-control form-control-sm"
                               placeholder="🔍 Search by name or category..."
                               value="${search}"
                               oninput="liveFilter()">
                    </div>
                    <div class="col-12 col-sm-3">
                        <select name="category" id="categorySelect" class="form-select form-select-sm" onchange="liveFilter()">
                            <option value="">All Categories</option>
                            <c:forEach var="cat" items="${categories}">
                                <option value="${cat}" ${filterCategory == cat ? 'selected' : ''}>${cat}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-12 col-sm-2">
                        <select name="stockFilter" id="stockFilter" class="form-select form-select-sm" onchange="liveFilter()">
                            <option value="">All Stock Levels</option>
                            <option value="critical" ${param.stockFilter == 'critical' ? 'selected' : ''}>🔴 Critical (&lt;10)</option>
                            <option value="low"      ${param.stockFilter == 'low'      ? 'selected' : ''}>🟡 Low (&lt;50)</option>
                            <option value="ok"       ${param.stockFilter == 'ok'       ? 'selected' : ''}>🟢 In Stock (50+)</option>
                        </select>
                    </div>
                    <div class="col-6 col-sm-1">
                        <button type="submit" class="btn btn-primary btn-sm w-100">Search</button>
                    </div>
                    <div class="col-6 col-sm-1">
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
                    <span>📦 Products <small class="text-muted">(LRU Cache Optimized)</small></span>
                    <button class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#addModal">+ Add Product</button>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover mb-0" id="productTable">
                            <thead class="table-dark">
                                <tr>
                                    <th>ID</th>
                                    <th>Name</th>
                                    <th>Category</th>
                                    <th>Stock</th>
                                    <th>Price</th>
                                    <th>Sales(30d)</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody id="tableBody">
                                <c:forEach var="p" items="${products}">
                                <tr class="${p.stock < 10 ? 'table-danger' : ''}"
                                    data-name="${p.name}"
                                    data-category="${p.category}"
                                    data-stock="${p.stock}">
                                    <td><span class="text-muted">#${p.id}</span></td>
                                    <td class="fw-semibold">${p.name}</td>
                                    <td><span class="badge bg-secondary">${p.category}</span></td>
                                    <td class="${p.stock < 10 ? 'text-danger fw-bold' : p.stock < 50 ? 'text-warning' : 'text-success'}">
                                        ${p.stock}<c:if test="${p.stock < 10}"> 🔴</c:if>
                                    </td>
                                    <td>₹<fmt:formatNumber value="${p.price}" pattern="#,##0.00"/></td>
                                    <td>
                                        <span class="badge ${p.sales30d > 100 ? 'bg-success' : p.sales30d > 30 ? 'bg-warning' : 'bg-secondary'}">
                                            ${p.sales30d}
                                        </span>
                                    </td>
                                    <td style="white-space:nowrap">
                                        <button class="btn btn-sm btn-warning me-1"
                                            onclick="openEdit(${p.id},'${p.name}','${p.category}',${p.stock},${p.price},${p.sales30d})">
                                            ✏ Edit
                                        </button>
                                        <c:if test="${sessionScope.role == 'ADMIN'}">
                                        <form action="inventory" method="post" style="display:inline"
                                              onsubmit="return confirm('Delete ${p.name}?')">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="id" value="${p.id}">
                                            <button type="submit" class="btn btn-sm btn-danger">🗑</button>
                                        </form>
                                        </c:if>
                                    </td>
                                </tr>
                                </c:forEach>
                                <c:if test="${empty products}">
                                    <tr id="emptyRow">
                                        <td colspan="7" class="text-center py-5">
                                            <div class="text-muted">
                                                <div style="font-size:2rem;margin-bottom:.5rem">📭</div>
                                                No products found.
                                            </div>
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
                <div class="card-footer d-flex justify-content-between align-items-center">
                    <span>Showing <strong id="visibleCount">${products.size()}</strong> product(s)
                        <c:if test="${not empty search}"> for "<strong>${search}</strong>"</c:if>
                        <c:if test="${not empty filterCategory}"> in <strong>${filterCategory}</strong></c:if>
                    </span>
                    <span id="liveFilterBadge" class="badge bg-secondary" style="display:none">Live filter</span>
                </div>
            </div>
        </div>

        <%-- ── Side Panel ── --%>
        <div class="col-12 col-lg-4 side-panel">

            <%-- Stock Chart --%>
            <div class="card shadow-sm mb-3">
                <div class="card-header py-2">
                    <span class="fw-bold">📈 Stock Distribution</span>
                    <small class="text-muted"> (Segment Tree)</small>
                </div>
                <div class="card-body p-2">
                    <canvas id="stockChart" height="180"></canvas>
                </div>
            </div>

            <%-- Trend Detection --%>
            <div class="card shadow-sm">
                <div class="card-header py-2">
                    <span class="fw-bold">🌊 Trend Detection</span>
                    <small class="text-muted"> (Sliding Window)</small>
                </div>
                <div class="card-body p-2 trends-scroll" style="max-height:220px;overflow-y:auto">
                    <c:choose>
                        <c:when test="${empty trends}">
                            <p class="text-muted small mb-0 text-center py-3">Not enough data for trend analysis.</p>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="t" items="${trends}">
                                <div class="d-flex justify-content-between align-items-center small border-bottom py-2" style="border-color: var(--border) !important">
                                    <span class="text-muted" style="font-family:'Space Mono',monospace;font-size:0.7rem">W${t.windowIndex}</span>
                                    <span class="badge ${t.trend == 'HIGH_DEMAND' ? 'bg-success' : t.trend == 'LOW_DEMAND' ? 'bg-danger' : 'bg-secondary'}">
                                        ${t.trend}
                                    </span>
                                    <span class="text-muted" style="font-size:0.75rem">
                                        <fmt:formatNumber value="${t.average}" pattern="0.0"/> avg
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
                    <div class="mb-3">
                        <label class="form-label">Name *</label>
                        <input type="text" name="name" class="form-control" placeholder="e.g. iPhone 16 Pro" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Category *</label>
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
                            <label class="form-label">Stock *</label>
                            <input type="number" name="stock" class="form-control" min="0" placeholder="0" required>
                        </div>
                        <div class="col-6">
                            <label class="form-label">Price (₹) *</label>
                            <input type="number" name="price" class="form-control" step="0.01" min="0" placeholder="0.00" required>
                        </div>
                    </div>
                    <div class="mt-3">
                        <label class="form-label">Sales Last 30 Days</label>
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
                    <div class="mb-3">
                        <label class="form-label">Name</label>
                        <input type="text" name="name" id="editName" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Category</label>
                        <input type="text" name="category" id="editCategory" class="form-control" required>
                    </div>
                    <div class="row g-2">
                        <div class="col-6">
                            <label class="form-label">Stock</label>
                            <input type="number" name="stock" id="editStock" class="form-control" min="0" required>
                        </div>
                        <div class="col-6">
                            <label class="form-label">Price (₹)</label>
                            <input type="number" name="price" id="editPrice" class="form-control" step="0.01" min="0" required>
                        </div>
                    </div>
                    <div class="mt-3">
                        <label class="form-label">Sales Last 30 Days</label>
                        <input type="number" name="sales30d" id="editSales30d" class="form-control" min="0">
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-warning">Update Product</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script src="js/app.js"></script>
<script>
    // Chart
    const labels = [<c:forEach var="p" items="${products}" varStatus="s">'${p.name}'<c:if test="${!s.last}">,</c:if></c:forEach>];
    const stocks = [<c:forEach var="p" items="${products}" varStatus="s">${p.stock}<c:if test="${!s.last}">,</c:if></c:forEach>];
    const sales  = [<c:forEach var="p" items="${products}" varStatus="s">${p.sales30d}<c:if test="${!s.last}">,</c:if></c:forEach>];
    initStockChart('stockChart', labels, stocks, sales);

    // Edit modal
    function openEdit(id, name, category, stock, price, sales30d) {
        document.getElementById('editId').value       = id;
        document.getElementById('editName').value     = name;
        document.getElementById('editCategory').value = category;
        document.getElementById('editStock').value    = stock;
        document.getElementById('editPrice').value    = price;
        document.getElementById('editSales30d').value = sales30d;
        new bootstrap.Modal(document.getElementById('editModal')).show();
    }

    // ── Live client-side filter ──────────────────────────
    function liveFilter() {
        const search   = document.getElementById('searchInput').value.toLowerCase().trim();
        const category = document.getElementById('categorySelect').value.toLowerCase();
        const stock    = document.getElementById('stockFilter').value;
        const rows     = document.querySelectorAll('#tableBody tr[data-name]');
        let visible    = 0;

        rows.forEach(row => {
            const name  = (row.dataset.name     || '').toLowerCase();
            const cat   = (row.dataset.category || '').toLowerCase();
            const qty   = parseInt(row.dataset.stock || '0', 10);

            const matchSearch   = !search   || name.includes(search) || cat.includes(search);
            const matchCategory = !category || cat === category;
            const matchStock    =
                stock === 'critical' ? qty < 10 :
                stock === 'low'      ? qty < 50 :
                stock === 'ok'       ? qty >= 50 : true;

            const show = matchSearch && matchCategory && matchStock;
            row.style.display = show ? '' : 'none';
            if (show) visible++;
        });

        document.getElementById('visibleCount').textContent = visible;
        const badge = document.getElementById('liveFilterBadge');
        badge.style.display = (search || category || stock) ? 'inline' : 'none';

        // Show/hide empty state
        let emptyRow = document.getElementById('emptyRow');
        if (!emptyRow && visible === 0) {
            emptyRow = document.createElement('tr');
            emptyRow.id = 'emptyRow';
            emptyRow.innerHTML = '<td colspan="7" class="text-center py-5"><div class="text-muted"><div style="font-size:2rem;margin-bottom:.5rem">🔍</div>No products match your filters.</div></td>';
            document.getElementById('tableBody').appendChild(emptyRow);
        } else if (emptyRow) {
            emptyRow.style.display = visible === 0 ? '' : 'none';
        }
    }
</script>
</body>
</html>