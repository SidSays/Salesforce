/**
 * This class creates dummy data for the assignment. 
 * Please run the below script Anonymously from your Developer Console:
 * System.enqueueJob( new CityDataCreationQueueableServices() );
 */
global class CityDataCreationQueueableServices implements Queueable {
    
    global void execute(QueueableContext context) {
        List<City__c> newCities = new List<City__c>();

        newCities.add( new City__c( City_Name__c = 'Los Angeles',
                                  State__c = 'CA',
                                  Country__c = 'USA',
                                  Geolocation__Latitude__s = 34.0522,
                                  Geolocation__Longitude__s = -118.2437));
        
        newCities.add( new City__c( City_Name__c = 'San Francisco', 
                                   State__c = 'CA', 
                                   Country__c = 'USA', 
                                   Geolocation__Latitude__s = 37.7749,
                                   Geolocation__Longitude__s = -122.4194));
        
        newCities.add( new City__c (City_Name__c = 'Tokyo',
                                    Country__c = 'Japan',
                                    Geolocation__Latitude__s = 35.6895,
                                    Geolocation__Longitude__s = 139.6917));
        newCities.add( new City__c (City_Name__c = 'Johannesburg',
                                    Country__c = 'South Africa',
                                    Geolocation__Latitude__s = -26.2041,
                                    Geolocation__Longitude__s = 28.0473));
        
        newCities.add( new City__c (City_Name__c = 'Mexico City',
                                    Country__c = 'Mexico',
                                    Geolocation__Latitude__s = 19.2465,
                                    Geolocation__Longitude__s = -99.1013));
        
        newCities.add( new City__c (City_Name__c = 'New York City',
                                    State__c = 'NY',
                                    Country__c = 'USA',
                                    Geolocation__Latitude__s = 40.7128,
                                    Geolocation__Longitude__s = -74.0059));
        
        newCities.add( new City__c (City_Name__c = 'Mumbai',
                                    State__c = 'Maharashtra',
                                    Country__c = 'India',
                                    Geolocation__Latitude__s = 19.0760,
                                    Geolocation__Longitude__s = 72.8777));
        
        insert newCities;
    }
    
}