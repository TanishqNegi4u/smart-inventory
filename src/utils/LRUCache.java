package utils;

import java.util.*;

public class LRUCache<K, V> {

    private class Node {
        K key; V value; Node prev, next;
        Node(K k, V v) { key = k; value = v; }
    }

    private final int capacity;
    private final Map<K, Node> cache = new HashMap<>();
    private final Node head = new Node(null, null);
    private final Node tail = new Node(null, null);

    public LRUCache(int capacity) {
        this.capacity = capacity;
        head.next = tail;
        tail.prev = head;
    }

    /** O(1) get; returns null on miss */
    public V get(K key) {
        Node node = cache.get(key);
        if (node == null) return null;
        moveToFront(node);
        return node.value;
    }

    /** O(1) put; evicts LRU entry when over capacity */
    public void put(K key, V value) {
        Node node = cache.get(key);
        if (node != null) {
            node.value = value;
            moveToFront(node);
        } else {
            Node newNode = new Node(key, value);
            cache.put(key, newNode);
            addToFront(newNode);
            if (cache.size() > capacity) evictLRU();
        }
    }

    public void invalidate(K key) {
        Node node = cache.remove(key);
        if (node != null) removeNode(node);
    }

    public int size()  { return cache.size(); }
    public boolean containsKey(K key) { return cache.containsKey(key); }

    // ── Doubly-linked list helpers ────────────────────────
    private void addToFront(Node node) {
        node.next       = head.next;
        node.prev       = head;
        head.next.prev  = node;
        head.next       = node;
    }

    private void removeNode(Node node) {
        node.prev.next = node.next;
        node.next.prev = node.prev;
    }

    private void moveToFront(Node node) {
        removeNode(node);
        addToFront(node);
    }

    private void evictLRU() {
        Node last = tail.prev;
        cache.remove(last.key);
        removeNode(last);
    }
}