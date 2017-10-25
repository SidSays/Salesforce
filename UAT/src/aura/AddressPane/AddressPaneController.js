({
    addressesLoaded: function(component, event, helper) {
        component.set("v.VoiceOn",$A.get('$Resource.Tooltip_images')+'/IconVoice.png');	                          
        component.set("v.VoiceOff",$A.get('$Resource.Tooltip_images')+'/IconVoiceDisabled.png');
		
        component.set("v.VideoOn",$A.get('$Resource.Tooltip_images')+'/IconVideo.png');	                          
        component.set("v.VideoOff",$A.get('$Resource.Tooltip_images')+'/IconVideoDisabled.png');
		
        component.set("v.XHOn",$A.get('$Resource.Tooltip_images')+'/IconXh.png');	                          
        component.set("v.XHOff",$A.get('$Resource.Tooltip_images')+'/IconXhDisabled.png');
		
        component.set("v.HSIOn",$A.get('$Resource.Tooltip_images')+'/IconInternet.png');	                          
        component.set("v.HSIOff",$A.get('$Resource.Tooltip_images')+'/IconInternetDisabled.png');
		
        component.set("v.TapStatusCold",$A.get('$Resource.Tooltip_images')+'/IconPlugInactive_gray.png');	                          
        component.set("v.TapStatusHot",$A.get('$Resource.Tooltip_images')+'/IconPlugActive.png');
        
		component.set("v.Targeted",$A.get('$Resource.Targeted'));
        
        var addresses = event.getParam('filteredAddresses');
        //console.log("addressLoadedaddresses:"+addresses);
        if(addresses != undefined) {
            //Default Sorting by Sort_Code__c
            //addresses.sort(function(a,b) {return (a.Sort_Code__c > b.Sort_Code__c) ? 1 : ((b.Sort_Code__c > a.Sort_Code__c) ? -1 : 0);} );         
            //Date format conversion      
            addresses.forEach(function(address){
                if(address.Last_Disconnected_Date__c){
                    address.Last_Disconnected_Date__c = helper.getShoreDate(component, new Date(address.Last_Disconnected_Date__c));                                
                }
            });            
            component.set("v.filteredAddresses",addresses);           
        }     
        //Highlight the first address
        setTimeout(helper.highlightFirstAddr, 50);                
    },
        
    /*CreatedDate: 14-June-2017
     * CreatedBy: Radhika Bansal
     * Requirement: US1099096 DSM to SF1: Default Address and Selecting Addresses on AddressFiltering
     * Modified By: Srini Bhattiprolu
     * Modified Date: 3-Jul-2017
     * User Story: US1124451 - DSM to SF1: AddressFiltering Cards and selected Address
     * Comments: Added logic for adding style for the selected address and removing the style
     * for the previously selected address
     */
    zoomOnAddress: function(component, event, helper){
        var selectedAddress = event.currentTarget.dataset.record;
        var address = component.get("v.filteredAddresses")[selectedAddress];
        var sendSelectedAddressLatLong = $A.get("e.c:selectedAddressLatLongEvent"); 
        
        //Remove selectedRow class from previously clicked card.
		$("div#mainDiv > div").children("article.selectedRow").removeClass("selectedRow");
		
        //Add selectedRow class to most recently clicked card.
        $(event.target).parentsUntil("div#mainDiv > div","article").addClass("selectedRow");   
        if(event.target.tagName === "ARTICLE"){
            $(event.target).addClass("selectedRow");
        }
        sendSelectedAddressLatLong.setParams({
            selectedAddressLat : address.Latitude__c,
            selectedAddressLong : address.Longitude__c
        }).fire();
    }
})