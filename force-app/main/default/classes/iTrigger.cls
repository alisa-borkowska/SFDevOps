/**
 * Created by alisa.borkowska on 28.11.2022.
 */

public interface iTrigger {
    void bulkBefore();

    void bulkAfter();

    void beforeInsert(List<sObject> newListObj, Map<Id, sObject> newMapObj);

    void beforeUpdate(List<sObject> newListObj, List<object> oldListObj, Map<Id, sObject> newMapObj, Map<Id, sObject> oldMapObj);

    void beforeDelete(List<sObject> oldListObj, Map<Id, sObject> oldMapObj);

    void afterInsert(List<sObject> newListObj, Map<Id, sObject> newMapObj);

    void afterUpdate(List<sObject> newListObj, List<object> oldListObj, Map<Id, sObject> newMapObj, Map<Id, sObject> oldMapObj);

    void afterDelete(List<sObject> oldListObj, Map<Id, sObject> oldMapObj);

    void andFinally();
}