({
    defaultClose : function(component, event, helper) {  
        component.destroy();
    },
    
    callingEvent : function(component, event, helper){
        var startDateTime= component.find("startDateTime"); 
        var stdate = startDateTime.get("v.value");    
        var toDate = component.find("toDate");
        var toDateValue = toDate.get("v.value"); 
        var appEvent = $A.get("e.c:CARMapViewSelectedDataEvent");        
        appEvent.setParams({                
            "user" : component.get("v.selectedUser"),                  
            "viewType": component.get("v.selectedValue"),
            "fromDate" : stdate,
            "toDate" : toDateValue
        });
        appEvent.fire();
        helper.defaultClose(component, event, helper);  
    },
    
    lastLocationMethod: function(component, event, helper){
        var user =  component.get("v.selectedUser");
        var userArray = user.split("/");
        
        var action1 = component.get("c.lastReportedData");
        action1.setParams({
            "selectedRep": userArray[1]
        });
        action1.setCallback(this, function(a){
            var todayLocation = a.getReturnValue();
            if(todayLocation == null || todayLocation == undefined|| todayLocation == ''){
                component.set("v.warnings", "There is no location data for this CAR.");	
            }
            else{                
                var appEvent = $A.get("e.c:CARMapViewSelectedDataEvent");        
                appEvent.setParams({                
                    "user" : component.get("v.selectedUser"),                  
                    "viewType": component.get("v.selectedValue")                    
                });
                appEvent.fire();
                helper.defaultClose(component, event, helper); 
            }
        });
        $A.enqueueAction(action1);
    },
    
    dailyLocationMethod: function(component, event, helper){
        var user =  component.get("v.selectedUser");
        var userArray = user.split("/");
        
        var dailyDate = component.find("dailyDate");
        var dailyDateValue = dailyDate.get("v.value");
        if(dailyDate.get("v.errors") != null){
            dailyDate.set("v.errors",null);
        }
        if(dailyDateValue == null || dailyDateValue == ''){                
            dailyDate.set("v.errors", [{message:"Please enter date." }]);              
        }else{
            var action1 = component.get("c.dailyLocation");
            action1.setParams({
                "selectedRep": userArray[1],
                "createdDate" : dailyDateValue
            });
            action1.setCallback(this, function(a){
                var dailyLocation = a.getReturnValue();
                if(dailyLocation == null || dailyLocation == undefined || dailyLocation == ''){
                    component.set("v.warnings", "There is no location data for this CAR.");	
                }else{                     
                    var appEvent = $A.get("e.c:CARMapViewSelectedDataEvent");        
                    appEvent.setParams({                
                        "user" : component.get("v.selectedUser"),                  
                        "viewType": component.get("v.selectedValue"),
                        "fromDate" : dailyDateValue                        
                    });
                    appEvent.fire();
                    helper.defaultClose(component, event, helper);
                }
            });
            $A.enqueueAction(action1);
        }
    },
    
    carActivityMethod: function(component, event, helper){
        var user =  component.get("v.selectedUser");
        var userArray = user.split("/");
        //console.log('userArray'+userArray[1]);
        var startDateTime= component.find("startDateTime"); 
        var stdate = startDateTime.get("v.value");
       // console.log('stdate'+stdate);
        var toDate = component.find("toDate");
        var toDateValue = toDate.get("v.value");   
       // console.log('toDateValue'+toDateValue);

        if(startDateTime.get("v.errors") != null){
            startDateTime.set("v.errors",null);
        }
        if(toDate.get("v.errors") != null){
            toDate.set("v.errors",null);
        }
        if((stdate == null || stdate == ''|| stdate == undefined) && (toDateValue == null || toDateValue == '' || toDateValue == undefined)){
            startDateTime.set("v.errors", [{message:"Please enter date." }]);
            toDate.set("v.errors", [{message:"Please enter date." }]);
        }
        
        if(stdate == null || stdate == '' || stdate == undefined){ 
         //   console.log('in sdate method');
            startDateTime.set("v.errors", [{message:"Please enter date." }]);
            
        }
        if(toDateValue == null || toDateValue == '' || toDateValue == undefined){
            toDate.set("v.errors", [{message:"Please enter date." }]);
        }
        var dateDiff =((new Date((new Date()).setFullYear((toDateValue).substring(0,4),((toDateValue).substring(5,7)-1),
                                                          (toDateValue).substring(8,10)))-(new Date((new Date()).setFullYear((stdate).substring(0,4),
                                                                                                                             ((stdate).substring(5,7)-1),(stdate).substring(8,10)))))/86400000);
        var rangeValue = $A.get("$Label.c.Number_of_days_for_CAR_activity_identification");
        var today = new Date();
        
        var toDateValueDate = new Date(toDateValue);
        var stdateDate = new Date(stdate);
        //console.log('today'+today);
        //console.log('toDateValue'+toDateValueDate);
        var todayDateDiff =Math.ceil((toDateValueDate-today)/(1000*60*60*24));
        var startDateDiff = Math.ceil((stdateDate-today)/(1000*60*60*24));
          // console.log('todayDateDiff'+todayDateDiff);
        if((dateDiff>rangeValue || dateDiff<0)|| (todayDateDiff > 0) || (startDateDiff > 0)){
          //  console.log('in if');
            component.set("v.warnings", "Please select the date within last "
                          +rangeValue+" days of the activity.");	
        }
        var sDate = stdate.toString();
        var tDate = toDateValue.toString();       
        
        if(( sDate != null || sDate != "") && (tDate != null || tDate != "") && 
           (component.get("v.warnings") == null || component.get("v.warnings") == '')){
            var action = component.get("c.getProperyData");
            action.setParams({
                "selectedRep": userArray[1],
                "createdDate": stdate,
                "endDate" : toDateValue
            });
            action.setCallback(this, function(a){
                var response = (a.getReturnValue()).properties;
                if(response == ''){
                    component.set("v.warnings", "There is no location data for this CAR.");	
                }else{
                    helper.callingEvent(component, event, helper);                   
                }
            });
            $A.enqueueAction(action);
            
        }
    }
})