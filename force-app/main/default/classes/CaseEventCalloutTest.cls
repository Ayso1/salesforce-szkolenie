@IsTest
public class CaseEventCalloutTest {

    @IsTest
    static void testSendCaseEvent_Success() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        Test.startTest();
        try {
            CaseEventCallout.sendCaseEvent(subject, description);
            Assert.isTrue(true, 'Callout completed successfully.');
        } catch (Exception e) {
            Assert.fail('No exception should be thrown, but got: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void testSendCaseEvent_Error() {
        Test.setMock(HttpCalloutMock.class, new MockHttpErrorResponse());

        try {
            Test.startTest();
            CaseEventCallout.sendCaseEvent(subject, description);
            Test.stopTest();
            Assert.fail('Expected CalloutException was not thrown.');
        } catch (Exception e) {
            Assert.isTrue(e.getMessage().contains('Error: Callout failed with Status Code: 500'),
                    'The exception message does not contain the expected error.');
        }
    }

    static String subject = 'Test Subject';
    static String description = 'Test Description';

    private class MockHttpResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(201);
            res.setBody('{"message":"Success"}');
            return res;
        }
    }

    private class MockHttpErrorResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('{"error":"Internal Server Error"}');
            return res;
        }
    }
}
