public with sharing class ProductCallout implements Queueable, Database.AllowsCallouts {

    private List<Product2> products;

    public ProductCallout(List<Product2> products) {
        this.products = products;
    }

    public void execute(QueueableContext context) {
        sendProduct(products);
    }

    public static void sendProduct(List<Product2> product2List) {
        String requestBody = JSON.serialize(product2List);
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:NamedCred/services/apexrest/Products');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        req.setBody(requestBody);

        Http http = new Http();
        HttpResponse res;

        try {
            res = http.send(req);
            if (res.getStatusCode() == 200) {
                IntegrationLogger.logSuccess('Product Callout', requestBody, res.getBody(), product2List[0]);
            } else {
                IntegrationLogger.logError('Product Callout', requestBody, 'Status Code: ' + res.getStatusCode() + ' - ' + res.getBody(), product2List[0]);
            }
        } catch (Exception e) {
            IntegrationLogger.logError('Product Callout', requestBody, e.getMessage(), product2List[0]);
        }
    }
}
