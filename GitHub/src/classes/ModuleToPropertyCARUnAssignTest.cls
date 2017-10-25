/*************************************************************************************
    Name             : ModuleToPropertyCARUnAssignTest.cls
    Description      : Test Controller class for Property Un Assingment page for Module
    Created By       : Accenture
    Created Date     : 10/18/2017
    User Story		 : 	US1202725: XC Car Modules Properties Related List
 
************************************************************************************/
@isTest
public class ModuleToPropertyCARUnAssignTest {
	public static list<MDU_Property__c> lstmdu = new list<MDU_Property__c>();
	public static Module__c objmodule;
	public static Module__c objmodule1;
	public static MDU_Property__c prop;
	public static User userObj;
	public static User userObj2;
	public static void createrecords(){
		List<MDU_Property__c> properties = new List<MDU_Property__c>();
        TestDataUtility.createCustomSettingRecords();
        
        userObj = TestDataUtility.createRSAUser();
        system.runas(userObj){
        userObj2 = TestDataUtility.createXfinityCARUser();
        userObj2.ManagerId = userObj.id;
        }
        TriggerSettings__c mduPropertyTrigger = new TriggerSettings__c();
         mduPropertyTrigger.Name = 'PropertyInsertUpdateTrigger';
            mduPropertyTrigger.isActive__c = false;
            insert mduPropertyTrigger;
        TriggerSettings__c triggerSetting122 = TriggerSettings__c.getValues('PropertyTrigger');
         triggerSetting122.isActive__c = false;
            update triggerSetting122;
        
        objmodule = new Module__c();
        objmodule.Region__c = 'Florida';
        objmodule.Assigned_CAR__c = userObj.id;
        insert objmodule;
        for(integer i=0;i<16;i++){
        	MDU_Property__c prop3 = TestDataUtility.createProperty();
       		prop3.Name = 'Test Property2'+i;
        	 prop3.Property_Rank__c = 1;
        	 prop3.Modules__c = objmodule.id;
        	 lstmdu.add(prop3);
        }
        insert lstmdu;
       		
	}
	public static testMethod void removePropertiesToCAR(){
		
        Test.startTest();
        createrecords();
            System.runAS(userObj){  
            	 ApexPages.currentPage().getParameters().put('Id' , objmodule.id);
            	ApexPages.StandardController stdCon = new ApexPages.StandardController(objmodule);
            	               
                ModuleToPropertyCARUnAssign obj = new ModuleToPropertyCARUnAssign(stdCon);
                
                
                obj.next();
                obj.previous();
                obj.isselected = true;
                obj.recordId = lstmdu[0].id;
                obj.onpropertyselected();
                obj.processRequests();
                
           
            }
        Test.stopTest();
	}
	
}