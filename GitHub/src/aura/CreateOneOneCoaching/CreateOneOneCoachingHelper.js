({	
    /****************
	* @Description: This helper method is for setting RecordTemplate of OneOneCoachingRecordCreator              
    * @Author: Amit Kumar Pradhan, Accenture    
    * @Date: 31-July-2017   
    * @User Story: US1141906   
    ****************/
    getRecordTemplate : function(component) {
        component.find("OneOneCoachingRecordCreator").getNewRecord(
            "one_one_Coaching__c", // sObject type (entityApiName)
            null, // recordTypeId
            false, // skip cache?
            $A.getCallback(function() {
                var rec = component.get("v.newOneOneCoaching");
                var error = component.get("v.newOneOneCoachingError");
                if(error || (rec === null)) {
                    console.log("Error initializing record template: " + error);
                }
                else {
                    console.log("Record template initialized: " + rec.sobjectType);
                    console.log("Record template initialized: " + rec);
                }
            })
        );
    },
    
    /****************
	* @Description: This helper method is for saving 1-1 coaching records as well retuning 
    				latest five records              
    * @Author: Amit Kumar Pradhan, Accenture    
    * @Date: 31-July-2017   
    * @User Story: US1141906   
    ****************/    
    saveOneOneCoaching : function(component, event, helper) {
        //Getting today details, that used in 1:1 coaching name
        //Format - 1-1_'mm-dd-yyyy+'_'+Rep Name(1-1_07-31-2017_TestRSC)
        var today = new Date();
        var name = null;
        var dd = today.getDate();
        var mm = today.getMonth()+1; //January is 0!
        var yyyy = today.getFullYear();        
        if(dd<10) {
            dd = '0'+dd
        }         
        if(mm<10) {
            mm = '0'+mm
        }         
        today = mm + '-' + dd + '-' + yyyy;
        var currentUser = component.get("v.userDetails");
        name = '1-1_'+today+'_'+currentUser.Name;
        
        //Setting Name and coaching Id(Name only for new record)
        if(component.get("v.simpleNewOneOneCoaching.Name") == null){
          component.set("v.simpleNewOneOneCoaching.Name", name);  
        }	             
        component.set("v.simpleNewOneOneCoaching.coaching__c", component.get("v.workCoachingId"));
        //Saving the 1:1 coaching record by calling saveRecord method
        component.find("OneOneCoachingRecordCreator").saveRecord(function(saveResult) {
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                var successMessage = '';
                if(component.get("v.recordId") != ''){
                    successMessage = 'The record is updated.'
                }else
                {
                    successMessage = 'The new 1-1 Coaching is created.';
                }
                    // Success! Prepare a toast UI message
                if(successMessage != ''){    
                var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "title": "1-1 Coaching Saved",
                        "type": "success",
                        "message": successMessage
                    });
                    resultsToast.fire();  
                }
                
                
                //Fetching latest five one one coaching records by calling "getLatestFiveOneOneCoachings"
                var personCoached = component.get("v.userDetails").Id; //Rep Id
                var getFiveOneOneCoachings = component.get("c.getLatestFiveOneOneCoachings");
                getFiveOneOneCoachings.setParams({
                    "coachedId" : personCoached     
                });
                getFiveOneOneCoachings.setCallback(this,function(oneOneCoachingData){
                    var result = oneOneCoachingData.getReturnValue();//Return one one coaching results
                    if(result){
                        //Firing event to show and hide coachingTimeline component
                        var showHideCoachingEvent = $A.get("e.c:CreateOneOneCoachingEvent");
                        showHideCoachingEvent.setParams({
                            "showCreateOneOneCoaching" : "false",
                            "showCoachingTimeline" : "true",
                            "pernrId": component.get("v.pernrId"),
                            "recordId" : ''                            
                        });
                        showHideCoachingEvent.fire();
                        
                        //Firing event to passing coaching details into coachingtimeline component
                        var coachingDetailsEvent = $A.get("e.c:OneOneCoachingDetailsEvent");
                        coachingDetailsEvent.setParams({           
                            "oneOneCoachingRecords" : result,
                            "userDetails" : component.get("v.userDetails"),
                            "coachingId" : component.get("v.workCoachingId"),
                            "isRep" : component.get("v.isRep"),
                            "pernrId": component.get("v.pernrId")
                        });
                        coachingDetailsEvent.fire();
                    }
                    
                });
                $A.enqueueAction(getFiveOneOneCoachings);                
            }           
        }); 
        //var addDisable = component.find("saveId");
        var SaveBtn = document.getElementById("saveId");        
        var attr = document.createAttribute("disabled");
        attr.value = "";
        SaveBtn.setAttributeNode(attr);
    },
    
    /****************
	* @Description: This helper method is cancel the 1-1 coaching creation
    * @Author: Amit Kumar Pradhan, Accenture    
    * @Date: 31-July-2017   
    * @User Story: US1141906   
    ****************/  
    cancel : function(component, event, helper) {
        //Firing event to show and hide coachingTimeline component
        var showHideCoachingEvent = $A.get("e.c:CreateOneOneCoachingEvent");
        showHideCoachingEvent.setParams({
            "showCreateOneOneCoaching" : "false",
            "showCoachingTimeline" : "true",
            "recordId" : '',
            "pernrId": component.get("v.pernrId")
        });
        showHideCoachingEvent.fire();
        //Firing event to passing coaching details into coachingtimeline component
        var coachingDetailsEvent = $A.get("e.c:OneOneCoachingDetailsEvent");
        coachingDetailsEvent.setParams({           
            "oneOneCoachingRecords" : component.get("v.oneOneCoachingRecords"),
            "userDetails" : component.get("v.userDetails"),
            "coachingId" : component.get("v.workCoachingId"),
            "isRep" : component.get("v.isRep"),
            "pernrId": component.get("v.pernrId")
        });
        coachingDetailsEvent.fire();
    }
})