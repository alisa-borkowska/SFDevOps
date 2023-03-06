public with sharing class HDP_ContractTriggerHandler implements ITrigger {
    public HDP_ContractTriggerHandler() {
    }

    public void bulkBefore() {

    }

    public void bulkAfter() {

    }

    public void beforeInsert(List<sObject> newListObj, Map<Id, sObject> newMapObj) {
        HDP_ContractsCheck.contractsDateChecking (newListObj, newMapObj); 
    }


    public void beforeUpdate(List<sObject> newListObj, List<object> oldListObj, Map<Id, sObject> newMapObj, Map<Id, sObject> oldMapObj) {
        HDP_ContractsCheck.contractsDateChecking (newListObj, newMapObj);
    }

    public void beforeDelete(List<sObject> oldListObj, Map<Id, sObject> oldMapObj) {

    }

    public void afterInsert(List<sObject> newListObj, Map<Id, sObject> newMapObj) {

    }

    public void afterUpdate(List<sObject> newListObj, List<object> oldListObj, Map<Id, sObject> newMapObj, Map<Id, sObject> oldMapObj) {

    }

    public void afterDelete(List<sObject> oldListObj, Map<Id, sObject> oldMapObj) {

    }

    public void andFinally() {

    }
}