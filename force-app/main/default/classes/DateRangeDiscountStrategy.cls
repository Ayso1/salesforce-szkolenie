public class DateRangeDiscountStrategy implements DiscountStrategy {
    private Date startDate;
    private Date endDate;

    public DateRangeDiscountStrategy() {}

    public void initialize(Discount_Type__c discountType) {
        this.startDate = discountType.Start_Date__c;
        this.endDate = discountType.End_Date__c;
    }

    public Decimal applyDiscount(Decimal discountedPrice, Decimal basePrice) {
        Date today = Date.today();

        Integer todayMonth = today.month();
        Integer todayDay = today.day();
        Integer startMonth = startDate.month();
        Integer startDay = startDate.day();
        Integer endMonth = endDate.month();
        Integer endDay = endDate.day();

        Boolean inRange = false;

        if (startMonth == endMonth) {
            inRange = (todayMonth == startMonth) && (todayDay >= startDay && todayDay <= endDay);
        } else if (todayMonth == startMonth && todayDay >= startDay) {
            inRange = true;
        } else if (todayMonth == endMonth && todayDay <= endDay) {
            inRange = true;
        } else if (todayMonth > startMonth && todayMonth < endMonth) {
            inRange = true;
        }

        return inRange ? discountedPrice : basePrice;
    }
}


