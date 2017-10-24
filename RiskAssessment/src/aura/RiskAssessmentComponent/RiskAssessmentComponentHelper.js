({
         
	/**
     *  @description Fetches the Disposition picklist values from Salesforce
     */
    doInit : function(component, event, helper) {
        // Get the debug flag to enable/disable console logging on the client side
		var action = component.get("c.getDebugFlag");
        action.setCallback(this, function(a) {
            // Capture the debug flag from server
            var resp = a.getReturnValue();
            component.set("v.debugFlag", resp);
        });
        $A.enqueueAction(action);
        /** sfdcTodo 20170609.1138 Remove the postInit attribute and logic, if you confirm that it won't work
         * 		Email sent to Skip Sauls to see if there is a way to prevent this when switching between sub-tabs
         * 		(i.e. switching between two apps via sub-tabs appear to invoke an onLoad event in the To-tab)
         */ 
        // Try to prevent gratuitous onLoad -> doInit invocations (seems more like a Salesforce framework issue)
        if(component.get("v.postInit")) {
            if(component.get("v.debugFlag")) {
                console.log('>>>sfdcDebug>>> postInit');
            }            
            return;
        } else {
	        component.set("v.postInit", true);        
        }
    	// c.<anything> refers to methods in the Server Side Controller (RiskAssessmentController)
		// Get the picklist values from the Risk_Assessment_Disposition__c custom object
        var action = component.get("c.getPicklistOptions");  
        action.setCallback(this, function(a) {
            // Capture picklist values back from server
            var resp = a.getReturnValue();
            component.set("v.listDispValues", resp);
        });
        $A.enqueueAction(action);
        // Get the max selected Sales Reps for dispositioning     
		var action = component.get("c.getMaxSalesReps");
        action.setCallback(this, function(a) {
            // Capture max selected Sales Reps from server
            var resp = a.getReturnValue();
            component.set("v.numMaxSalesReps", resp);
        });
        $A.enqueueAction(action);
	},
 	
	/**
     *  @description Handles Wave Filter Event. This is a standard event from Wave Dashboards ("wave:selectionChanged")
     */
	handleWaveSelections : function(component, event, helper) {
        var params = event.getParams();
        // There does not appear to be any value in caching the Dashboard Id, but no pressing reason to remove it
        var strDashboardId = params.id;
        component.set("v.strDashboardId", strDashboardId);
        var listReps = [];
        var listPERNR = [];
        var listExternalIds = [];
        var listFiscalMonth = [];
        var listDispositions = [];
        var isSalesRep = false;
        var numMaxSalesReps = component.get("v.numMaxSalesReps");
		var numSalesReps = 0;
        var listFiscalMonthCached = component.get("v.listFiscalMonth");
        var isFiscal = false;  
        var displayDispositionSelections;
        var payload = params.payload;
        // clears the existing message present below "Disposition" button (do this first, to allow messaging below)
        $("#messageSec").text('');
        $("#messageSec").css("display", "none");
        // Determine filter event and set context variables
        if(payload) {
            if(component.get("v.debugFlag")) {
                console.log('>>>sfdcDebug>>> params.payload: ',payload);
            }
            if (payload["step"] == "SALES_REP_FILTER") {
                if(component.get("v.debugFlag")) {
                    console.log('>>>sfdcDebug>>> payload.data.length: ',payload.data.length);
                }
                isSalesRep = true;
                numSalesReps = payload.data.length;
            } else if (payload["step"] == "FISCAL_PERIOD_FILTER") {
                isFiscal = true;
            }            
        }
		/*
		 * Set and cache displayDispositionSelections to control if/when the disposition selections will be displayed
		 */ 
        if(isSalesRep) {
            if(numSalesReps == 0) { // 20170706 sfdcBugFix Added logic to check if numSalesReps == 0
                displayDispositionSelections = false;
            } else if(numSalesReps <= numMaxSalesReps) {
                displayDispositionSelections = true;
            } else {
                displayDispositionSelections = false;
                helper.addMessage("Please select less than " + numMaxSalesReps + " Sales Reps", "errorSec");
            }
			/**
			 * This is the only place where displayDispositionSelections gets cached (aside from the default value)
			 * Why? Because the selection of sales reps (i.e. selected and # selected < max) drives the display
			 */ 
            component.set("v.displayDispositionSelections", displayDispositionSelections);                
        }
        /**
         * We only process the Wave filter event if:
         * 1. Dashboard filtered by sales rep, and less than the max # of sales reps have been selected, or
         * 2. Dashboard filtered by fiscal month end
         */ 
        if(isFiscal || (isSalesRep && (numSalesReps <= numMaxSalesReps))) {
            // Get the data associated with the Wave filter event
            var data = payload.data;
            if(component.get("v.debugFlag")) {
            	console.log('>>>sfdcDebug>>> payload.data: ',data);
            }
            // Cycle through the data associated with the Wave filter event
			data.forEach(function(obj) {
                for(var k in obj) {
                    if(component.get("v.debugFlag")) {
                        console.log('>>>sfdcDebug>>> Filter Event: ',k);
                        console.log('>>>sfdcDebug>>> Filter Payload: ',obj[k]);
                    }
                    // NAME_PERNR filter = Sales Rep Filter
                    if(k == "NAME_PERNR") {
                        var salesRepPERNR = obj[k];
                        var index = salesRepPERNR.lastIndexOf("[");
                        // Store Sales REp PERNR and Sales Rep Name separately
                        var PERNR = salesRepPERNR.slice(index + 1, salesRepPERNR.length-1);
						var salesRep = salesRepPERNR.slice(0, index-1);
                        listReps.push(salesRep);
                        listPERNR.push(PERNR);
                    }                    
                    // FISCAL_MONTH_END = Fiscal Month End Filter
                    if(k == "FISCAL_MONTH_END") {
                        listFiscalMonth.push(obj[k]);
                    }
                }
            });
			// Cache the lists to attributes
            if(isSalesRep) {
				/**
				 * If previously selected sales reps are completely de-selected, then the cached list will be reset
				 * i.e. the step comes through with no payload, so isSalesRep = True but listReps = []
				 */ 
                component.set("v.listReps", listReps);
                component.set("v.listPERNR",listPERNR);
            } else if(isFiscal) {
         		/**
         		 * In the current dashboard design, we will always have a selected fiscal month end
         		 * (If this ever changes, then the same reset would apply here as it does with listReps)
         		 */ 
            	component.set("v.listFiscalMonth", listFiscalMonth);
            }
        }
        /**
         * Retrieved the cached displayDispositionSelections flag, which will be:
         * The default value (false), if not set above
         * True if <= max # of allowable sales reps selected (in this or prior invocation)
         * False if > max # of allowable sales reps selected (in this or a prior invocaction)
         */
		displayDispositionSelections = component.get("v.displayDispositionSelections");
		// we only perform the following logic if we are going to display disposition selections
        if(displayDispositionSelections) {
            listReps = component.get("v.listReps");
            listPERNR = component.get("v.listPERNR");
            listFiscalMonth = component.get("v.listFiscalMonth");            
            /**
             * We compose listExternalIds from the retrieved listPERNR and listFiscalMonth variables
             * This is a coding-clarity-convenience, as each of these lists are set by different filter events
             * The logic to set them in real time when processing the filter event would be a bit dense
             */
            listFiscalMonth.forEach(function(month) {
               listPERNR.forEach(function(PERNR) {
	               listExternalIds.push(PERNR + '-' + month); 
       	        }); 
           	});
            // Add disposition records to the list with default values
            listFiscalMonth.forEach(function(month) {
                listReps.forEach(function(salesRep, index) {
                    listDispositions.push({
                        strId : '',
                        strName : salesRep + ' [' + listPERNR[index] + '] ' + ' Period Ending: ' + month,
                        strSalesRep : salesRep,
                        strPERNR : listPERNR[index],
                        strFiscalMonth : month,
                        strDisposition : '',
                        strComment : '',
                        strExternalId : listPERNR[index] + '-' + month
                    });
                });
            });
	        if(component.get("v.debugFlag")) {
            	console.log('>>>sfdcDebug>>> ExternalIds in scope: ',listExternalIds);
            }
            // IFF listExternalIds is populated, retrieve existing disposition records via Server-Side Controller
            // We do this regardless of what is in the local cache, and then update the local cache accordingly
            if(listExternalIds.length > 0) {
                var action = component.get("c.getDispositionRecords");
                action.setParams({
                    "listExternalIds": listExternalIds
                });            
                action.setCallback(this, function(a) {
                    var listDisps = a.getReturnValue();
                    var listPrevDisps = component.get("v.listDisps");
                    if(!listPrevDisps) {
                        listPrevDisps = {};
                    }
                    // Update the local cache of dispositions
                    listDisps.forEach(function(disposition) {
                        listPrevDisps[disposition.ExternalId__c] = disposition;
                    });
                    // If disposition records found then load comment and disposition values from them
                    listDispositions.forEach(function(disposition) {
                        var key = disposition.strPERNR + '-' + disposition.strFiscalMonth;   
                        if(listPrevDisps[key]) {
                            disposition.strId = listPrevDisps[key].Id;
                            disposition.strDisposition = listPrevDisps[key].Disposition__c;
                            disposition.strComment = listPrevDisps[key].Disposition_Comments__c;
                        }
                    });
                    /**
                     * Save the dispositions (i.e. cache the values)
                     * Note that listDispositions will be cached even if there are no existing disposition records
                     * (i.e. the list will simply be cached without pre-populated values)
                     */ 
                    component.set("v.listDispositions", listDispositions);
                });
                $A.enqueueAction(action);
            }
        }
	},
    
	/**
     *  @description upsert disposition records to Salesforce
     */
    saveDispositions : function(component, event, helper) {
        var action = component.get("c.saveDispositionRecords");
        var listDispositions = component.get("v.listDispositions");
        var isCommentAbsent = false;
        $(".dispositionText").text("");
        listDispositions.forEach(function(disposition, index) {
            // Validate that each selected Sales Rep has a disposition, or else display an error 
            if(!disposition.strDisposition) {
                $("#disposition" + index).text("Error: Select a Disposition for this Sales Rep");
                isCommentAbsent = true;
            }
        });
        
        // creating json of disposition record to send to server
        var strDispositionWrap = JSON.stringify(listDispositions);  
        if(component.get("v.debugFlag")) {
          	console.log('>>>sfdcDebug>>> strDispositionWrap: ',strDispositionWrap);
        }        
        action.setParams({
          "strDispositionWrap": strDispositionWrap
        });
        action.setCallback(this, function(a) {
            var listDisps = a.getReturnValue();
            
            // Update Disposition records present in cache with updated values
            if(listDisps.length > 0) {
            	$(".modalContainer").css("display", "none");
                helper.addMessage("Dispositions Submitted", "SuccessSec");
                var listPrevDisps = component.get("v.listDisps");
                if(!listPrevDisps) {
                    listPrevDisps = {};
                }
                
                // Update cache based on ExternalId__c
                listDisps.forEach(function(disposition) {
                    listPrevDisps[disposition.ExternalId__c] = disposition;
                });
                
				// sfdcTodo 20170605.1914 Figure out what this code does, and update the comment
                // Assign Id values to the records present on the list
                listDispositions.forEach(function(disposition, index) {
                    var key = disposition.strPERNR + '-' + disposition.strFiscalMonth;
                    if(listPrevDisps[key]) {
                        disposition.strId = listPrevDisps[key].Id;
                    }
                });
                
                component.set("v.listDisps", listPrevDisps);
                component.set("v.listDispositions", listDispositions);
            }
            else {
                helper.addMessage("Error: Dispositions not saved. Please try again.", "errorSec");
            }
        });
        
        if(!isCommentAbsent) {
        	$A.enqueueAction(action);
        }
        else {
            helper.addMessage("Disposition Cancelled", "errorSec");
        }
	},

	/**
     *  @description upsert disposition records to Salesforce
     */
    showPopup : function(component, event, helper) {
    	// Show modal dialog
        $(".dispositionText").text("");
        var listDispositions = component.get("v.listDispositions");     
        var displayDispositionSelections = component.get("v.displayDispositionSelections");
        if(component.get("v.debugFlag")) {
            console.log('>>>sfdcDebug>>> ENTER showPopup');
            console.log('>>>sfdcDebug>>> displayDispositionSelections: ',displayDispositionSelections);
        }
        // checks whether sales reps are selected or not, if not selected then it won't show pop up
        if(listDispositions.length == 0) {
            helper.addMessage("Please select 1 or more Sales Reps.", "errorSec");
        } else if (displayDispositionSelections) {
           	$(".modalContainer").css("display", "block");
        }
    },
    
	/**
     *  @description displays error or success message on component below "Disposition" button
     */
    addMessage : function(strMessage, strClass) {
        $("#messageSec").text(strMessage);
        $("#messageSec").addClass(strClass);
        $("#messageSec").css("display", "block");
    }
})