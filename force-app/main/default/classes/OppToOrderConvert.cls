public with sharing class OppToOrderConvert {
    public static void convertOrder(List<Opportunity> opportunities, Map<Id, Opportunity> opportunityOldMap) {
        Set<Id> opportunityIds = new Set<Id>();
        List<Order> orders = new List<Order>();
        List<Contract> contractsToInsert = new List<Contract>();
        List<Contract> contractsToUpdate = new List<Contract>();

        for (Opportunity opp : opportunities) {
            if (opp.StageName == 'Closed Won' && (opportunityOldMap.get(opp.Id).StageName != 'Closed Won')) {
                if (opp.AccountId != null) {
                    opportunityIds.add(opp.Id);


                    Contract contract;
                    if (opp.ContractId == null) {

                        contract = new Contract();
                        contract.AccountId = opp.AccountId;
                        contract.ContractTerm = 1;
                        contract.Status = 'Draft';
                        contract.CurrencyIsoCode = opp.CurrencyIsoCode;
                        contractsToInsert.add(contract);
                    } else {

                        contract = [SELECT Id, Status, CurrencyIsoCode FROM Contract WHERE Id = :opp.ContractId LIMIT 1];
                        if (contract.Status == 'Draft') {
                            contract.Status = 'Activated';
                            contractsToUpdate.add(contract);
                        }

                        if (contract.CurrencyIsoCode != opp.CurrencyIsoCode) {
                            contract.CurrencyIsoCode = opp.CurrencyIsoCode;
                            contractsToUpdate.add(contract);
                        }
                    }

                    Order newOrder = new Order();
                    newOrder.OpportunityId = opp.Id;
                    newOrder.AccountId = opp.AccountId;
                    newOrder.EffectiveDate = Date.today();
                    newOrder.Status = 'Draft';
                    newOrder.Pricebook2Id = opp.Pricebook2Id;
                    newOrder.CurrencyIsoCode = opp.CurrencyIsoCode;


                    if (opp.ContractId == null && !contractsToInsert.isEmpty()) {

                    } else {
                        newOrder.ContractId = opp.ContractId;
                    }

                    orders.add(newOrder);
                } else {
                    System.debug('Opportunity ' + opp.Id + ' is missing AccountId.');
                }
            }
        }

        if (!contractsToInsert.isEmpty()) {
            insert contractsToInsert;

            for (Contract con : contractsToInsert) {
                con.Status = 'Activated';
                contractsToUpdate.add(con);
            }
            if (!contractsToUpdate.isEmpty()) {
                update contractsToUpdate;
            }

            for (Order order : orders) {
                for (Contract con : contractsToInsert) {
                    if (con.AccountId == order.AccountId) {
                        order.ContractId = con.Id;
                    }
                }
            }
        }

        if (!orders.isEmpty()) {
            insert orders;
        }

        Map<Id, Id> opportunityOrderId = new Map<Id, Id>();
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


