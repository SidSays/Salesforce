({
    processInit : function(cmp, event) {
        var action = cmp.get("c.getAppSections"),
            getRecentApps = cmp.get("c.getSalesSpaceRecentAppsForUser"),
            SALESSPACE_RECENT_APPS = "SalesSpace_Recent_Apps";

        cmp.set("v.hasRecentApps", false);

        getRecentApps.setCallback(this, function(response) {
          var state = response.getState();
          if (state === "SUCCESS") {
            var recentAppsValue = response.getReturnValue();
            var recentApps = recentAppsValue && recentAppsValue.value ? JSON.parse(recentAppsValue.value)[SALESSPACE_RECENT_APPS]: [];
            var appSectionWrapperList = cmp.get("v.appSectionWrapperList");

            // Following code will remove the element from local storage, in case we have not
            // configure the access to app.
            if(appSectionWrapperList != null && appSectionWrapperList != ''){
                // Remove any unauthorized apps present in the local storage.
                recentApps = this.removeUnauthorizedApp(cmp, event, recentApps);
                if (recentApps.length > 0) {
                    cmp.set("v.hasRecentApps", true);
                    cmp.set("v.appSectionRecentList", recentApps);
                }
            }
          } else if (state === "ERROR") {
              var errors = response.getError();
              if (errors) {
                  if (errors[0] && errors[0].message) {
                      console.log("Error message: " +
                               errors[0].message);
                      alert("Error message: " +
                               errors[0].message)
                  }
              } else {
                  console.log("Unknown error");
                  alert("Unknown error");
              }
          }
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {

                var appSectionWrapperList = response.getReturnValue();
                cmp.set("v.appSectionWrapperList", appSectionWrapperList);

                $A.enqueueAction(getRecentApps);

            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                 errors[0].message);
                        alert("Error message: " +
                                 errors[0].message)
                    }
                } else {
                    console.log("Unknown error");
                    alert("Unknown error");
                }
            }
        });
        // Add action to queue
        $A.enqueueAction(action);

    },

    removeUnauthorizedApp : function(cmp, event, recentApps){
        	// This method iterate over the apps for which we have access and
        	// only shows those apps in the recent items
        	// We have to ignore/remove the element from recent items.

        	var appSectionWrapperList = cmp.get("v.appSectionWrapperList");
            if(appSectionWrapperList != null && appSectionWrapperList != ''){
                   for (var i=0; i < recentApps.length; i++) {
                       var hasAccess = false;
                       for (var k=0; k < appSectionWrapperList.length; k++) {
                           for (var j=0; j < appSectionWrapperList[k].appLaucherWrapperList.length; j++) {
                                if (recentApps[i].label === appSectionWrapperList[k].appLaucherWrapperList[j].label) {
                                    hasAccess = true;
                                }
                            }
                       }
                       if(!hasAccess){
                           recentApps.splice(i, 1);
                       }
                   }
            }
		return recentApps;
    },

    updateRecentItems : function(cmp, event) {
        var SALESSPACE_RECENT_APPS = "SalesSpace_Recent_Apps",
          getRecentApps = cmp.get("c.getSalesSpaceRecentAppsForUser");

        getRecentApps.setCallback(this, function(response) {
          var state = response.getState();
          if (state === "SUCCESS") {
            var recentAppsValue = response.getReturnValue();
            var recentApps = recentAppsValue && recentAppsValue.value ? JSON.parse(recentAppsValue.value)[SALESSPACE_RECENT_APPS]: [];
            var appSectionWrapperList = cmp.get("v.appSectionWrapperList");

            // Following code will remove the element from local storage, in case we have not
            // configure the access to app.
            if(appSectionWrapperList != null && appSectionWrapperList != ''){
                // Remove any unauthorized apps present in the local storage.
                recentApps = this.removeUnauthorizedApp(cmp, event, recentApps);
                if (recentApps.length > 0) {
                    cmp.set("v.hasRecentApps", true);
                    cmp.set("v.appSectionRecentList", recentApps);
                }
            }
          } else if (state === "ERROR") {
              var errors = response.getError();
              if (errors) {
                  if (errors[0] && errors[0].message) {
                      console.log("Error message: " +
                               errors[0].message);
                      alert("Error message: " +
                               errors[0].message)
                  }
              } else {
                  console.log("Unknown error");
                  alert("Unknown error");
              }
          }
        });

        // Add action to queue
        $A.enqueueAction(getRecentApps);
    }
})