package utils;

/**
 * Segment Tree for O(log n) range-sum queries on stock / sales arrays.
 * Used by InventoryServlet to detect low-stock windows efficiently.
 */
public class SegmentTree {
    private final int[] tree;
    private final int n;

    public SegmentTree(int[] arr) {
        n    = arr.length;
        tree = new int[4 * n];
        if (n > 0) build(arr, 0, 0, n - 1);
    }

    private void build(int[] arr, int node, int start, int end) {
        if (start == end) { tree[node] = arr[start]; return; }
        int mid = (start + end) / 2;
        build(arr, 2 * node + 1, start, mid);
        build(arr, 2 * node + 2, mid + 1, end);
        tree[node] = tree[2 * node + 1] + tree[2 * node + 2];
    }

    /** Returns the sum of arr[left..right] in O(log n) */
    public int query(int left, int right) {
        if (n == 0 || left > right) return 0;
        return queryUtil(0, 0, n - 1, left, right);
    }

    private int queryUtil(int node, int start, int end, int l, int r) {
        if (r < start || end < l) return 0;
        if (l <= start && end <= r) return tree[node];
        int mid = (start + end) / 2;
        return queryUtil(2 * node + 1, start, mid, l, r)
             + queryUtil(2 * node + 2, mid + 1, end, l, r);
    }

    /** Point-update: change arr[idx] by delta */
    public void update(int idx, int delta) {
        updateUtil(0, 0, n - 1, idx, delta);
    }

    private void updateUtil(int node, int start, int end, int idx, int delta) {
        if (start == end) { tree[node] += delta; return; }
        int mid = (start + end) / 2;
        if (idx <= mid) updateUtil(2 * node + 1, start, mid, idx, delta);
        else            updateUtil(2 * node + 2, mid + 1, end, idx, delta);
        tree[node] = tree[2 * node + 1] + tree[2 * node + 2];
    }
}