/**
 * @author Salesforce Program Architect
 * @date 2017-05-10
 * @description Implementation for RiskAssessmentDispotionTrigger
 * If certain fields are changed, then set the Risk_Assessment_Analyst__c to the current logged in user
 */ 
public class RiskAssessmentDispositionTriggerHandler {
	/**
	 * @description If key values are changed on a disposition record, then capture logged in user as risk assessment analyst
	 * @param riskADs list of new disposition records
	 * @return void
	 * @example Invoked via trigger on RiskAssessmentDisposition__c 
	 */ 
    public static void beforeUpdate (List<Risk_Assessment_Disposition__c> listNewDispositions, Map<Id, Risk_Assessment_Disposition__c> mapOldDispositions) {
		// Cycle through the updated dispositions and, for each record that qualifies, update the risk assessment analyst
        for(Risk_Assessment_Disposition__c newDisposition : listNewDispositions) {
            if(
                (newDisposition.Disposition__c != mapOldDispositions.get(newDisposition.Id).Disposition__c) ||
                (newDisposition.Status__c != mapOldDispositions.get(newDisposition.Id).Status__c) ||
                (newDisposition.Risk_Assessment_Comments__c != mapOldDispositions.get(newDisposition.Id).Risk_Assessment_Comments__c)
            ) {
                newDisposition.Risk_Assessment_Analyst__c = UserInfo.getUserId();
            }
        }        
    }
}