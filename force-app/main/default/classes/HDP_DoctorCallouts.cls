@RestResource(urlMapping='/Doctor/*')
global with sharing class HDP_DoctorCallouts {

    @HttpGet
    global static void getRecord() {
        RestRequest request = RestContext.request;
        String searchByFirstName = request.params.get('searchFName');
        String searchByLastName = request.params.get('searchLName');
        String searchByEmail = request.params.get('searchEmail');
        String searchByCountry = request.params.get('searchCountry');

        if (searchByFirstName != null && !String.isEmpty(searchByFirstName)) {
            searchByFirstName = '%' + searchByFirstName + '%';

        } else if (searchByFirstName == '' && searchByLastName =='' && searchByEmail =='') {
            searchByFirstName = '%' + searchByFirstName + '%';
        } else {
            searchByFirstName = '_';
        }
        if (searchByLastName != null && !String.isEmpty(searchByLastName)) {
            searchByLastName = '%' + searchByLastName + '%';
        } else {
            searchByLastName = '_';
        }
        if (searchByEmail != null && !String.isEmpty(searchByEmail)) {
            searchByEmail = '%' + searchByEmail + '%';
        } else {
            searchByEmail = '_';
        }
        if (searchByCountry != null && !String.isEmpty(searchByCountry)) {
            searchByCountry = '%' + searchByCountry + '%';
        } else {
            searchByCountry = '_';
        }


        List<Doctor__c> resultDoctor = [
                SELECT Name, First_Name__c, Last_Name__c, Id, License_Number__c, Date_of_Birth__c, Start_of_Career__c, Nationality__c, Speciality__c, Phone__c, Email__c, Street__c, Postal_Code__c, City__c, Country__c
                FROM Doctor__c
                WHERE First_Name__c LIKE :searchByFirstName
                OR Last_Name__c LIKE :searchByLastName
                OR Email__c LIKE :searchByEmail
                OR Country__c LIKE :searchByCountry
        ];

        List<HDP_Doctor> result = new List<HDP_Doctor>();
        for (Doctor__c doc : resultDoctor) {
            result.add(new HDP_Doctor(doc));
        }
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(result));
    }

    @HttpPost
    global static void addRecord() {
        RestRequest request = RestContext.request;
        String body = request.requestBody.toString();
        if (body == '' || body == null) {
            RestContext.response.responseBody = Blob.valueOf('{"success": false, "message": "Request body is empty"}');
            RestContext.response.statusCode = 400;
            return;
        }
        HDP_Doctor doc = (HDP_Doctor) JSON.deserialize(body, HDP_Doctor.class);
        if (doc.name == null || doc.firstName == null || doc.lastName == null) {
            RestContext.response.responseBody = Blob.valueOf('{"success": false, "message": "One of the required fields is null: name, firstName, lastName"}');
            RestContext.response.statusCode = 400;
            return;
        }
        Doctor__c resultDoctor;
        try {
            if (doc.dateOfBirth != null) {
                Date.valueOf(doc.dateOfBirth);
            }
            if (doc.startOfCareer != null) {
                Date.valueOf(doc.startOfCareer);
            }

        } catch (Exception e) {
            RestContext.response.responseBody = Blob.valueOf('{"success": false, "message": "Invalid format of date."}');
            RestContext.response.statusCode = 400;
            return;
        }
        try {
            resultDoctor = doc.createDoctor();
        } catch (Exception e) {
            RestContext.response.responseBody = Blob.valueOf('{"success": false, "message": "Unknown error. Review your data."}');
            RestContext.response.statusCode = 400;
            return;
        }

        try {
            insert resultDoctor;
        } catch (System.DmlException e) {
            RestContext.response.responseBody = Blob.valueOf('{"success": false, "message": "Validation error: ' + e.getDmlMessage(0) + '"}');
            RestContext.response.statusCode = 400;
            return;
        }

        doc.loadDoctor(resultDoctor);

        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(doc));
    }

    @HttpDelete
    global static void deleteRecord() {
        Id id = RestContext.request.params.get('id');
        if (id == null) {
            RestContext.response.responseBody = Blob.valueOf('{"success": false, "message": "Id can\'t be null"');
            RestContext.response.statusCode = 400;
            return;
        }
        Doctor__c doc = [
                SELECT Name
                FROM Doctor__c
                WHERE Id = :id
        ][0];
        delete doc;
        RestContext.response.responseBody = Blob.valueOf('{"success": true}');
    }

    @HttpPatch
    global static void patchRecord() {
        Id id = RestContext.request.params.get('id');
        if (id == null) {
            RestContext.response.responseBody = Blob.valueOf('{"success": false, "message": "Required param \"id\" is missing."}');
            RestContext.response.statusCode = 400;
            return;
        }
        String body = RestContext.request.requestBody.toString();
        if (body == '' || body == null) {
            RestContext.response.responseBody = Blob.valueOf('{"success": false, "message": "One of the required fields is empty: name, firstName, lastName"}');
            RestContext.response.statusCode = 400;
            return;
        }
        HDP_Doctor doc = new HDP_Doctor(id);

        HDP_Doctor incomingDoctor = (HDP_Doctor) JSON.deserialize(body, HDP_Doctor.class);
        if (incomingDoctor.doctorId != null) {
            RestContext.response.responseBody = Blob.valueOf('{"success": false, "message": "Id can\'t be changed"}');
            RestContext.response.statusCode = 400;
            return;
        }
        if (incomingDoctor.name == '' || incomingDoctor.firstName == '' || incomingDoctor.lastName == '') {
            RestContext.response.responseBody = Blob.valueOf('{"success": false, "message": "One of the required fields is empty: name, firstName, lastName"}');
            RestContext.response.statusCode = 400;
            return;
        }
        HDP_Doctor updatedDoctor = doc.updateDoctor(incomingDoctor);
        try {
            if (updatedDoctor.dateOfBirth != null) {
                Date.valueOf(updatedDoctor.dateOfBirth);
            }
            if (updatedDoctor.startOfCareer != null) {
                Date.valueOf(updatedDoctor.startOfCareer);
            }

        } catch (Exception e) {
            RestContext.response.responseBody = Blob.valueOf('{"success": false, "message": "Invalid format of date."}');
            RestContext.response.statusCode = 400;
            return;
        }
        Doctor__c resultDoctor;
        try {
            resultDoctor = updatedDoctor.createDoctor();
        } catch (Exception e) {
            RestContext.response.responseBody = Blob.valueOf('{"success": false, "message": "Unknown error. Review your data."}');
            RestContext.response.statusCode = 400;
            return;
        }

        try {
            update resultDoctor;
        } catch (System.DmlException e) {
            RestContext.response.responseBody = Blob.valueOf('{"success": false, "message": "Validation error: ' + e.getDmlMessage(0) + '"}');
            RestContext.response.statusCode = 400;
            return;
        }
        RestContext.response.responseBody = Blob.valueOf('{"success": true}');
    }
}