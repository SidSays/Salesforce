({
    toggleParent : function(component, event, helper) {      
        var mainDivTag = component.find("mainDiv");
        var arrowButton = component.find("arrowButton");
        var isOpen = $A.util.hasClass(mainDivTag, "slds-is-open");
        if(isOpen){
            $A.util.removeClass(mainDivTag, "slds-is-open");
            $A.util.addClass(mainDivTag, "slds-is-closed"); 
            
            $A.util.removeClass(arrowButton, "slds-is-open");
            $A.util.addClass(arrowButton, "slds-is-closed"); 
             
        }else{
            $A.util.addClass(mainDivTag, "slds-is-open");
            $A.util.removeClass(mainDivTag, "slds-is-closed");
            
            $A.util.addClass(arrowButton, "slds-is-open");
            $A.util.removeClass(arrowButton, "slds-is-closed");
        }
        
        var myEvent = component.getEvent("toggleClick");
    	myEvent.fire();
    }
})