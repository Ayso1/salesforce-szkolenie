public class MonthlyDiscountStrategy implements DiscountStrategy {
    private String targetMonth;

    public MonthlyDiscountStrategy() {}

    public void initialize(Discount_Type__c discountType) {
        this.targetMonth = discountType.Month__c;
    }

    public Decimal applyDiscount(Decimal discountedPrice, Decimal basePrice) {
        Datetime now = Datetime.now();
        String currentMonthName = now.format('MMMM');
        return currentMonthName == targetMonth ? discountedPrice : basePrice;
    }
}


