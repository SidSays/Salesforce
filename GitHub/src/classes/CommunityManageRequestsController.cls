/**
*Class Name :       CommunityManageRequestsController
*CreatedBy :        Accenture
*CreatedDate :      July-2017
*Description :      US1193371 -XCP Request Listing
*Modification History:
*/
public  with Sharing class CommunityManageRequestsController {
	
 	/***************************************
    * @MethodName: fetchUsercases
    * @Author : Suchita, Accenture
    * @Date : 9-Oct-2017 
    * @Description : Method to fetch case list
    * @UserStory : US1193371 -XCP Request Listing
    * @Return : List<case>
    *****************************************/
   @AuraEnabled
    public static List<case> fetchUsercases(){
      
      List<String> xcpCaseRecordTypesNameSet = null;
      if(!String.isBlank(System.Label.XCP_Portal_Record_Type_Names))
      {
        xcpCaseRecordTypesNameSet= System.Label.XCP_Portal_Record_Type_Names.split(ConstantHandler.COMMA);
      }
        try{                                 
            return [select id,property__c,Property__r.Name, RecordType.Name, CaseNumber,Status from case where RecordType.Name IN : xcpCaseRecordTypesNameSet AND CreatedbyId =: UserInfo.getUserId()];
        }catch(Exception ex){
            System.debug(ex.getMessage());
            return null;
        }
        
    }
    
    
    /***************************************
    * @MethodName: getAllRequestTypesForCommunityPortal
    * @Author : Sagarika, Accenture
    * @Date : 20-Oct-2017 
    * @Description : Method to retrive all communnity portal request types
    * @UserStory : US1193371 -XCP Request Listing
    * @Return : List<String>
    *****************************************/
    @AuraEnabled
    public static List<String> getAllRequestTypesForCommunityPortal(){
      
      List<String> xcpCaseRecordTypesNameSet = null;
      if(!String.isBlank(System.Label.XCP_Portal_Record_Type_Names))
      {
        xcpCaseRecordTypesNameSet= System.Label.XCP_Portal_Record_Type_Names.split(ConstantHandler.COMMA);
      }
        List<String> options = new List<String>();
        for(String requestType : xcpCaseRecordTypesNameSet)
        {
            options.add(requestType);
        }  
        return options;
    }
    
    
    /***************************************
    * @MethodName: getRequestTypeValue
    * @Author : Suchita, Accenture
    * @Date : 9-Oct-2017 
    * @Description : Method to retrive picklist values
    * @UserStory : US1193371 -XCP Request Listing
    * @Return : List<String>
    *****************************************/
    @AuraEnabled
    public static List<String> getPropertyValue(){
        List<String> xcpCaseRecordTypesNameSet = null;
    Set<String> propertyNameSet = new Set<String>();
        List<String> proplist = new List<String>();
      if(!String.isBlank(System.Label.XCP_Portal_Record_Type_Names))
      {
        xcpCaseRecordTypesNameSet= System.Label.XCP_Portal_Record_Type_Names.split(ConstantHandler.COMMA);
      }
        try{                                 
            List<case> caseslst = [select id, Property__c,Property__r.Name from case where RecordType.Name IN : xcpCaseRecordTypesNameSet AND CreatedbyId =: UserInfo.getUserId()];
      for(case cases : caseslst)
      {
        if(cases.Property__c !=null && cases.Property__r.Name != null)
          propertyNameSet.add(cases.Property__r.Name);
      }  
      if(!propertyNameSet.isEmpty()){
                proplist.addAll(propertyNameSet);
        return proplist;
            }else{
                return null;
            }
        }catch(Exception ex){
            System.debug(ex.getMessage());
            return null;
        }
    }
}