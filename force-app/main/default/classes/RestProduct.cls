@RestResource(UrlMapping='/Products/*')
global with sharing class RestProduct {
    @HttpPost
    global static String receiveProduct() {
        String jsonProduct = RestContext.request.requestBody.toString();

        List<Product2> deserializeProducts = (List<Product2>) JSON.deserialize(jsonProduct, List<Product2>.class);
        List<Product2> productsToInsert = new List<Product2>();

        for (Product2 product : deserializeProducts) {
            System.debug('Product: ' + product);
            product.External_Id__c = product.Id;
            product.Id = null;
            product.External_Product__c = true;
            productsToInsert.add(product);
        }

        try {
            if (!productsToInsert.isEmpty()) {
                upsert productsToInsert External_Id__c;

                List<String> createdProductIds = new List<String>();
                for (Product2 product : productsToInsert) {
                    createdProductIds.add(product.Id);
                }

                return 'Product records created successfully: ' + productsToInsert.size() + ' products inserted. IDs: ' + JSON.serialize(createdProductIds);
            } else {
                return 'No products to insert.';
            }
        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }
    }
}
