@isTest
public class TilesControllerTest {

    @testSetup static void createTestData(){
		Profile retailStManager = [Select Id from Profile where Name = 'Retail Store Manager'];
        
        User RetailStoreManager = new User();
            RetailStoreManager.profileId = retailStManager.Id;
            RetailStoreManager.FirstName = 'TestStManager';
            RetailStoreManager.ManagerId = UserInfo.getUserId();
            RetailStoreManager.PERNR__c = '33423';
            RetailStoreManager.UserPermissionsWorkDotComUserFeature = true;
            RetailStoreManager.Username = 'TestStM@abc.com.devpro1';
            RetailStoreManager.LastName = 'LastName';
            RetailStoreManager.Email = 'TestStM@abc.com';    
            RetailStoreManager.Alias = 'TestStm';
            RetailStoreManager.CommunityNickname = 'CommunityNicknamestm';
            RetailStoreManager.TimeZoneSidKey =  'America/Panama';
            RetailStoreManager.LocaleSidKey = 'en_US';
            RetailStoreManager.EmailEncodingKey = 'ISO-8859-1';
            RetailStoreManager.LanguageLocaleKey = 'en_US';
            RetailStoreManager.FederationIdentifier = 'FedId32312';
            insert RetailStoreManager;
        
		Tile__c tile1 = new Tile__c(Name='Dashboard', 
                                    Tile_Icon__c='utility:moneybag', 
                                    IsExternal__c=false, 
                                    Tile_URL__c='https://google.com');
        
        Tile__c tile2 = new Tile__c(Name='ComcastNow', 
                                    Tile_Icon__c='utility:moneybag', 
                                    IsExternal__c=false, 
                                    Tile_URL__c='https://google.com');
        
        List<Tile__c> tileList = new List<Tile__c>();
        tileList.add(tile1);
        tileList.add(tile2);
        insert tileList;
        
        Tile_Configuration__c tileConfig1 = new Tile_Configuration__c(Profiles__c='Retail Store Manager', 
                                    Tile__c='Dashboard', 
                                    Order__c=1);
        
        Tile_Configuration__c tileConfig2 = new Tile_Configuration__c(Profiles__c='Retail Store Manager', 
                                    Tile__c='ComcastNow', 
                                    Order__c=2);
        
        Tile_Configuration__c tileConfig3 = new Tile_Configuration__c(Profiles__c='System Administrator', 
                                    Tile__c='ComcastNow', 
                                    Order__c=1);
        List<Tile_Configuration__c> tileConfigList = new List<Tile_Configuration__c>();
        tileConfigList.add(tileConfig1);
        tileConfigList.add(tileConfig2);
        tileConfigList.add(tileConfig3);
        insert tileConfigList;
        
    }
    
    @isTest static void validateTilesCreation(){
        TilesController.getProfileList();
        TilesController.getProfileName();
        TilesController.getTilesByUserProfile();
        TilesController.getAllTiles();
        TilesController.getTilesByProfile('Retail Store Manager');
        List<String> tilesList = new List<String>();
        tilesList.add('Dashboard');
        Boolean isSaveSuccesfull = TilesController.saveSelectedTiles(tilesList, 'System Administrator');
        System.assertEquals(true, isSaveSuccesfull);
        
    }
}