/**
*Class Name :       CommunityManageRequestsControllerTest
*CreatedBy :        Accenture
*CreatedDate :      24-Oct-2017
*Description :      Test class for CommunityManageRequestsController
*Modification History:
*/
@isTest
public class CommunityManageRequestsControllerTest {
	/***************************************
    * @MethodName: communityManageRequestsTest
    * @Author : Suchita, Accenture
    * @Date : 9-Oct-2017 
    * @Description : Test method
    * @UserStory : US1193371 -XCP Request Listing
    * @Return : void
    *****************************************/
    private static testMethod void communityManageRequestsTest(){
        
        TriggerSettings__c propertyTrigger = new TriggerSettings__c();
		propertyTrigger.Name = 'PROPERTY_TRIGGER';
		propertyTrigger.isActive__c = false;
		Database.insert(propertyTrigger); 
		
		TriggerSettings__c xfinityPropertyTrigger = new TriggerSettings__c();
		xfinityPropertyTrigger.Name = 'PROPERTYINSERT_TRIGGER';
		xfinityPropertyTrigger.isActive__c = false;
		Database.insert(xfinityPropertyTrigger); 
        
		Test.startTest();
		// Create test data
		MDU_Property__c  testProperty = TestDataUtility.createProperty();
		Database.insert(testProperty,true);		
		Case testCase = new Case();
		testCase.Status = 'Open';
		testCase.Property__c = testProperty.Id;
		testCase.Event_Date__c = system.today();
		testCase.End_Time__c = '1:00AM';
		testCase.Start_Time__c = '6:00AM';
		testCase.Number_of_Residents__c = 1;
		testCase.Event_name_or_type__c = 'Test';		   
		testCase.How_can_the_CAR_get_involved__c = 'Test Comment';           
		Map<String,Schema.RecordTypeInfo> caseRecordTypeInfos = Case.SObjectType.getDescribe().getRecordTypeInfosByName();
		testCase.RecordTypeId = caseRecordTypeInfos.get('Request Event Support').getRecordTypeId();
		database.insert(testCase,true);
           
		List<Case> caselst = CommunityManageRequestsController.fetchUsercases();
		List<String> allRequestTypelst = CommunityManageRequestsController.getAllRequestTypesForCommunityPortal();
		List<String> propertyValuelst = CommunityManageRequestsController.getPropertyValue();
                   
        Test.stopTest();
    }
}