({
    filterDialog : function(component, event, helper) {         
          
        var  users = component.get("v.CARusers");
       
            var title="Start Over";
            // var title = title;
            
            $A.createComponent(
                "c:CARMapViewDialog",{ 
                    "title" : title,
                    "confirmBox" : false,
                    "users" : users
                },
                function(msgBox){
                    if (component.isValid()) {
                        var targetCmp = component.find('optionalModalDialog');
                        var body = targetCmp.get("v.body");
                        body.push(msgBox);
                        targetCmp.set("v.body", body); 
                    }                
                }
            );
       
    },
    
    profileCheck : function(component, event, helper){
        var action = component.get("c.checkProfile");               
        action.setCallback(this, function(a){
            var RSAprofile = a.getReturnValue();           
            component.set("v.profileCheck",  a.getReturnValue()); 
            if(RSAprofile == true){
                helper.RSAProfile(component, event, helper);
            }
            else{
                helper.CARManagerProfile(component, event, helper);
            }
        });
        $A.enqueueAction(action); 
        
    },
    
    RSAProfile : function(component, event, helper){
      
        var action = component.get("c.userRSADet");
        action.setCallback(this, function(a){          
            if( a.getReturnValue() != ""){                
                component.set("v.CARusers", a.getReturnValue());               
                if(component.get("v.CARusers") != ""){                    
                    helper.filterDialog(component, event, helper);
                }
            }
            else{
                component.set("v.errorMessage", "ERROR: You don't have any CARs reporting to you.");
            }
            
        }); 
        $A.enqueueAction(action); 
    },
    
    CARManagerProfile : function(component, event, helper){  
        console.log('in CARManagerProfile method');
        var action = component.get("c.userData");
        action.setCallback(this, function(a){            
            if( a.getReturnValue() != ""){
                component.set("v.CARusers", a.getReturnValue());              
                if(component.get("v.CARusers") != ""){
                    helper.filterDialog(component, event, helper);
                }
            }
            else{
                component.set("v.errorMessage", "ERROR: You don't have any CARs reporting to you.");
            }
        });
        $A.enqueueAction(action); 
    },
    
    
})