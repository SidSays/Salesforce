({
	getAddresses : function(component, event) {
		var action = component.get("c.getPlanAddresses");
        action.setParams({
			"planId" : component.get("v.pageRecordId")           					
		});
       action.setCallback(this, function(a) {
           if(a.getState() === "SUCCESS"){
               var addressesAndPlan = a.getReturnValue();
               if(addressesAndPlan != null){
                   
               	component.set("v.addresses", addressesAndPlan.addresses);
                component.set("v.AssignedPlans", addressesAndPlan.plans);
                component.set("v.currentPlanName", addressesAndPlan.currentPlanName);   
               var sendAddresses = $A.get("e.c:SendFilteredAndOriginalAddressList");
               
                sendAddresses.setParams({"filteredAddresses": component.get("v.addresses"),
                                  "originalAddresses": component.get("v.addresses")}).fire();
               
               var sendPlans = $A.get("e.c:SendPlanList");
                   sendPlans.setParams({"Plans" : addressesAndPlan.plans,
                                        "CurrentPlanName" : addressesAndPlan.currentPlanName}).fire();
               }else{
                   console.log("Some Error");
               }
           } else{
               console.log("No Address found");
           }
        });
    $A.enqueueAction(action);
	}
})