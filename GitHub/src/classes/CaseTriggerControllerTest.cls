@isTest
/***********************************************************
* Class Name: CaseTriggerControllerTest
* Author: Amitkumar Bangad, Accenture
* Date: 27-January-2013  
* * Description: This class does the test coverage
*              for CaseTriggerController class.
***********************************************************/
private class CaseTriggerControllerTest{
    static Group affiliateGroup;
    static Contact partContact;
    static Account partAcc;
    static User adminUser;
    static User EscalationUser;
    static Order__c Custorder;
    
    
    /* This method is creates data for code coverage*/
    private static void setupData(){
        SetupTestData.createCustomSettingRecords();
        
        //Create Account of Type Partner
        partAcc = new Account();
        partAcc.Name = 'Test Partner Account';
        partAcc.Type = 'Partner';
        partAcc.ClaimEligibilityDuration__c = 240;
        partAcc.ClaimWaitDuration__c = 60;
        insert partAcc; 
        
        //Create Account of Type Customer
        Account custAcc = new Account();
        custAcc.Name = 'Test Customer Account';
        custAcc.Type = 'Customer';
        insert custAcc;
        
        //Enable the account as partner
        partAcc.IsPartner = true;
        update partAcc;
        
        // Create a contact under the partner account
        partContact = new Contact();
        partContact.AccountId = partAcc.Id;
        partContact.lastName = 'Test Contact';
        insert partContact;
        
        // fetch the admin profile
        Profile p1 = [Select UserType, UserLicenseId, Name From Profile where Name =:'System Administrator' limit 1];
        
        //generate Random String 
        UserRole role=[Select Id From UserRole WHERE Name='Comcast: Residential'];
        String randomstr1 = Math.round(Math.random()*Math.pow(10, 7))+'';
        User currentUser=[Select Id From User WHERE Id=:UserInfo.getUserId()];
        system.runAs(currentUser){
        adminUser = new User(Alias = 'DA_' + randomstr1.substring(0,4),
                                    Email = randomstr1 + 'userTest@SampleclassTest.com',
                                    LastName='Testing',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p1.Id,
                                    Username = 'userTest' + randomstr1 + '@SampleclassTest.com',
                                    UserRoleId=role.Id,
                                    EmployeeNumber = 'Emp' + randomstr1.substring(0,4),
                                    Region__c = 'Global',
                                    FederationIdentifier = 'userTest@SampleclassTest.com');
        insert adminUser;
      }
        
        // Insert Group 
        affiliateGroup = new Group (name = 'Test Partner Account Group');
        insert affiliateGroup;
    }
    /* This method used for test coverage of scenarios of CaseTriggerController class*/

    private static testMethod void CaseTriggerControllerTest() {
        
        setupData();
        Test.startTest();
            case claim = new Case();
            claim.Case_Name__c = 'test case';
            claim.ContactId = partContact.Id;
            claim.Affiliate_Account__c = partAcc.Id;
            claim.Status = 'New';
          claim.Region__c='Corporate';
            claim.Claimed_Amount__c = 300; 
            insert claim;
            
            claim.OwnerId = adminUser.Id;
            update claim;
            
            List<caseShare> caseshareList = new List<caseShare>();
            caseshareList = [Select caseId from caseShare where caseId =: claim.Id];
            system.assertNotequals(caseshareList.size(),0);
       Test.stopTest(); 
    }
    
    /*
        Decription : Test Cases to test trigger CaseBeforeUpdate & CaseBeforeInsert
        Author : Sneha Rathi, Accenture
        Date : 27 Nov, 2013
    */
    
    //Setup the test Data
    private static Account customerAcc;
    private static User partnerUser;
    private static User waveAdminUser; //added this for Wave cases
    private static Order__c order1;
    private static Order__c order2;
    private static ID preOrderRecordTypeId;
    private static ID postOrderRecordTypeId;
    private static Group g1;
    private static void setUpTestData()
    {
        SetupTestData.createCustomSettingRecords();

        //Create a partner & a customer Account
        List<Account> lstAcc = new List<Account>();
        partAcc = new Account();
        partAcc.Name = 'Test Partner Account';
        partAcc.Type = 'Partner';
        lstAcc.add(partAcc);
        customerAcc = new Account();
        customerAcc.Name = 'Test Customer Account';
        customerAcc.Type = 'Customer';
        customerAcc.Billing_Account_Number__c = 'TestAcc@01';
        lstAcc.add(customerAcc);
        insert lstAcc;
        
        // Create a contact under the partner account
        partContact = new Contact();
        partContact.AccountId = partAcc.Id;
        partContact.lastName = 'Test Contact';
        insert partContact;
        
        System.runAs(new User(Id = Userinfo.getUserId())) {
        
            //Create a Affiliate Claims User
            // fetch the partner profile
            Profile p = [Select UserType, UserLicenseId, Name From Profile where Name = 'Affiliate Claims User'];
            UserRole r = [SELECT Id,Name FROM UserRole where Name = 'Affiliate Agent'];
            Profile p2 = [Select UserType, UserLicenseId, Name From Profile where Name =:'System Administrator' limit 1];//added this for Wave cases
            UserRole r2=[Select Id From UserRole WHERE Name='Comcast: Residential'];//added this for Wave cases
            
            //generate Random String 
            String randomstr = Math.round(Math.random()*Math.pow(10, 7))+'';
            partnerUser = new User(Alias = 'DA_' + randomstr.substring(0,4),
                                        Email = randomstr + 'userTest@SampleclassTest.com',
                                        LastName='Testing',
                                        EmailEncodingKey='UTF-8', 
                                        LanguageLocaleKey='en_US', 
                                        LocaleSidKey='en_US', 
                                        TimeZoneSidKey='America/Los_Angeles',
                                        ProfileId = p.Id,
                                        Username = 'userTest' + randomstr + '@SampleclassTest.com',
                                        EmployeeNumber = 'Emp' + randomstr.substring(0,4),
                                        ContactId = partContact.Id,
                                        FederationIdentifier = 'userTest@SampleclassTest.com');
                                        
            insert partnerUser;
            //user creation for Wave cases
            waveAdminUser = new User(Alias = 'DA_' + randomstr.substring(0,4),
                                    Email = randomstr + 'WaveUserTest@SampleclassTest.com',
                                    LastName='Testing',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p2.Id,
                                    Username = 'WaveUserTest' + randomstr + '@SampleclassTest.com',
                                    UserRoleId=r2.Id,
                                    EmployeeNumber = 'Emp' + randomstr.substring(0,4),
                                    Region__c = 'Global',
                                    FederationIdentifier = 'WaveUserTest@SampleclassTest.com');
            insert WaveAdminUser;
            
            //Enable the account as partner
            partAcc.IsPartner = true;
            update partAcc;
            
            g1 = new Group(Name= label.Escalation_Dispute, type='Queue');
            insert g1;
            QueueSObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
            insert q1;
            
            //create the custom setting data
            EnvironmentSpecificIds__c cs = new EnvironmentSpecificIds__c(ID__c = g1.id, Name = 'EscalationDispute');
            insert cs;
            //Create Opportunity
            Opportunity opp = new Opportunity();
            opp.Name = 'Test Opportunity'; 
            opp.AccountId = customerAcc.Id; 
            opp.StageName='Open';
            opp.Affiliate_Account__c = partAcc.id;
            opp.CloseDate=Date.today()+30;
            opp.LeadSource = 'Affiliate';
            insert opp;
            
            //Create Orders
            list<Order__c> orderList = new list<Order__c>();
            order1 = new Order__c();
            order1.Name = '110795673534';
            order1.Opportunity__c = opp.Id;
            order1.Order_Number__c = '110795673534';
            order1.Order_Number__c = 'Order1Id@01';
            order1.OrderStatus__c = 'Activated';
            order1.Order_Created_Date__c = system.now() - 200;
            order1.OrderCompletedDate__c = system.today() - 100;
            orderList.add(order1);
           
            order2= new Order__c();
            order2.Name = '110795673534';
            order2.Opportunity__c = opp.Id;
            order2.Order_Number__c = '110795673534';
            order2.OrderStatus__c = 'Activated';
            order2.Order_Number__c = 'Order1Id@02';
            order2.Order_Created_Date__c = system.now() - 200;
            order2.OrderCompletedDate__c = system.today() - 100;
            orderList.add(order2);
            
            insert orderList;
            
            //fetch the record type information for cases
            Map<String,Schema.RecordTypeInfo> caseRecordTypeInfos = Case.SObjectType.getDescribe().getRecordTypeInfosByName();
            preOrderRecordTypeId = caseRecordTypeInfos.get('Pre-Order Escalation').getRecordTypeId();
            postOrderRecordTypeId = caseRecordTypeInfos.get('Post-Order Escalation').getRecordTypeId();
        }
    }
    
    //tests if the Customer Account / Partner Account / Contact & Order Details are correctly populated for a new Pre-order / Post - Order Case
    public static testmethod void testCaseBeforeInsert()
    {  
       setUpTestData();
       test.startTest();
       System.runas(partnerUser)
       {
           //test.startTest();
           Case case1 = new Case();
           case1.Case_Name__c = 'Test Case';
           case1.IssueType__c = 'Serviceability Check';
           case1.OrderID__c = order1.Order_Number__c ;
           case1.Request_Type__c = 'Order Lab / Sales Portal' ;
           case1.Region__c='Corporate';
           case1.Ticket_Category__c = 'Affiliate Inquiry' ;
           case1.Ticket_Category_II__c = 'Affiliate Inquiry' ;
           case1.AccountNumber__c = customerAcc.Billing_Account_Number__c;
           Map<String,Schema.RecordTypeInfo> caseRecordTypeInfos = Case.SObjectType.getDescribe().getRecordTypeInfosByName();
           case1.RecordTypeId = caseRecordTypeInfos.get('Pre-Order Escalation').getRecordTypeId();
           insert case1;
           
           case1 = [Select Customer_Account__c, Affiliate_Account__c, OwnerId, OrderName__c from Case where id = :case1.id];
           System.assertEquals(case1.Customer_Account__c, customerAcc.id);
           //System.assertEquals(case1.Affiliate_Account__c, null);
           //System.assertEquals(case1.OwnerId, g1.id);
           System.assertEquals(case1.OrderName__c, order1.id);
           //test.stopTest();
       }
       
       System.runas(waveAdminUser)
       {
           User u = [Select Id, Email, Region__c from User where Id =:UserInfo.getUserId()];
           Case case2 = new Case();
           case2.Channel__c = 'Wave';
           case2.Status = 'New';
           case2.Description = 'Wave Only User Case Description' ;
           case2.Subject = 'Wave Only User Case Subject' ;
           case2.Request_Type__c = 'Wave' ;
           case2.Region__c='Corporate';
           case2.SuppliedEmail = u.Email;
           case2.Origin = 'Email';
           case2.Priority = 'Medium';
           case2.OwnerId = u.Id;
           Map<String,Schema.RecordTypeInfo> caseRecordTypeInfos = Case.SObjectType.getDescribe().getRecordTypeInfosByName();
           case2.RecordTypeId = caseRecordTypeInfos.get('Wave Only User').getRecordTypeId();
           insert case2;
           
           //case2 = [Select Id, Region__c, Requested_For__c from Case where id = :case2.id];
           //System.assertEquals(case2.Region__c, u.Region__c);
           //System.assertEquals(case2.Requested_For__c, u.Id);
       } 
      test.stopTest();
    }
    
    //tests if the Customer Account / Partner Account / Contact & Order Details are correctly populated for a existiong Pre-order / Post - Order Case when its updated
    public static testmethod void testCaseBeforeUpdate()
    {
        setUpTestData();
       
       System.runas(partnerUser)
       {
           test.startTest();
           Case case1 = new Case();
           case1.Case_Name__c = 'Test Case';
           case1.Requested_For__c = UserInfo.getUserId();
           case1.IssueType__c = 'Serviceability Check';
           case1.OrderID__c = order1.Order_Number__c ;
           case1.Region__c='Corporate';
           case1.Request_Type__c = 'Order Lab / Sales Portal' ;
           case1.Ticket_Category__c = 'Affiliate Inquiry' ;
           case1.Ticket_Category_II__c = 'Affiliate Inquiry' ;
           case1.AccountNumber__c = customerAcc.Billing_Account_Number__c;
           Map<String,Schema.RecordTypeInfo> caseRecordTypeInfos = Case.SObjectType.getDescribe().getRecordTypeInfosByName();
           case1.RecordTypeId = caseRecordTypeInfos.get('Pre-Order Escalation').getRecordTypeId();
           insert case1;
           
           case1 = [Select Customer_Account__c, Affiliate_Account__c, OwnerId, OrderName__c from Case where id = :case1.id];
           
           System.assertEquals(case1.Customer_Account__c, customerAcc.id);
           //System.assertEquals(case1.Affiliate_Account__c, null);
           //System.assertEquals(case1.OwnerId, g1.id);
           System.assertEquals(case1.OrderName__c, order1.id);
           
           case1.OrderID__c = order2.Order_Number__c ;
           update case1;
           case1 = [Select Customer_Account__c, Affiliate_Account__c, OwnerId, OrderName__c from Case where id = :case1.id];
           System.assertEquals(case1.Customer_Account__c, customerAcc.id);
           //System.assertEquals(case1.Affiliate_Account__c, null);
           //System.assertEquals(case1.OwnerId, g1.id);
           System.assertEquals(case1.OrderName__c, order2.id);
           
           test.stopTest();
       }
    }   
    public static testmethod void testCaseFollowUpForXCP(){
        setUpTestData();
        Variable_Setting__c vs = new Variable_Setting__c();
        vs.Name = 'XCP_NETWORK_ID';
        vs.Description__c = 'NetworkId of Xfinity portal page(Used in caseTriggerController)';
        vs.Value__c = '0DB0t000000004IGAQ';
        insert vs;      
        Case case1 = new Case();
        case1.Case_Name__c = 'Test Case';         
        case1.Region__c = 'Corporate';
        case1.Status = 'New';
        case1.RecordTypeId = Case.SObjectType.getDescribe().getRecordTypeInfosByName().get('Report Property Service Issue').getRecordTypeId();
        test.startTest();
            insert case1;           
        test.stopTest();       
    }    
}