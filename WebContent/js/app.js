/* ── Smart Inventory Pro — Frontend JS ─────────────────── */

// ── DSA: Sliding Window — trend detection ────────────────
function detectTrends(data, windowSize = 7) {
    const trends = [];
    for (let i = 0; i <= data.length - windowSize; i++) {
        const window = data.slice(i, i + windowSize);
        const avg    = window.reduce((a, b) => a + (b.sales30d ?? b), 0) / windowSize;
        const trend  = avg > 100 ? 'HIGH_DEMAND' : avg < 30 ? 'LOW_DEMAND' : 'NORMAL';
        trends.push({ period: i, avg: avg.toFixed(1), trend });
    }
    return trends;
}

// ── DSA: Fenwick Tree (BIT) for prefix-sum stock queries ─
class FenwickTree {
    constructor(size) {
        this.size = size;
        this.tree = new Array(size + 1).fill(0);
    }
    update(index, delta) {
        for (let i = index + 1; i <= this.size; i += i & -i)
            this.tree[i] += delta;
    }
    query(index) {
        let sum = 0;
        for (let i = index + 1; i > 0; i -= i & -i)
            sum += this.tree[i];
        return sum;
    }
    rangeQuery(l, r) { return this.query(r) - (l > 0 ? this.query(l - 1) : 0); }
}

// ── Set Chart.js global dark defaults ───────────────────
Chart.defaults.color          = '#94a3b8';
Chart.defaults.borderColor    = 'rgba(255,255,255,0.05)';
Chart.defaults.backgroundColor = 'rgba(255,255,255,0.04)';

// ── Chart initialiser (called from JSP) ─────────────────
function initStockChart(canvasId, labels, stocks, sales) {
    const ctx = document.getElementById(canvasId);
    if (!ctx) return;

    new Chart(ctx, {
        type: 'bar',
        data: {
            labels,
            datasets: [
                {
                    label: 'Stock',
                    data: stocks,
                    backgroundColor: stocks.map(s =>
                        s < 10  ? 'rgba(239,68,68,0.75)'   :
                        s < 50  ? 'rgba(245,158,11,0.75)'  :
                                  'rgba(16,185,129,0.75)'),
                    borderRadius: 6,
                    borderSkipped: false,
                    yAxisID: 'y'
                },
                {
                    label: 'Sales (30d)',
                    data: sales,
                    type: 'line',
                    borderColor: '#3b82f6',
                    backgroundColor: 'rgba(59,130,246,0.08)',
                    pointBackgroundColor: '#3b82f6',
                    pointRadius: 3,
                    tension: 0.4,
                    fill: true,
                    yAxisID: 'y1'
                }
            ]
        },
        options: {
            responsive: true,
            interaction: { mode: 'index', intersect: false },
            plugins: {
                legend: {
                    position: 'top',
                    labels: { color: '#94a3b8', font: { size: 11 }, boxWidth: 12 }
                },
                tooltip: {
                    backgroundColor: '#141b2b',
                    borderColor: 'rgba(59,130,246,0.3)',
                    borderWidth: 1,
                    titleColor: '#e2e8f0',
                    bodyColor: '#94a3b8'
                }
            },
            scales: {
                x: {
                    ticks: {
                        maxRotation: 45,
                        font: { size: 9 },
                        color: '#475569',
                        maxTicksLimit: 8
                    },
                    grid: { color: 'rgba(255,255,255,0.04)' }
                },
                y: {
                    beginAtZero: true,
                    title: { display: true, text: 'Stock', color: '#64748b', font: { size: 10 } },
                    ticks: { color: '#64748b', font: { size: 10 } },
                    grid: { color: 'rgba(255,255,255,0.04)' }
                },
                y1: {
                    beginAtZero: true,
                    position: 'right',
                    title: { display: true, text: 'Sales', color: '#64748b', font: { size: 10 } },
                    ticks: { color: '#64748b', font: { size: 10 } },
                    grid: { drawOnChartArea: false }
                }
            }
        }
    });
}

// ── Low-stock client-side check ──────────────────────────
function checkLowStock(products) {
    const fit = new FenwickTree(products.length);
    products.forEach((p, i) => fit.update(i, p.stock));
    const alerts = [];
    products.forEach((p, i) => {
        if (fit.rangeQuery(i, i) < 15)
            alerts.push(`⚠ ${p.name} is critically low (${p.stock} units)`);
    });
    return alerts;
}