/**
 * @author Salesforce Program Architect / Salesforce Services
 * @date 20170605
 * @group Risk Assessment
 * @description Server-Side Controller for the RiskAssessmentComponent Lightning Component
 */
public class RiskAssessmentController {
    /**
     * @description Get the debug flag to enable/disable console logging on the client-side
     * @param None
     * @return Boolean
     */
	@AuraEnabled
    public static Boolean getDebugFlag() {
		// Set the default to OFF to prevent console logging
		// Arguably, this might mask a missing mdt value, but this is tolerable
        Boolean debugFlag = false;
        try {
            for (System_Property__mdt spMDT : [SELECT value__c FROM System_Property__mdt WHERE DeveloperName = 'RiskAssessmentDebugFlag']) {
                debugFlag = Boolean.valueOf(spMDT.Value__c);
            }
        }
        catch(Exception ex) {
            System.debug(ex.getMessage());
        }        
        return debugFlag;
    }
        
    /**
     * @description Get picklist values dynamically from the Risk_Assessment_Disposition__c.Disposition__c field
     * @param None
     * @return List<String>
     */
	@AuraEnabled
    public static List<String> getPicklistOptions() {
        List<String> listOptions = new List<String>();        
        try {
            for(Schema.PicklistEntry pEntry : Risk_Assessment_Disposition__c.Disposition__c.getDescribe().getPicklistValues()) {
                listOptions.add(pEntry.getValue());
            }
        }
        catch(Exception ex) {
            System.debug(ex.getMessage());
        }        
        return listOptions;
    }
    /**
     * @description Get picklist values dynamically from the Risk_Assessment_Disposition__c.Disposition__c field
     * @param None
     * @return List<String>
     */
	@AuraEnabled
    public static Integer getMaxSalesReps() {
		// Set a default based on known business requirements
		// Arguably, this might mask a missing MDT, but this is tolerable
        Integer numMaxSalesReps = 100;
        try {
            for (System_Property__mdt spMDT : [SELECT value__c FROM System_Property__mdt WHERE DeveloperName = 'RiskAssessmentMaxSalesReps']) {
                numMaxSalesReps = Integer.valueOf(spMDT.Value__c);
            }
        }
        catch(Exception ex) {
            System.debug(ex.getMessage());
        }        
        return numMaxSalesReps;
    }
    
    /**
     * @description Get Risk_Assessment_Disposition__c records based on input ExternalId__c list
     * @param List<String> of ExternalId__c Values
     * @return List<Risk_Assessment_Disposition__c> Records 
     */
    @AuraEnabled
    public static List<Risk_Assessment_Disposition__c> getDispositionRecords(List<String> listExternalIds) {
        List<Risk_Assessment_Disposition__c> listDispRecs = new List<Risk_Assessment_Disposition__c>();
        try {
            listDispRecs = 
            [
            	SELECT Id, 
            	Name, 
            	OwnerId, 
            	Sales_Rep_PERNR__c, 
            	Fiscal_Month_End__c, 
            	Disposition__c, 
                Disposition_Comments__c, 
                ExternalId__c 
                FROM Risk_Assessment_Disposition__c 
                WHERE ExternalId__c IN : listExternalIds
            ];
        }
        catch(Exception ex) {
            System.debug(ex.getMessage());
            System.debug(ex.getStackTraceString());
        }
        return listDispRecs;
    }
    
    /**
     * @description Save Risk_Assessment_Disposition__c Records (Created via RiskAssessmentComponent)
     * @param strDispositionWrap: List of Disposition Records in JSON Format
     * @return List of Risk_Assessment_Disposition__c Records
     */
	@AuraEnabled
    public static List<Risk_Assessment_Disposition__c> saveDispositionRecords(String strDispositionWrap) {
        Boolean isSuccess = true;
        List<DispositionWrap> listDispositions;
        List<Risk_Assessment_Disposition__c> listDispRecs = new List<Risk_Assessment_Disposition__c>();
        // Define collections to facilitate the enrichment of Risk_Assessment_Disposition__c records prior to upserting
        List<String> listPernrs = new List<String>();
        Map<String,String> mapPernrUserId = new Map<String,String>();
        try {
        	// Deserialize List of Disposisions in JSON to List of Disposition Wrapper Class Objects
            listDispositions = (List<DispositionWrap>) System.JSON.deserializeStrict(strDispositionWrap, List<DispositionWrap>.Class);
			System.debug('>>>sfdcDebug>>> listDipsitions: ' + listDispositions);            
            // Create a list of Sales Rep PERNR numbers to facilitate getting Sales Rep Id by PERNR
            for(DispositionWrap dispositionW : listDispositions) {
            	listPernrs.add(dispositionW.strPERNR);
            }
            System.debug('>>>sfdcDebug>>> listPernrs: ' + listPernrs);            
            for(User userRec : [SELECT Id, PERNR__c FROM User WHERE PERNR__c IN :listPernrs]) {
            	mapPernrUserId.put(userRec.PERNR__c, userRec.Id);
            }
            System.debug('>>>sfdcDebug>>> mapPernrUserId: ' + mapPernrUserId);            
            // Cycle through the List of Disposision Wrapp Class Objects
            for(DispositionWrap dispositionW : listDispositions) {
                Risk_Assessment_Disposition__c disposition = new Risk_Assessment_Disposition__c(
                    Name = dispositionW.strName,
                    OwnerId = UserInfo.getUserId(),
                    Sales_Rep__c = mapPernrUserId.get(dispositionW.strPERNR),
                    Sales_Rep_PERNR__c = dispositionW.strPERNR,
                    Fiscal_Month_End__c = Date.valueOf(dispositionW.strFiscalMonth),
                    Disposition__c = dispositionW.strDisposition,
                    Disposition_Comments__c = dispositionW.strComment,
                    ExternalId__c = dispositionW.strExternalId
                );                
                System.debug('>>>sfdcDebug>>> PERNR -> UserId: ' + dispositionW.strPERNR + ' -> ' + mapPernrUserId.get(dispositionW.strPERNR));
                listDispRecs.add(disposition);
            }
            System.debug('>>>sfdcDebug>>> listDispRecs: ' + listDispRecs);            
            if(listDispRecs.size() > 0) {
                upsert listDispRecs ExternalId__c;
            }
        }
        catch(Exception ex) {
            isSuccess = false;
            System.debug(ex.getMessage());
            System.debug(ex.getStackTraceString());
        }
        return listDispRecs;
    }
	
    /**
     *  @description Define a Wrapper Class to facilitate Deserializing Disposition Records from JSON
     */
    public class DispositionWrap {
        @AuraEnabled public String strId {get; set;}
        @AuraEnabled public String strName {get; set;}
        @AuraEnabled public String strSalesRep {get; set;}
        @AuraEnabled public String strPERNR {get; set;}
        @AuraEnabled public String strFiscalMonth {get; set;}
        @AuraEnabled public String strDisposition {get; set;}
        @AuraEnabled public String strComment {get; set;}
        @AuraEnabled public String strExternalId {get; set;}
    }
}