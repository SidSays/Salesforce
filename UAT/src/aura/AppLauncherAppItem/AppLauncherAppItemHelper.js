({
    handleClick: function(cmp, event) {
        var SALESSPACE_RECENT_APPS = "SalesSpace_Recent_Apps",
            currentApp = cmp.get("v.appItem"),
            getRecentApps = cmp.get("c.getSalesSpaceRecentAppsForUser"),
            upsertSalesSpaceRecentApps = cmp.get("c.upsertSalesSpaceRecentAppsForUser"),
            IS_IPAD = navigator.userAgent.match(/iPad/i) != null,
            IS_IPHONE = !IS_IPAD && ((navigator.userAgent.match(/iPhone/i) != null) || (navigator.userAgent.match(/iPod/i) != null)),
            IS_IOS = IS_IPAD || IS_IPHONE,
            recentAppsObj, recentApps;

        getRecentApps.setCallback(this, function(response) {
          var state = response.getState();
          if (state === "SUCCESS") {
            var recentAppsValue = response.getReturnValue();
            recentAppsObj = recentAppsValue && recentAppsValue.value ? JSON.parse(recentAppsValue.value) : {};
            recentApps = recentAppsObj[SALESSPACE_RECENT_APPS] || [];
            for (var i=0; i < recentApps.length; i++) {
                if (recentApps[i].label === currentApp.label) {
                    // Remove item from array if already in it
                    recentApps.splice(i, 1);
                }
            }

            // Add item to front of array
            recentApps.unshift(currentApp);
            recentAppsObj[SALESSPACE_RECENT_APPS] = recentApps.slice(0, 3);

            // Put most recent 3 into storage
            upsertSalesSpaceRecentApps.setParams({
              "value": JSON.stringify(recentAppsObj)
            });

            upsertSalesSpaceRecentApps.setCallback(this, function(response) {
              var state = response.getState();
              if (state === "SUCCESS") {
                // Fire event to refresh items
                $A.get("e.c:AppLauncherUpdateRecentEvent").fire();
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

            $A.enqueueAction(upsertSalesSpaceRecentApps);

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

        $A.enqueueAction(getRecentApps);

        // Go to URL
        if (IS_IOS && currentApp.appBinaryUrl) {
            /**
            setTimeout(function() {
                if (!document.webkitHidden) {
                    var goTo = currentApp.mobileUrl ? currentApp.mobileUrl : currentApp.url;
                    window.open(goTo, '_blank');
                }
            }, 25);
            **/
            // open native app
            window.location = currentApp.appBinaryUrl;
        } else if (IS_IOS && currentApp.mobileUrl) {
            //window.open(currentApp.mobileUrl, '_blank');
        } else {
            //window.open(currentApp.url, '_blank');
        }
    },
    handleInit: function(cmp, event) {
        var currentApp = cmp.get("v.appItem"),
            IS_IPAD = navigator.userAgent.match(/iPad/i) != null,
            IS_IPHONE = !IS_IPAD && ((navigator.userAgent.match(/iPhone/i) != null) || (navigator.userAgent.match(/iPod/i) != null)),
            IS_IOS = IS_IPAD || IS_IPHONE;
        // Go to URL
        var url = '';
        if (IS_IOS && currentApp.appBinaryUrl) {
            if (!document.webkitHidden)
              url = currentApp.mobileUrl ? currentApp.mobileUrl : currentApp.url;
        } else if (IS_IOS && currentApp.mobileUrl) {
            url = currentApp.mobileUrl;
        } else {
            url = currentApp.url;
        }
        cmp.set("v.sshref", url);
    }
})