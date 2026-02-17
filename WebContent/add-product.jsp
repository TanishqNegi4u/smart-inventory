<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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
    <title>Add Product — Smart Inventory Pro</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<nav class="navbar navbar-dark bg-dark px-3">
    <span class="navbar-brand fw-bold">🧠 Smart Inventory Pro</span>
    <a href="inventory" class="btn btn-outline-light btn-sm">← Back to Dashboard</a>
</nav>

<div class="container mt-5">
    <div class="row justify-content-center">
        <div class="col-md-6">
            <div class="card shadow-sm">
                <div class="card-header"><h5 class="mb-0">➕ Add New Product</h5></div>
                <div class="card-body">
                    <form action="inventory" method="post">
                        <input type="hidden" name="action" value="add">
                        <div class="mb-3">
                            <label class="form-label fw-semibold">Product Name *</label>
                            <input type="text" name="name" class="form-control" placeholder="e.g. iPhone 15 Pro" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-semibold">Category *</label>
                            <select name="category" class="form-select" required>
                                <option value="">— Select Category —</option>
                                <option>Electronics</option>
                                <option>Apparel</option>
                                <option>Footwear</option>
                                <option>Appliances</option>
                                <option>Sports</option>
                                <option>Books</option>
                                <option>Other</option>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-semibold">Initial Stock *</label>
                            <input type="number" name="stock" class="form-control" min="0" placeholder="0" required>
                        </div>
                        <div class="mb-4">
                            <label class="form-label fw-semibold">Price (₹) *</label>
                            <input type="number" name="price" class="form-control" step="0.01" min="0" placeholder="0.00" required>
                        </div>
                        <div class="d-grid gap-2">
                            <button type="submit" class="btn btn-primary btn-lg">➕ Add Product</button>
                            <a href="inventory" class="btn btn-outline-secondary">Cancel</a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>