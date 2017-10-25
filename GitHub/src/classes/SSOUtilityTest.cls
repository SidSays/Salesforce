@isTest                        
private class SSOUtilityTest{
    //Test Method to test the class   
    static testmethod void testGetToken(){
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
        SSO_Setting__c cs3 = new SSO_Setting__c();
        cs3.Name = 'redirect_uri';
        cs3.Param_Value__c = 'http://uat-onecomcast.cs67.force.com/case';
        cs3.Param_Name__c = 'redirect_uri';
        csList.add(cs3);
        SSO_Setting__c cs4 = new SSO_Setting__c();
        cs4.Name = 'redirect_uri_XH';
        cs4.Param_Value__c = 'http://devpro1-onecomcast.cs14.force.com/XHConsult';
        cs4.Param_Name__c = 'redirect_uri_XH';
        csList.add(cs4);
        insert csList;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseForSSO());     
            SSOUtility.getToken('YtaU5Z1bGLnAhMawXL71nR6itNKFzHVsDD35xgAB');
        Test.stopTest();    
        SSOUtility.parseToken('112fsddgh');
        //SSOUtility.decodePayload('dasfdsg.afdas.asafag.asgsg');
    }
    
    static testmethod void testGetTokenForXhConsult(){
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
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseForSSO());     
            SSOUtility.getToken('YtaU5Z1bGLnAhMawXL71nR6itNKFzHVsDD35xgAB','redirect_uri_XH');
        Test.stopTest();    
        SSOUtility.parseToken('112fsddgh');
        //SSOUtility.decodePayload('dasfdsg.afdas.asafag.asgsg');
    }
}