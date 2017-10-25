({
    doInit : function(component, event, helper){
        var actionBase = component.get("c.getProfileName");	
        actionBase.setCallback(this, function(response) {
            component.set("v.profileName",response.getReturnValue()) ;
        });
        
        $A.enqueueAction(actionBase);
    }
})