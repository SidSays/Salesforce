({
    doInit : function(component, event, helper) {
        /*console.log('in do init');
        var action = component.get("c.getProperyData");
        action.setCallback(this, function(a){
            var propertyData = a.getReturnValue();
           // console.log('propertyData'+propertyData);
            var properties = propertyData.properties;
            var propVisits = propertyData.propVisits;
            var newpropVisits;
            for(var i=0; i<propVisits.length; i++){
                var ps = propVisits[i].Start_Date_Time__c;
                var startTime = moment(ps).format("HH:mm");
            	var pe = propVisits[i].End_Date_Time__c;
                var endTime = moment(pe).format("HH:mm");
            
                propVisits[i].Start_Date_Time__c = startTime;
                propVisits[i].End_Date_Time__c = endTime;
            }
            
            for(var i=0; i<properties.length ; i++){
                for(var j=0; j<propVisits.length;j++){
                    if(propVisits[j].Property__c == properties[i].Id){
                        newpropVisits.add(propVisits[j]);
                    }
                }
            }
            component.set("v.properties",properties);
            component.set("v.propVisits",newpropVisits);
            
        });
        $A.enqueueAction(action);*/
    },
    showTable : function(component, event, helper){
        var propertyData = event.getParam("propertyData");  
        
		
        var propVisits = propertyData.propVisits;
        
        var properties = propertyData.properties;
        
        for(var i=0; i<propVisits.length; i++){
                var ps = propVisits[i].Start_Date_Time__c;
                var startTime = moment(ps).format("HH:mm");
            	var pe = propVisits[i].End_Date_Time__c;
                var endTime = moment(pe).format("HH:mm");
            
                propVisits[i].Start_Date_Time__c = startTime;
                propVisits[i].End_Date_Time__c = endTime;
            }
       component.set("v.properties",properties);
            component.set("v.propVisits",propVisits);
        
    }
})