/**
 * Created by alisa.borkowska on 29.11.2022.
 */

@IsTest
private class HDP_ContractTriggerTest {

    @TestSetup
    private static void setupData() {
        List<Doctor__c> testDoctors = new List<Doctor__c>();
        testDoctors.add(new Doctor__c(Name = 'Test_Doctor1', First_Name__c = 'Jan', Last_Name__c = 'Kowalski', License_Number__c = 120));
        testDoctors.add(new Doctor__c(Name = 'Test_Doctor2', First_Name__c = 'Grażyna', Last_Name__c = 'Żarko', License_Number__c = 666));
        List<Hospital__c> testHospitals = new List<Hospital__c>();
        testHospitals.add(new Hospital__c(Name = 'Test_Hospital1', City__c = 'Białystok', Country__c = 'Polska'));
        testHospitals.add(new Hospital__c(Name = 'Test_Hospital2', City__c = 'Warszawa', Country__c = 'Polska'));
        List<Contract__c> testContracts = new List<Contract__c>();

        insert testHospitals;
        insert testDoctors;

        testContracts.add(new Contract__c(Hospital__c = testHospitals[0].Id,
                Doctor__c = testDoctors[0].Id,
                Start_Date__c = Date.newInstance(2020, 1, 1),
                End_Date__c = Date.newInstance(2020, 12, 31)));

        insert testContracts;
    }

    @IsTest
    private static void shouldAllowContractWhereDatesAreNotOverlapping() {
        List<Hospital__c> testHospitals = [
                SELECT Name
                FROM Hospital__c
                WHERE Name LIKE 'Test_%'
        ];
        List<Doctor__c> testDoctors = [
                SELECT Name
                FROM Doctor__c
                WHERE Name LIKE 'Test_%'
        ];
        List<Contract__c> testContracts = [
                SELECT Name, Start_Date__c, End_Date__c
                FROM Contract__c
        ];

        List<Contract__c> newContracts = new List<Contract__c>();
        newContracts.add(new Contract__c(Hospital__c = testHospitals[0].Id,
                Doctor__c = testDoctors[0].Id,
                Start_Date__c = Date.newInstance(2021, 1, 1),
                End_Date__c = Date.newInstance(2021, 1, 30)));

        Test.startTest();

        insert newContracts;

        Test.stopTest();

        System.assertEquals(newContracts, [SELECT Hospital__c, Doctor__c, Start_Date__c, End_Date__c FROM Contract__c WHERE Id IN :newContracts]);

    }

    @IsTest
    private static void shouldAllowContractWhereDatesAreOverlappingButHospitalIsDifferentOnUpdate() {
        List<Hospital__c> testHospitals = [
                SELECT Name
                FROM Hospital__c
                WHERE Name LIKE 'Test_%'
        ];
        List<Doctor__c> testDoctors = [
                SELECT Name
                FROM Doctor__c
                WHERE Name LIKE 'Test_%'
        ];
        List<Contract__c> testContracts = [
                SELECT Name, Start_Date__c, End_Date__c
                FROM Contract__c
        ];

        List<Contract__c> newContracts = new List<Contract__c>();
        newContracts.add(new Contract__c(Hospital__c = testHospitals[1].Id,
                Doctor__c = testDoctors[0].Id,
                Start_Date__c = Date.newInstance(2021, 1, 1),
                End_Date__c = Date.newInstance(2021, 1, 30)));
        insert newContracts;
        newContracts[0].Start_Date__c = Date.newInstance(2021, 2, 1);
        newContracts[0].End_Date__c = Date.newInstance(2021, 2, 30);

        Test.startTest();

        update newContracts;

        Test.stopTest();

        System.assertEquals(newContracts, [SELECT Hospital__c, Doctor__c, Start_Date__c, End_Date__c FROM Contract__c WHERE Id IN :newContracts]);
        delete newContracts;
    }

    @IsTest
    private static void shouldDenyContractWhereWholePeriodIsOverlapping() {
        List<Hospital__c> testHospitals = [
                SELECT Name
                FROM Hospital__c
                WHERE Name LIKE 'Test_%'
        ];
        List<Doctor__c> testDoctors = [
                SELECT Name
                FROM Doctor__c
                WHERE Name LIKE 'Test_%'
        ];
        List<Contract__c> testContracts = [
                SELECT Hospital__c, Doctor__c, Start_Date__c, End_Date__c
                FROM Contract__c
        ];

        List<Contract__c> newContracts = new List<Contract__c>();
        newContracts.add(new Contract__c(Hospital__c = testHospitals[0].Id,
                Doctor__c = testDoctors[0].Id,
                Start_Date__c = Date.newInstance(2021, 2, 1),
                End_Date__c = Date.newInstance(2021, 3, 30)));
        insert newContracts;
        List<Contract__c> failingContracts = newContracts.deepClone(true);
        failingContracts[0].Start_Date__c = Date.newInstance(2020, 2, 1);
        failingContracts[0].End_Date__c = Date.newInstance(2020, 2, 30);


        Test.startTest();

        try {
            update failingContracts;
            throw new TestException('Contracts with overlapping period allowed.');
        } catch (System.DmlException e) {
            System.assert(e.getMessage().contains(System.Label.Overlapping));
        }

        Test.stopTest();

        testContracts.addAll(newContracts);

        System.assertEquals(testContracts, [SELECT Hospital__c, Doctor__c, Start_Date__c, End_Date__c FROM Contract__c]);
        delete testContracts;
    }

    @IsTest
    private static void shouldDenyContractWherePeriodIsOverlappingAndEndDateIsNull() {

        List<Hospital__c> testHospitals = [
                SELECT Name
                FROM Hospital__c
                WHERE Name LIKE 'Test_%'
        ];
        List<Doctor__c> testDoctors = [
                SELECT Name
                FROM Doctor__c
                WHERE Name LIKE 'Test_%'
        ];
        List<Contract__c> testContracts = [
                SELECT Name, Start_Date__c, End_Date__c
                FROM Contract__c
        ];

        List<Contract__c> newContracts = new List<Contract__c>();
        newContracts.add(new Contract__c(Hospital__c = testHospitals[0].Id,
                Doctor__c = testDoctors[0].Id,
                Start_Date__c = Date.newInstance(2020, 4, 1)));

        Test.startTest();

        try {
            insert newContracts;
            throw new TestException('Error! Contracts with overlapping period allowed.');
        } catch (System.DmlException e) {
            System.assert(e.getMessage().contains(System.Label.Overlapping));
        }

        Test.stopTest();
        System.assertEquals(testContracts, [SELECT Name, Start_Date__c, End_Date__c, Id FROM Contract__c]);
        delete testContracts;
    }

}