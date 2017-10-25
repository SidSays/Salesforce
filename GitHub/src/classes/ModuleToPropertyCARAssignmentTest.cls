/*************************************************************************************
    Name             : ModuleToPropertyCARAssignmentTest.cls
    Description      : Test Controller class for Property Assingment page for Module
    Created By       : Accenture
    Created Date     : 10/18/2017
    User Story		 : 	US1202725: XC Car Modules Properties Related List
 
************************************************************************************/
@isTest
public class ModuleToPropertyCARAssignmentTest {
	public static list<MDU_Property__c> lstmdu = new list<MDU_Property__c>();
	public static Module__c objmodule;
	public static Module__c objmodule1;
	public static MDU_Property__c prop2;
	public static MDU_Property__c prop1;
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
        
        MDU_Property__c prop = TestDataUtility.createProperty();
        prop.Name = 'Property11';
         
        insert prop;
       
        prop1 = TestDataUtility.createProperty();
        //prop1.Assigned_CAR__c= userObj2.Id;
        prop1.Name = 'Test Property1';
        prop1.Property_Rank__c = 1;
        insert prop1;
        
        prop2 = TestDataUtility.createProperty();
        prop2.Name = 'Test Property2';
        prop2.Property_Rank__c = 1;
        insert prop2;
        
        for(integer i=0;i<10;i++){
        	MDU_Property__c prop3 = TestDataUtility.createProperty();
       		prop3.Name = 'Test Property2'+i;
        	 prop3.Property_Rank__c = 1;
        	 lstmdu.add(prop3);
        }
        insert lstmdu;
        objmodule = new Module__c();
        objmodule.Region__c = 'Florida';
        objmodule.Assigned_CAR__c = userObj.id;
        insert objmodule;
        objmodule1 = new Module__c();
        objmodule1.Region__c = 'Florida';
        insert objmodule1;
		
	}
	public static testMethod void assignPropertiesToCAR(){
		
        Test.startTest();
        createrecords();
            System.runAS(userObj){  
            	 ApexPages.currentPage().getParameters().put('Id' , objmodule.id);
            	ApexPages.StandardController stdCon = new ApexPages.StandardController(objmodule);
            	               
                ModuleToPropertyCARAssignment obj = new ModuleToPropertyCARAssignment(stdCon);
                obj.pname = 'Test';
                obj.pcity = '';
                obj.pstate = '';
                obj.searchproperty();
                obj.pname = 'Test';
                obj.pcity = 'Pune';
                obj.pstate = 'Alaska';
                obj.searchproperty();
                obj.pname = 'Test';
                obj.pcity = 'Pune';
                obj.pstate = '';
                obj.searchproperty();
                obj.pname = '';
                obj.pcity = 'Pune';
                obj.pstate = '';
                obj.searchproperty();
                obj.pname = '';
                obj.pcity = '';
                obj.pstate = 'Alaska';
                obj.searchproperty();
                obj.pname = 'Test';
                obj.pcity = '';
                obj.pstate = 'Alaska';
                obj.searchproperty();
                obj.pname = '';
                obj.pcity = 'Pune';
                obj.pstate = 'Alaska';
                obj.searchproperty();
                obj.pname = '';
                obj.pcity = '';
                obj.pstate = '';
                obj.searchproperty();
                obj.onpropertyselected();
                obj.pname = 'Test';
                obj.pcity = '';
                obj.pstate = '';
                obj.searchproperty();
                
                obj.next();
                obj.previous(); 
                obj.recordId = prop1.id;
                obj.onpropertyselected();
                obj.processRequests();
                
           
            }
        Test.stopTest();
	}
	public static testMethod void assignPropertiesToCAR2(){
        Test.startTest();
        createrecords();
            System.runAS(userObj){  
            	 ApexPages.currentPage().getParameters().put('Id' , objmodule1.id);
            	ApexPages.StandardController stdCon = new ApexPages.StandardController(objmodule1);
            	               
                ModuleToPropertyCARAssignment obj = new ModuleToPropertyCARAssignment(stdCon);
                obj.pname = 'Test';
                obj.pcity = '';
                obj.pstate = '';
                obj.searchproperty();
         }
        Test.stopTest();
	}
	
}