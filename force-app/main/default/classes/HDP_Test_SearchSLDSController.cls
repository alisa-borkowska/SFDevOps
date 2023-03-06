@IsTest
private class HDP_Test_SearchSLDSController {

    static testMethod HDP_SearchSLDSController shouldSearchDoctors() {
        String res = [SELECT Id, Body FROM StaticResource WHERE Name = 'HDP_REST_getDoctors' LIMIT 1].Body.toString();
        SingleRequestMock fakeResponse = new SingleRequestMock(200, 'OK', res, null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        HDP_SearchSLDSController controller = new HDP_SearchSLDSController();
        HDP_Doctor searchDoctor = controller.searchFields;
        searchDoctor.firstName = 'Alisa';
        searchDoctor.lastName = 'Borkowska';
        searchDoctor.country = 'Poland';

        Test.startTest();
            controller.searchDoctorRecords();
        Test.stopTest();

        System.assertEquals(1, controller.doctorsList.size(), 'Doctors\' count');
        HDP_Doctor doctor = controller.doctorsList[0];
        System.assertEquals(searchDoctor.firstName, doctor.firstName, 'First name');
        System.assertEquals(searchDoctor.lastName, doctor.lastName, 'Last name');
        System.assertEquals(searchDoctor.country, doctor.country, 'Country');
        System.assertEquals(true, String.isEmpty(controller.respond), 'Error message');

        return controller;
    }

    static testMethod void shouldReturnNotFound () {
        SingleRequestMock fakeResponse = new SingleRequestMock(404, 'Not Found', '', null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        HDP_SearchSLDSController controller = new HDP_SearchSLDSController();
        HDP_Doctor searchDoctor = controller.searchFields;
        searchDoctor.firstName = 'Malwina';

        Test.startTest();
            controller.searchDoctorRecords();
        Test.stopTest();

        System.assertEquals(null, controller.doctorsList, 'Doctors\' count');

        System.assertEquals(true, controller.isEmpty, 'isEmpty');
        System.assertEquals(true, String.isEmpty(controller.respond), 'Error message');

    }
    static testMethod void shouldCreateDoctors() {
        String res = [SELECT Id, Body FROM StaticResource WHERE Name = 'HDP_REST_createDoctor' LIMIT 1].Body.toString();

        SingleRequestMock fakeResponse = new SingleRequestMock(200, 'OK', res, null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);


        HDP_SearchSLDSController controller = new HDP_SearchSLDSController();
        HDP_Doctor ext = new HDP_Doctor();
        ext.firstName = 'Alisa';
        ext.lastName = 'Borkowska';
        ext.street = 'Rzemieslnicza';
        ext.startOfCareer = '2020-01-01';
        ext.postalCode = '15-773';
        ext.licenseNumber = '111111111';
        ext.email = 'al.b@gmail.com';
        ext.dateOfBirth = '1995-06-26';
        ext.city = 'Białystok';
        ext.country = 'Poland';

        Test.startTest();
            controller.showCreatePopup();
            controller.ext = ext;
            controller.createDoctorRecords();
            controller.hideCreatePopup();
        Test.stopTest();

        System.assertEquals(1, controller.doctorsList.size(), 'Doctors\' count');
        HDP_Doctor doctor = controller.doctorsList[0];
        System.assertEquals(ext.firstName, doctor.firstName, 'First name');
        System.assertEquals(ext.lastName, doctor.lastName, 'Last name');
        System.assertEquals(ext.country, doctor.country, 'Country');
        System.assertEquals(true, String.isEmpty(controller.respond), 'Error message');


    }
    static testMethod void shouldDeleteDoctor() {
        SingleRequestMock fakeResponse = new SingleRequestMock(200, 'OK', '', null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        HDP_SearchSLDSController controller = new HDP_SearchSLDSController();
        HDP_Doctor ext = new HDP_Doctor();
        ext.doctorId = '123';
        ApexPages.currentPage().getParameters().put('idToDelete', ext.doctorId);
        controller.pageNumber = 1;
        controller.doctorsList = new List<HDP_Doctor>{ext};
        HDP_Doctor undeletedDoctor = ext.clone();
        undeletedDoctor.doctorId = '456';
        controller.doctorsList.add(0, undeletedDoctor);

        Test.startTest();
            controller.showPopup();
            controller.ext = ext;
            controller.deleteDoctorFromParams();
            controller.hidePopup();
        Test.stopTest();

        System.assertEquals(1, controller.doctorsList.size(), 'Doctors\' count');
        System.assertEquals(true, String.isEmpty(controller.respond), 'Error message');
    }

    static testMethod void shouldEditDoctor() {
        String res1 = [SELECT Id, Body FROM StaticResource WHERE Name = 'HDP_REST_getDoctors' LIMIT 1].Body.toString();
        String res2 = [SELECT Id, Body FROM StaticResource WHERE Name = 'HDP_REST_createDoctor' LIMIT 1].Body.toString();
        SingleRequestMock fakeResponse = new SingleRequestMock(200, 'OK', res2, null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        HDP_SearchSLDSController controller = new HDP_SearchSLDSController();
        HDP_Doctor ext = ((List<HDP_Doctor>)JSON.deserialize(res1, List<HDP_Doctor>.class))[0];
        ext.street = 'Rzemieslnicza';
        ext.email = 'al.b@gmail.com';
        ext.dateOfBirth = '1995-06-26';
        controller.doctorsList = new List<HDP_Doctor>{ext};
        ApexPages.currentPage().getParameters().put('idToEdit', ext.doctorId);

        Test.startTest();
            controller.showEditPopup();
            controller.editDoctorFromParams();
            System.assertEquals(ext.name, controller.ext.name, 'Ext doctor');
            controller.hideEditPopup();
        Test.stopTest();

        System.assertNotEquals(controller.ext.name, ext.name, 'Ext doctor');
        System.assertEquals(1, controller.doctorsList.size(), 'Doctors\' count');
        HDP_Doctor doctor = controller.doctorsList[0];
        System.assertEquals(ext.street, doctor.street, 'Street');
        System.assertEquals(ext.email, doctor.email, 'Email');
        System.assertEquals(ext.dateOfBirth, doctor.dateOfBirth, 'Date of birth');
        System.assertEquals(true, String.isEmpty(controller.respond), 'Error message');
    }

    static testMethod void shouldReturnError() {
        String error = [SELECT Id, Body FROM StaticResource WHERE Name = 'HDP_REST_error' LIMIT 1].Body.toString();
        SingleRequestMock fakeResponse = new SingleRequestMock(200, 'OK', error, null);
        String errorMessage = (String)((Map<String, Object>)JSON.deserializeUntyped(error)).get('message');
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        HDP_SearchSLDSController controller = new HDP_SearchSLDSController();
        controller.doctorsList = new List<HDP_Doctor>();
        controller.idToEdit = '123';
        controller.ext = new HDP_Doctor();
        controller.ext.doctorId = '123';
        String message1, message2;

        Test.startTest();
            controller.editDoctorFromParams();
            message1 = controller.respond;
            controller.createDoctorRecords();
            message2 = controller.respond;
        Test.stopTest();

        System.assertEquals(0, controller.doctorsList.size(), 'Doctors\' count');
        System.assertEquals(errorMessage, message1, 'Edit error message');
        System.assertEquals(errorMessage, message2, 'Create error message');
    }

    static testMethod void shouldHideErrorPopup() {
        HDP_SearchSLDSController controller = new HDP_SearchSLDSController();
        controller.respond = 'message';

        Test.startTest();
            controller.showErrorPopup();
            controller.hideErrorPopup();
        Test.stopTest();

        System.assertEquals(null, controller.respond);
    }

    static testMethod void shouldNotMoveNavigationWhenThereIsOnlyOneResult() {
        String res = [SELECT Id, Body FROM StaticResource WHERE Name = 'HDP_REST_getDoctors' LIMIT 1].Body.toString();
        HDP_SearchSLDSController controller = new HDP_SearchSLDSController();
        controller.doctorsList = (List<HDP_Doctor>)JSON.deserialize(res, List<HDP_Doctor>.class);
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
        String res = [SELECT Id, Body FROM StaticResource WHERE Name = 'HDP_REST_getDoctors' LIMIT 1].Body.toString();
        HDP_SearchSLDSController controller = new HDP_SearchSLDSController();
        controller.doctorsList = (List<HDP_Doctor>)JSON.deserialize(res, List<HDP_Doctor>.class);
        for (Integer i=0; i<40; i++) {
            controller.doctorsList.add(controller.doctorsList[0].clone());
        }
        controller.resultSize = 41;
        controller.pageSize = 20;
        System.debug(controller.doctorsList.size());

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

    static testMethod void shouldGetCountryOptions() {
        String res = [SELECT Id, Body FROM StaticResource WHERE Name = 'HDP_REST_getDoctors' LIMIT 1].Body.toString();
        List<HDP_Doctor> doctors = (List<HDP_Doctor>)JSON.deserialize(res, List<HDP_Doctor>.class);
        doctors.add(doctors[0].clone());
        HDP_Doctor doctorWithoutCountry = doctors[0].clone();
        doctorWithoutCountry.country = null;
        doctors.add(doctorWithoutCountry);
        res = JSON.serialize(doctors);
        SingleRequestMock fakeResponse = new SingleRequestMock(200, 'OK', res, null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        HDP_SearchSLDSController controller = new HDP_SearchSLDSController();
        Test.startTest();
            List<SelectOption> countries = controller.getCountryOptions();
        Test.stopTest();

        System.assertEquals(2, countries.size(), 'Countries\' size');
        System.assertEquals('Poland', countries[0].getValue(), 'Country');
        System.assertEquals('', countries[1].getValue(), 'Empty country option');
    }

    static testMethod void shouldExportCSV() {
        String res = [SELECT Id, Body FROM StaticResource WHERE Name = 'HDP_REST_getDoctors' LIMIT 1].Body.toString();
        HDP_SearchSLDSController controller = new HDP_SearchSLDSController();
        controller.doctorsList = (List<HDP_Doctor>)JSON.deserialize(res, List<HDP_Doctor>.class);

        Test.startTest();
            PageReference pageRef = controller.exportCSV();
        Test.stopTest();

        System.assertNotEquals(null, pageRef, 'Page reference');
    }

    static testMethod void shouldExportXLS() {
        String res = [SELECT Id, Body FROM StaticResource WHERE Name = 'HDP_REST_getDoctors' LIMIT 1].Body.toString();
        HDP_SearchSLDSController controller = new HDP_SearchSLDSController();
        controller.doctorsList = (List<HDP_Doctor>)JSON.deserialize(res, List<HDP_Doctor>.class);

        Test.startTest();
            PageReference pageRef = controller.exportXLS();
        Test.stopTest();

        System.assertNotEquals(null, pageRef, 'Page reference');
    }

    static testMethod void shouldReloadEmptyController() {
        HDP_SearchSLDSController controller = new HDP_SearchSLDSController();
        controller.doctorsList = null;
        controller.pageSize = null;
        controller.pageNumber = null;

        Test.startTest();
            controller.reloadPagedDoctors();
        Test.stopTest();

        System.assertNotEquals(null, controller.doctorsList, 'Doctors\' list');
        System.assertNotEquals(null, controller.pageNumber, 'Page Number');
        System.assertNotEquals(null, controller.pageSize, 'Page Size');
    }

    static testMethod void shouldClearDoctorRecords() {
        HDP_SearchSLDSController controller = new HDP_SearchSLDSController();
        controller.doctorsList = new List<HDP_Doctor>{new HDP_Doctor()};
        Test.startTest();
            controller.clearDoctorRecords();
        Test.stopTest();

        System.assertEquals(0, controller.doctorsList.size(), 'Doctors\' count');
    }

    static testMethod void shouldNotThrowErrorsIfDoctorsListIsNullOnGetCountries() {
        SingleRequestMock fakeResponse = new SingleRequestMock(200, 'OK', '', null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        HDP_SearchSLDSController controller = new HDP_SearchSLDSController();
        List<SelectOption> countries;

        Test.startTest();
            countries = controller.getCountryOptions();
        Test.stopTest();

        System.assertEquals(0, countries.size(), 'Countries\' size');
    }

    static testMethod void shouldNotFailOnEmptyList() {
        SingleRequestMock fakeResponse = new SingleRequestMock(200, 'OK', '[]', null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        HDP_SearchSLDSController controller = new HDP_SearchSLDSController();

        Test.startTest();
            controller.searchDoctorRecords();
        Test.stopTest();

        System.assertEquals(true, controller.isEmpty, 'isEmpty');
        System.assertEquals(0, controller.resultSize, 'Result Size');
        System.assertNotEquals(null, controller.doctorsList, 'Doctors\' list');
    }
}