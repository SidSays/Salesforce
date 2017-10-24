/**
 * @author Salesforce Program Architect
 * @date 2017-07-08
 * @description Test class for the Risk Assessment App Controller
 */ 
@isTest
public class RiskAssessmentControllerTest {
    static testMethod void testRiskAssessmentController() {
        /*
         * Test the more gratuitous methods first
         */ 
        Boolean testGetDebugFlag = RiskAssessmentController.getDebugFlag();
        System.assertNotEquals(testGetDebugFlag, null);
        List<String> testGetPicklistOptions = RiskAssessmentController.getPicklistOptions();
        System.assert(testGetPicklistOptions.size() > 0);
        Integer testGetMaxSalesReps = RiskAssessmentController.getMaxSalesReps();
        System.assert(testGetMaxSalesReps > 0);       
		/*
		 * Test Risk_Assessment_Disposition__c DML
		 * We do not need to create test users for this because the code is tolerant of not retrieving a user by PERNR
		 */
        List<RiskAssessmentController.DispositionWrap> testDispositions = new List<RiskAssessmentController.DispositionWrap>();
        for(Integer i = 0; i < 5; ++i) {
        	RiskAssessmentController.DispositionWrap testDisposition = new RiskAssessmentController.DispositionWrap();
            testDisposition.strName = 'Name_' + i;
            testDisposition.strSalesRep = 'SalesRep_' + i;
            testDisposition.strPERNR = 'PERNR_' + i;
            testDisposition.strFiscalMonth = '2017-01-01';
            testDisposition.strDisposition = 'Valid Performance';
            testDisposition.strComment = 'Valid Performance Comment';
            testDisposition.strExternalId = 'ExternalId__' + i;
            testDispositions.add(testDisposition);
        }
        String strDispositionWrap = JSON.serialize(testDispositions);
        List<Risk_Assessment_Disposition__c> testDispositionUpsert = RiskAssessmentController.saveDispositionRecords(strDispositionWrap);
        System.assert(testDispositionUpsert.size() > 0);
        List<String> radExternalIds = new List<String>();
        for(Risk_Assessment_Disposition__c radRec : testDispositionUpsert) {
            radExternalIds.add(radRec.ExternalId__c);
        }
        List<Risk_Assessment_Disposition__c> testDispositionQuery = RiskAssessmentController.getDispositionRecords(radExternalIds);
        System.assert(testDispositionQuery.size() > 0);
    }
}