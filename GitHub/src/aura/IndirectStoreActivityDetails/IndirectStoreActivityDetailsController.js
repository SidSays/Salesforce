({   
    save : function(component, event, helper){ 	
        if(component.get("v.LookupFieldValue") != null){
            var action = component.get("c.DoActivityContactsExist");
            action.setParams({
                "activityId" : component.get("v.storeActivity.Id"),
                "lookUpFieldValue" : component.get("v.LookupFieldValue")
            });
            
            action.setCallback(this, function(a){
                var message = component.find("messagebox");
                var outputText = message.get("v.body")[0];
                if(a.getState() === 'SUCCESS'){		                
                    if(a.getReturnValue()){
                        message.set("v.class","slds-hide");
                        //changed the variable name as editMarkup as part of US1146600
                        var editMarkup = component.find("edit");
                        //Start changes for checking whether the returned value is object or array 
                        if(editMarkup != undefined && editMarkup != null && typeof editMarkup == 'object'){
                             editMarkup.get("e.recordSave").fire();
                        }
                        else{
                            var resultsToast = $A.get("e.force:showToast");
                            resultsToast.setParams({
                                "title": "Error",
                                "type": "error",
                                "message": "Something went wrong. Please try again or contact System Admin."
                            });
                            resultsToast.fire(); 
                        }
                        //changes end
                    } else{
                        message.set("v.class","slds-show");
                        outputText.set("v.value","This field is required");                    
                    }  
                    
                } else{
                    message.set("v.class","slds-show");
                    outputText.set("v.value","Internal server error");
                }  
            });
            $A.enqueueAction(action);
        }else{
            //Start changes for checking whether the returned value is object or array 
            var nonContactMarkup = component.find("edit"); 
              if(nonContactMarkup != undefined && nonContactMarkup != null && typeof nonContactMarkup == 'object'){
                nonContactMarkup.get("e.recordSave").fire();
            }else{
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Error",
                    "type": "error",
                    "message": "Something went wrong. Please try again or contact System Admin."
                });
                resultsToast.fire(); 
                }
        //changes end
    }        
    },
    
    handleSaveSuccess : function(component, event, helper){ 
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "The activity has been saved successfully."
        });
        toastEvent.fire();
        var latestRecordId = component.get("c.getLatestStoreActivity");
        latestRecordId.setParams({
            "loggedInUser" : component.get("v.loggedInUser.Id"),
            "store" : component.get("v.storeTest.Id")
        });
        
        latestRecordId.setCallback(this, function(a){            
            component.set("v.storeActivity", a.getReturnValue());           
            var appEvent = $A.get("e.c:IndirectAddButtonEvent");
            appEvent.setParams({
                "storeActivities" : component.get("v.storeActivity"),
                "edit" : false,
                "readOnly" : true
            });
            appEvent.fire();
        });
        $A.enqueueAction(latestRecordId);
    },
    
    contactsSelection : function(component, event, helper){         
        var selectedItem = event.currentTarget; 
        var currentLookupFieldValue = selectedItem.dataset.record; // Get the LookupField Value        
        var appEvent = $A.get("e.c:IndirectContactSelectionForActivityEvent");
        appEvent.setParams({
            "storeId" : component.get("v.storeTest.Id"),                
            "bodyToRender" : "addContactsToActivity" ,
            "storeActivityId" : component.get("v.storeActivity.Id"),
            "StoreActivityCatagory" : component.get("v.StoreActivityCatagory"),
            "storeVisitCategory" : component.get("v.storeVisitCategory"),
            "LookupFieldValue" : currentLookupFieldValue
        });
        appEvent.fire();
    }
})