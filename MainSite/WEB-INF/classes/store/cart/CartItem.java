package store.cart;

public class CartItem {
   private int itemId;
   private String itemName;
   private String itemType;
   private String itemDescription;
   private double unitPrice;
   private int maxInStock;
   
   public CartItem(int id) {
      itemId = id;
      itemName = "";
      itemDescription = "";
      unitPrice=0.0;
      maxInStock = 0;
   }
   
   public CartItem(int id, String name, String type, String description, double price, int inventory) {
      itemId = id;
      itemName = name;
      itemType = type;
      itemDescription = description;
      unitPrice=price;
      maxInStock = inventory;
   }
   
   public int getItemId() {
      return itemId;
   }
   
   public String getName() {
      return itemName;
   }
   
   
   public String getType() {
      return itemType;
   }
   
   public String getDescription() {
      return itemDescription;
   }
   
   public double getPrice() {
      return unitPrice;
   }
   
   public int getInventory() {
      return maxInStock;
   }
   
   public void setItemId(int id) {
      itemId=id;
   }
   
   public void setName(String name) {
      itemName=name;
   }
   
   public void setType(String type) {
      itemType=type;
   }
   
   public void setDescription(String description) {
      itemDescription=description;
   }
   
   public void setPrice(double price) {
      unitPrice=price;
   }
   
   public void setInventory(int inventory) {
      maxInStock=inventory;
   }
   
   public boolean inStock() {
      return maxInStock==0;
   }
   
}