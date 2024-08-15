public with sharing class AccountBuilder {

    public static Builder getBuilder() {
        return new Builder();
    }

    public class Builder {
        private Account account;

        public Builder() {
            account = new Account();
        }

        public Builder setName(String name) {
            account.Name = name;
            return this;
        }

        public Builder setIndustry(String industry) {
            account.Industry = industry;
            return this;
        }

        public Builder setPhone(String phone) {
            account.Phone = phone;
            return this;
        }

        public Account save() {
            insert account;
            return account;
        }

        public Account getAccount() {
            return account;
        }
    }
}