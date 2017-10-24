/**
 * @author Salesforce Program Architect
 * @date 2017-05-10
 * @description Trigger for Risk_Assessment_Disposition__c Custom Object
 * Logic implemented in RiskAssessmentTriggerHandler
 */ 
trigger RiskAssessmentDispositionTrigger on Risk_Assessment_Disposition__c (before update) {
    if(Trigger.isBefore) {
        if(Trigger.isUpdate){
            RiskAssessmentDispositionTriggerHandler.beforeUpdate(trigger.new, trigger.oldMap);
        }
    }
}