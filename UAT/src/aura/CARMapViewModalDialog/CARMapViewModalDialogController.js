({
	doInit : function(component, event, helper) {
		var types = [
            { class: "optionClass", label: "Last reported location today", value: "Last reported location today", selected: "true" },
            { class: "optionClass", label: "CAR Activity locations", value: "CAR Activity locations" },
            { class: "optionClass", label: "Daily location history", value: "Daily location history" }
        ];
        component.find("viewType").set("v.options",types);
        var action = component.get("c.userData");
        action.setCallback(this,function(a){
            var CARs = []; var carList = [];
            var message = component.find("messagebox");
        	var outputText = message.get("v.body")[0];
            CARs = a.getReturnValue();
            if(CARs == null || CARs.size() == 0){
                message.set("v.class","slds-show");
            	outputText.set("v.value","You don't have CARs under you...!!!");
            }
            else{
                message.set("v.class","slds-hide");
                carList.push({class: "optionClass", label: "--Select CAR--", value: "--Select CAR--", selected: "true" });
                for(var i =0; i< CARs.length; i++){
                    carList.push({class: "optionClass", label: CARs[i], value: CARs[i]});
                }
            }
            component.find("CARList").set("v.options",carList);
        });
        $A.enqueueAction(action);
	},
    
    defaultCloseAction : function(component, event, helper) {  
        component.destroy();
    },
    
    onSelectChange : function(component, event, helper) {
        var selectedCAR = component.find("CARList").get("v.value");
        component.set("v.selectedCAR",selectedCAR);
        var selectedType = component.find("viewType").get("v.value");
        component.set("v.selectedType",selectedType);
        var message = component.find("messagebox");
        message.set("v.class","slds-hide");
    },
    
    showDetails : function(component, event, helper) {
        //component.destroy();
    }
})