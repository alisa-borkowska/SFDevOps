@IsTest
private class HDP_Test_HospitalsSearchController {

    static testMethod void shouldSearchHospitalsCorrectly() {
        Test.setMock(WebServiceMock.class, HDP_SOAP_Mock.getResponses());

        HDP_HospitalSearchController controller = new HDP_HospitalSearchController();
        HDP_Hospital searchHospital  = controller.searchFields;
        searchHospital.name = 'Seattle Grace Hospital';
        searchHospital.city = 'Seattle';

        Test.startTest();
            controller.searchHospitalsRecords();
        Test.stopTest();

        System.assertEquals(1, controller.hospitalsList.size(), 'Hospitals\' count');
        HDP_Hospital hospital = controller.hospitalsList[0];
        System.assertEquals(searchHospital.name, hospital.name, 'Name');
        System.assertEquals(searchHospital.city, hospital.city, 'City');
        System.assertEquals(null, controller.respond, 'Error message');
    }

    static testMethod void shouldDeleteHospital() {
        Test.setMock(WebServiceMock.class, HDP_SOAP_Mock.getResponses());

        HDP_HospitalSearchController controller = new HDP_HospitalSearchController();
        HDP_Hospital hsp = new HDP_Hospital();
        hsp.id = '123';
        controller.hospitalsList = new List<HDP_Hospital>{hsp};
        HDP_Hospital hsp2 = hsp.clone();
        hsp2.id = '456';
        controller.hospitalsList.add(0, hsp2);
        ApexPages.currentPage().getParameters().put('idToDelete', '123');

        Test.startTest();
            controller.showPopup();
            controller.deleteHospitalFromParams();
            controller.hidePopup();
        Test.stopTest();

        System.assertEquals(1, controller.hospitalsList.size(), 'Hospitals\' count');
        System.assertEquals(null, controller.ext.id, 'Clearing ext');
        System.assertEquals(null, controller.respond, 'Error message');
    }

    static testMethod void shouldEditHospital() {
        Test.setMock(WebServiceMock.class, HDP_SOAP_Mock.getResponses());
        HDP_HospitalSearchController controller = new HDP_HospitalSearchController();
        HDP_Hospital hsp = new HDP_Hospital();
        hsp.id = '123';
        hsp.name = 'Seattle Grace Hospital';
        hsp.city = 'Seattle';
        controller.hospitalsList = new List<HDP_Hospital>{hsp};
        ApexPages.currentPage().getParameters().put('idToEdit', '123');
        HDP_Hospital edited = hsp.clone();
        edited.name = 'Saint Grace Hospital';
        edited.country = 'USA';


        Test.startTest();
            controller.showEditPopup();
            controller.ext = edited;
            controller.editHospital();
            controller.hideEditPopup();
        Test.stopTest();

        HDP_Hospital hospital = controller.hospitalsList[0];
        System.assertEquals(edited.name, hospital.name, 'Hospital name');
        System.assertEquals(edited.country, hospital.country, 'Hospital country');
        System.assertEquals(hsp.city, hospital.city, 'Hospital city');
        System.assertEquals(null, controller.respond, 'Error message');
    }

    static testMethod void shouldCreateHospital() {
        Test.setMock(WebServiceMock.class, HDP_SOAP_Mock.getResponses());
        HDP_HospitalSearchController controller = new HDP_HospitalSearchController();
        HDP_Hospital hsp = new HDP_Hospital();
        hsp.name = 'Seattle Grace Hospital';
        hsp.city = 'Seattle';

        Test.startTest();
            controller.showCreatePopup();
            controller.ext = hsp;
            controller.createHospitalRecords();
            controller.hideCreatePopup();
        Test.stopTest();

        System.assertEquals(hsp.name, controller.hospitalsList[0]?.name, 'Hospital name');
        System.assertEquals(hsp.city, controller.hospitalsList[0]?.city, 'Hospital city');
        System.assertEquals(null, controller.respond, 'Error message');
    }

    static testMethod void shouldReturnError() {
        Test.setMock(WebServiceMock.class, HDP_SOAP_Mock.getFailResponses());
        HDP_HospitalSearchController controller = new HDP_HospitalSearchController();
        controller.ext = new HDP_Hospital();
        controller.ext.name = 'toolongnametoolongnametoolongnametoolongnametoolongnametoolongname';
        controller.ext.id = controller.idToEdit = controller.idToDelete = '123';
        controller.searchFields.name = controller.ext.name;

        Test.startTest();
            controller.createHospitalRecords();
            String msg1 = controller.respond;
            controller.editHospital();
            String msg2 = controller.respond;
            controller.deleteHospitalFromParams();
            String msg3 = controller.respond;
            controller.searchHospitalsRecords();
            String msg4 = controller.respond;
            controller.hideErrorPopup();
        Test.stopTest();

        System.assertNotEquals(null, msg1, 'Create error message');
        System.assertNotEquals(null, msg2, 'Edit error message');
        System.assertNotEquals(null, msg3, 'Delete error message');
        System.assertNotEquals(null, msg4, 'Search error message');
    }

    static testMethod void shouldNotMoveNavigationWhenThereIsOnlyOneResult() {
        Test.setMock(WebServiceMock.class, HDP_SOAP_Mock.getResponses());
        HDP_HospitalSearchController controller = new HDP_HospitalSearchController();
        HDP_Hospital hsp = new HDP_Hospital();
        hsp.name = 'test';
        hsp.city = 'test';
        controller.hospitalsList = new List<HDP_Hospital> {hsp};
        controller.resultSize = 1;

        Test.startTest();
        controller.first();
        System.assertEquals(0, controller.pageNumber, 'Page after first()');
        controller.next();
        System.assertEquals(0, controller.pageNumber, 'Page after next()');
        controller.previous();
        System.assertEquals(0, controller.pageNumber, 'Page after previous()');
        controller.last();
        System.assertEquals(0, controller.pageNumber, 'Page after last()');
        Test.stopTest();
    }

    static testMethod void shouldAllowNavigationWhenManyResults() {
        Test.setMock(WebServiceMock.class, HDP_SOAP_Mock.getResponses());
        HDP_HospitalSearchController controller = new HDP_HospitalSearchController();
        HDP_Hospital hsp = new HDP_Hospital();
        hsp.name = 'test';
        hsp.city = 'test';
        controller.hospitalsList = new List<HDP_Hospital>();
        for (Integer i=0; i<40; i++) {
            controller.hospitalsList.add(hsp.clone());
        }
        controller.resultSize = 41;
        controller.pageSize = 20;
        System.debug(controller.hospitalsList.size());

        Test.startTest();
            controller.first();
            System.assertEquals(0, controller.pageNumber, 'Page after first()');
            controller.next();
            System.assertEquals(1, controller.pageNumber, 'Page after next()');
            controller.previous();
            System.assertEquals(0, controller.pageNumber, 'Page after previous()');
            controller.last();
            System.assertEquals(2, controller.pageNumber, 'Page after last()');
        Test.stopTest();
    }

    static testMethod void shouldReloadEmptyController() {
        HDP_HospitalSearchController controller = new HDP_HospitalSearchController();
        controller.pageSize = null;
        controller.pageNumber = null;
        controller.hospitalsList = null;

        Test.startTest();
            controller.reloadPagedHospitals();
        Test.stopTest();

        System.assertNotEquals(null, controller.pageSize, 'Page Size');
        System.assertNotEquals(null, controller.pageNumber, 'Page Number');
        System.assertNotEquals(null, controller.hospitalsList, 'Hospitals\' list');
    }

    static testMethod void shouldClearHospitals() {
        HDP_HospitalSearchController controller = new HDP_HospitalSearchController();
        controller.hospitalsList = new List<HDP_Hospital>{new HDP_Hospital()};

        Test.startTest();
            controller.clearHospitalsRecords();
        Test.stopTest();

        System.assertEquals(0, controller.hospitalsList.size(), 'Hospitals\' count');
    }

    static testMethod void shouldNotFailOnSearchNullList() {
        Test.setMock(WebServiceMock.class, HDP_SOAP_Mock.getNullResponse()); 
        HDP_HospitalSearchController controller = new HDP_HospitalSearchController();
        controller.searchFields.name = 'hospitaldoesntexist';

        Test.startTest();
            controller.searchHospitalsRecords();
        Test.stopTest();

        System.assertEquals(true, controller.isEmpty, 'isEmpty');
        System.assertNotEquals(null, controller.hospitalsList, 'Hospitals\' list');
    }

    static testMethod void shouldNotFailOnSearchEmptyList() {
        Test.setMock(WebServiceMock.class, HDP_SOAP_Mock.getEmptyResponse());
        HDP_HospitalSearchController controller = new HDP_HospitalSearchController();
        controller.searchFields.name = 'hospitaldoesntexist';

        Test.startTest();
        controller.searchHospitalsRecords();
        Test.stopTest();

        System.assertEquals(true, controller.isEmpty, 'isEmpty');
    }
}