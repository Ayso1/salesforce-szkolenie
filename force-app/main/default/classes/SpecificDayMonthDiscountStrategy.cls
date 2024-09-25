public class SpecificDayMonthDiscountStrategy implements DiscountStrategy {
    private Integer specificDay;
    private Integer specificMonth;

    public SpecificDayMonthDiscountStrategy() {}

    public void initialize(Discount_Type__c discountType) {
        List<String> dateParts = discountType.Specific_Day_Month__c.split('\\.');
        if (dateParts.size() == 2) {
            this.specificDay = Integer.valueOf(dateParts[0]);
            this.specificMonth = Integer.valueOf(dateParts[1]);
        }
    }

    public Decimal applyDiscount(Decimal discountedPrice, Decimal basePrice) {
        Datetime now = Datetime.now();
        Integer currentDayOfMonth = now.day();
        Integer currentMonth = now.month();

        if (currentDayOfMonth == specificDay && currentMonth == specificMonth) {
            return discountedPrice;
        }
        return basePrice;
    }
}


