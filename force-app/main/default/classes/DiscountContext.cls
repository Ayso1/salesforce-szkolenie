public class DiscountContext {
    private DiscountStrategy strategy;

    public DiscountContext(Discount_Type__c discountType, String discountPeriodLabel) {

        try {
            Type strategyType = Type.forName(discountPeriodLabel);
            strategy = (DiscountStrategy) strategyType.newInstance();
            strategy.initialize(discountType);

        } catch (Exception e) {
            System.debug('Error creating strategy instance: ' + e.getMessage());
        }
    }

    public Decimal applyDiscount(Decimal discountedPrice, Decimal basePrice) {
        if (strategy != null) {
            return strategy.applyDiscount(discountedPrice, basePrice);
        }
        return basePrice;
    }
}

