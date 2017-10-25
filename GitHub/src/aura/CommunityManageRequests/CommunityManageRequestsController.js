({
    doInit : function(component, event, helper){
        var fetchUsercases = component.get("c.fetchUsercases");
        fetchUsercases.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS"){                
                component.set("v.filteredCaseslst", response.getReturnValue());
                component.set("v.allCaseslst",response.getReturnValue());
            }else{
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(fetchUsercases);
        
        var action = component.get("c.getPropertyValue");       
        action.setCallback(this, function(response){
            if(response.getState() == 'SUCCESS'){
                component.set("v.propertylst", response.getReturnValue());                   
            }else{
                var errors = actionResult.getError();
                if(errors){
                    if(errors[0] && errors[0].message){
                        console.log('Error Message-->'+errors[0].message);
                    }else{
                        console.log('Unknown Error');
                    }
                }
            }
        });
        $A.enqueueAction(action);
        var action = component.get("c.getAllRequestTypesForCommunityPortal");       
        action.setCallback(this, function(response){
            if(response.getState() == 'SUCCESS'){
                component.set("v.requestTypesForCommunityPortal", response.getReturnValue());                   
            }else{
                var errors = actionResult.getError();
                if(errors){
                    if(errors[0] && errors[0].message){
                        console.log('Error Message-->'+errors[0].message);
                    }else{
                        console.log('Unknown Error');
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    //Method called when Make new request button is clicked.
    navigateToSubmitRequests : function(component,event,helper){
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": '/submit-request',             
        });
        urlEvent.fire();
        
    },
    searchData : function(component, event, helper){
        console.log('inside search');
        var newResult = [];
        var result = component.get("v.filteredCaseslst");
        var searchText = document.getElementById("searchbox-id").value;
        component.set("v.searchedText", searchText);
        if(searchText != ''){
            
            for(var i=0; i < result.length; i++){
                var propertyName = result[i].Property__r.Name;
                console.log('propertyName>>>>'+propertyName);
                //console.log('searchText>>>>'+searchText);
                if((result[i].CaseNumber!=null && result[i].CaseNumber.toLowerCase().indexOf(searchText.toLowerCase()) > -1)
                   || (result[i].Status!=null && result[i].Status.toLowerCase().indexOf(searchText.toLowerCase()) > -1)
                   || (result[i].RecordType.Name!=null && result[i].RecordType.Name.toLowerCase().indexOf(searchText.toLowerCase()) > -1) 
                   || (propertyName!=null && propertyName.toLowerCase().indexOf(searchText.toLowerCase()) > -1) 
                  ){                     
                    newResult.push(result[i]);                          
                }
            }           
            component.set("v.filteredCaseslst", newResult);                   
        }else{   
            var allCaseslst = component.get("v.allCaseslst");
            component.set("v.filteredCaseslst", allCaseslst);   
        }
    },
    /*
    onRequestTypeChange : function(component, event, helper){
        var newResult = [];
        var filteredCaseslst = component.get("v.allCaseslst");
        var requestType = component.find("myRequestType").get("v.value"); 
        var propertyName = component.find("myProperty").get("v.value"); 
        var status = component.find("myStatus").get("v.value");       
        
        if(requestType != '' && propertyName != '' && status != ''){
            for(var i=0; i < filteredCaseslst.length; i++){ 
                if((filteredCaseslst[i].XCP_Request_Type__c !=null && filteredCaseslst[i].XCP_Request_Type__c ==requestType )
                   && (filteredCaseslst[i].Property__r.Name !=null && filteredCaseslst[i].Property__r.Name == propertyName )
                   && (filteredCaseslst[i].Status !=null && filteredCaseslst[i].Status == status )){
                    newResult.push(filteredCaseslst[i]);
                }
            }
            component.set("v.filteredCaseslst", newResult);                   
        }else{}
    },
    
    onPropertyChange : function(component, event, helper){
        var newResult = [];
        var filteredCaseslst = component.get("v.filteredCaseslst");
        var fiterText = component.find("myProperty").get("v.value"); 
        console.log('fiterText'+fiterText);
        if(fiterText != ''){
            for(var i=0; i < filteredCaseslst.length; i++){ 
                if((filteredCaseslst[i].Property__r.Name !=null && filteredCaseslst[i].Property__r.Name.toLowerCase().indexOf(fiterText.toLowerCase()) > -1)){
                    newResult.push(filteredCaseslst[i]);
                }
            }
            component.set("v.filteredCaseslst", newResult);                   
        }else{}
    },
    onStatusTypeChange : function(component, event, helper){
        var newResult = [];
        var filteredCaseslst = component.get("v.filteredCaseslst");
        var fiterText = component.find("myStatus").get("v.value");       
        if(fiterText != ''){
            for(var i=0; i < filteredCaseslst.length; i++){ 
                if((filteredCaseslst[i].Status !=null && filteredCaseslst[i].Status.toLowerCase().indexOf(fiterText.toLowerCase()) > -1)){
                    newResult.push(filteredCaseslst[i]);
                }
            }
            component.set("v.filteredCaseslst", newResult);                   
        }else{}
    },
	*/    
    sortByCaseNumber: function(component, event, helper) {
        var sortBy = component.find("myCaseNumber").get("v.value");        
        if(sortBy == 'Ascending' ){            
            var sortAsc = false;            
        }else if(sortBy == 'Descending' ){           
            var sortAsc = true;          
        }
        component.set("v.sortAsc",sortAsc);       
        helper.sortBy(component, "CaseNumber");
    },
    
    clearAllFilter :function(component, event, helper){        
        var allCaseslst = component.get("v.allCaseslst");
        component.set("v.filteredCaseslst", allCaseslst); 
        component.find("myStatus").set("v.value",'--Select--');
        component.find("myRequestType").set("v.value",'--Select--');
        component.find("myProperty").set("v.value",'--Select--');
        component.find("myCaseNumber").set("v.value",'--Select--');       
    },
    redirectTosObj : function(component, event, helper){
        var navEvent = $A.get("e.force:navigateToSObject");
        navEvent.setParams({
            "recordId" : event.target.getAttribute("data-id")
        });
        navEvent.fire();
    },
    onchangeValue :function(component, event, helper){
        var filteredCaseslst = component.get("v.allCaseslst");
        var requestType = component.find("myRequestType").get("v.value"); 
        var propertyName = component.find("myProperty").get("v.value"); 
        var status = component.find("myStatus").get("v.value"); 
        var selectOption = '--Select--';
        
        var filterCriteria = function(cases){
            var finalCriteria = true;
            if(requestType != null && requestType != selectOption){
                finalCriteria = cases.RecordType.Name == requestType;
            }
            
            if(propertyName != null && propertyName != selectOption){
                finalCriteria = finalCriteria && cases.Property__r.Name == propertyName;
            }
            if(status != null && status != selectOption){
                finalCriteria = finalCriteria && cases.Status == status;
            }
            return finalCriteria;
        };
        
        var filteredCases = helper.applyFilter(component,filteredCaseslst,filterCriteria);
        component.set("v.filteredCaseslst", filteredCases);  
    },
})