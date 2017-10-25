/*
    * @Description: Xfinity Home Service availability
    * @Author: Siddharth Sinha
    * @Date: 07-Oct-2017
    * @Param: VF page variables
    * @Return: Address from Database (US1203476)
    * @CreatedBy : Siddharth Sinha 
*/
public without sharing class XHConsult {
    // Define attributes for Xfinity Home Serviceeability page
    public String                           inputTextbox                {get;set;}  //To get Address entered on VF page by Billing Account Number
    public List<Customer_Address__c>        AddressList                 {get;set;}  //To query based on Address - from Customer Address
    public List<Account>                    AccountList                 {get;set;}  //To query based on Billing Account Number - from Standard Account object
    public String                           selectRadio                 {get;set;}  //Flag to get selection of end user from VF page
    public String                           returnResponse              {get;set;}  //To return search from apex to VF for displaying on UI
    public List<Customer_Address__c>        cAdd                        {get;set;}  //To Store related address for Account
    public Customer_Address__c              add                         {get;set;}  
    public boolean                          outputpanel                 {get;set;}  //To Show/Hide Outputpanel
    public Xfinity_Home_Consult__c          newXHC                      {get;set;}
    public boolean                          enableForm                  {get;set;}
    public Id                               XHCrecordTypeID             {get;set;}  
    public boolean                          banFlag                     {get;set;}
    public boolean                          addFlag                     {get;set;}
    public boolean                          submitSuccess               {get;set;}
    private Id                              ServiceAddressId            {get;set;}
    public String                           add2;
    private static final String             XH_searchTerm           = ErrorMessages.getErrorMessage('XH_searchTerm');
    private static final String             XH_outputMsg            = ErrorMessages.getErrorMessage('XH_outputMsg');
    private static final String             XH_alreadyInstalled     = ErrorMessages.getErrorMessage('XH_alreadyInstalled');
    private static final String             XH_serviceable          = ErrorMessages.getErrorMessage('XH_serviceable');
    private static final String             XH_moreThanOne          = ErrorMessages.getErrorMessage('XH_moreThanOne');
    private static final String             XH_noAddressFound       = ErrorMessages.getErrorMessage('XH_noAddressFound');
    private static final String             REPORT_XH_ALREADY       = ErrorMessages.getErrorMessage('AlreadyXHInstalled');
    private static final String             XH_bansrc               = ErrorMessages.getErrorMessage('XH_bansrc');
    private static final String             XH_addrsrc              = ErrorMessages.getErrorMessage('XH_addrsrc');
    private static final String             XH_catchException       = ErrorMessages.getErrorMessage('XH_catchException');
    // These are the attributes for Authentication SSO
    
    public String                           Name                        {get;set;}
    public String                           Email                       {get;set;}
    public String                           NTAccount                   {get;set;}      
    public boolean                          validRequest                {get;set;}
    public SSOUserToken                     userToken                   {get;set;}
    public Boolean                          redirectFlag                {get;set;}
    private String                          accessResponse              {get;set;}
    private static final string             BLANK_STR               = '';
    private static final string             DefaultRT              	= 'Default';
    private static final string             CODE                    = 'code';
    private static final String             missingAuthCode         = ErrorMessages.getErrorMessage('MISSING_AUTH_CODE');
    private static final String             invalidAuthCode         = ErrorMessages.getErrorMessage('INVALID_AUTH_CODE');
    private static final String             invalidAccessToken      = ErrorMessages.getErrorMessage('INVALID_ACCESS_TOKEN');
    private static final String             REDIRECT_XH             = 'redirect_uri_XH';
    private static final String             BLANK_SPACE             = ' ';
    private static final String             AUTH_CODE               ='Auth Code: ';
    private static final String             TOKEN                   = 'Token: ';
    private static final String             BLANK_ERROR             = '*** ';


    
/*
    * @Description: Constructor
    * @Author: Siddharth Sinha
    * @Date: 07-Oct-2017
    * @Param: VF page variables
    * @Return: Address from Database (US1203476)
    * @CreatedBy : Siddharth Sinha 
*/
    public XHConsult(){
    AddressList             =   new List<Customer_Address__c>();        //To store all the Addresses
    AccountList             =   new List<Account>();                    //To store all the Accounts
    cAdd                    =   new List<Customer_Address__c>();        //To store all the Addresses
    newXHC                  =   new Xfinity_Home_Consult__c();
    returnResponse          =   BLANK_STR;                                     //To default address found to blank
    outputpanel             =   false;                                  //Turn off the panel by default
    XHCrecordTypeID         =   Schema.SObjectType.Xfinity_Home_Consult__c.getRecordTypeInfosByName().get(DefaultRT).getRecordTypeId();
    submitSuccess           =   false;
    authenticateUser();
    }

    /**
    * @Description: Search and call Form Submit
    * @Author: Siddharth Sinha
    * @Date: 07-Oct-2017
    * @Param: VF page variables
    * @Return: Address from Database
    * @LastUpdatedBy : Siddharth Sinha 
    */
    public PageReference search(){
    //Clear any cache/reference instance
    outputpanel     =   false;
    banFlag         =   false;
    addFlag         =   false;
    enableForm      =   false;
    submitSuccess   =   false;
    // Blank the form fields at start so that page can be used without refreshing.
    returnResponse              = BLANK_STR;
    newXHC.First_Name__c        = BLANK_STR;
    newXHC.Last_Name__c         = BLANK_STR;
    newXHC.Best_time_to_call__c = BLANK_STR;
    newXHC.Email__c             = BLANK_STR;
    newXHC.Packages__c          = BLANK_STR;
    newXHC.Primary_phone__c     = BLANK_STR; 
    newXHC.Consult_Date__c      = system.today();
    newXHC.Consult_Time__c      = BLANK_STR;
    newXHC.Notes__c             = BLANK_STR;  
        //Perform SOSL search and get Serviceability information
        
        if(inputTextbox.length()==1){
           ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,XH_searchTerm,'');
           ApexPages.addMessage(myMsg);
           return null;         
        }
        List<List<sObject>> searchList = [FIND :String.valueOf(inputTextbox) IN ALL FIELDS RETURNING Account(Name, Billing_Account_Number__c,Service_Address__c),Customer_Address__c(Name,Address_2__c,XH_Active1__c,City__c,State__c,PostalCode__c,Account__c,Active_Inactive__c)];
        AccountList = ((Account[])searchList[0]);
        system.debug('AccountList='+AccountList+AccountList.size());
        AddressList = ((Customer_Address__c[])searchList[1]);

        // This section will get invoked only if the user selects Billing Account Number in the Visualforce Page.        
        if(selectRadio == XH_bansrc && AccountList.size()==1){
                for(Account acc : AccountList){
                ServiceAddressId = acc.Service_Address__c;
                }
                // Query the related Service Address belonging to this Account
                cAdd = [select Id,Name,Address_2__c,XH_Active1__c,City__c,State__c,PostalCode__c,Account__c,Active_Inactive__c from Customer_Address__c where Id =: ServiceAddressId LIMIT 1];
                if(!cAdd.isEmpty()){
                // There is a service address in this found Billing Account Number, but check if it already has Xfinity Home installed.
                    if(cAdd[0].XH_Active1__c == true){
                    // The BAN  entered by user is exactly matching a record from database and that this address already has Xfinity Home 
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,XH_alreadyInstalled,'');
                    ApexPages.addMessage(myMsg);
                    return null;
                    }
                    // The BAN  entered by user is exactly matching a record from database and that this address does not have Xfinity Home right now
                    else if(cAdd[0].XH_Active1__c == false){            
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,XH_serviceable,'');
                    ApexPages.addMessage(myMsg);
                    // Defect fix for Address2 returning blank leading to URL redirection.
                    if(String.ISBLANK(String.valueOf(cAdd[0].Address_2__c))){
                        add2 = BLANK_STR;
                        }
                        else{ add2 = String.valueOf(cAdd[0].Address_2__c);
                        }
                    returnResponse = String.valueOf(cAdd[0].Name) + ' ' + add2 + ' ' + String.valueOf(cAdd[0].City__c) + ' ' + String.valueOf(cAdd[0].PostalCode__c) ;
                    enableForm = true;
                    banFlag = true;
                    addFlag = false;
                    return null;
                    } 
                }
        }
        else if(selectRadio == XH_bansrc && AccountList.size()>1){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,XH_moreThanOne,'');
            ApexPages.addMessage(myMsg);
            return null;
        }
        else if(selectRadio == XH_bansrc && AccountList.size()==0){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,XH_noAddressFound,'');
            ApexPages.addMessage(myMsg);
            return null;
        }
        
// This section will get invoked only if the user selects Address in the Visualforce Page.
// Design parameter is that only if 1 address is returned, we will perform the operations.
        if(selectRadio == XH_addrsrc && AddressList.size()==1){
                if(AddressList[0].XH_Active1__c == true){
                    enableForm = false;     
                    // The BAN  entered by user is exactly matching a record from database and that this address already has Xfinity Home 
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,XH_alreadyInstalled,'');
                    ApexPages.addMessage(myMsg);
                    }
                else if(AddressList[0].XH_Active1__c == false){         
                    // The BAN  entered by user is exactly matching a record from database and that this address does not have Xfinity Home right now
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,XH_serviceable,'');
                    ApexPages.addMessage(myMsg);
                    // Defect fix for Address2 returning blank leading to URL redirection.
                    if(String.ISBLANK(String.valueOf(AddressList[0].Address_2__c))){
                        add2 = BLANK_STR;
                        }
                        else{ add2 = String.valueOf(AddressList[0].Address_2__c);
                        }
                    returnResponse = String.valueOf(AddressList[0].Name) + ' ' + add2 + ' ' + String.valueOf(AddressList[0].City__c) + ' ' + String.valueOf(AddressList[0].PostalCode__c) ;
                    enableForm = true;
                    addFlag = true;
                    banFlag = false;                
                    return null;
                    }      
        }
        else if(selectRadio == XH_addrsrc && AddressList.size()>1){
            enableForm = false;     
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,XH_moreThanOne,'');
            ApexPages.addMessage(myMsg);
            return null;
        }
            else if(selectRadio == XH_addrsrc && AddressList.size()==0){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,XH_noAddressFound,'');
            ApexPages.addMessage(myMsg);
            return null;
        }        
    //End of Search Function
    return null;
    }

    /**
    * @Description: Submit the New User request form to apply for an Xfinity Home connection
    * @Author: Siddharth Sinha
    * @Date: 12-Oct-2017
    * @Param: VF page variables
    * @Return: None
    * @LastUpdatedBy : Siddharth Sinha 
    */
    public void Submit(){
    if(selectRadio == XH_bansrc){
        try{
            newXHC.recordTypeID                 = XHCrecordTypeID;
            newXHC.Name                         = cAdd[0].Id;
            newXHC.Street__c                    = cAdd[0].Name;
            newXHC.Street_Line_2__c             = cAdd[0].Address_2__c;
            newXHC.City__c                      = cAdd[0].City__c;
            newXHC.State__c                     = cAdd[0].State__c;
            newXHC.Zip__c                       = cAdd[0].PostalCode__c;
            newXHC.Account__c                   = cAdd[0].Account__c;
            newXHC.Service_Address__c           = cAdd[0].Id;
            newXHC.Rep_Name__c                  = Name;
            newXHC.Rep_Email__c                 = Email;
            newXHC.Rep_NTID__c                  = NTAccount;
            insert newXHC;
            submitSuccess = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,XH_outputMsg,'');
            ApexPages.addMessage(myMsg);
            }
        catch(exception e){
            String exceptionErrMsg = String.valueOf(e.getMessage()).substringAfter('Error-');
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,exceptionErrMsg,'');
            ApexPages.addMessage(myMsg);
            }
        }
    else if (selectRadio == XH_addrsrc){
        try{
            newXHC.recordTypeID                 = XHCrecordTypeID;
            newXHC.Name                         = AddressList[0].Id;
            newXHC.Street__c                    = AddressList[0].Name;
            newXHC.Street_Line_2__c             = AddressList[0].Address_2__c;
            newXHC.City__c                      = AddressList[0].City__c;
            newXHC.State__c                     = AddressList[0].State__c;
            newXHC.Zip__c                       = AddressList[0].PostalCode__c;
            newXHC.Account__c                   = AddressList[0].Account__c;
            newXHC.Service_Address__c           = AddressList[0].Id;
            newXHC.Rep_Name__c                  = Name;
            newXHC.Rep_Email__c                 = Email;
            newXHC.Rep_NTID__c                  = NTAccount;
            insert newXHC;
            submitSuccess = true;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,XH_outputMsg,'');
            ApexPages.addMessage(myMsg);
            }
        catch(exception e){
            //system.debug(e);
            String exceptionErrMsg = String.valueOf(e.getMessage()).substringAfter('Error-');
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,exceptionErrMsg,'');
            ApexPages.addMessage(myMsg);
            }
        }   
    }
/*
    * @Description: Getting User details from NT Account(SSO User) by passing auth code
    * @Author: Kiran Kumar, Accenture
    * @Date: 10-Oct-2017
    * @Param: VF page variables
    * @US : US1197171(SSO Access for XH Form)
*/     
      public void authenticateUser(){     
        validRequest = true;
        userToken = new SSOUserToken ();
        redirectFlag = false; 
        if(ApexPages.currentPage().getParameters().get(CODE) == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,missingAuthCode,'');
            ApexPages.addMessage(myMsg);
            validRequest = false;
        }else{
            try{
                String authCode = ApexPages.currentPage().getParameters().get(CODE);
                accessResponse = SSOUtility.getToken(authCode,REDIRECT_XH);
                if(accessResponse == null || accessResponse == BLANK_STR){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,invalidAuthCode+' custom message','');
                    ApexPages.addMessage(myMsg);
                    validRequest = false;
                    redirectFlag = true;   
                }else{
                    SSOToken token = SSOUtility.parseToken(accessResponse);
                    if(token == null){
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,invalidAuthCode+ ' custom message','');
                        ApexPages.addMessage(myMsg);
                        validRequest = false;
                        redirectFlag = true;                    
                    }else{
                        if(token.access_token != null && token.access_token != BLANK_STR){
                            userToken = SSOUtility.decodePayload(token.access_token);
                            Name = userToken.COMCAST_FNAME + BLANK_SPACE + userToken.COMCAST_LNAME;
                            Email = userToken.COMCAST_EMAIL;
                            NTAccount = userToken.COMCAST_USERNAME;
                            system.debug(Name);
                            system.debug(Email);
                            system.debug(NTAccount);
                        }else{
                            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,invalidAccessToken);ApexPages.addMessage(myMsg);
                            myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,AUTH_CODE + authCode);ApexPages.addMessage(myMsg);
                            myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,TOKEN + token.access_token);ApexPages.addMessage(myMsg);validRequest = false;redirectFlag = true;       
                        }
                    }
                }
            }catch(Exception e){ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,BLANK_ERROR + e.getMessage());ApexPages.addMessage(myMsg);validRequest = false;}
          } 
        }    

// end of class  
}