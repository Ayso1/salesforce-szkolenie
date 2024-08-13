public with sharing class OppToOrderConvert {
    public static void convertOrder(List<Opportunity> opportunities, Map<Id, Opportunity> opportunityOldMap) {
        Set<String> opportunityIds = new Set<String>();
        List<Order> orders = new List<Order>();
        for (Opportunity opp : opportunities) {
            if (opp.StageName == 'Closed Won' && (opportunityOldMap.get(opp.Id).StageName != 'Closed Won')) {
                opportunityIds.add(opp.Id);
                Order newOrder = new Order();
                newOrder.OpportunityId = opp.Id;
                newOrder.AccountId = opp.AccountId;
                newOrder.EffectiveDate = Date.today();
                newOrder.ContractId = opp.ContractId;
                newOrder.Status = 'Draft';
                newOrder.Pricebook2Id = opp.Pricebook2Id;
                newOrder.CurrencyIsoCode = opp.CurrencyIsoCode;
                orders.add(newOrder);
            }
        }

        if (!orders.isEmpty()) {
            insert orders;
        }

        Map<String, String> opportunityOrderId = new Map<String, String>();
        for (Order order : orders) {
            opportunityOrderId.put(order.OpportunityId, order.Id);
        }

        List<OrderItem> orderItems = new List<OrderItem>();
        List<OpportunityLineItem> opportunityLineItems = [
                SELECT Product2Id, Quantity, UnitPrice, PricebookEntryId, OpportunityId
                FROM OpportunityLineItem
                WHERE OpportunityId IN :opportunityIds
        ];

        if (!opportunityLineItems.isEmpty()) {
            for (OpportunityLineItem oli : opportunityLineItems) {
                OrderItem orderItem = new OrderItem();
                orderItem.OrderId = opportunityOrderId.get(oli.OpportunityId);
                orderItem.Product2Id = oli.Product2Id;
                orderItem.Quantity = oli.Quantity;
                orderItem.UnitPrice = oli.UnitPrice;
                orderItem.PricebookEntryId = oli.PricebookEntryId;
                orderItems.add(orderItem);
            }
            insert orderItems;
        }
    }
}