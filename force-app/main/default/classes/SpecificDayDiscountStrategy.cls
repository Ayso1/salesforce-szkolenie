public class SpecificDayDiscountStrategy implements DiscountStrategy {
    private Decimal specificDay;

    public SpecificDayDiscountStrategy() {}

    public void initialize(Discount_Type__c discountType) {
        this.specificDay = discountType.Specific_Day__c;
    }

    public Decimal applyDiscount(Decimal discountedPrice, Decimal basePrice) {
        Datetime now = Datetime.now();
        Integer currentDayOfMonth = now.day();
        return currentDayOfMonth == specificDay ? discountedPrice : basePrice;
    }
}


