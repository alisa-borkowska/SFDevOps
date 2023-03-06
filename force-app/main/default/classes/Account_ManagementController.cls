public with sharing class Account_ManagementController {
    @AuraEnabled
    public static List<Account> searchAccounts(String searchTerm) {
        List<Account> searchResults = [
                SELECT
                        Id, Name, Website, NumberOfEmployees,
                        BillingStreet, BillingCity,
                        BillingState, BillingPostalCode
                FROM Account
                WHERE Name LIKE :'%' + searchTerm + '%'
                ORDER BY Name
        ];
        return searchResults;
    }

    @AuraEnabled
    public static Account removeAccount(Account account) {
        delete account;
        System.debug('test');
        return account;
    }
}