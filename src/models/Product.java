package models;

public class Product {
    private int id, stock, sales30d;
    private String name, category;
    private double price;

    public Product(int id, String name, String category, int stock, double price, int sales30d) {
        this.id       = id;
        this.name     = name;
        this.category = category;
        this.stock    = stock;
        this.price    = price;
        this.sales30d = sales30d;
    }

    // ── Getters ──────────────────────────────────────────
    public int    getId()       { return id; }
    public String getName()     { return name; }
    public String getCategory() { return category; }
    public int    getStock()    { return stock; }
    public double getPrice()    { return price; }
    public int    getSales30d() { return sales30d; }

    // ── Setters ──────────────────────────────────────────
    public void setId(int id)             { this.id = id; }
    public void setName(String name)      { this.name = name; }
    public void setCategory(String cat)   { this.category = cat; }
    public void setStock(int stock)       { this.stock = stock; }
    public void setPrice(double price)    { this.price = price; }
    public void setSales30d(int sales30d) { this.sales30d = sales30d; }

    @Override
    public String toString() {
        return "Product{id=" + id + ", name='" + name + "', category='" + category +
               "', stock=" + stock + ", price=" + price + ", sales30d=" + sales30d + "}";
    }
}