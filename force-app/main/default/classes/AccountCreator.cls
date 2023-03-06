public with sharing class AccountCreator {
    @AuraEnabled

    public static Account[] saveAccount(Account[] accounts) {
        insert accounts;
        return accounts;
    }
}