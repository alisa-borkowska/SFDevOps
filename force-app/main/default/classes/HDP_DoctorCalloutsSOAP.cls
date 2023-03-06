/**
 * Created by alisa.borkowska on 21.12.2022.
 */

global with sharing class HDP_DoctorCalloutsSOAP {
    webService static List<Hospital__c> searchHospitals(String name) {
        List<Hospital__c> Hospitals = [SELECT Id, Name, City__c, Country__c, Street__c, Postal_Code__c, No_Ambulances__c, Phone_Number__c FROM Hospital__c WHERE Name LIKE :name];
        return Hospitals;
    }
    webService static List<Hospital__c> getRecordByCity(String city) {
        List<Hospital__c> Hospitals = [SELECT Id, Name, City__c, Country__c, Street__c, Postal_Code__c, No_Ambulances__c, Phone_Number__c FROM Hospital__c WHERE City__c LIKE :city ];
        return Hospitals;
    }


}