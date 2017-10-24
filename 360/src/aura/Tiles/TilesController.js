({
    doInit : function(component, event, helper){
        var actionBase = component.get("c.getTilesByUserProfile");	
        actionBase.setCallback(this, function(response) {
            var state = response.getState();
            var tileResponse = JSON.parse(response.getReturnValue());
            component.set("v.tiles",tileResponse) ;
        });
        
        $A.enqueueAction(actionBase);
    }
})