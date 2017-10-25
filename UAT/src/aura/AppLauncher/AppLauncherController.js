({
    "doInit" : function(cmp, event, helper) {
       helper.processInit(cmp, event);

    },

    "appLauncherEventHandler" : function(cmp, event){
        // Toggle the appLauncherDiv div, with slds-panel-active class.
        var toggleDashboard = cmp.find("appLauncherDiv");
        $A.util.toggleClass(toggleDashboard, "slds-panel-active");
    },

    "appSelectionEvent" : function(cmp, event){
         // Fire Event
         $A.get("e.c:AppSelectionEvent").fire();
    },

    "updateRecentItems" : function(cmp, event, helper) {
        helper.updateRecentItems(cmp, event);
    },

    "toggleAppLauncher": function(cmp, event) {
      // Toggle the appLauncherDiv div, with slds-panel-active class.
      var toggleDashboard = cmp.find("appLauncherDiv");
      $A.util.toggleClass(toggleDashboard, "slds-panel-active");

      $A.get("e.c:ToggleCloseEvent").fire();
    }
})