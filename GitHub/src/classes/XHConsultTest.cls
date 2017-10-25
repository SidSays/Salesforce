@isTest
public class XHConsultTest{
    
    static testMethod void XHMethod(){
        // Create an address 
        Customer_Address__c cadd1 = new Customer_Address__c();
        cadd1.Name='941 South Ave';
        cadd1.Address_2__c = 'Apt A26';
        cadd1.State__c = 'PA';
        cadd1.Country__c = 'USA';
        cadd1.City__c  = 'Secane'; 
        cadd1.PostalCode__c ='19018';
        cadd1.PostalCode_4__c ='1234';
        insert cadd1;
        system.assert(cadd1.id<>NULL);
        //address 2
        Customer_Address__c cadd2 = new Customer_Address__c();
        cadd2.Name='941 South Ave';
        cadd2.Address_2__c = 'Apt A25';
        cadd2.State__c = 'PA';
        cadd2.Country__c = 'USA';
        cadd2.City__c  = 'Secane'; 
        cadd2.PostalCode__c ='19018';
        cadd2.PostalCode_4__c ='1234';
        insert cadd2;
        system.assert(cadd2.id<>NULL);
        //Account1
        Account a1 = New Account();
        a1.Name                              = 'TestAccount1';
        a1.Customer_Status__c                   = 'Active';
        a1.recordTypeId                     =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Default').getRecordTypeId();  
        a1.Billing_Account_Number__c         =  '112233';
        a1.Service_Address__c                =  cadd1.id;
        insert a1;
        system.assert(a1.id<>NULL);
        //Account 2
        Account a2 = New Account();
        a2.Name                              = 'TestAccount2';
        a2.recordTypeId                     =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Default').getRecordTypeId();
        a2.Customer_Status__c                   = 'Active';
        a2.Billing_Account_Number__c         =  '1122334455';
        a2.Service_Address__c                =  cadd2.id;
        insert a2;
        system.assert(a2.id<>NULL);
        //Test a valid Account via billing account number
        Test.startTest();
        XHConsult t2 = new XHConsult();
        PageReference pageRef1 = Page.UniversalSubmitCase;
        
        pageRef1.getParameters().put('RecordType', '01216000001Ik5G');
        pageRef1.getParameters().put('code', 'YtaU5Z1bGLnAhMawXL71nR6itNKFzHVsDD35xgAB');
        Test.setCurrentPage(pageRef1);
        XHConsult t1 = new XHConsult();
        /* t1.inputTextbox = '1';
t1.selectRadio = 'bansrc';
t1.search();

t1.inputTextbox = '1122';
t1.selectRadio = 'bansrc';
t1.search();*/
        
        t1.inputTextbox = '1122334455';
        t1.selectRadio = 'bansrc';
        t1.search();
        
    }
    
    static testMethod void XHMethod1(){
        // Create an address 
        Customer_Address__c cadd1 = new Customer_Address__c();
        cadd1.Name='941 South Ave';
        cadd1.Address_2__c = 'Apt A26';
        cadd1.State__c = 'PA';
        cadd1.Country__c = 'USA';
        cadd1.City__c  = 'Secane'; 
        cadd1.PostalCode__c ='19018';
        cadd1.PostalCode_4__c ='1234';
        insert cadd1;
        system.assert(cadd1.id<>NULL);
        //address 2
        Customer_Address__c cadd2 = new Customer_Address__c();
        cadd2.Name='941 South Ave';
        cadd2.Address_2__c = 'Apt A25';
        cadd2.State__c = 'PA';
        cadd2.Country__c = 'USA';
        cadd2.City__c  = 'Secane'; 
        cadd2.PostalCode__c ='19018';
        cadd2.PostalCode_4__c ='1234';
        insert cadd2;
        system.assert(cadd2.id<>NULL);
        //Account1
        Account a1 = New Account();
        a1.Name                              = 'TestAccount1';
        a1.Customer_Status__c                   = 'Active';
        a1.recordTypeId                     =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Default').getRecordTypeId();  
        a1.Billing_Account_Number__c         =  '112233';
        a1.Service_Address__c                =  cadd1.id;
        insert a1;
        system.assert(a1.id<>NULL);
        //Account 2
        Account a2 = New Account();
        a2.Name                              = 'TestAccount2';
        a2.recordTypeId                     =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Default').getRecordTypeId();
        a2.Customer_Status__c                   = 'Active';
        a2.Billing_Account_Number__c         =  '1122334455';
        a2.Service_Address__c                =  cadd2.id;
        insert a2;
        system.assert(a2.id<>NULL);
        SSOToken sToken = new SSOToken();
        sToken.access_token = 'Test';
        sToken.id_token = 'Test';
        sToken.token_type = 'Test';
        sToken.expires_in = 'Test';
        
        SSOUserToken sUserToken = new SSOUserToken();
        List<String> stringList = new List<String>();
        stringList.add('Test');
        
        sUserToken.scope = stringList;
        sUserToken.client_id = 'Test';
        sUserToken.COMCAST_LNAME = 'Test';
        sUserToken.COMCAST_USERNAME = 'Test';
        sUserToken.COMCAST_EMAIL = 'Test';
        sUserToken.COMCAST_FNAME = 'Test';
        sUserToken.COMCAST_OBJGUID = 'Test';
        sUserToken.COMCAST_OBJGUID_BASE64 = 'Test';
        sUserToken.COMCAST_GUID = 'Test';
        sUserToken.exp = 1;
        
        //SSOUserToken.parse('test');
        
        List<SSO_Setting__c> csList = new List<SSO_Setting__c>();
        SSO_Setting__c cs = new SSO_Setting__c();
        cs.Name = 'clientId';
        cs.Param_Value__c = 'nsosfdcclient';
        cs.Param_Name__c = 'clientId';
        csList.add(cs);
        SSO_Setting__c cs1 = new SSO_Setting__c();
        cs1.Name = 'clientSecret';
        cs1.Param_Value__c = 'e166481280e74fb4b5ee2a6386e2fa7b';
        cs1.Param_Name__c = 'clientSecret';
        csList.add(cs1);
        SSO_Setting__c cs2 = new SSO_Setting__c();
        cs2.Name = 'endPoint';
        cs2.Param_Value__c = 'https://websec-stg.cable.comcast.com/as/token.oauth2';
        cs2.Param_Name__c = 'endPoint';
        csList.add(cs2);
        SSO_Setting__c cs4 = new SSO_Setting__c();
        cs4.Name = 'redirect_uri_XH';
        cs4.Param_Value__c = 'http://devpro1-onecomcast.cs14.force.com/XHConsult';
        cs4.Param_Name__c = 'redirect_uri_XH';
        csList.add(cs4);
        insert csList;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseForSSO());
        //Test a valid Account via billing account number
        Test.startTest();
        XHConsult t2 = new XHConsult();
        PageReference pageRef1 = Page.UniversalSubmitCase;
        
        pageRef1.getParameters().put('RecordType', '01216000001Ik5G');
        pageRef1.getParameters().put('code', 'YtaU5Z1bGLnAhMawXL71nR6itNKFzHVsDD35xgAB');
        Test.setCurrentPage(pageRef1);
        XHConsult t1 = new XHConsult();
        /* t1.inputTextbox = '1';
t1.selectRadio = 'bansrc';
t1.search();

t1.inputTextbox = '1122';
t1.selectRadio = 'bansrc';
t1.search();*/
        
        t1.inputTextbox = '1122334455';
        t1.selectRadio = 'bansrc';
        t1.search();
        
    }
}