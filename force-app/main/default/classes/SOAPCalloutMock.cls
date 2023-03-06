@IsTest
global class SOAPCalloutMock implements WebServiceMock {
    Map<String, Object> responseList;

    global void doInvoke(
            Object stub,
            Object request,
            Map<String, Object> response,
            String endpoint,
            String soapAction,
            String requestName,
            String responseNS,
            String responseName,
            String responseType
    ) {
        System.debug(responseType);
        if (responseList.containsKey(responseType)) {
            response.put('response_x', responseList.get(responseType));
        }
    }

    global SOAPCalloutMock(Map<String, Object> responses) {
        responseList = responses;
    }
}