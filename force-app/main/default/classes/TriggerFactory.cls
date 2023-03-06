/**
 * Created by alisa.borkowska on 28.11.2022.
 */
public with sharing class TriggerFactory {

    public static void createHandler(Schema.sObjectType soType) {

        ITrigger handler = getHandler(soType);

        if (handler == null) {
            throw new TriggerException ('No Trigger Handler registered for Object Type: ' + soType);
        }

        execute(handler);
    }

    private static void execute(ITrigger handler) {

        if (Trigger.isBefore) {

            handler.bulkBefore();
            if (Trigger.isDelete) {
                handler.beforeDelete(trigger.old, trigger.oldMap);
            }

            else if (Trigger.isInsert) {
                handler.beforeInsert(trigger.new, trigger.newMap);
            }

            else if (Trigger.isUpdate) {
                handler.beforeUpdate(trigger.new, trigger.old, trigger.newMap, trigger.oldMap);
            }
        } else {

            handler.bulkAfter();

            if (Trigger.isDelete) {
                handler.afterDelete(trigger.old, trigger.oldMap);
            }

            else if (Trigger.isInsert) {
                handler.afterInsert(trigger.new, trigger.newMap);
            }

            else if (Trigger.isUpdate) {
                handler.afterUpdate(trigger.new, trigger.old, trigger.newMap, trigger.oldMap);
            }
        }

        handler.andFinally();
    }

    public static ITrigger getHandler(Schema.sObjectType soType) {
        if (soType == Contract__c.sObjectType) {
            return new HDP_ContractTriggerHandler();
        }
        return null;

    }
}