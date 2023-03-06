@isTest
public class MultiRequestMock implements HttpCalloutMock {
    Map<String, Map<String, HttpCalloutMock>> requests;

    public MultiRequestMock(Map<String, Map<String, HttpCalloutMock>> requests) {
        this.requests = requests;
    }

    public HTTPResponse respond(HTTPRequest req) {
        Map<String, HttpCalloutMock> mocks = requests.get(req.getEndpoint());
        if (mocks != null) {
            HttpCalloutMock mock = mocks.get(req.getMethod());
            if (mock != null) {
                return mock.respond(req);
            }
        }
        HttpResponse fail = new HttpResponse();
        fail.setStatusCode(404);
        fail.setStatus('Not Found');
        return fail;
    }

    public void addRequestMock(String url, Map<String, HttpCalloutMock> mock) {
        requests.put(url, mock);
    }
}