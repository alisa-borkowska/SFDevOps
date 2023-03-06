public without sharing class AccountController {
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts(String searchPhrase) {
        String query = ''
            + 'SELECT Id, Name, Website, NumberOfEmployees, BillingStreet, BillingCity, '
            + 'BillingState, BillingPostalCode '
            + 'FROM Account';
        if (searchPhrase.length()>0) {
            query += ' WHERE Name LIKE \'%' + searchPhrase + '%\'';
        }
        return Database.query(query);
    }
    
    @AuraEnabled
    public static void updateAccounts(Object accounts){
        List<Account> accountsToUpdate = (List<Account>) JSON.deserialize(
            JSON.serialize(accounts),
            List<Account>.class
        );
        
        update accountsToUpdate;
    }

    @AuraEnabled
    public static void addAccounts(Object accounts){
        List<Account> accountsToAdd = (List<Account>) JSON.deserialize(
            JSON.serialize(accounts),
            List<Account>.class
        );
        
        insert accountsToAdd;
    }

    @AuraEnabled
    public static void deleteAccount(Object account){
        try {
            Account accountToUpdate = (Account) JSON.deserialize(
                JSON.serialize(account),
                Account.class
            );
            delete accountToUpdate;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}