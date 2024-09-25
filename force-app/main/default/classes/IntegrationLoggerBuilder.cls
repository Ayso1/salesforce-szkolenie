public with sharing class IntegrationLoggerBuilder {

    public static Builder getBuilder() {
        return new Builder();
    }

    public class Builder {
        private Integration_Logger__c logger;

        public Builder() {
            logger = new Integration_Logger__c();
        }

        public Builder setName(String name) {
            logger.Name = name;
            return this;
        }

        public Builder setStatus(String status) {
            logger.Status__c = status;
            return this;
        }

        public Builder setRequestData(String requestData) {
            logger.Request_Data__c = requestData;
            return this;
        }

        public Builder setResponseData(String responseData) {
            logger.Response_Data__c = responseData;
            return this;
        }

        public Builder setTimestamp(Datetime timestamp) {
            logger.Timestamp__c = timestamp;
            return this;
        }

        public Builder setProductId(Id productId) {
            logger.Product__c = productId;
            return this;
        }

        public Integration_Logger__c save() {
            insert logger;
            return logger;
        }

        public Integration_Logger__c getLogger() {
            return logger;
        }
    }
}
