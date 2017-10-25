/***************************************************************************************************************************************
 * Author     : Gaurav Aggarwal, Accenture
 * Date       : 30-May-2013
 * Description: This is Test class for "AddressTriggerController" class.
 * History
     Version             : 1.0
     Author Last Updated : Gaurav Aggarwal, Accenture 
     PROJECT             : Direct Sales
***************************************************************************************************************************************/
@isTest
public class AddressTriggerControllerTest{


    private static testMethod void testAddressTriggerController()
    {
       // SetupTestData. ();
        //SetupTestData.createUsers();
        List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
        TriggerSettings__c planTrigger = new TriggerSettings__c();
        planTrigger.Name = 'PlanTrigger';
        planTrigger.isActive__c = True;
        triggerSettingsList.add(planTrigger);
        
        TriggerSettings__c addressTrigger = new TriggerSettings__c();
        addressTrigger.Name = 'AddressTrigger';
        addressTrigger.isActive__c = True;
        triggerSettingsList.add(addressTrigger);

        TriggerSettings__c addressStatisticsTrigger = new TriggerSettings__c();
        addressStatisticsTrigger.Name = 'AddressStatisticsTrigger';
        addressStatisticsTrigger.isActive__c = True;
        triggerSettingsList.add(addressStatisticsTrigger);
               
        TriggerSettings__c userTrigger = new TriggerSettings__c();
        userTrigger.Name = 'UserTrigger';
        userTrigger.isActive__c = True;
        triggerSettingsList.add(userTrigger);
        
        TriggerSettings__c address1 = new TriggerSettings__c();
        address1.Name = 'BypassAddressTerritory';
        address1.isActive__c = True;
        triggerSettingsList.add(address1);
        
        insert triggerSettingsList;
        VariableSettingTestUtility.variableSettingsData();
       User supervisorUser;
        User managerUser;
        User businessAdminUser;
        Profile p2 = [Select UserType, UserLicenseId, Name From Profile where Name like 'Sales Development Manager'];
        Profile p3 = [Select UserType, UserLicenseId, Name From Profile where Name like 'Area Sales Manager'];
        Profile p4 = [Select UserType, UserLicenseId, Name From Profile where Name like 'Business Administrator'];
        UserRole r2 = [Select Id, Name from UserRole where Name='DS Supervisor'];
        UserRole r3 = [Select Id, Name from UserRole where Name='DS Manager'];
        UserRole r4 = [Select Id, Name from UserRole where Name='National Manager'];
        String randomstr2 = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
        String randomstr3 = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
        String randomstr4 = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
        
        User user = [Select Id from User where Id=:UserInfo.getUserId()];
        System.runAs(user)
        {
          businessAdminUser = new User(Alias = 'DA_' + randomstr4.substring(0,4),
                                    Email = randomstr4 + 'userTest@SampleclassTest.com',
                                    LastName='Testing',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p4.Id,
                                    UserRoleId = r4.Id,
                                    Username = 'userTest' + randomstr4 + '@SampleclassTest.com',
                                    Region__c = 'Freedom',
                                    FederationIdentifier = 'FedId1',
                                    EmployeeNumber = 'Emp' + randomstr4.substring(0,4));
        insert businessAdminUser;
       }
        
         System.runAs(businessAdminUser)
        {
         managerUser = new User(Alias = 'DA_' + randomstr3.substring(0,4),
                                    Email = randomstr3 + 'userTest@SampleclassTest.com',
                                    LastName='Testing',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p3.Id,
                                    UserRoleId = r3.Id,
                                    PERNR__c = '12312345',
                                    Username = 'userTest' + randomstr3 + '@SampleclassTest.com',
                                    Region__c = 'Freedom',
                                    ManagerId = businessAdminUser.Id,
                                    FederationIdentifier = 'FedId2',
                                    EmployeeNumber = 'Emp' + randomstr3.substring(0,4));
        insert managerUser;
        }
        
         System.runAs(managerUser )
        {
         supervisorUser = new User(Alias = 'DA_' + randomstr2.substring(0,4),
                                    Email = randomstr2 + 'userTest@SampleclassTest.com',
                                    LastName='Testing',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p2.Id,
                                    UserRoleId = r2.Id,
                                    PERNR__c = '32132145',
                                    Username = 'userTest' + randomstr2 + '@SampleclassTest.com',
                                    Region__c = 'Freedom',
                                    ManagerId = managerUser.Id,
                                    FederationIdentifier = 'FedId3',
                                    EmployeeNumber = 'Emp' + randomstr3.substring(0,4));
        insert supervisorUser;  
        }
        
            Exclusion__c excl ;
            excl = new Exclusion__c();
            excl.Name = 'Test Exclusion';
            excl.Expiration_Date__c = System.Today() + 30;
            excl.Division__c = 'NorthEast';
            excl.Region__c = 'Freedom';
            excl.Nodes__c = '12345';
            insert excl;
        
        Division freedomRegion = [select id, name from Division where name ='Freedom Market'];
       // User user = [Select Id from User where Id=:UserInfo.getUserId()];
        
        Test.startTest();

        System.runAs(supervisorUser)
        {
            
            //Create a turf Level Plan 
            Plan__c pln = new Plan__c();
            pln.Name = 'TestPlan';
            pln.Plan_Level__c = 'Turf';   
            pln.Expiration_Date__c = system.Today() + 30;
            insert pln;
            ApexPages.StandardController controller1 = new ApexPages.StandardController(pln);
            PlanEditExtn extnObj1 = new PlanEditExtn(controller1);
            extnObj1.quickSave();           
            
            List<Customer_Address__c> addrList = new List<Customer_Address__c>();
            Customer_Address__c addr1;
            
            // Create 10 Customer Address Data
            for(integer i=0; i<5; i++){
                addr1 = new Customer_Address__c();
                addr1.Address__c = 'Test Address' +i;
                addr1.State__c = 'Test State' +i;
                addr1.City__c = 'Test City' +i;
                addr1.Country__c = 'Test Country'+i;
                addr1.PostalCode__c = '12345';
                addr1.Corp__c = '111111';
                addr1.Node__c = '1111';
                addr1.Route_Code__c = '1111111111';
                addr1.Region__c = 'Freedom Market';
                addr1.Division=freedomRegion.Id;
                addrList.add(addr1);
            }
            insert addrList; 
            system.debug(addrList);
            // Assign Addresses to plan 
            addrList[0].Node__c = '12345';
            addrList[1].Node__c = '12345';
            addrList[2].Plan__c = pln.Id;
            addrList[3].Plan__c = pln.Id;
            addrList[4].Plan__c = pln.Id;
            update addrList;
            
            // Apply Exclusion to Plan
            pln.Exclusion__c = excl.Id;         
            extnObj1.Save();
            
            // Validate the excluded addresses
            Double excludedCount = [Select Number_of_Excluded_Addresses__c from Plan__c where Id=:pln.Id].Number_of_Excluded_Addresses__c;
            System.assert(excludedCount == 0);
            
            pln.User__c = user.Id;
            extnObj1.Save();
            
            //Create a new plan and associate addresses
            Plan__c pln1 = new Plan__c();
            pln1.Name = 'TestPlan1';
            pln1.Plan_Level__c = 'Turf';   
            pln1.Expiration_Date__c = system.Today() + 30;
            ApexPages.StandardController controller2 = new ApexPages.StandardController(pln1);
            PlanEditExtn extnObj2 = new PlanEditExtn(controller2);
            extnObj2.quickSave();
            pln1.User__c = user.Id;
            extnObj2.Save();
            addrList[3].Plan__c = pln1.Id;
            addrList[4].Plan__c = pln1.Id;
            update addrList;
            
            // Create 5 Customer Addresses
            List<Customer_Address__c> addrList1 = new List<Customer_Address__c>();
            Customer_Address__c addr;
            for(integer i=0; i<5; i++){
                addr = new Customer_Address__c();
                addr.Address__c = 'Test Address' +i;
                addr.State__c = 'Test State' +i;
                addr.City__c = 'Test City' +i;
                addr.Country__c = 'Test Country'+i;
                addr.PostalCode__c = '12345';
                addr.Corp__c = '111111';
                addr.Node__c = '1111';
                addr.Route_Code__c = '1111111111';
                addr.Region__c = NULL;
//                addr.Status__C = 'Former';
                addr.Disconnected__c = TRUE;
                addrList1.add(addr);
            }
            // Cover the scenarios for creating Complex Office & reparenting on change of Property Code         
            addrList1[0].Complex_Office__c = true;
            addrList1[0].Property_Code__c ='123456';
            addrList1[1].Complex_Office__c = true;
            addrList1[1].Property_Code__c ='123457';
            insert addrList1;
            
            addrList[0].Parent_Address__c = addrList1[0].Id;
            addrList[0].Property_Code__c ='123456';
            addrList[1].Parent_Address__c = addrList1[0].Id;
            addrList[1].Property_Code__c ='123456';
            addrList[2].Parent_Address__c = addrList1[0].Id;
            addrList[2].Property_Code__c ='123456';
            update addrList;
            
            addrList1[0].Number_of_Units__c = 3;
            update addrList1;
            addrList[0].Property_Code__c ='123457';
            addrList[0].Most_Recent_Disposition__c = 'Contact';
            addrList[1].Property_Code__c ='123457';
            addrList[1].Most_Recent_Disposition__c = 'Contact';
            update addrList;
            Double noOfUnits1 = [Select Number_of_Units__c from Customer_Address__c where Id =:addrList1[0].Id].Number_of_Units__c;
            System.assert(noOfUnits1 == 3);
        }
        Test.stopTest();
    }

    private static testMethod void testAddressTriggerController1()
    { 
        List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
        TriggerSettings__c planTrigger = new TriggerSettings__c();
        planTrigger.Name = 'PlanTrigger';
        planTrigger.isActive__c = True;
        triggerSettingsList.add(planTrigger);

        TriggerSettings__c addressTrigger = new TriggerSettings__c();
        addressTrigger.Name = 'AddressTrigger';
        addressTrigger.isActive__c = True;
        triggerSettingsList.add(addressTrigger);

        TriggerSettings__c addressStatisticsTrigger = new TriggerSettings__c();
        addressStatisticsTrigger.Name = 'AddressStatisticsTrigger';
        addressStatisticsTrigger.isActive__c = True;
        triggerSettingsList.add(addressStatisticsTrigger);
           
        TriggerSettings__c userTrigger = new TriggerSettings__c();
        userTrigger.Name = 'UserTrigger';
        userTrigger.isActive__c = True;
        triggerSettingsList.add(userTrigger);
        
        TriggerSettings__c address1 = new TriggerSettings__c();
        address1.Name = 'BypassAddressTerritory';
        address1.isActive__c = True;
        triggerSettingsList.add(address1);
                       
        insert triggerSettingsList;
        VariableSettingTestUtility.variableSettingsData();
        User supervisorUser;
        User managerUser;
        User businessAdminUser;
        Profile p2 = [Select UserType, UserLicenseId, Name From Profile where Name like 'Sales Development Manager'];
        Profile p3 = [Select UserType, UserLicenseId, Name From Profile where Name like 'Area Sales Manager'];
        Profile p4 = [Select UserType, UserLicenseId, Name From Profile where Name like 'Business Administrator'];
        UserRole r2 = [Select Id, Name from UserRole where Name='DS Supervisor'];
        UserRole r3 = [Select Id, Name from UserRole where Name='DS Manager'];
        UserRole r4 = [Select Id, Name from UserRole where Name='National Manager'];
        String randomstr2 = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
        String randomstr3 = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
        String randomstr4 = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
        
        User user = [Select Id from User where Id=:UserInfo.getUserId()];
        System.runAs(user)
        {
          businessAdminUser = new User(Alias = 'DA_' + randomstr4.substring(0,4),
                                    Email = randomstr4 + 'userTest@SampleclassTest.com',
                                    LastName='Testing',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p4.Id,
                                    UserRoleId = r4.Id,
                                    Username = 'userTest' + randomstr4 + '@SampleclassTest.com',
                                    Region__c = 'Freedom',
                                    FederationIdentifier = 'FedId1',
                                    EmployeeNumber = 'Emp' + randomstr4.substring(0,4));
        insert businessAdminUser;
       }
        
         System.runAs(businessAdminUser)
        {
         managerUser = new User(Alias = 'DA_' + randomstr3.substring(0,4),
                                    Email = randomstr3 + 'userTest@SampleclassTest.com',
                                    LastName='Testing',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p3.Id,
                                    UserRoleId = r3.Id,
                                    PERNR__c = '23423456',
                                    Username = 'userTest' + randomstr3 + '@SampleclassTest.com',
                                    Region__c = 'Freedom',
                                    ManagerId = businessAdminUser.Id,
                                    FederationIdentifier = 'FedId2',
                                    EmployeeNumber = 'Emp' + randomstr3.substring(0,4));
        insert managerUser;
        }
        
         System.runAs(managerUser )
        {
         supervisorUser = new User(Alias = 'DA_' + randomstr2.substring(0,4),
                                    Email = randomstr2 + 'userTest@SampleclassTest.com',
                                    LastName='Testing',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p2.Id,
                                    UserRoleId = r2.Id,
                                    PERNR__c = '43243265',
                                    Username = 'userTest' + randomstr2 + '@SampleclassTest.com',
                                    Region__c = 'Freedom',
                                    ManagerId = managerUser.Id,
                                    FederationIdentifier = 'FedId3',
                                    EmployeeNumber = 'Emp' + randomstr3.substring(0,4));
        insert supervisorUser;  
        }
        
      //  Exclusion__c excl = SetupTestData.createExclusionRecord();
      Exclusion__c excl;
      //  System.runAs(supervisorUser) {
            excl = new Exclusion__c();
            excl.Name = 'Test Exclusion';
            excl.Expiration_Date__c = System.Today() + 30;
            excl.Division__c = 'NorthEast';
            excl.Region__c = 'Freedom';
            excl.Nodes__c = '12345';
            insert excl;
      //  }
       
    
       // Division freedomRegion = [select id, name from Division where name ='Freedom Market'];

        Test.startTest();

      //  System.runAs(supervisorUser){
            Customer_Address__c addr1;
            Plan__c pln = new Plan__c();
            pln.Name = 'TestPlan';
            pln.Plan_Level__c = 'Turf';   
            pln.Expiration_Date__c = system.Today() + 30;
            insert pln;
            ApexPages.StandardController controller1 = new ApexPages.StandardController(pln);
            PlanEditExtn extnObj1 = new PlanEditExtn(controller1);
            extnObj1.quickSave();  
            List<Customer_Address__c> addrList = new List<Customer_Address__c>();
            // Create 2 Customer Address Data
            for(integer i=0; i<2; i++){
                addr1 = new Customer_Address__c();
                addr1.Address__c = 'Test Address' +i;
                addr1.State__c = 'Test State' +i;
                addr1.City__c = 'Test City' +i;
                addr1.Country__c = 'Test Country'+i;
                addr1.PostalCode__c = '12345';
                addr1.Corp__c = '111111';
                addr1.Node__c = '1111';
                addr1.Route_Code__c = '1111111111';
                addr1.Region__c = 'Freedom Market';
              //  addr1.Division=freedomRegion.Id;
                addrList.add(addr1);
            }
            insert addrList; 
            
            // Assign Addresses to plan 
            addrList[0].Node__c = '12345';
          //  addrList[0].Division=freedomRegion.Id;
            addrList[1].Node__c = '12345';
           // addrList[1].Division=freedomRegion.Id;
            addrList[0].Plan__c = pln.Id;
            addrList[1].Plan__c = pln.Id;
            update addrList;
            Plan__c pln1 = new Plan__c();           
            pln1.Name = 'TestPlan1';
            pln1.Plan_Level__c = 'Turf';   
            pln1.Expiration_Date__c = system.Today() + 30;
            insert pln1;
            ApexPages.StandardController controller2 = new ApexPages.StandardController(pln1);
            PlanEditExtn extnObj2 = new PlanEditExtn(controller2);
            extnObj2.quickSave();
            pln1.User__c = supervisorUser.Id;
            extnObj2.Save();
            addrList[1].Plan__c = pln1.Id;
            update addrList;
       // }
        Test.stopTest();
        
        
    }
    private static testMethod void testAddressTriggerController2(){
       // SetupTestData.createCustomSettingRecords();
       // SetupTestData.createUsers();
        List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
        TriggerSettings__c planTrigger = new TriggerSettings__c();
        planTrigger.Name = 'PlanTrigger';
        planTrigger.isActive__c = True;
        triggerSettingsList.add(planTrigger);

        TriggerSettings__c addressTrigger = new TriggerSettings__c();
        addressTrigger.Name = 'AddressTrigger';
        addressTrigger.isActive__c = True;
        triggerSettingsList.add(addressTrigger);

        TriggerSettings__c addressStatisticsTrigger = new TriggerSettings__c();
        addressStatisticsTrigger.Name = 'AddressStatisticsTrigger';
        addressStatisticsTrigger.isActive__c = True;
        triggerSettingsList.add(addressStatisticsTrigger);
           
        TriggerSettings__c userTrigger = new TriggerSettings__c();
        userTrigger.Name = 'UserTrigger';
        userTrigger.isActive__c = True;
        triggerSettingsList.add(userTrigger);
        
        TriggerSettings__c address1 = new TriggerSettings__c();
        address1.Name = 'BypassAddressTerritory';
        address1.isActive__c = True;
        triggerSettingsList.add(address1);
        
        insert triggerSettingsList;
        VariableSettingTestUtility.variableSettingsData();
        User supervisorUser;
        User managerUser;
        User businessAdminUser;
        Profile p2 = [Select UserType, UserLicenseId, Name From Profile where Name like 'Sales Development Manager'];
        Profile p3 = [Select UserType, UserLicenseId, Name From Profile where Name like 'Area Sales Manager'];
        Profile p4 = [Select UserType, UserLicenseId, Name From Profile where Name like 'Business Administrator'];
        UserRole r2 = [Select Id, Name from UserRole where Name='DS Supervisor'];
        UserRole r3 = [Select Id, Name from UserRole where Name='DS Manager'];
        UserRole r4 = [Select Id, Name from UserRole where Name='National Manager'];
        String randomstr2 = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
        String randomstr3 = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
        String randomstr4 = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
        
        User user = [Select Id from User where Id=:UserInfo.getUserId()];
        System.runAs(user)
        {
          businessAdminUser = new User(Alias = 'DA_' + randomstr4.substring(0,4),
                                    Email = randomstr4 + 'userTest@SampleclassTest.com',
                                    LastName='Testing',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p4.Id,
                                    UserRoleId = r4.Id,
                                    Username = 'userTest' + randomstr4 + '@SampleclassTest.com',
                                    Region__c = 'Freedom',
                                    FederationIdentifier = 'FedId1',
                                    EmployeeNumber = 'Emp' + randomstr4.substring(0,4));
        insert businessAdminUser;
       }
        
         System.runAs(businessAdminUser)
        {
         managerUser = new User(Alias = 'DA_' + randomstr3.substring(0,4),
                                    Email = randomstr3 + 'userTest@SampleclassTest.com',
                                    LastName='Testing',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p3.Id,
                                    UserRoleId = r3.Id,
                                    PERNR__c = '34534567',
                                    Username = 'userTest' + randomstr3 + '@SampleclassTest.com',
                                    Region__c = 'Freedom',
                                    ManagerId = businessAdminUser.Id,
                                    FederationIdentifier = 'FedId2',
                                    EmployeeNumber = 'Emp' + randomstr3.substring(0,4));
        insert managerUser;
        }
        
         System.runAs(managerUser )
        {
         supervisorUser = new User(Alias = 'DA_' + randomstr2.substring(0,4),
                                    Email = randomstr2 + 'userTest@SampleclassTest.com',
                                    LastName='Testing',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p2.Id,
                                    UserRoleId = r2.Id,
                                    PERNR__c = '54354367',
                                    Username = 'userTest' + randomstr2 + '@SampleclassTest.com',
                                    Region__c = 'Freedom',
                                    ManagerId = managerUser.Id,
                                    FederationIdentifier = 'FedId3',
                                    EmployeeNumber = 'Emp' + randomstr3.substring(0,4));
        insert supervisorUser;  
        }
        //Exclusion__c excl = SetupTestData.createExclusionRecord();
         Exclusion__c excl;
      //  System.runAs(supervisorUser) {
            excl = new Exclusion__c();
            excl.Name = 'Test Exclusion';
            excl.Expiration_Date__c = System.Today() + 30;
            excl.Division__c = 'NorthEast';
            excl.Region__c = 'Freedom';
            excl.Nodes__c = '12345';
            insert excl;
      //  }
        Test.startTest();

        System.runAs(supervisorUser){
            Plan__c pln = new Plan__c();
            pln.Name = 'TestPlan';
            pln.Plan_Level__c = 'Turf';   
            pln.Expiration_Date__c = system.Today() + 30;
            insert pln;
            ApexPages.StandardController controller1 = new ApexPages.StandardController(pln);
            PlanEditExtn extnObj1 = new PlanEditExtn(controller1);
            extnObj1.quickSave(); 
            List<Customer_Address__c> addrList1 = new List<Customer_Address__c>();
            Customer_Address__c addr;
            for(integer i=0; i<5; i++){
                addr = new Customer_Address__c();
                addr.Address__c = 'Test Address' +i;
                addr.State__c = 'Test State' +i;
                addr.City__c = 'Test City' +i;
                addr.Country__c = 'Test Country'+i;
                addr.PostalCode__c = '12345';
                addr.Corp__c = '111111';
                addr.Node__c = '1111';
                addr.Route_Code__c = '1111111111';
                addr.Region__c = NULL;
               // addr.Status__C = 'Former';
                addr.Disconnected__c = TRUE;
                addrList1.add(addr);
            }
            insert addrList1;
        }
        Test.stopTest();
    }
    
      private static testMethod void testAddressTriggerController3(){   
        List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
        TriggerSettings__c planTrigger = new TriggerSettings__c();
        planTrigger.Name = 'PlanTrigger';
        planTrigger.isActive__c = True;
        triggerSettingsList.add(planTrigger);

        TriggerSettings__c addressTrigger = new TriggerSettings__c();
        addressTrigger.Name = 'AddressTrigger';
        addressTrigger.isActive__c = True;
        triggerSettingsList.add(addressTrigger);

        TriggerSettings__c addressStatisticsTrigger = new TriggerSettings__c();
        addressStatisticsTrigger.Name = 'AddressStatisticsTrigger';
        addressStatisticsTrigger.isActive__c = True;
        triggerSettingsList.add(addressStatisticsTrigger);
           
        TriggerSettings__c userTrigger = new TriggerSettings__c();
        userTrigger.Name = 'UserTrigger';
        userTrigger.isActive__c = True;
        triggerSettingsList.add(userTrigger);
        
        TriggerSettings__c address1 = new TriggerSettings__c();
        address1.Name = 'BypassAddressTerritory';
        address1.isActive__c = True;
        triggerSettingsList.add(address1);
        
        
        insert triggerSettingsList;   
        VariableSettingTestUtility.variableSettingsData();
        User supervisorUser;
        User managerUser;
        User businessAdminUser;
        Profile p2 = [Select UserType, UserLicenseId, Name From Profile where Name like 'Contractor Sales Professional'];
        Profile p3 = [Select UserType, UserLicenseId, Name From Profile where Name like 'Contractor Sales Leader'];
        Profile p4 = [Select UserType, UserLicenseId, Name From Profile where Name like 'Regional System Admin (RSA)'];
        UserRole r2 = [Select Id, Name from UserRole where Name='Contractor - PMA'];
        UserRole r3 = [Select Id, Name from UserRole where Name='Contractor'];
        UserRole r4 = [Select Id, Name from UserRole where Name='Regional Manager'];
        String randomstr2 = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
        String randomstr3 = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
        String randomstr4 = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
        
        User user = [Select Id from User where Id=:UserInfo.getUserId()];
        System.runAs(user)
        {
          businessAdminUser = new User(Alias = 'DA_' + randomstr4.substring(0,4),
                                    Email = randomstr4 + 'userTest@SampleclassTest.com',
                                    LastName='Testing',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p4.Id,
                                    UserRoleId = r4.Id,
                                    Username = 'userTest' + randomstr4 + '@SampleclassTest.com',
                                    Region__c = 'Freedom',
                                    FederationIdentifier = 'FedId1',
                                    EmployeeNumber = 'Emp' + randomstr4.substring(0,4));
        insert businessAdminUser;
       }
        
         System.runAs(businessAdminUser)
        {
         managerUser = new User(Alias = 'DA_' + randomstr3.substring(0,4),
                                    Email = randomstr3 + 'userTest@SampleclassTest.com',
                                    LastName='Testing',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p3.Id,
                                    UserRoleId = r3.Id,
                                    PERNR__c = '45645678',
                                    Username = 'userTest' + randomstr3 + '@SampleclassTest.com',
                                    Region__c = 'Freedom',
                                    ManagerId = businessAdminUser.Id,
                                    FederationIdentifier = 'FedId2',
                                    EmployeeNumber = 'Emp' + randomstr3.substring(0,4));
        insert managerUser;
        }
        
         System.runAs(managerUser )
        {
         supervisorUser = new User(Alias = 'DA_' + randomstr2.substring(0,4),
                                    Email = randomstr2 + 'userTest@SampleclassTest.com',
                                    LastName='Testing',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p2.Id,
                                    UserRoleId = r2.Id,
                                    PERNR__c = '45645687',
                                    Username = 'userTest' + randomstr2 + '@SampleclassTest.com',
                                    Region__c = 'Freedom',
                                    ManagerId = managerUser.Id,
                                    FederationIdentifier = 'FedId3',
                                    EmployeeNumber = 'Emp' + randomstr3.substring(0,4));
        insert supervisorUser;  
        }
        Test.startTest();

           Map<Id,Customer_Address__c> oldMap = new Map<Id,Customer_Address__c>();
           Id RecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Knock').getRecordTypeId();
           List<Task> knockList = new List<Task>(); 
      //  System.runAs(supervisorUser){
            Customer_Address__c addr;
            Plan__c pln = new Plan__c();
            pln.Name = 'TestPlan';
            pln.Plan_Level__c = 'Turf';   
            pln.Expiration_Date__c = system.Today() + 30;
            insert pln;
            ApexPages.StandardController controller1 = new ApexPages.StandardController(pln);
            PlanEditExtn extnObj1 = new PlanEditExtn(controller1);
            extnObj1.quickSave();  
                List<Customer_Address__c> addressList = new List<Customer_Address__c>();    
           
                addr = new Customer_Address__c();
                addr.Name = 'Old Test Address';
                addr.State__c = 'Test State';
                addr.City__c = 'Test City';
                addr.Country__c = 'Test Country';
                addr.PostalCode__c = '12345';
                addr.Corp__c = '111111';
                addr.Node__c = '1111';
                addr.Region__c = 'Freedom market';
                addr.Plan__c = pln.Id;
                insert addr;
                oldMap.put(addr.Id,addr);
                
                addressList.add(addr);

                Customer_Address__c addr2 = new Customer_Address__c();
                addr2.Name = 'New Test Address2';
                addr2.State__c = 'Test State';
                addr2.City__c = 'Test City';
                addr2.Country__c = 'Test Country';
                addr2.PostalCode__c = '12345';
                addr2.Corp__c = '111111';
                addr2.Parent_Address__c = null;
                addr2.Node__c = '1ab1';
                addr2.Property_Code__c = '12345';
                addr2.Is_new__c = true;
                addr2.Region__c = 'Freedom market';
                addr2.plan__c = pln.Id;
                addr2.ownerid = supervisorUser.Id;
                
                addressList.add(addr2);
                insert addr2;
                oldMap.put(addr2.Id,addr2);
                
                Database.insert(addressList,false);
             
                addr2.Most_Recent_Disposition__c = 'Start';
                update addr2;               
                update addressList;
                update pln;
                
                                            
                //AddressTriggerController.updateTotalWorkedAddrOnPlan(addressList,oldMap);
                
        
        
          Customer_Address__Share cusAddShare =  new Customer_Address__Share();
          Group g = [SELECT Id, RelatedId,Type FROM Group WHERE Type = 'manager' AND RelatedId = :supervisorUser.ID ];
          Map<Id, Id> groupMap = new Map<Id, Id>();       
          groupMap.put(g.RelatedId, g.Id);
          
           For(Customer_Address__c address : addressList){
            if(!groupMap.isEmpty()){
            cusAddShare.ParentId = addr2.Id;
            cusAddShare.UserOrGroupId = groupMap.get(address.OwnerId);
            cusAddShare.AccessLevel = System.Label.EditAddressTriggerController;
              }
           } 
           insert cusAddShare;
          
          
           Map<Customer_Address__c, String> addressCodesMap = new Map<Customer_Address__c,String>();
                   
           for(Customer_Address__c addr3: addressList){
            if(addr3.Property_Code__c != null && addr3.Corp__c !=null && addr3.Region__c !=null)
                addressCodesMap.put(addr3,addr3.Property_Code__c+'_'+addr3.Corp__c+'_'+addr3.Region__c );
            }
           
            Test.stopTest();
    
}
private static testMethod void testAddressTriggerController4(){   
        
    Account objaccount;
        
       
       test.startTest();
            List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
        
        TriggerSettings__c addressTrigger = new TriggerSettings__c();
        addressTrigger.Name = 'AddressTrigger';
        addressTrigger.isActive__c = True;
        triggerSettingsList.add(addressTrigger);
        TriggerSettings__c planTrigger = new TriggerSettings__c();
        planTrigger.Name = 'PlanTrigger';
        planTrigger.isActive__c = false;
        triggerSettingsList.add(planTrigger); 
        TriggerSettings__c accountTrigger = new TriggerSettings__c();
        accountTrigger.Name = 'AccountTrigger';
        accountTrigger.isActive__c = True; 
        triggerSettingsList.add(accountTrigger); 
        TriggerSettings__c propertyTrigger = new TriggerSettings__c();
        propertyTrigger.Name = 'PropertyTrigger';
        propertyTrigger.isActive__c = false;
        triggerSettingsList.add(propertyTrigger);
        TriggerSettings__c propTrigger = new TriggerSettings__c();
        propTrigger.Name = 'PropertyInsertUpdateTrigger';
        propTrigger.isActive__c = false;
        triggerSettingsList.add(propTrigger);
        Database.insert(triggerSettingsList,false);
  
        VariableSettingTestUtility.variableSettingsData();
           Map<Id,Customer_Address__c> oldMap = new Map<Id,Customer_Address__c>();
           list<Account> lstaccount = new list<Account>();
            Customer_Address__c addr;
            Plan__c pln = new Plan__c();
            pln.Name = 'TestPlan';
            pln.Plan_Level__c = 'Turf';   
            pln.Expiration_Date__c = system.Today() + 30;
            pln.Parameters__c = 'Non-Marketable Addresses Excluded=true';
            insert pln;
            objaccount = new Account();
            objaccount.Name = 'test Account';
            objaccount.Customer_Status__c = 'Former';
            lstaccount.add(objaccount);
            objaccount = new Account();
            objaccount.Name = 'test Account2';
            objaccount.Customer_Status__c = 'Former';
            lstaccount.add(objaccount);
            
            insert lstaccount;
            
            MDU_Property__c prop = TestDataUtility.createProperty();
            prop.Property_Region__c = 'Big South Region';
            prop.House_Misc_Code__c = '1234';
            prop.Sys__c = '1111';
            prop.Prin__c = '1111';
            //prop.Address_Code__c = '1234_111111_Big South Region';
            Database.insert(prop);
            system.debug('prop.id>>>'+prop.id);
        
            List<Customer_Address__c> addressList = new List<Customer_Address__c>();    
            List<Customer_Address__c> uaddressList = new List<Customer_Address__c>();
                addr = new Customer_Address__c();
                addr.Name = 'Old Test Address';
                addr.State__c = 'Test State';
                addr.City__c = 'Test City';
                addr.Country__c = 'Test Country';
                addr.PostalCode__c = '12345';
                addr.Corp__c = '11111111';
                addr.Property_Code__c = '1234';
                addr.Node__c = '1111';
                addr.Region__c = 'Big South Region';
                addr.Plan__c = pln.Id;
                addr.Account__c = lstaccount[0].id;
                addr.Dwelling_Type__c = 'SFU';
                addr.Targeted__c =true;
                addr.Non_Marketable__c = true;
                addressList.add(addr);
                
                addr = new Customer_Address__c();
                addr.Name = 'Old Test Addressee';
                addr.State__c = 'Test State';
                addr.City__c = 'Test City';
                addr.Country__c = 'Test Country';
                addr.PostalCode__c = '12345';
                addr.Corp__c = '1111111';
                addr.Node__c = '1111';
                addr.Region__c = 'California Market';
                addr.Plan__c = pln.Id;
                addr.Account__c = lstaccount[1].id;
                addr.Dwelling_Type__c = 'SFU';
                addr.Targeted__c =true;
                addr.Non_Marketable__c = true;
                addressList.add(addr);
                
                
                insert addressList;
                lstaccount[0].Customer_Status__c = 'Active';
                lstaccount[1].Customer_Status__c = 'Active';
                update lstaccount;
                
                addressList[0].Most_Recent_Disposition__c = 'Contact';
                addressList[1].Most_Recent_Disposition__c = 'Contact';
                update addressList;
                addressList[0].Most_Recent_Disposition__c = 'Door Hanger';
                update addressList;
                
            Test.stopTest();
    
    }
    private static testMethod void testAddressTriggerControllerAddAddressToPlan(){   
        
        Account objaccount;
        
        
        test.startTest();
        List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
        
        TriggerSettings__c addressTrigger = new TriggerSettings__c();
        addressTrigger.Name = 'AddressTrigger';
        addressTrigger.isActive__c = True;
        triggerSettingsList.add(addressTrigger);
        TriggerSettings__c planTrigger = new TriggerSettings__c();
        planTrigger.Name = 'PlanTrigger';
        planTrigger.isActive__c = false;
        triggerSettingsList.add(planTrigger); 
        TriggerSettings__c accountTrigger = new TriggerSettings__c();
        accountTrigger.Name = 'AccountTrigger';
        accountTrigger.isActive__c = True; 
        triggerSettingsList.add(accountTrigger);       
        insert triggerSettingsList;   
        VariableSettingTestUtility.variableSettingsData();
        
        Territory__c territory = new Territory__c();
        territory.name = 'testTerritory';
        territory.Territory_Code__c = 'TEST01';
        insert territory;
        
        Map<Id,Customer_Address__c> oldMap = new Map<Id,Customer_Address__c>();
        list<Account> lstaccount = new list<Account>();
        Customer_Address__c addr;
        
        Profile p1 = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p1.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        
        Profile p2 = [SELECT Id FROM Profile WHERE Name='Xfinity CAR']; 
        User u2 = new User(Alias = 'standt2', Email='Xfinity@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p2.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='Xfinity@testorg.com');
        
        Team__c team = new Team__c();
        team.name = 'TestTeam';
        team.Region__c = [Select region__c from user where Id = : UserInfo.getUserId()].region__c;
        team.supervisor__c = UserInfo.getUserId();
        insert team;
        
        Plan__c pln = new Plan__c();
        pln.Parameters__c = '10550104021122332';
        pln.Name = 'TestPlan';
        pln.Plan_Level__c = 'Turf';   
        pln.Expiration_Date__c = system.Today() + 30;
        pln.User__c = u1.Id;
        pln.Assigned_To_CAR__c = u2.Id;
        pln.Assigned_Team__c = team.Id;
        pln.Plan_Status__c = 'Assigned';
        pln.Territory__c = territory.Id;
        pln.Census_Tracts__c = '10550104021,98765432101';
        insert pln;
        objaccount = new Account();
        objaccount.Name = 'test Account';
        objaccount.Customer_Status__c = 'Former';
        lstaccount.add(objaccount);
        objaccount = new Account();
        objaccount.Name = 'test Account2';
        objaccount.Customer_Status__c = 'Former';
        lstaccount.add(objaccount);
         Account account1 = new Account();
        account1.Name = 'Test HSI to Non-HSI';
        account1.Customer_Status__c = 'Active';
        account1.HSI_Active__c = true;
        account1.Voice_Active__c = false;
        account1.Region__c = 'Freedom Market';
        lstaccount.add(account1);
        insert lstaccount;
        
        List<Customer_Address__c> addressList = new List<Customer_Address__c>();    
        List<Customer_Address__c> uaddressList = new List<Customer_Address__c>();
        addr = new Customer_Address__c();
        addr.Name = 'Old Test Address';
        addr.State__c = 'Test State';
        addr.City__c = 'Test City';
        addr.Country__c = 'Test Country';
        addr.PostalCode__c = '12345';
        addr.Corp__c = '111111';
        addr.Node__c = '1111';
        addr.Region__c = 'Big South Region';
        addr.Plan__c = pln.Id;
        addr.Account__c = lstaccount[0].id;
        addr.Dwelling_Type__c = 'SFU';
        addr.Targeted__c =false;
        addr.Non_Marketable__c = true;
        addr.Census_Block__c = '10550104021122332';
        addr.Territory__c = territory.Id;
        
        
        
        CensusTract__c demo = new CensusTract__c();
        demo.CensusTractNumber__c = '12345678912';
        demo.name = 'testcensus';
        addr.CensusTract__c = demo.id;
        addressList.add(addr);
        
        addr = new Customer_Address__c();
        addr.Name = 'Old Test Addressee';
        addr.State__c = 'Test State';
        addr.City__c = 'Test City';
        addr.Country__c = 'Test Country';
        addr.PostalCode__c = '12345';
        addr.Corp__c = '111111';
        addr.Node__c = '1111';
        addr.Region__c = 'California Market';
        addr.Plan__c = pln.Id;
        addr.Account__c = lstaccount[1].id;
        addr.Dwelling_Type__c = 'SFU';
        addr.Targeted__c =false;
        addr.Non_Marketable__c = true;
        addr.Territory__c = territory.Id;
        addr.Census_Block__c = '10550104021122332';
        addressList.add(addr);
        
        Customer_Address__c addr3 = new Customer_Address__c();
        addr3.Name = 'Test Address Excluded From Territory';
        addr3.State__c = 'Test State';
        addr3.City__c = 'Test City';
        addr3.Country__c = 'Test Country';
        addr3.PostalCode__c = '12345';
        addr3.Corp__c = '111111';
        addr3.Node__c = '1111';
        addr3.Region__c = 'Freedom Market';
        addr3.Plan__c = pln.Id;
        addr3.Account__c = lstaccount[2].id;
        addr3.Dwelling_Type__c = 'SFU';
        addr3.Targeted__c =false;
        addr3.HSI_Only_Address__c = false;
        addr3.Census_Block__c = '10550104021122332';
        //addr3.Active_Inactive__c='Inactive';
        //addr2.Territory__c = territory.Id;
        addr3.Team__c = team.Id;
        addr3.Excluded_from_Territory__c = false;
        addressList.add (addr3);
        
        insert addressList;
        addressList[2].Territory__c = territory.Id;
         update addressList;
        lstaccount[0].Customer_Status__c = 'Active';
        lstaccount[1].Customer_Status__c = 'Active';
        //lstaccount[1].HSI_Active__c = true;
        update lstaccount;
        addressList[1].HSI_Only_Address__c = true;
        update addressList;
        
        Test.stopTest();
        
    }
    
    private static testMethod void testAddressTriggerControllerAddAddressToPlan1(){           
        Account objaccount;
        test.startTest();
        List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
        
        TriggerSettings__c addressTrigger = new TriggerSettings__c();
        addressTrigger.Name = 'AddressTrigger';
        addressTrigger.isActive__c = True;
        triggerSettingsList.add(addressTrigger);
        TriggerSettings__c planTrigger = new TriggerSettings__c();
        planTrigger.Name = 'PlanTrigger';
        planTrigger.isActive__c = false;
        triggerSettingsList.add(planTrigger); 
        TriggerSettings__c accountTrigger = new TriggerSettings__c();
        accountTrigger.Name = 'AccountTrigger';
        accountTrigger.isActive__c = True; 
        triggerSettingsList.add(accountTrigger);       
        insert triggerSettingsList;   
        VariableSettingTestUtility.variableSettingsData();
        
        List<Territory__c> territoryList = new List<Territory__c>();
        Territory__c territory = new Territory__c();
        territory.name = 'testTerritory';
        territory.Territory_Code__c = 'TEST01';
        territoryList.add(territory);
        
        Territory__c territory1 = new Territory__c();
        territory1.name = 'testTerritory1';
        territory1.Territory_Code__c = 'TEST02';
        territoryList.add(territory1);
        //insert territoryList;
        Territory__c territory2 = new Territory__c();
        territory2.name = 'testTerritory2';
        territory2.Territory_Code__c = 'TEST03';
        territoryList.add(territory2);
        insert territoryList;
        
        list<Account> lstaccount = new list<Account>();
        Customer_Address__c addr;
        
        Profile p1 = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p1.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        
        Team__c team = new Team__c();
        team.name = 'TestTeam';
        team.Region__c = [Select region__c from user where Id = : UserInfo.getUserId()].region__c;
        team.supervisor__c = UserInfo.getUserId();
        insert team;
        List<Plan__c> planList = new List<Plan__c>();
        Plan__c pln = new Plan__c();
        pln.Parameters__c = '10550104021122332';
        pln.Name = 'TestPlan';
        pln.Plan_Level__c = 'Turf';   
        pln.Expiration_Date__c = system.Today() + 30;
        pln.User__c = u1.Id;
        pln.Assigned_Team__c = team.Id;
        pln.Plan_Status__c = 'Assigned';
        pln.Territory__c = territory.Id;
        pln.Census_Tracts__c = '10550104021,98765432101';
        planList.add(pln);
        
        Plan__c pln01 = new Plan__c();
        pln01.Parameters__c = '10550104021122332';
        pln01.Name = 'TestPlan';
        pln01.Plan_Level__c = 'Turf';   
        pln01.Expiration_Date__c = system.Today() + 30;
        pln01.User__c = u1.Id;
        pln01.Assigned_Team__c = team.Id;
        pln01.Plan_Status__c = 'Assigned';
        pln01.Territory__c = territory.Id;
        pln01.Census_Tracts__c = '10550104021,98765432101';
        planList.add(pln01);
        insert planList;
        
        objaccount = new Account();
        objaccount.Name = 'test Account';
        objaccount.Customer_Status__c = 'Former';
        lstaccount.add(objaccount);
        objaccount = new Account();
        objaccount.Name = 'test Account2';
        objaccount.Customer_Status__c = 'Former';
        lstaccount.add(objaccount);
        insert lstaccount;
        
        List<CensusTract__c> censusList = new List<CensusTract__c>();
        CensusTract__c census = new CensusTract__c();
        census.CensusTractNumber__c = '10550104021';
        census.name = 'testcensus1';
        census.Territory__c = territory.Id;
        censusList.add(census);
        
        CensusTract__c census1 = new CensusTract__c();
        census1.CensusTractNumber__c = '10550104022';
        census1.name = 'testcensus2';
        census1.Territory__c = territory1.Id;
        censusList.add(census1);
        insert censusList;
        
        List<Customer_Address__c> addressList = new List<Customer_Address__c>();    
        List<Customer_Address__c> uaddressList = new List<Customer_Address__c>();
        addr = new Customer_Address__c();
        addr.Name = 'Test Address';
        addr.State__c = 'Test State';
        addr.City__c = 'Test City';
        addr.Country__c = 'Test Country';
        addr.PostalCode__c = '12345';
        addr.Corp__c = '111111';
        addr.Node__c = '1111';
        addr.Region__c = 'Big South Region';
        addr.Plan__c = pln.Id;
        addr.Account__c = lstaccount[0].id;
        addr.Dwelling_Type__c = 'SFU';
        addr.Targeted__c =false;
        addr.Non_Marketable__c = true;
        addr.Census_Block__c = '10550104021122332';
        addr.Territory__c = territory.Id;
        addr.CensusTract__c = census.id;
        addressList.add(addr);
        
        Customer_Address__c addr01;
        addr01 = new Customer_Address__c();
        addr01.Name = 'Test Address';
        addr01.State__c = 'Test State';
        addr01.City__c = 'Test City';
        addr01.Country__c = 'Test Country';
        addr01.PostalCode__c = '12345';
        addr01.Corp__c = '111111';
        addr01.Node__c = '1111';
        addr01.Region__c = 'Big South Region';
        addr01.Plan__c = pln01.Id;
        addr01.Account__c = lstaccount[0].id;
        addr01.Dwelling_Type__c = 'SFU';
        addr01.Targeted__c =false;
        addr01.Non_Marketable__c = true;
        addr01.Census_Block__c = '10550104021122332';
        addr01.Territory__c = territory.Id;
        addr01.CensusTract__c = census.id;
        addressList.add(addr01);
        insert addressList;

        list<Account> lstaccount1 = new list<Account>();
        Customer_Address__c addr1;

        Plan__c pln1 = new Plan__c();
        pln1.Parameters__c = '10550104022122332';
        pln1.Name = 'TestPlan';
        pln1.Plan_Level__c = 'Turf';   
        pln1.Expiration_Date__c = system.Today() + 30;
        pln1.User__c = u1.Id;
        pln1.Assigned_Team__c = team.Id;
        pln1.Plan_Status__c = 'Assigned';
        pln1.Territory__c = territory1.Id;
        pln1.Census_Tracts__c = '10550104022,98765432101';
        insert pln1;
        
        objaccount = new Account();
        objaccount.Name = 'test Account';
        objaccount.Customer_Status__c = 'Former';
        lstaccount1.add(objaccount);
        objaccount = new Account();
        objaccount.Name = 'test Account2';
        objaccount.Customer_Status__c = 'Former';
        lstaccount1.add(objaccount);
        Account acc = new Account();
        //acc = new Account();
        acc.Name = 'test Account3';
        acc.Customer_Status__c = 'Active';
        lstaccount1.add(acc);
        insert lstaccount1;
        
        List<Customer_Address__c> addressList1 = new List<Customer_Address__c>();    
        List<Customer_Address__c> uaddressList1 = new List<Customer_Address__c>();
        addr1 = new Customer_Address__c();
        addr1.Name = 'Test Address';
        addr1.State__c = 'Test State';
        addr1.City__c = 'Test City';
        addr1.Country__c = 'Test Country';
        addr1.PostalCode__c = '12345';
        addr1.Corp__c = '111111';
        addr1.Node__c = '1111';
        addr1.Region__c = 'Big South Region';
        addr1.Plan__c = pln1.Id;
        addr1.Account__c = lstaccount1[0].id;
        addr1.Dwelling_Type__c = 'SFU';
        addr1.Targeted__c =false;
        addr1.Non_Marketable__c = true;
        addr1.Census_Block__c = '10550104022122332';
        addr1.Territory__c = territory1.Id;
        addr1.CensusTract__c = census1.Id;
        addressList1.add(addr1);
        
        Customer_Address__c addr2;
        addr2 = new Customer_Address__c();
        addr2.Name = 'Test Address';
        addr2.State__c = 'Test State';
        addr2.City__c = 'Test City';
        addr2.Country__c = 'Test Country';
        addr2.PostalCode__c = '12345';
        addr2.Corp__c = '111111';
        addr2.Node__c = '1111';
        addr2.Region__c = 'Big South Region';
        addr2.Plan__c = pln1.Id;
        addr2.Account__c = lstaccount1[0].id;
        addr2.Dwelling_Type__c = 'SFU';
        addr2.Targeted__c =false;
        addr2.Non_Marketable__c = true;
        addr2.Census_Block__c = '10550104022122332';
        addr2.Territory__c = territory1.Id;
        addr2.CensusTract__c = census1.Id;
        addressList1.add(addr2);
        
        Customer_Address__c addr3;
        addr3 = new Customer_Address__c();
        addr3.Name = 'Test Address Excluded From Territory1';
        addr3.State__c = 'Test State';
        addr3.City__c = 'Test City';
        addr3.Country__c = 'Test Country';
        addr3.PostalCode__c = '12345';
        addr3.Corp__c = '111111';
        addr3.Node__c = '1111';
        addr3.Region__c = 'Freedom Market';
        addr3.Plan__c = pln1.Id;
        addr3.Account__c = lstaccount1[2].id;
        addr3.Dwelling_Type__c = 'SFU';
        addr3.Targeted__c =true;
        addr3.HSI_Only_Address__c = false;
        addr3.Census_Block__c = '10550104021122332';
        //addr3.Territory__c = territory1.Id;
        addr3.Team__c = team.Id;
        addr3.Excluded_from_Territory__c = false;
        addressList1.add (addr3);
        insert addressList1;
        
        addr1.Census_Block__c = '10550104021122332';
        addr1.Territory__c = territory.Id;
        addr1.CensusTract__c = census.id;
        uaddressList1.add(addr1);
        
        addr2.Census_Block__c = '10550104021122332';
        addr2.Territory__c = territory.Id;
        addr2.CensusTract__c = census.id;
        uaddressList1.add(addr2);
        
        addr3.Territory__c = territory2.id;
        uaddressList1.add(addr3);
        update uaddressList1;
        
        Test.stopTest(); 
    }
    
    private static testMethod void testAddressTriggerControllerRemoveAddressFromPlan(){
        
        List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
        List<User> userList = new List<User>();
        List<Account> accountList = new List<Account>();
        List<Customer_Address__c> addressList = new List<Customer_Address__c>();
        
        TriggerSettings__c addressTrigger = new TriggerSettings__c();
        addressTrigger.Name = 'AddressTrigger';
        addressTrigger.isActive__c = True;
        triggerSettingsList.add(addressTrigger);
        
        TriggerSettings__c planTrigger = new TriggerSettings__c();
        planTrigger.Name = 'PlanTrigger';
        planTrigger.isActive__c = false;
        triggerSettingsList.add(planTrigger); 
        
        TriggerSettings__c accountTrigger = new TriggerSettings__c();
        accountTrigger.Name = 'AccountTrigger';
        accountTrigger.isActive__c = True; 
        triggerSettingsList.add(accountTrigger); 
        
        TriggerSettings__c userTrigger = new TriggerSettings__c();
        userTrigger.Name = 'UserTrigger';
        userTrigger.isActive__c = True;
        triggerSettingsList.add(userTrigger);
        
        TriggerSettings__c teamMemberTrigger = new TriggerSettings__c();
        teamMemberTrigger.Name = 'TeamMemberTrigger';
        teamMemberTrigger.isActive__c = True;
        triggerSettingsList.add(teamMemberTrigger);
        
        insert triggerSettingsList; 
        
        VariableSettingTestUtility.variableSettingsData();
        
        User adminUser;
        User xsp1,xsp2,xsp3;
        Territory__c territory;
               
        Profile p1 = [SELECT Id FROM Profile WHERE Name='System Administrator' Limit 1]; 
        UserRole r1 = [Select Id, Name from UserRole where Name='Comcast: Residential'];
        Profile p2 = [SELECT Id FROM Profile WHERE Name='XFINITY Sales Professional' Limit 1]; 
        UserRole r2 = [Select Id, Name from UserRole where Name='DSR'];
        String randomstr1 = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
        String randomstr2 = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
        String randomstr3 = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
        String randomstr4 = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
        
        User user = [Select Id from User where Id=:UserInfo.getUserId()];
        
        System.runAs(user){
        adminUser = new User(Alias = 'SA_' + randomstr1.substring(0,4), 
                                Email= randomstr1 + 'sysAdminUser@testorg.com', 
                                EmailEncodingKey='UTF-8', 
                                LastName='Testing', 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                ProfileId = p1.Id, 
                                UserRoleId = r1.Id,
                                TimeZoneSidKey='America/Los_Angeles', 
                                UserName='sysAdmin' + randomstr1 + '@SampleclassTest.com',
                                Region__c = 'Freedom Market',
                                PERNR__c = '12345678',
                                FederationIdentifier = 'FedIdTest1',
                                EmployeeNumber = 'Emp' + randomstr1.substring(0,4));
                                
        userList.add (adminUser);
        
        xsp1 = new User(Alias = 'XSP1' + randomstr2.substring(0,4), 
                                Email= randomstr2 + 'xsp1User@testorg.com', 
                                EmailEncodingKey='UTF-8', 
                                LastName='Testing', 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                ProfileId = p2.Id, 
                                UserRoleId = r2.Id,
                                TimeZoneSidKey='America/Los_Angeles', 
                                UserName='xsp1' + randomstr2 + '@SampleclassTest.com',
                                Region__c = 'Freedom Market',
                                PERNR__c = '12345679',
                                FederationIdentifier = 'FedIdTest2',
                                EmployeeNumber = 'Emp' + randomstr2.substring(0,4));                        
            
        userList.add (xsp1);
        
        xsp2 = new User(Alias = 'XSP2' + randomstr3.substring(0,4), 
                                Email= randomstr3 + 'xsp2User@testorg.com', 
                                EmailEncodingKey='UTF-8', 
                                LastName='Testing', 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                ProfileId = p2.Id, 
                                UserRoleId = r2.Id,
                                TimeZoneSidKey='America/Los_Angeles', 
                                UserName='xsp2' + randomstr3 + '@SampleclassTest.com',
                                Region__c = 'Freedom Market',
                                PERNR__c = '12345671',
                                FederationIdentifier = 'FedIdTest3',
                                EmployeeNumber = 'Emp' + randomstr3.substring(0,4));                        
            
        userList.add (xsp2);
        
        xsp3 = new User(Alias = 'XSP3' + randomstr4.substring(0,4), 
                                Email= randomstr4 + 'xsp3User@testorg.com', 
                                EmailEncodingKey='UTF-8', 
                                LastName='Testing', 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                ProfileId = p2.Id, 
                                UserRoleId = r2.Id,
                                TimeZoneSidKey='America/Los_Angeles', 
                                UserName='xsp3' + randomstr1 + '@SampleclassTest.com',
                                Region__c = 'Freedom Market',
                                PERNR__c = '12345670',
                                FederationIdentifier = 'FedIdTest4',
                                EmployeeNumber = 'Emp' + randomstr4.substring(0,4));                        
            
        userList.add (xsp3);
        
        insert userList;
        
        territory = new Territory__c();
        territory.name = 'testTerritory';
        territory.Territory_Code__c = 'TEST01';
        insert territory;
        }
        
        System.runAs(adminUser){
        
        Team__c team = new Team__c();
        team.name = 'TestTeam';
        team.Region__c = 'Freedom Market';
        team.supervisor__c = xsp1.Id;
        insert team;
        
        //List<Team_Member__c> teamMemList = new List<Team_Member__c>();
        
        //Team_Member__c teamMem1 = new Team_Member__c (User_Name__c = xsp1.Id , Team__c = team.Id);
        //insert teamMem1;
        Team_Member__c teamMem2 = new Team_Member__c (User_Name__c = xsp2.Id , Team__c = team.Id);
        insert teamMem2;
        //Team_Member__c teamMem3 = new Team_Member__c (User_Name__c = xsp3.Id , Team__c = team.Id);
        //insert teamMem3;
        //insert teamMemList;
    
        test.startTest();
        Plan__c pln = new Plan__c();
        pln.Parameters__c = '10550104021122332';
        pln.Name = 'AddressRemovalPlanTest';
        pln.Plan_Level__c = 'Turf';   
        pln.Expiration_Date__c = system.Today() + 30;
        //pln.User__c = xsp1.Id;
        pln.Assigned_Team__c = team.Id;
        pln.Plan_Status__c = 'Assigned';
        pln.Territory__c = territory.Id;
        pln.Census_Tracts__c = '10550104021,98765432101';
        insert pln;
        

        Account account1 = new Account();
        account1.Name = 'Test HSI to Non-HSI';
        account1.Customer_Status__c = 'Active';
        account1.HSI_Active__c = true;
        account1.Voice_Active__c = false;
        account1.Region__c = 'Freedom Market';
        accountList.add(account1);
        
        Account account2 = new Account();
        account2.Name = 'Test Exclude From Territory';
        account2.Customer_Status__c = 'Former';
        account2.Region__c = 'Freedom Market';
        account2.HSI_Active__c = true;
        account2.Voice_Active__c = true;
        accountList.add(account2);
        
        insert accountList;
        
            
        Customer_Address__c addr1 = new Customer_Address__c();
        Customer_Address__c addr2 = new Customer_Address__c();
        Customer_Address__c addr3 = new Customer_Address__c();
        
        addr1.Name = 'Test Address HSI to Non-HSI';
        addr1.State__c = 'Test State';
        addr1.City__c = 'Test City';
        addr1.Country__c = 'Test Country';
        addr1.PostalCode__c = '12345';
        addr1.Corp__c = '111111';
        addr1.Node__c = '1111';
        addr1.Region__c = 'Freedom Market';
        addr1.Plan__c = pln.Id;
        addr1.Account__c = accountList[0].id;
        addr1.Dwelling_Type__c = 'SFU';
        addr1.Targeted__c =false;
        addr1.HSI_Only_Address__c = true;
        addr1.Census_Block__c = '10550104021122332';
        addr1.Territory__c = territory.Id;
        addr1.Team__c = team.Id;
        addr1.Excluded_from_Territory__c = false;
        addressList.add (addr1);
        
        addr2.Name = 'Test Address Excluded From Territory';
        addr2.State__c = 'Test State';
        addr2.City__c = 'Test City';
        addr2.Country__c = 'Test Country';
        addr2.PostalCode__c = '12345';
        addr2.Corp__c = '111111';
        addr2.Node__c = '1111';
        addr2.Region__c = 'Freedom Market';
        addr2.Plan__c = pln.Id;
        addr2.Account__c = accountList[1].id;
        addr2.Dwelling_Type__c = 'SFU';
        addr2.Targeted__c =true;
        addr2.HSI_Only_Address__c = false;
        addr2.Census_Block__c = '10550104021122332';
        addr2.Territory__c = territory.Id;
        addr2.Team__c = team.Id;
        addr2.Excluded_from_Territory__c = false;
        addressList.add (addr2);
        
        addr3.Name = 'Test Address Excluded From Territory';
        addr3.State__c = 'Test State';
        addr3.City__c = 'Test City';
        addr3.Country__c = 'Test Country';
        addr3.PostalCode__c = '12345';
        addr3.Corp__c = '111111';
        addr3.Node__c = '1111';
        addr3.Region__c = 'Freedom Market';
        addr3.Plan__c = pln.Id;
        addr3.Account__c = accountList[1].id;
        addr3.Dwelling_Type__c = 'SFU';
        addr3.Targeted__c =false;
        addr3.HSI_Only_Address__c = false;
        addr3.Census_Block__c = '10550104021122332';
        //addr3.Active_Inactive__c='Inactive';
        //addr2.Territory__c = territory.Id;
        addr3.Team__c = team.Id;
        addr3.Excluded_from_Territory__c = false;
        addressList.add (addr3);
        insert addressList;
        
        accountList[0].Voice_Active__c = true;
        update accountList;
        addressList[2].Territory__c = territory.Id;
        update addressList;
        addressList[1].Excluded_from_Territory__c = true;
        update addressList;
    }    
        Test.stopTest();
   }
}