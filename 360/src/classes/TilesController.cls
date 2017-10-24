public with sharing class TilesController {
        
    public static Set<String> getAllTiles() {
        Set<String> allTiles = new Set<String>();
        List<Tile__c> tilesList = [SELECT Id, Name, Tile_Icon__c, Tile_URL__c, IsExternal__c
                                    FROM Tile__c LIMIT 100];  
        for(Tile__c tile : tilesList){
            allTiles.add(tile.Name);
        }      
        return allTiles;       
    }   
    
    @AuraEnabled
    public static String getTilesByUserProfile(){
        List<TileIconWrapper> wrapper = new List<TileIconWrapper>();
        
        //get the logged in user profile
        Id userProfileId = UserInfo.getProfileId();
        Profile profileDetails = [SELECT Name FROM Profile WHERE Id =:userProfileId] ;
        
        Map<String, Decimal> mapOfSelectedTileOrder = new Map<String, Decimal>();
        Map<String, Tile__c> mapOfNameTile = new Map<String, Tile__c>();
        
        //get all the tiles associated to the profile from Tile_Configuration__c
        List<Tile_Configuration__c> tileConfigurationList = [Select Tile__c, Order__c FROM Tile_Configuration__c 
                                                         	 WHERE Profiles__c =: profileDetails.Name Order By Order__c];
      
        if(tileConfigurationList.size() > 0){
            for(Tile_Configuration__c tileConfig : tileConfigurationList){
                mapOfSelectedTileOrder.put(tileConfig.Tile__c, tileConfig.Order__c);
            }
                
            List<Tile__c> tilesList = [SELECT Id, Name, Tile_Icon__c, Tile_URL__c, IsExternal__c  
                                        FROM Tile__c 
                                        WHERE Name IN : mapOfSelectedTileOrder.keySet()];
           
            List<Id> tileIds = new List<Id>();
            if(tilesList.size() > 0){
                for(Tile__c tile : tilesList){
                    mapOfNameTile.put(tile.Name, tile);
                    tileIds.add(tile.Id);
                }
                
                List<ContentDocumentLink> contentDocLinkList = [SELECT ContentDocumentId,Id,LinkedEntityId,ShareType 
                                                                FROM ContentDocumentLink WHERE LinkedEntityId IN : tileIds];                                
                
                Map<Id, Id> mapOfFileTile = new Map<Id, Id>();
                if(contentDocLinkList.size() > 0){
                    for(ContentDocumentLink cdl : contentDocLinkList){
                        mapOfFileTile.put(cdl.LinkedEntityId, cdl.ContentDocumentId);
                    }
                }
                
                List<ContentVersion> contentVerList = [SELECT Id,ContentDocumentId, Title FROM ContentVersion WHERE ContentDocumentId IN :mapOfFileTile.values()];

                Map<Id, Id> mapOfContentDocumentVersion = new Map<Id, Id>();
                if(contentVerList.size() > 0){
                    for(ContentVersion cv : contentVerList){
                        mapOfContentDocumentVersion.put(cv.ContentDocumentId, cv.Id);
                    }
                }
                
                
                for(String tile : mapOfSelectedTileOrder.keySet()){
                    wrapper.add(new TileIconWrapper(mapOfNameTile.get(tile), mapOfContentDocumentVersion.get(mapOfFileTile.get(mapOfNameTile.get(tile).Id)) ));
                }
            }
        }       
        return JSON.serialize(wrapper);
    }
    
    @AuraEnabled
    public static String getTilesByProfile(String profileName){
        //get all tiles
        Set<String> allTiles = getAllTiles();
        Set<String> availableTiles = new Set<String>();
        Set<String> selectedTiles = new Set<String>();
        
        //get selected tiles from config per profile        
        List<Tile_Configuration__c> tileConfigurationList = [Select Tile__c, Order__c FROM Tile_Configuration__c 
                                                         	 WHERE Profiles__c =: profileName Order By Order__c];
        if(tileConfigurationList.size() > 0){
            for(Tile_Configuration__c tileConfig : tileConfigurationList){
                if(allTiles.contains(tileConfig.Tile__c)){
                    selectedTiles.add(tileConfig.Tile__c);
                }
            }     	
        
            //get available tiles
            for(String tile : allTiles){
                if(!selectedTiles.contains(tile)){
                    availableTiles.add(tile);
                }            
            }
        }
        else{
            availableTiles = allTiles;
        }
        
        //construct wrapper for avail and selected items
        TileWrapper wrapper = new TileWrapper(availableTiles, selectedTiles);
       	return JSON.serialize(wrapper); 
    }
    
    @AuraEnabled
    public static String getProfileName() {
        String profileName = '';
        Id userProfileId = UserInfo.getProfileId();
        Profile profileDetails = [SELECT Name FROM Profile WHERE Id =:userProfileId] ;
        profileName = profileDetails.Name;
        return profileName;
        
    }
 
    @AuraEnabled
    public static String getProfileList()
    {
      	List<String> options = new List<String>();            
       	Schema.DescribeFieldResult fieldResult = Tile_Configuration__c.Profiles__c.getDescribe();
       	List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
       	for( Schema.PicklistEntry f : ple)
       	{
          	options.add(f.getValue());
       	}       
       	return JSON.serialize(options);
    }
    
    @AuraEnabled
    public static Boolean saveSelectedTiles(List<String> selectedTiles, String profileName){
        List<Tile_Configuration__c> tileConfigs = new List<Tile_Configuration__c>();
        Boolean isDeleted = true;
		Boolean isSaved = false;
     
        List<Tile_Configuration__c> delTileList = [Select Id From Tile_Configuration__c 
                                                   WHERE Profiles__c =: profileName];
        
        if(delTileList.size() > 0){
            //delete the existing configuration for the profile
            Database.DeleteResult[] drList = Database.delete(delTileList, true);
            
            // Iterate through each returned result
            for(Database.DeleteResult dr : drList) {
                if (!dr.isSuccess()) {
                    isDeleted = false;
                    break;
                }
            }
    	}
        
        //create the latest configuration for profile and tile association
        if(isDeleted){            
            for(Integer i=0; i<selectedTiles.size(); i++){
                Tile_Configuration__c tc = new Tile_Configuration__c(Tile__c=selectedTiles[i], Order__c=i+1, Profiles__c=profileName);
                tileConfigs.add(tc);
            }
            Database.SaveResult[] srList = Database.insert(tileConfigs, true);
            // Iterate through each returned result
            Integer counter = 0;
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    counter++;
                }
            }
            if(counter == 0){
            	isSaved = true;
            }
        }        
        return isSaved;
    }
        
    public class TileWrapper{
        Set<String> availableTiles {get;set;}
        Set<String> selectedTiles {get;set;}
        
        public TileWrapper(Set<String> availableTiles, Set<String> selectedTiles){
            this.availableTiles = availableTiles;
            this.selectedTiles = selectedTiles;
        }
    }
    
    public class TileIconWrapper{
        Tile__c tile {get;set;}
        Id iconId {get;set;}
        
        public TileIconWrapper(Tile__c tile, Id iconId){
            this.tile = tile;
            this.iconId = iconId;
        }
    }

}