/**
* Class Name: CaseTriggerController 
* Author: Amitkumar Bangad, Accenture
* Date: 10-January-2013 
* Requirement # Request Id: 067
* Description: Contains supporting Actions for Case Triggers (Giving access to Affiliate public group on Owner change)
* Modified By : Ashish Srivastava - US735966(Implemented NSO Record Type check for Case Trigger)
* Modified By : Srini Bhattiprolu - US1039173( Added logic for Wave Only User case record type)
* Modified By: Tejaswini Kasar, Accenture on 23 September, 2017 - US1186033(Case Comments by Email for Retail and Wave Only Case Types)
* Modified By : Malay Desai - US1199875 - (Added check for IsActive for RequestedFor)
* Modified By : Deekipa - (Added new method "updateEmailforCommunity" to update preferred email)
* Modified By : Amit Kumar Pradhan - US1193504 - (Added new method "caseFollowUpForXCP" for auto follow up)
* Last Modified :
*/
public class CaseTriggerController {
    /**
    * @Description: This method handles below requests:
                 443 - Updates Case's Order field based on the order number
                 446 - Update Case's Account field based on the account number
                 442 - update the affiliate account with partner portal user's account
                 Note : This functionality should only work for Post & Pre Order Escalations disputes Cases
    * @Author: Sneha Rathi, Accenture
    * @Date: 20 Nov, 2013
    * @Param: Trigger.New
    * @Return: void.
    */
    private static final string LABEL_NAME_SPLIT = ';';
    private static final string RETAIL_STORE = 'Retail Store';
    private static final string WAVE_ONLY = 'Wave Only User';
    private static final string Case_URL ='Case_URL';
    private static final string Case_Number = 'Case_Number';
    private static final string Created_By = 'Created_By';
    private static final string CONSTANT_SLASH = '/';
    private static final string PROPERTY_NAME = 'PROPERTY_NAME';
    private static final string XCP_NETWORK_ID = 'XCP_NETWORK_ID';//Added part of US1193504
    
    public static void updateCases(Map<Id, Case> caseOldMap, List<Case> lstCases){
        //Fetching the recordtype info for Pre-order & Post-order Case object recordtypes
        set<String> setCaseRecordTypesName = new Set<String>{'Pre-Order Escalation','Post-Order Escalation'};
        Map<String,Schema.RecordTypeInfo> caseRecordTypeInfos = Case.SObjectType.getDescribe().getRecordTypeInfosByName();
        set<Id> caseRecordtypeIds = new set<Id>();
        List<String> webEmail = new List<String>(); // To capture user e-mail addresses for Wave cases - US1039173
        Boolean isInternalUser = false;
        for(String s: setCaseRecordTypesName)
        {
            if(caseRecordTypeInfos.get(s) != null)
                caseRecordtypeIds.add(caseRecordTypeInfos.get(s).getRecordTypeId());
        }  
        
        Set<String> setOrderNumber = new Set<String>();
        Set<String> setAccountNumber = new Set<String>();
        //collect the order & account numbers for the new cases
                for(Case cs: lstCases)
                {
                    if(!caseRecordtypeIds.isEmpty() && caseRecordtypeIds.contains(cs.RecordTypeId))
                    {
                        if(cs.OrderID__c != '' && cs.OrderID__c != null)
                           setOrderNumber.add(cs.OrderID__c);
                        if(cs.AccountNumber__c != '' && cs.AccountNumber__c != null)
                           setAccountNumber.add(cs.AccountNumber__c);
                     } 
                    //US1039173 - To capture Supplied Email of Wave cases in a list
                    if(cs.SuppliedEmail !='' && cs.SuppliedEmail !=null && Label.Wave_Only_User_Case_Record_Type == cs.RecordTypeId) 
                       webEmail.add(cs.SuppliedEmail);
                }
        //fetch the corresponding order details
        Map<String, Order__c> mapOrders = new Map<String, Order__c>();
        if(setOrderNumber.size() > 0)
        {
            for(Order__c ord: [Select id, Order_Number__c from Order__c where Order_Number__c in :setOrderNumber limit 50000])
            {
                 mapOrders.put(ord.Order_Number__c, ord);   
            }
        }    
        //fetch the corresponding Account details
        Map<String, Account> mapAccounts = new Map<String, Account>();
        if(setAccountNumber.size() > 0)
        {
            for(Account acc: [Select id, Billing_Account_Number__c from Account where Billing_Account_Number__c in :setAccountNumber])
            {
                mapAccounts.put(acc.Billing_Account_Number__c, acc);
            }
        } 
        //US1039173 - Define Map, query user object using Supplied Email on the case and fill the Map 
        Map<String, User> webEmailToUserMap = new Map<String, User>(); 
            for (User u : [SELECT Id, Email, Region__c from User where Email IN :webEmail])
             {
                webEmailToUserMap.put (u.EMail, u);
             }
        
        //Determining if the current user is an partner portal user and fetching its user
        Id affiliateAccount = null;
        for(Profile p :[Select Name from Profile where Id=: UserInfo.getProfileId()])
        {
            if(p.Name != label.Affiliate_User_Profile){
                isInternalUser = true;
            }
        }
        if(!isInternalUser){
            User usr = [Select Id, AccountId from User where Id =: UserInfo.getUserId()];
            if(usr.AccountId != null){
                affiliateAccount = usr.AccountId;
            }
        }
        
        //Update the cases with the order details, account details and Affiliate account details
                for(Case cs: lstCases)
                {
                    if(!caseRecordtypeIds.isEmpty() && caseRecordtypeIds.contains(cs.RecordTypeId))
                    {
                        //DRice 3/13 - If the owner changes, don't set it to EscaalationDispute
                        if(caseOldMap == null){
                            //cs.OwnerId = EnvironmentSpecificIds__c.getValues('EscalationDispute').Id__c;
                        } else if((caseOldMap.get(cs.Id).OwnerId != cs.OwnerId) && (caseOldMap.get(cs.Id).Status == 'Submitted')){
                            cs.Status = 'Open';
                        }
                        
                        cs.EscalationDisputes__c = True;
                        if(cs.OrderID__c != '' && mapOrders.get(cs.OrderID__c) != null){
                            cs.OrderName__c = mapOrders.get(cs.OrderID__c).id;
                        }
                        
                        if(cs.AccountNumber__c != '' && mapAccounts.get(cs.AccountNumber__c) != null){
                            cs.Customer_Account__c = mapAccounts.get(cs.AccountNumber__c).id;
                        }
                        if(affiliateAccount != null){
                            cs.Affiliate_Account__c = affiliateAccount;
                        }
                    }
                    //US1039173 - Update region and Requested For fiedls on the case
                    if (webEmailToUserMap.get(cs.SuppliedEmail) != null && Label.Wave_Only_User_Case_Record_Type == cs.RecordTypeId){
                       cs.Requested_For__c = webEmailToUserMap.get(cs.SuppliedEmail).Id;
                       cs.Region__c = webEmailToUserMap.get(cs.SuppliedEmail).Region__c;
                    }
                }
    }
    
    /**
    * @Description: This method will give edit access to 
    *               the user who has created the record 
    *               in case of owner change to add attachments.                 
    * @Author: Mandeep Singh, Accenture
    * @Modified: Mangesh Wanjari, Accenture-11 July 2016.
    * @Last Modified: Malay Desai, Accenture- 12 Oct 2017.
    * @Created Date: 15 June, 2016
    * @Return: void.
    */
    public static void caseRecordAccess(Map<id,case> caseOldMap,List<Case> caseList){
        List<CaseShare> sharesToCase = new List<CaseShare>();
        CaseShare csShare = new CaseShare();
        CaseShare csShareRequestedFor = new CaseShare();
        Id caseId;
        Id createdBy;
        Id requestedFor;
        User requestedForUser;
        Set<String> recordTypeSet = getCaseRecordTypes();
        try{
            for(Case cs : caseList){
                if(!recordTypeSet.isEmpty() && recordTypeSet.contains(cs.RecordTypeId)){
                        caseId = cs.Id;
                        if(caseOldMap.get(cs.Id).OwnerId != cs.OwnerId){
                            createdBy= cs.CreatedById;
                            // Creating CaseShare record                  
                            csShare.CaseID= caseId;
                            csShare.UserOrGroupId = createdBy ;
                            csShare.CaseAccessLevel= label.EditLabel; 
                            sharesToCase.add(csShare);       
                        }
                        // Share the case record with the "Requested For" user(Enhancement in US729143)
                        if(cs.Requested_For__c != null){
                            requestedFor= cs.Requested_For__c ;
                            //Start : US1199875 - Added check for IsActive for RequestedFor : Malay Desai
                            requestedForUser = [SELECT Id, IsActive FROM User WHERE Id =:requestedFor];
                            if(requestedForUser.IsActive){
                           ////End : US1199875 - Added check for IsActive for RequestedFor : Malay Desai
                                csShareRequestedFor.CaseID= caseId;
                                csShareRequestedFor.UserOrGroupId= requestedFor;
                                csShareRequestedFor.CaseAccessLevel= label.EditLabel;
                                sharesToCase.add(csShareRequestedFor); 
                            }
                        }
                }
            }
            if(!sharesToCase.isEmpty()){  
                database.insert(sharesToCase); 
            }
        }catch(Exception ex){
            system.debug('****Following error occurred****'+ex.getMessage());
        }
    }
   
    
    /**
    * @Description: Assingment rules are not fired from SF1.
                    This method will make sure, the assingment rules
                    are always fired, be it from browser or SF1.
                                     
    * @Author: Malay Desai, Accenture
    * @Date: 27 June, 2016
    * @Return: void.
    */
    public static void fireAssignmentRule(List<Case> newCases){
        List<Id> caseIds = new List<Id>();

        for (Case theCase:newCases) 
            caseIds.add(theCase.Id);
        List<Case> cases = new List<Case>();
        Set<String> recordTypeSet = getCaseRecordTypes();   
        for(Case c : [Select Id,RecordTypeId from Case where Id in :caseIds])
        
        {
            if(!recordTypeSet.isEmpty() && recordTypeSet.contains(c.RecordTypeId)){
                    Database.DMLOptions dmo = new Database.DMLOptions();
         
                    dmo.assignmentRuleHeader.useDefaultRule = true;
                    c.setOptions(dmo);
                    
                    cases.add(c);
            }
        }
        
        Database.upsert(cases);
    }
    
    
    /**
    * @Description: This method will perform a Record Type check
    *               on Case for NSO Record Types 
    * @Author: Ashish Srivastava, Accenture
    * @Date: 30 September, 2016
    * @Return: Set of String containing recordType Ids.
    */
    public static Set<String> getCaseRecordTypes(){
        String labelName = System.Label.CaseRecordType;
        Set<String> recordTypeIdSet = new Set<String>();
        
        if(!String.isBlank(labelName)){
            for(String str: labelName.split(LABEL_NAME_SPLIT )){
                if(str != null){
                    recordTypeIdSet.add(Schema.SObjectType.Case.getRecordTypeInfosByName().get(str).getRecordTypeId());                
                }
            }
        }
        return recordTypeIdSet;
    }
    
    /**
    * @Description: This method will update "Check Incoming Email" fields (before update)(US1186033)
    * @Author: Tejaswini Kasar, Accenture
    * @Date: 23 September, 2017
    * User Story: US1186033 - Case Comments by Email for Retail and Wave Only Case Types
    */
    public static void updateCaseFlag(List<Case> caseList){
        
        Set<String> caseRecordTypesNameSet = new Set<String>{RETAIL_STORE,WAVE_ONLY};//remove hard code
        Map<String,Schema.RecordTypeInfo> caseRecordTypeInfosMap = Case.SObjectType.getDescribe().getRecordTypeInfosByName();
        Set<Id> caseRecordtypeIds = new Set<Id>();
        try{
            for(String str: caseRecordTypesNameSet)
            {
                if(caseRecordTypeInfosMap.get(str) != null){
                    caseRecordtypeIds.add(caseRecordTypeInfosMap.get(str).getRecordTypeId());//getting case record type ids for this operation
                }
            } 
            for(Case cas: caseList){
                if(!caseRecordtypeIds.isEmpty() && caseRecordtypeIds.contains(cas.RecordTypeId)){
                    if(cas.Check_Incoming_Email__c){
                        // flag is set to true in bound email handler
                        // set this flag to false when case comments is added directly in salesforce by user
                          cas.Check_Incoming_Email__c = false;
                    }
               }
            }
        }
        catch (Exception exp) {
            System.debug('***Following exception has occured: ' + exp.getMessage());
        }
    }
    
    /***************************************
    * @Description: This method is for updating Preferred_Email__c by assigned CAR email of Property
    * @Author: Deepika   
    * @Created Date: 24 Oct, 2017
    * @Param: List<Case>
    * @Return: void.
    ****************************************/
    public static void updateEmailforCommunity(List<Case> newCasesList){
        try{
            List<Case> lstCases = new List<Case>();
            if(!newCasesList.isEmpty()){
                lstCases = [SELECT Id,Recordtype.Name,CaseNumber,CreatedBy.Name,Property__r.Name,Property__c,
                            Property__r.Assigned_CAR__r.Email FROM Case 
                            WHERE Id IN : newCasesList LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
            }
            
            String xcpCaseRecordTypesNames = (!String.isBlank(System.Label.XCP_Portal_Record_Type_Names) ? System.Label.XCP_Portal_Record_Type_Names : ConstantHandler.EMPTY_STRING);           
            for(Case cs: lstCases){
                if(xcpCaseRecordTypesNames.contains(cs.RecordType.name)){
                    if(cs.Property__r != null && cs.Property__r.Assigned_CAR__r != null && !String.isBlank(cs.Property__r.Assigned_CAR__r.Email)){
                        cs.Preferred_Email__c = cs.Property__r.Assigned_CAR__r.Email;//Updating Preferred Email
                    	cs.OwnerId = cs.Property__r.Assigned_CAR__c;//Updating Owner
                    }
                }
            }
            Database.update(lstCases, false);
        }
        catch(Exception exp){
            System.debug('***Following exception has occured: ' + exp.getMessage());
        }
    }
    
    /***************************************
    * @Description: This method is for creating EntitySubscription record for cases created from portal,
                    so that auto follow up happen for property professioanl
    * @User Story: US1193504(XCP -  Home Page)
    * @Author: Amit Kumar Pradhan   
    * @Created Date: 24 Oct, 2017
    * @Param: List<Case>
    * @Return: void.
    ****************************************/
    public static void caseFollowUpForXCP(List<Case> newCasesList){     
        List<EntitySubscription> subscriptionList = new List<EntitySubscription>();
        EntitySubscription subscription = new EntitySubscription();
        List<String> xcpCaseRecordTypesNameList = new List<String>();
        Set<String> xcpCaseRecordTypesIdSet = new Set<String>();
        try{
            //Fetching recordtype name from custom label
            if(!String.isBlank(System.Label.XCP_Portal_Record_Type_Names)){
                xcpCaseRecordTypesNameList = System.Label.XCP_Portal_Record_Type_Names.split(ConstantHandler.COMMA);
            }
            
            //Creating recordtype id set of XCP cases
            if(!xcpCaseRecordTypesNameList.isEmpty()){
                Map<String,Schema.RecordTypeInfo> caseRecordTypeInfosMap = Case.SObjectType.getDescribe().getRecordTypeInfosByName();           
                for(String recordTypeName : xcpCaseRecordTypesNameList){
                    if(caseRecordTypeInfosMap.get(recordTypeName) != null){
                        xcpCaseRecordTypesIdSet.add(caseRecordTypeInfosMap.get(recordTypeName).getRecordTypeId());
                    }
                }
            }
            
            //Fetching NetworkId from variable setting
            Variable_Setting__c xcpNetworkId = Variable_Setting__c.getInstance(XCP_NETWORK_ID);            
            if(xcpNetworkId != null && xcpNetworkId.value__c != null && !xcpCaseRecordTypesIdSet.isEmpty()){               
                for(Case caseObj : newCasesList){  
                    if(xcpCaseRecordTypesIdSet.contains(caseObj.RecordTypeId)){
                        //creation of subscription reord to auto follow up while creating case record
                        subscription.ParentId = caseObj.Id;
                        subscription.SubscriberId = caseObj.CreatedById;
                        subscription.NetworkId = xcpNetworkId.value__c;
                        subscriptionList.add(subscription);
                    }
                }               
            }
            if(!subscriptionList.isEmpty()){
                Database.insert(subscriptionList, false);
            }
        }catch (Exception exp) {
            System.debug('***Following exception has occured: ' + exp.getMessage());
        }        
    }
}