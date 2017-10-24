/**
 * Testing class to test CityDataCreationQueueableServices
 */
@isTest
private class TestCityDataCreationQueueableServices {
    
    private static testMethod void testCityDataCreationQueueableServices(){
        Test.startTest();
            System.enqueueJob( new CityDataCreationQueueableServices() );
        Test.stopTest();
        
        List<City__c> cities = [
            SELECT Id
            FROM City__c
        ];
        
        System.assertEquals( 7, cities.size(), 'There should be 7 cities created.' );
    }
    
}