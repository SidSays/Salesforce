({
    doInit : function(component, event, helper) {
        helper.profileCheck(component, event, helper);
   }, 
    
    changeFilter : function(component, event, helper) {
        helper.filterDialog(component, event, helper);    
    },
    
    
    
    propertyAndPropertVisit : function(component, event, helper){
        console.log('in property visit');
        var user = event.getParam("user"); 
        var userArray = user.split("/");
        console.log('in car map view comp'+ user);
        component.set("v.user", userArray[0]);
        var viewType = event.getParam("viewType");
        component.set("v.viewType", viewType);
        var fromDate = event.getParam("fromDate");
        component.set("v.fromDate", fromDate);
        var toDate = event.getParam("toDate");
        component.set("v.toDate", toDate);
        
        
        var appEvent = $A.get("e.c:CARMapViewToMap");
        console.log('appEvent'+appEvent);
        appEvent.setParams({                
            "user": user,
            "viewType":viewType,
            "fromDate":fromDate,
            "toDate":toDate
        });
        appEvent.fire();
        
    },
    
})