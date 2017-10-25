({
    doInit : function(component, event, helper){
        var types = [
            { class: "optionClass", label: "Last reported location today", value: "Last reported location today", selected: "true" },
            { class: "optionClass", label: "CAR Activity locations", value: "CAR Activity locations" },
            { class: "optionClass", label: "Daily location history", value: "Daily location history" }
        ];
        component.find("viewType").set("v.options",types);
        component.set("v.options", types);
        
        
    },
    
    defaultCloseAction : function(component, event, helper) {  
        helper.defaultClose(component,event, helper);
    },
    
    userChange : function(component, event, helper) {  
        if(component.get("v.warnings") != null){
            component.set("v.warnings",null);
        }
    },
    
    viewTypeChange: function(component, event, helper) {  
        if(component.get("v.warnings") != null){
            component.set("v.warnings",null);
        }
        var viewType = component.get("v.selectedValue");
        
        if(viewType == "Daily location history"){
            var dailyDate = component.find("dailyDate");
            var dailyDateValue = dailyDate.get("v.value");
            if(dailyDateValue != null){
                dailyDate.set("v.value", null);
            }  
        }
        
        if(viewType == 'CAR Activity locations'){
            var startDateTime= component.find("startDateTime"); 
            var stdate = startDateTime.get("v.value");
            var toDate = component.find("toDate");
            var toDateValue = toDate.get("v.value");
            
            if(stdate != null){
                startDateTime.set("v.value", null);
            }
            if(toDateValue != null){
                toDate.set("v.value", null);
            }
        }
        
    },
    
    SaveEvent : function(component, event ,helper) {
        if(component.get("v.warnings") != null){
            component.set("v.warnings",null);
        }
        
        var viewType = component.get("v.selectedValue");
        if(viewType == 'Last reported location today'){   
            if(component.get("v.warnings") != null){
                component.set("v.warnings",null);
            }
            helper.lastLocationMethod(component, event, helper); 
        }        
        
        if(viewType == "Daily location history"){
            if(component.get("v.warnings") != null){
                component.set("v.warnings",null);
            }
            helper.dailyLocationMethod(component, event, helper); 
        }
        
        if(viewType == 'CAR Activity locations'){
            if(component.get("v.warnings") != null){
                component.set("v.warnings",null);
            }
            helper.carActivityMethod(component, event, helper);  
        }
    }
})