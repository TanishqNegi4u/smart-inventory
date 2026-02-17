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
                        s < 10  ? 'rgba(220,53,69,.8)'  :
                        s < 30  ? 'rgba(255,193,7,.8)'  :
                                  'rgba(25,135,84,.8)'),
                    borderRadius: 5,
                    yAxisID: 'y'
                },
                {
                    label: 'Sales (30d)',
                    data: sales,
                    type: 'line',
                    borderColor: '#0d6efd',
                    backgroundColor: 'rgba(13,110,253,.1)',
                    tension: 0.4,
                    fill: true,
                    yAxisID: 'y1'
                }
            ]
        },
        options: {
            responsive: true,
            interaction: { mode: 'index', intersect: false },
            plugins: { legend: { position: 'top' } },
            scales: {
                x:  { ticks: { maxRotation: 45, font: { size: 10 } } },
                y:  { beginAtZero: true, title: { display: true, text: 'Stock' } },
                y1: { beginAtZero: true, position: 'right', title: { display: true, text: 'Sales' },
                      grid: { drawOnChartArea: false } }
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