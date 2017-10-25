/*************************************************************************************
    Name             : ModuleToPropertyCARAssignment.cls
    Description      : Controller class for Property Assingment page for Module
    Created By       : Accenture
    Created Date     : 10/18/2017
    User Story       :  US1202725: XC Car Modules Properties Related List
 
************************************************************************************/
public class ModuleToPropertyCARAssignment {
    //Define the Variables ****START************
    CustomIterableForPagination obj;
    public list<SobjectInner> propertyInnerObj {get;set;}
    public string strmodule{get;set;}
    public Module__c objmodule{get;set;}
    public boolean isValid{get;set;}
    public list<SobjectInner> propertyInnerList {get; set;}
    public string pName{get; set;}
    public string pcity{get; set;}
    public string pstate{get; set;}
    SobjectInner propInnerObj;
    public boolean isselected{get; set;}
    public boolean issearchparameter{get; set;}
    public string  recordId{get; set;}
    set<String> setpropertyId=new set<string>();
    public static FINAL string STRPARAMETERERROR = 'Please enter atleast one search parameter.';
    public static FINAL string STRCARERROR = 'Please assign a CAR before assigning property.';
    public static FINAL string STRUPDATEERROR = 'Something went wrong with property assignment. Please contact support';
    public static FINAL string STRID = 'Id';
    public static FINAL string STRBACKSLASH = '/';
    //Define the Variables ****END************
    /************************************************************************************************************
        @Name       :   ModuleToPropertyCARAssignment
        @Description:   Constructor for the class
        @Parameters :   None
        @Returns    :   pagereference
    ************************************************************************************************************/
    public ModuleToPropertyCARAssignment (ApexPages.StandardController controller) {  
        strmodule= ApexPages.currentPage().getParameters().get(STRID); //Get the Id of the Module record
        if(strmodule!=null){
        	objmodule = getModulerecord(strmodule);
        }
        isValid = validatemodulerecord(); //Boolean to check the CAR availble on Module record.
        issearchparameter = false; //Set the search block boolean flag to false 
    } 
    /************************************************************************************************************
        @Name       :   getModulerecord
        @Description:   Class to get the Module record
        @Parameters :   None
        @Returns    :   Module record
    ************************************************************************************************************/
    public Module__c getModulerecord (string strmoduleid) {  
    	Module__c objmodule = [Select id, Region__c,Assigned_CAR__c,Assigned_CAR__r.Name from Module__c where Id=:strmoduleid Limit 1]; //Get the Module record based on Id
        return objmodule;
    }
    /************************************************************************************************************
        @Name       :   searchproperty
        @Description:   Method to process the search the Property based on the parameter enter on the Page
        @Parameters :   None
        @Returns    :   pagereference
    ************************************************************************************************************/
    public pagereference searchproperty(){
        if(pName.length()==0 && pcity.length()==0 && pstate.length()==0 ){ //Check the three search condition
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,STRPARAMETERERROR); //Throw and error message in case of issue
            ApexPages.addMessage(myMsg);
             
        }else{
            issearchparameter = true; 
            string searchquery = 'Select id,Name, Assigned_CAR__r.Name,Property_Rank__c,Property_Rank_Status__c,Property_Region__c,Modules__c,Modules__r.Name,City__c,MDU_State__c FROM MDU_Property__c where Property_Region__c = \'' + objmodule.Region__c + '\'AND Property_Rank__c!=null ';
            if(pName.length()>0 && pcity.length()>0 && pstate.length()>0 ){
                searchquery +='AND name like \'%'+pName+'%\' AND City__c = \'' + pcity + '\' AND MDU_State__c = \'' + pstate + '\'';
            }else if(pName.length()>0 && pcity.length()>0 && pstate.length()==0 ){
                searchquery +='AND name like \'%'+pName+'%\' AND City__c = \'' + pcity + '\'';
            }else if(pName.length()>0 && pcity.length()==0 && pstate.length()==0 ){
                searchquery+='AND name like \'%'+pName+'%\'';
            }else if(pName.length()>0 && pcity.length()==0 && pstate.length()>0 ){
                searchquery+='AND name like \'%'+pName+'%\'  AND MDU_State__c = \'' + pstate + '\'';
            }else if(pName.length()==0 && pcity.length()>0 && pstate.length()>0 ){
                searchquery+='AND City__c = \'' + pcity + '\' AND MDU_State__c = \'' + pstate + '\'';
            }else if(pName.length()==0  && pcity.length()==0 && pstate.length()>0 ){
                searchquery+='AND MDU_State__c = \'' + pstate + '\'';
            }else if(pName.length()==0 && pcity.length()>0 && pstate.length()==0 ){
                searchquery+='AND City__c = \'' + pcity + '\'';
            } 
            obj = new CustomIterableForPagination(searchquery,false); //Search the result based on Query passed as Parameter
            obj.setPageSize = 10;
            next();   
       
        }
        return null;
    }
    
    /************************************************************************************************************
        @Name       :   onpropertyselected
        @Description:   Method to select the property across the pagination 
        @Parameters :   None
        @Returns    :   pagereference
    ************************************************************************************************************/
    public void onpropertyselected(){
        if(recordId!=null && recordId.trim()!='' ){
            if( setpropertyId.contains(recordId)){
                setpropertyId.remove(recordId);
            }else{
                    setpropertyId.add(recordId);
                }
            }
    }   
   
    /************************************************************************************************************
        @Name       :   processRequests
        @Description:   Method to Process the Property. Set the Module and CAR based on Module.
        @Parameters :   None
        @Returns    :   pagereference
    ************************************************************************************************************/
    public pagereference processRequests(){
         map<id,MDU_Property__c> mapupdateproperty = new map<id,MDU_Property__c>();
        if(!setpropertyId.Isempty()){
            for(MDU_Property__c objproperty:[Select Assigned_CAR__c,Modules__c from MDU_Property__c where Id IN:setpropertyId]){
                objproperty.Assigned_CAR__c = objmodule.Assigned_CAR__c;
                objproperty.Modules__c = objmodule.id;
                mapupdateproperty.put(objproperty.id,objproperty);
            }
            if(!mapupdateproperty.isEmpty()){
                try{
                    update mapupdateproperty.values(); //update the Property record
                }catch(Exception ex){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, STRUPDATEERROR));
                }
            }
        }
        pagereference pr = new pagereference(STRBACKSLASH + objmodule.id);
        return pr;
    }
  
   /************************************************************************************************************
        @Name       :   validatemodulerecord
        @Description:   Method to Check the Module CAR field .
        @Parameters :   None
        @Returns    :   boolean
    ************************************************************************************************************/
    public boolean validatemodulerecord(){
        boolean isvalidrecord = true;
        if(objmodule.Assigned_CAR__c==null){
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, STRCARERROR));
              isvalidrecord = false;
        }
         return  isvalidrecord;                                                    
    }
   //Method to check next page 
   public Boolean hasNext {get{if(obj!=null){return obj.hasNext();}else{return false;}}set;
   }
    //Method to check previous page 
   public Boolean hasPrevious {get{if(obj!=null){return obj.hasPrevious();}else{return false;}}set;
    }
    //Method to check next list 
    /************************************************************************************************************
        @Name       :   next
        @Description:   method to get the next set of record
        @Parameters :   None
        @Returns    :   none
    ************************************************************************************************************/
    public void next() {
        propertyInnerList = obj.next();
    }
    /************************************************************************************************************
        @Name       :   previous
        @Description:    method to get the previous set of record
        @Parameters :   None
        @Returns    :   boolean
    ************************************************************************************************************/
    public void previous() {
        propertyInnerList = obj.previous();
    }
    
}