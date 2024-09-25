public interface DiscountStrategy {
    Decimal applyDiscount(Decimal discountedPrice, Decimal basePrice);
    void initialize(Discount_Type__c discountType);
}
