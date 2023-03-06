/**
 * Created by alisa.borkowska on 01.12.2022.
 */

public with sharing class HDP_ContractsCheck {

    public static void contractsDateChecking(List<sObject> newListObj, Map<Id, sObject> newMapObj) {
        Set<Id> hospitalIds = new Set<Id>();
        Set<Id> doctorsIds = new Set<Id>();

        for (sObject contract : newListObj) {
            Contract__c ctr = (Contract__c) contract;
            hospitalIds.add (ctr.Hospital__c);
            doctorsIds.add (ctr.Doctor__c);
        }

        List<Hospital__c> hospitals = [SELECT Id FROM Hospital__c WHERE Id IN :hospitalIds];
        List<Doctor__c> doctors = [SELECT Id FROM Doctor__c WHERE Id IN :doctorsIds];

        List<Contract__c> contracts = [
                SELECT Id, Start_Date__c, End_Date__c, Name
                FROM Contract__c
                WHERE Hospital__c IN :hospitals
                AND Doctor__c IN :doctors
                AND Id NOT IN :newListObj
        ];

        for (sObject newContract : newListObj) {
            Contract__c newCtr = (Contract__c) newContract;
            for (Contract__c existingContract : contracts) {
                if (newCtr.End_Date__c < existingContract.Start_Date__c ||
                        newCtr.Start_Date__c > existingContract.End_Date__c) {
                    continue;
                } else {
                    String errorInfo = System.Label.Overlapping + ' ' + existingContract.Name;
                    newContract.addError(errorInfo);
                }

            }
        }
    }

}