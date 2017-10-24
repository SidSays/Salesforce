({   
    doInit : function(component, event, helper) {
        var action = component.get("c.getProfileList");
        action.setCallback(this, function(e){
            if(e.getState()==='SUCCESS')
            {                
                var picklist = component.find('picklistOptions');
                component.set("v.profilesList", JSON.parse(e.getReturnValue()));
            }
        });
        $A.enqueueAction(action);
        helper.displayTiles(component, event, helper);
        
    },    	   
    
    moveLeft : function(component, event, helper) {
        var leftComp = component.find('leftOptions');
        var rightComp = component.find('rightOptions');
        var availableOptions = component.get('v.availableTileValues');
        var selectedLeftValue = leftComp.get('v.value');
        if(!selectedLeftValue)
            return;
        var selectedOptions = component.get('v.selectedTileValues');
        if(!selectedOptions)
            selectedOptions = [];
        if(selectedLeftValue!='undefined'&& selectedLeftValue!='')
        {
            var values = selectedLeftValue.split(';');
			for(var i=0;i<values.length;i++)
            {
                for(var j=0;j<availableOptions.length;j++)
                {     
                    if(values[i]===availableOptions[j])
                    {
                        selectedOptions.push(availableOptions[j]);
                        availableOptions.splice(j,1);
                        break;
                    }                   
                }
            } 
            component.set('v.availableTileValues',availableOptions.sort());
        }
        if(selectedOptions.length>0)
        {
            component.set('v.selectedTileValues',selectedOptions);
        }
    },
    
    moveRight : function(component, event, helper) {
        var leftComp = component.find('leftOptions');
        var rightComp = component.find('rightOptions');
        var selectedOptions = component.get('v.selectedTileValues');
        var selectedRightValue = rightComp.get('v.value');
        if(!selectedRightValue)
            return;
        var availableOptions = component.get('v.availableTileValues');
        if(!availableOptions)
            availableOptions = [];
        if(selectedRightValue!='undefined'&& selectedRightValue!='')
        {
            var values = selectedRightValue.split(';');
			for(var i=0;i<values.length;i++)
            {
                for(var j=0;j<selectedOptions.length;j++)
                {                    
                    if(values[i]===selectedOptions[j])
                    {
                        availableOptions.push(selectedOptions[j]);
                        selectedOptions.splice(j,1);
                        break;
                    }                   
                }
            } 
            component.set('v.selectedTileValues',selectedOptions);
        }
        if(availableOptions.length>0)
        {
            component.set('v.availableTileValues', availableOptions);
        }
    },
    
    moveUp : function(component, event, helper) {
        var rightComp = component.find('rightOptions');
        var selectedOptions = component.get('v.selectedTileValues');
        var selectedRightValue = rightComp.get('v.value');
        if(!selectedRightValue)
            return;
        if(selectedRightValue!='undefined'&& selectedRightValue!='')
        {
            var values = selectedRightValue.split(';');
			for(var i=0;i<values.length;i++)
            {
                for(var j=0;j<selectedOptions.length;j++)
                {                    
                    if(values[i]===selectedOptions[j])
                    {
                        selectedOptions.splice(j,1);
                        selectedOptions.splice(j-1, 0, values[i]);
                        break;
                    }                   
                }
            } 
            component.set('v.selectedTileValues',selectedOptions);
        }
    },
    
    moveDown : function(component, event, helper) {
        var rightComp = component.find('rightOptions');
        var selectedOptions = component.get('v.selectedTileValues');
        var selectedRightValue = rightComp.get('v.value');
        if(!selectedRightValue)
            return;
        if(selectedRightValue!='undefined'&& selectedRightValue!='')
        {
            var values = selectedRightValue.split(';');
			for(var i=0;i<values.length;i++)
            {
                for(var j=0;j<selectedOptions.length;j++)
                {                    
                    if(values[i]===selectedOptions[j])
                    {
                        selectedOptions.splice(j,1);
                        selectedOptions.splice(j+1, 0, values[i]);
                        break;
                    }                   
                }
            } 
            component.set('v.selectedTileValues',selectedOptions);
        }
    },
    
    onSelectChange : function(component, event, helper) {
        helper.displayTiles(component, event, helper);
    },
    
    onCancel : function(component, event, helper) {
        helper.displayTiles(component, event, helper);
    },
    
    onSave: function(component, event, helper) {
        var profileList = component.find('picklistOptions');
        var profileName = profileList.get('v.value');
        if(typeof profileName === 'undefined' || profileName === null){
            profileName = "System Administrator";
        }
        var selectedOptions = component.get("v.selectedTileValues");
        var selectedOptionsList = [];
        for(var j=0;j<selectedOptions.length;j++){ 
            selectedOptionsList.push(selectedOptions[j]);
        }
    	
        var action = component.get("c.saveSelectedTiles");
        action.setParams({
                "selectedTiles": selectedOptionsList,
            	"profileName": profileName
            });
        action.setCallback(this, function(e){
            if(e.getState()==='SUCCESS')
            {   
                var isSaveSuccess = e.getReturnValue();
                if(isSaveSuccess){
                	component.set('v.saveMessage',"Configuration Saved Successfully");
                }
            }
        });
        $A.enqueueAction(action);
            
    }
})