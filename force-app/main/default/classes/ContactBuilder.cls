public with sharing class ContactBuilder {

    public static Builder getBuilder() {
        return new Builder();
    }

    public class Builder {
        private Contact contact;

        public Builder() {
            contact = new Contact();
        }

        public Builder setFirstName(String firstName) {
            contact.FirstName = firstName;
            return this;
        }

        public Builder setLastName(String lastName) {
            contact.LastName = lastName;
            return this;
        }

        public Builder setEmail(String email) {
            contact.Email = email;
            return this;
        }

        public Contact save() {
            insert contact;
            return contact;
        }

        public Contact getContact() {
            return contact;
        }
    }
}