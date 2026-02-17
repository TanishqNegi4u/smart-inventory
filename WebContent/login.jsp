<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login — Smart Inventory Pro</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="css/style.css">
    <style>
        body {
            background: #080c14;
            background-image:
                radial-gradient(ellipse at 25% 35%, rgba(59,130,246,0.13) 0%, transparent 55%),
                radial-gradient(ellipse at 75% 65%, rgba(139,92,246,0.1) 0%, transparent 55%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .login-card {
            background: #0e1420;
            border: 1px solid rgba(255,255,255,0.06);
            border-radius: 20px;
            box-shadow: 0 30px 80px rgba(0,0,0,0.6);
            padding: 2.5rem;
            width: 100%;
            max-width: 420px;
            animation: fadeUp 0.4s ease both;
        }
        .brand-logo {
            font-size: 2.5rem;
            display: inline-block;
            background: linear-gradient(135deg, #3b82f6, #06b6d4);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        .brand-title {
            font-family: 'Space Mono', monospace;
            font-size: 1.3rem;
            font-weight: 700;
            background: linear-gradient(135deg, #3b82f6, #06b6d4);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        .form-control {
            background: #141b2b !important;
            border: 1px solid rgba(255,255,255,0.08) !important;
            color: #e2e8f0 !important;
            border-radius: 10px !important;
            padding: 0.75rem 1rem !important;
            font-size: 0.9rem;
            transition: all 0.2s;
        }
        .form-control:focus {
            border-color: #3b82f6 !important;
            box-shadow: 0 0 0 3px rgba(59,130,246,0.15) !important;
            background: #1a2336 !important;
        }
        .form-control::placeholder { color: #475569 !important; }
        .form-label { color: #94a3b8; font-weight: 500; font-size: 0.83rem; margin-bottom: 0.4rem; }
        .btn-signin {
            background: linear-gradient(135deg, #3b82f6, #06b6d4);
            border: none;
            border-radius: 10px;
            padding: 0.75rem;
            font-weight: 700;
            font-size: 0.95rem;
            color: #fff;
            width: 100%;
            transition: all 0.2s;
            box-shadow: 0 6px 20px rgba(59,130,246,0.35);
        }
        .btn-signin:hover { opacity: 0.88; transform: translateY(-1px); box-shadow: 0 10px 28px rgba(59,130,246,0.5); }
        .divider { border-color: rgba(255,255,255,0.06) !important; }
        .hint-box {
            background: rgba(59,130,246,0.06);
            border: 1px solid rgba(59,130,246,0.15);
            border-radius: 10px;
            padding: 0.7rem 1rem;
            font-size: 0.8rem;
            color: #64748b;
            font-family: 'Space Mono', monospace;
        }
        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(16px); }
            to   { opacity: 1; transform: translateY(0); }
        }
    </style>
    <link href="https://fonts.googleapis.com/css2?family=Space+Mono:wght@400;700&family=DM+Sans:wght@400;500;700&display=swap" rel="stylesheet">
</head>
<body>
<div class="login-card">
    <div class="text-center mb-4">
        <div class="brand-logo">⬡</div>
        <div class="brand-title mt-1">Smart Inventory Pro</div>
        <p style="color:#475569;font-size:0.8rem;margin-top:0.4rem">DSA-Powered Inventory Management</p>
    </div>

    <% if (request.getAttribute("error") != null) { %>
    <div class="alert" style="background:rgba(239,68,68,0.1);border:none;border-left:3px solid #ef4444;border-radius:8px;color:#fca5a5;font-size:0.85rem;padding:0.65rem 1rem;margin-bottom:1.25rem">
        <%= request.getAttribute("error") %>
    </div>
    <% } %>

    <form action="login" method="post">
        <div class="mb-3">
            <label class="form-label">Username</label>
            <input type="text" name="username" class="form-control"
                   placeholder="Enter your username" required autofocus>
        </div>
        <div class="mb-4">
            <label class="form-label">Password</label>
            <input type="password" name="password" class="form-control"
                   placeholder="Enter your password" required>
        </div>
        <button type="submit" class="btn-signin">🔐 Sign In</button>
    </form>

    <hr class="divider my-4">
    <div class="hint-box">
        <span style="color:#3b82f6">→</span> Default credentials:<br>
        admin / admin123
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>