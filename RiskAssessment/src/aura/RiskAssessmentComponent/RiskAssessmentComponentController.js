({
	/*
     *  @description calls the method present in helper to fetch Picklist values
     */
    doInit : function(component, event, helper) {
        helper.doInit(component, event, helper);
	},
    
	/*
     *  @description call the helper method to categorise the data coming from wave dashboard
     */
	handleWaveSelections : function(component, event, helper) {
        helper.handleWaveSelections(component, event, helper);
	},
    
	/*
     *  @description saves the dispositions and comments added by user to Salesforce
     */
    saveDispositions : function(component, event, helper) {
        helper.saveDispositions(component, event, helper);
	},
    
	/*
     *  @description shows the popup to user based on some conditions
     */
    showPopup : function(component, event, helper) {
		helper.showPopup(component, event, helper);
    },
    
	/*
     *  @description hides the pop up
     */
    hidePopup : function(component, event, helper) {
        $(".modalContainer").css("display", "none");
	}
})