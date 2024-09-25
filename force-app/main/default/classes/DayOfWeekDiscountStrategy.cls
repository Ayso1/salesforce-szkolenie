public class DayOfWeekDiscountStrategy implements DiscountStrategy {
    private String targetDayOfWeek;

    public DayOfWeekDiscountStrategy() {
    }

    public void initialize(Discount_Type__c discountType) {
        this.targetDayOfWeek = discountType.Day_of_Week__c;
    }

    public Decimal applyDiscount(Decimal discountedPrice, Decimal basePrice) {
        Datetime now = Datetime.now();
        String currentDayOfWeek = now.format('EEEE');
        return currentDayOfWeek == targetDayOfWeek ? discountedPrice : basePrice;
    }
}

