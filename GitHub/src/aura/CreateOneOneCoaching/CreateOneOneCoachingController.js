({	
    /****************
	* @Description: doInit method to set template for 1-1 coaching
    * @Author: Amit Kumar Pradhan, Accenture    
    * @Date: 31-July-2017   
    * @User Story: US1141906   
    ****************/ 
    doInit: function(component, event, helper) {

            var action = component.get("c.getStatusTypeValue");       
            action.setCallback(this, function(response){
                if(response.getState() == 'SUCCESS'){
                    var opts= [];  var types = [];
                    types = response.getReturnValue();            
                    for(var i =0; i< types.length; i++){
                        opts.push({ class: "optionClass", label: types[i], value: types[i] });
                    }            
                   var statusId =  component.find("StatusId")
                   if(statusId != undefined){
                       statusId.set("v.options", opts);
                   }
                       
                }
            });
            $A.enqueueAction(action);
       
        if(component.get("v.recordId") == ''|| component.get("v.recordId") == undefined){
            helper.getRecordTemplate(component);    
        }
    },
    
    /****************
	* @Description: gettingAllCoachingRecords method to set attribute that are 
    				passing through OneOneCoachingDetailsEvent
    * @Author: Amit Kumar Pradhan, Accenture    
    * @Date: 31-July-2017   
    * @User Story: US1141906   
    ****************/    
    gettingAllCoachingRecords : function(component, event, helper) {
        component.set("v.oneOneCoachingRecords",event.getParam("oneOneCoachingRecords"));
        component.set("v.userDetails",event.getParam("userDetails"));
        component.set("v.workCoachingId",event.getParam("coachingId"));
        component.set("v.isRep",event.getParam("isRep"));
    },
    
    /****************
	* @Description: saveOneOneCoaching method save one one coaching
    * @Author: Amit Kumar Pradhan, Accenture    
    * @Date: 31-July-2017   
    * @User Story: US1141906   
    ****************/    
    saveOneOneCoaching : function(component, event, helper) {    
        helper.saveOneOneCoaching(component, event, helper); 
    },
    
    /****************
	* @Description: cancel method cancel one one coaching creation
    * @Author: Amit Kumar Pradhan, Accenture    
    * @Date: 31-July-2017   
    * @User Story: US1141906   
    ****************/    
    cancel : function(component, event, helper) {		
        helper.cancel(component, event, helper);
    },
    
    handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
            // record is loaded (render other component which needs record data value)
            console.log("Record is loaded successfully.");
        } else if(eventParams.changeType === "CHANGED") {
            // record is changed
            
        } else if(eventParams.changeType === "REMOVED") {
            console.log('in removed');
        } else if(eventParams.changeType === "ERROR") {
            console.log('in error');
        }
    },
    
    onChangeFunction: function(component, event, helper){
        var selected = component.find("StatusId").get("v.value");
        console.log('selected value'+ selected);
        component.set("v.simpleNewOneOneCoaching.Status__c", selected);        
    }
    
})