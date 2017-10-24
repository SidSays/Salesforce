({
	displayTiles : function(component, event, helper){
        var profileList = component.find('picklistOptions');
        var profileName = profileList.get('v.value');
        if(typeof profileName === 'undefined' || profileName === null){
            profileName = "System Administrator";
        }
        
        var action = component.get("c.getTilesByProfile");
        action.setParams({
                "profileName": profileName
            });
        action.setCallback(this, function(e){
            if(e.getState()==='SUCCESS')
            {
                var tileResponse = JSON.parse(e.getReturnValue());
                console.log('displayTiles A $$$: ' + tileResponse.availableTiles);
                console.log('displayTiles S $$$: ' + tileResponse.selectedTiles);
                component.set("v.availableTileValues", tileResponse.availableTiles);
                component.set("v.selectedTileValues", tileResponse.selectedTiles);
            }
        });
        $A.enqueueAction(action);
    }
})