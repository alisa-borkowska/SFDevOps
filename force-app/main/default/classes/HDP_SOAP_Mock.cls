@IsTest
public class HDP_SOAP_Mock {
    static Map<String, Object> loginResponse() {
        HDP_WSDL.loginResponse_element loginResponse = new HDP_WSDL.loginResponse_element();
        loginResponse.result = new HDP_WSDL.LoginResult();
        loginResponse.result.sessionId = '123';
        return new Map<String, Object>{
                'HDP_WSDL.loginResponse_element'=>loginResponse
        };
    }

    public static SOAPCalloutMock getResponses() {
        HDP_ExternalSoapWSDL.HA_HospitalObjectWrapper hosp1 = new HDP_ExternalSoapWSDL.HA_HospitalObjectWrapper();
        hosp1.name = 'Seattle Grace Hospital';
        hosp1.hospitalName = 'Seattle Grace Hospital';
        hosp1.city = 'Seattle';

        HDP_ExternalSoapWSDL.HA_HospitalObjectWrapper hosp2 = hosp1.clone();
        hosp2.hospitalName = 'Saint Grace Hospital';
        hosp2.country = 'USA';

        HDP_ExternalSoapWSDL.HA_HospitalObjectWrapper fail = new HDP_ExternalSoapWSDL.HA_HospitalObjectWrapper();
        fail.message = 'failed';

        HDP_ExternalSoapWSDL.getHospitalsResponse_element getHospitalResponse = new HDP_ExternalSoapWSDL.getHospitalsResponse_element();
        getHospitalResponse.result = new List<HDP_ExternalSoapWSDL.HA_HospitalObjectWrapper>{hosp1};
        HDP_ExternalSoapWSDL.deleteHospitalByIdResponse_element deleteHospitalResponse = new HDP_ExternalSoapWSDL.deleteHospitalByIdResponse_element();
        deleteHospitalResponse.result = hosp1;
        HDP_ExternalSoapWSDL.updateHospitalByIdResponse_element updateHospitalResponse = new HDP_ExternalSoapWSDL.updateHospitalByIdResponse_element();
        updateHospitalResponse.result = hosp2;
        HDP_ExternalSoapWSDL.createHospitalResponse_element createHospitalResponse = new HDP_ExternalSoapWSDL.createHospitalResponse_element();
        createHospitalResponse.result = hosp1;
        Map<String, Object> ret =  new Map<String, Object>{
                'HDP_ExternalSoapWSDL.getHospitalsResponse_element'=>getHospitalResponse,
                'HDP_ExternalSoapWSDL.deleteHospitalByIdResponse_element'=>deleteHospitalResponse,
                'HDP_ExternalSoapWSDL.updateHospitalByIdResponse_element'=>updateHospitalResponse,
                'HDP_ExternalSoapWSDL.createHospitalResponse_element'=>createHospitalResponse
        };
        ret.putAll(loginResponse());
        return new SOAPCalloutMock(ret);
    }

    public static SOAPCalloutMock getNullResponse() {
        Map<String, Object> ret = new Map<String, Object>{
                'HDP_ExternalSoapWSDL.getHospitalsResponse_element'=>new HDP_ExternalSoapWSDL.getHospitalsResponse_element()
        };
        ret.putAll(loginResponse());
        return new SOAPCalloutMock(ret);
    }

    public static SOAPCalloutMock getEmptyResponse() { 
        HDP_ExternalSoapWSDL.getHospitalsResponse_element getHospitalsResponse = new HDP_ExternalSoapWSDL.getHospitalsResponse_element();
        getHospitalsResponse.result = new List<HDP_ExternalSoapWSDL.HA_HospitalObjectWrapper>();
        Map<String, Object> ret = new Map<String, Object>{
                'HDP_ExternalSoapWSDL.getHospitalsResponse_element'=>getHospitalsResponse
        };
        ret.putAll(loginResponse());
        return new SOAPCalloutMock(ret);
    }

    public static SOAPCalloutMock getFailResponses() {
        HDP_ExternalSoapWSDL.HA_HospitalObjectWrapper fail = new HDP_ExternalSoapWSDL.HA_HospitalObjectWrapper();
        fail.message = 'failed';

        HDP_ExternalSoapWSDL.getHospitalsResponse_element getHospitalResponse = new HDP_ExternalSoapWSDL.getHospitalsResponse_element();
        getHospitalResponse.result = new List<HDP_ExternalSoapWSDL.HA_HospitalObjectWrapper>{fail};
        HDP_ExternalSoapWSDL.deleteHospitalByIdResponse_element deleteHospitalResponse = new HDP_ExternalSoapWSDL.deleteHospitalByIdResponse_element();
        deleteHospitalResponse.result = fail;
        HDP_ExternalSoapWSDL.updateHospitalByIdResponse_element updateHospitalResponse = new HDP_ExternalSoapWSDL.updateHospitalByIdResponse_element();
        updateHospitalResponse.result = fail;
        HDP_ExternalSoapWSDL.createHospitalResponse_element createHospitalResponse = new HDP_ExternalSoapWSDL.createHospitalResponse_element();
        createHospitalResponse.result = fail;
        Map<String, Object> ret =  new Map<String, Object>{
                'HDP_ExternalSoapWSDL.getHospitalsResponse_element'=>getHospitalResponse,
                'HDP_ExternalSoapWSDL.deleteHospitalByIdResponse_element'=>deleteHospitalResponse,
                'HDP_ExternalSoapWSDL.updateHospitalByIdResponse_element'=>updateHospitalResponse,
                'HDP_ExternalSoapWSDL.createHospitalResponse_element'=>createHospitalResponse
        };
        ret.putAll(loginResponse());
        return new SOAPCalloutMock(ret);
    }
}