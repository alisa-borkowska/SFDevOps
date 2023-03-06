public with sharing class AccountDeleter {
    @AuraEnabled

    public static Account[] saveAccount(Account[] accounts) {
        delete accounts;
        return accounts;
    }
}