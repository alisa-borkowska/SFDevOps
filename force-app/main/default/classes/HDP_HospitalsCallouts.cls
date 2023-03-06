global with sharing class HDP_HospitalsCallouts {
    webService static List<HDP_Hospital> searchHospitals(String name, String city) {
        if (name != null && !String.isEmpty(name)) {
            name = '%' + name + '%';
        } else {
            name = '_';
        }
        if (city != null && !String.isEmpty(city)) {
            city = '%' + city + '%';
        } else {
            city = '_';
        }
        if (name == '_' && city == '_') {
            name = '%%';
            city = '%%';
        }

        List<Hospital__c> resultHospital = [
                SELECT Name, Id, Phone_Number__c, Fax_Number__c, Street__c, Postal_Code__c, City__c, Country__c, No_Ambulances__c, Helicopter_Access__c
                FROM Hospital__c
                WHERE City__c LIKE :city
                OR Name LIKE :name
        ];
        List<HDP_Hospital> result = new List<HDP_Hospital>();
        for (Hospital__c hosp : resultHospital) {
            result.add(HDP_Hospital.fromHospital_c(hosp));
        }
        return result;
    }
    webService static Boolean deleteHospital(String id) {

        Hospital__c hosp = [
                SELECT Name
                FROM Hospital__c
                WHERE Id = :id
        ][0];
        try {
            delete hosp;
        } catch (System.DmlException e) {
            return false;
        }
        return true;
    }

    webService static HDP_Hospital createHospital(HDP_Hospital hospital) {
        Hospital__c hosp = HDP_Hospital.newHospital(hospital);
        try {

            insert hosp;
            System.debug(hosp);
            hospital.message = 'Success, hospital ID :' + hosp.Id;
        } catch (System.JSONException e) {
            hospital.message = 'Required fields missing: hospital name, name';
        } catch (System.TypeException e) {
            hospital.message = 'Invalid format of no. ambulances or helicopter access';
        } catch (System.DmlException e) {
            hospital.message = e.getDmlMessage(0);
            hospital.message = hospital.message.replaceAll('__c', '');
            hospital.message = hospital.message.replaceAll('_', ' ');
        } catch (Exception e) {
            hospital.message = 'Internal server error';
        }
        return hospital;
    }

    webService static HDP_Hospital editHospital(String id, HDP_Hospital hospital) {
        Hospital__c hosp = [
                SELECT Name, City__c, Country__c, Street__c, Postal_Code__c, Phone_Number__c, Fax_Number__c, No_Ambulances__c, Helicopter_Access__c, Id
                FROM Hospital__c
                WHERE Id = :id
        ][0];

        Hospital__c updatedHospital;
        try {
            hospital = HDP_Hospital.updateHospital(HDP_Hospital.fromHospital_c(hosp), hospital);
            updatedHospital = HDP_Hospital.newHospital(hospital);
            update updatedHospital;
            hospital.message = !String.isEmpty(hospital.message) ? hospital.message : 'Success';
        } catch (System.JSONException e) {
            hospital.message = 'Missing required fields: name, country, city.';
        } catch (System.TypeException e) {
            hospital.message = 'Invalid type of ambulance No or helicopter access. Try again.';
        } catch (System.DmlException e) {
            hospital.message = e.getDmlMessage(0) ;

        } catch (Exception e) {
            hospital.message = 'Internal server error';
        }
        return hospital;
    }

}