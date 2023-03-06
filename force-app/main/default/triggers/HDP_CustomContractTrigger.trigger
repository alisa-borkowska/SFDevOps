trigger HDP_CustomContractTrigger on Contract__c (before insert, before update) {
    TriggerFactory.createHandler(Contract__c.sobjectType);
}