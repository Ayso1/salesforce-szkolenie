@isTest
private class ExternalDatabaseControllerTest {
    @isTest
    static void testSearch() {
        ExternalDatabaseController controller = new ExternalDatabaseController();
        controller.searchKeyword = 'Test';

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        controller.search();
        Test.stopTest();

        System.assertNotEquals(null, controller.leads, 'The leads list should not be null');
        System.assertEquals(1, controller.leads.size(), 'The leads list should contain one lead');
        System.assertEquals('Test', controller.leads[0].FirstName, 'The lead FirstName should be "Test"');
        System.assertEquals('User', controller.leads[0].LastName, 'The lead LastName should be "User"');
        System.assertEquals('Test Company', controller.leads[0].Company, 'The lead Company should be "Test Company"');
    }

    @isTest
    static void testClear() {
        ExternalDatabaseController controller = new ExternalDatabaseController();

        controller.searchKeyword = 'Test';
        controller.leads = new List<Lead>{
                new Lead(FirstName = 'Test', LastName = 'User', Company = 'Test Company')
        };
        controller.clear();

        System.assertEquals('', controller.searchKeyword);
        System.assertEquals(0, controller.leads.size());
    }

    @isTest
    static void testUpdateLead() {
        String jsonLead = '{"FirstName":"Updated","LastName":"User","Company":"Test Company"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        boolean result = ExternalDatabaseController.updateLead(jsonLead);
        Test.stopTest();

        System.assertEquals(true, result);
    }

    @isTest
    static void testDeleteLead() {
        String leadId = '00Q5g000004xxyz';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        ExternalDatabaseController.deleteLead(leadId);
        Test.stopTest();
    }

}

