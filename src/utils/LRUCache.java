package utils;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * LRU Cache backed by LinkedHashMap.
 * Supports get, put, remove, clear, size — all O(1).
 */
public class LRUCache<K, V> {

    private final int capacity;
    private final LinkedHashMap<K, V> map;

    public LRUCache(int capacity) {
        this.capacity = capacity;
        this.map = new LinkedHashMap<K, V>(capacity, 0.75f, true) {
            @Override
            protected boolean removeEldestEntry(Map.Entry<K, V> eldest) {
                return size() > capacity;
            }
        };
    }

    /** Returns value for key, or null if not cached. Marks as recently used. */
    public synchronized V get(K key) {
        return map.getOrDefault(key, null);
    }

    /** Inserts or updates a key-value pair. Evicts LRU entry if over capacity. */
    public synchronized void put(K key, V value) {
        map.put(key, value);
    }

    /** Removes a specific key from the cache. */
    public synchronized void remove(K key) {
        map.remove(key);
    }

    /** Clears all entries from the cache. */
    public synchronized void clear() {
        map.clear();
    }

    /** Returns current number of cached entries. */
    public synchronized int size() {
        return map.size();
    }

    /** Returns true if the key exists in cache. */
    public synchronized boolean containsKey(K key) {
        return map.containsKey(key);
    }
}
