({
    searchKeyChange: function(component, event) {
        component.set("v.searchResults", null);
        var searchKey = event.getParam("searchKey");
        var action = component.get("c.findAddressesBySearchKey");
        
        action.setParams({
            "searchKey": event.getParam("searchKey"),
            "onOrOff" :  event.getParam("onOrOff"),
            "planId"  :  event.getParam("planId")
        });
        action.setCallback(this, function(a) {
            var results = a.getReturnValue();
            if(results != null){
                component.set("v.searchResults", a.getReturnValue());
            } else{
                component.set("v.searchResults", null);
                //console.log("Nothing");
            }
        });
        $A.enqueueAction(action);
    },
    
    gotoAddressDetail : function(component, event) {
        var addrId = event.currentTarget.dataset.record;
        
        if(addrId && addrId.slice(0,3) == 'a0E'){ //set redirection to load playlist
        	var myURL = "/"+addrId;
              if( (typeof sforce != 'undefined') && (sforce != null) ) {
		        // Salesforce1 navigation
		        sforce.one.navigateToURL(myURL);
		      } else {
		    	  // In Browser 
		    	  window.location.href = myURL;
		      }
        } else{
            console.log("Error loading the Plan");
        }        
    }
})