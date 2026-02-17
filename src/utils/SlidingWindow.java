package utils;

import java.util.*;

/**
 * Sliding Window utilities for trend detection on sales / stock data.
 */
public class SlidingWindow {

    public static final int DEFAULT_WINDOW = 7;

    public static double[] movingAverage(int[] data, int window) {
        if (data == null || data.length < window) return new double[0];
        double[] result = new double[data.length - window + 1];
        double sum = 0;
        for (int i = 0; i < window; i++) sum += data[i];
        result[0] = sum / window;
        for (int i = window; i < data.length; i++) {
            sum += data[i] - data[i - window];
            result[i - window + 1] = sum / window;
        }
        return result;
    }

    public static List<TrendResult> detectTrends(int[] data, int window, double highMark, double lowMark) {
        List<TrendResult> trends = new ArrayList<>();
        double[] avgs = movingAverage(data, window);
        for (int i = 0; i < avgs.length; i++) {
            String label = avgs[i] >= highMark ? "HIGH_DEMAND"
                         : avgs[i] <= lowMark  ? "LOW_DEMAND"
                         : "NORMAL";
            trends.add(new TrendResult(i, avgs[i], label));
        }
        return trends;
    }

    public static int[] slidingMax(int[] data, int window) {
        if (data == null || data.length < window) return new int[0];
        int[] result = new int[data.length - window + 1];
        Deque<Integer> deque = new ArrayDeque<>();
        for (int i = 0; i < data.length; i++) {
            while (!deque.isEmpty() && deque.peekFirst() < i - window + 1)
                deque.pollFirst();
            while (!deque.isEmpty() && data[deque.peekLast()] <= data[i])
                deque.pollLast();
            deque.addLast(i);
            if (i >= window - 1) result[i - window + 1] = data[deque.peekFirst()];
        }
        return result;
    }

    public static class TrendResult {
        private final int    windowIndex;
        private final double average;
        private final String trend;

        TrendResult(int idx, double avg, String trend) {
            this.windowIndex = idx;
            this.average     = avg;
            this.trend       = trend;
        }

        // FIX: JSTL EL needs getters — public fields alone don't work
        public int    getWindowIndex() { return windowIndex; }
        public double getAverage()     { return average; }
        public String getTrend()       { return trend; }
    }
}