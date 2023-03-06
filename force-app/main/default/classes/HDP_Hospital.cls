/**
 * Created by alisa.borkowska on 21.12.2022.
 */

global with sharing class HDP_Hospital {
    webService String id { get; set; }
    webService String name { get; set; }
    webService String street { get; set; }
    webService String city { get; set; }
    webService String country { get; set; }
    webService String postalCode { get; set; }
    webService String noAmbulances { get; set; }
    webService String phone { get; set; }
    webService String fax { get; set; }
    webService Boolean helicopterAccess { get; set; }
    webService String message {get; set;}

    public static HDP_Hospital fromExternalWrapper(HDP_ExternalSoapWSDL.HA_HospitalObjectWrapper hospital) {
        HDP_Hospital hosp = new HDP_Hospital();
        hosp.id = hospital.hospitalId;
        hosp.name = hospital.hospitalName;
        hosp.street = hospital.street;
        hosp.city = hospital.city;
        hosp.country = hospital.country;
        hosp.postalCode = hospital.postalCode;
        hosp.noAmbulances = hospital.noAmbulances;
        hosp.phone = hospital.phoneNumber;
        hosp.fax = hospital.faxNumber;
        hosp.message = hospital.message;
        hosp.helicopterAccess = hospital.helicopterAccess=='true';
        return hosp;
    }
    public static HDP_ExternalSoapWSDL.HA_HospitalObjectWrapper toExternalWrapper(HDP_Hospital hosp) {
        HDP_ExternalSoapWSDL.HA_HospitalObjectWrapper hospital = new HDP_ExternalSoapWSDL.HA_HospitalObjectWrapper();
        hospital.hospitalId = String.isEmpty(hosp.id) ? null : hosp.id;
        hospital.hospitalName = String.isEmpty(hosp.name) ? null : hosp.name;
        hospital.name = String.isEmpty(hosp.name) ? null : hosp.name;
        hospital.street = String.isEmpty(hosp.street) ? null : hosp.street;
        hospital.city = String.isEmpty(hosp.city) ? null : hosp.city;
        hospital.country = String.isEmpty(hosp.country) ? null : hosp.country;
        hospital.postalCode = String.isEmpty(hosp.postalCode) ? null : hosp.postalCode;
        hospital.noAmbulances = String.isEmpty(hosp.noAmbulances) ? null : hosp.noAmbulances;
        hospital.phoneNumber = String.isEmpty(hosp.phone) ? null : hosp.phone;
        hospital.faxNumber = String.isEmpty(hosp.fax) ? null : hosp.fax;
        System.debug(hospital);
        System.debug(hosp);
        hospital.helicopterAccess = hosp.helicopterAccess==true ? 'true' : 'false';
        return hospital;
    }

    public static HDP_Hospital fromHospital_c(Hospital__c hospital) {
        HDP_Hospital hosp = new HDP_Hospital();
        hosp.id = hospital.Id;
        hosp.name = hospital.Name;
        hosp.street = hospital.Street__c;
        hosp.city = hospital.City__c;
        hosp.country = hospital.Country__c;
        hosp.postalCode = hospital.Postal_Code__c;
        hosp.noAmbulances = String.valueOf(hospital.No_Ambulances__c);
        hosp.phone = String.valueOf(hospital.Phone_Number__c);
        hosp.fax = String.valueOf(hospital.Fax_Number__c);
        hosp.helicopterAccess = hospital.Helicopter_Access__c;
        return hosp;
    }

    public static Hospital__c newHospital(HDP_Hospital hospital) {
        Hospital__c hosp = new Hospital__c(Name = hospital.name, Street__c = hospital.street, City__c = hospital.city, Country__c = hospital.country, Postal_Code__c = hospital.postalCode, Phone_Number__c = hospital.phone, Fax_Number__c = hospital.fax);
        try {
            hosp.No_Ambulances__c = Decimal.valueOf(hospital.noAmbulances);
        } catch (Exception e) {
        }
        try {
            hosp.Helicopter_Access__c = Boolean.valueOf(hospital.helicopterAccess);
        } catch (Exception e) {
        }
        if (hospital.id != null && !String.isEmpty(hospital.id)) {
            hosp.Id = hospital.id;
        }
        return hosp;
    }

    public static HDP_Hospital updateHospital(HDP_Hospital main, HDP_Hospital other) {
        Map<String, String> requiredFields = new Map<String, String>{
                'name' => other.name,
                'city' => other.city,
                'country' => other.country
        };
        for (String field : requiredFields.keySet()) {
            if (requiredFields.get(field) == null || String.isEmpty(requiredFields.get(field))) {
                main.message = 'Field ' + field + ' can\'t be empty.';
            }
        }
        main.name = other.name != null ? other.name : main.name;
        main.street = other.street != null ? other.street : main.street;
        main.city = other.city != null ? other.city : main.city;
        main.country = other.country != null ? other.country : main.country;
        main.postalCode = other.postalCode != null ? other.postalCode : main.postalCode;
        main.noAmbulances = other.noAmbulances != null ? other.noAmbulances : main.noAmbulances;
        main.phone = other.phone != null ? other.phone : main.phone;
        main.fax = other.fax != null ? other.fax : main.fax;
        main.helicopterAccess = other.helicopterAccess != null ? other.helicopterAccess : main.helicopterAccess;
        return main;
    }
}