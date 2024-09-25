public with sharing class ProductBuilder {

    public static Builder getBuilder() {
        return new Builder();
    }

    public class Builder {
        private Product2 product;

        public Builder() {
            product = new Product2();
        }

        public Builder setName(String name) {
            product.Name = name;
            return this;
        }

        public Builder setDescription(String description) {
            product.Description = description;
            return this;
        }


        public Product2 save() {
            insert product;
            return product;
        }

        public Product2 getProduct() {
            return product;
        }
    }
}
