/*************************************************************************************
    Name             : ModuleToPropertyCARUnAssign.cls
    Description      : Controller class for Property Un-Assingment page for Module
    Created By       : Accenture
    Created Date     : 10/18/2017
    User Story		 : 	US1202725: XC Car Modules Properties Related List
 
************************************************************************************/
public class ModuleToPropertyCARUnAssign {
    //Define the Variables ****START************
    CustomIterableForPagination obj;
    public list<SobjectInner> propertyInnerObj {get;set;}
    public string strmodule{get;set;}
    public Module__c objmodule{get;set;}
    public boolean isselected{get; set;}
    public string  recordId{get; set;}
    set<String> setpropertyId=new set<string>();
    public static FINAL string STRUPDATEERROR = 'Something went wrong with property assignment. Please contact support';
    public static FINAL string STRID = 'Id';
    public static FINAL string STRBACKSLASH = '/';
    //Define the Variables ****END************
    /************************************************************************************************************
        @Name       :   ModuleToPropertyCARUnAssign
        @Description:   Constructor for the class
        @Parameters :   None
        @Returns    :   None
    ************************************************************************************************************/
   public ModuleToPropertyCARUnAssign (ApexPages.StandardController controller) {  
        strmodule= ApexPages.currentPage().getParameters().get(STRID);
        if(strmodule!=null){
        	objmodule = getModulerecord(strmodule);
        	obj = new CustomIterableForPagination(objmodule.id,true); 
        	obj.setPageSize = 10;
        	next();
        }
        
    }
    /************************************************************************************************************
        @Name       :   getModulerecord
        @Description:   Class to get the Module record
        @Parameters :   None
        @Returns    :   Module record
    ************************************************************************************************************/
    public Module__c getModulerecord (string strmoduleid) {  
    	Module__c objmodule = [Select id, Region__c,Assigned_CAR__c,Assigned_CAR__r.Name from Module__c where Id=:strmodule LIMIT 1];
        return objmodule;
    }
    /************************************************************************************************************
        @Name       :   onpropertyselected
        @Description:   Method for selecting Property on mutiple paginated page
        @Parameters :   None
        @Returns    :   void
    ************************************************************************************************************/
    public void onpropertyselected(){
		if(recordId!=null && recordId.trim()!='' ){
         	if(	setpropertyId.contains(recordId)){
               	setpropertyId.remove(recordId);
            }else{
                    setpropertyId.add(recordId);
                }
            }
	} 
    /************************************************************************************************************
        @Name       :   processRequests
        @Description:   Method for process selected record. This method will remove the property from Module
        @Parameters :   None
        @Returns    :   Pagereference
    ************************************************************************************************************/
    public pagereference processRequests(){
         map<id,MDU_Property__c> mapupdateproperty = new map<id,MDU_Property__c>();
        if(!setpropertyId.Isempty()){
            for(MDU_Property__c objproperty:[Select Assigned_CAR__c,Modules__c from MDU_Property__c where Id IN:setpropertyId  LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                objproperty.Assigned_CAR__c = null;
                objproperty.Modules__c = null;
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
    //Getter setter for next button
    public Boolean hasNext {
        get {return obj.hasNext();} set;
    } 
    //Getter setter for Previous button
    public Boolean hasPrevious {
        get {return obj.hasPrevious();}set;
    }
   /************************************************************************************************************
        @Name       :   next
        @Description:   method to get the next set of record
        @Parameters :   None
        @Returns    :   none
    ************************************************************************************************************/
    public void next() {
        propertyInnerObj = obj.next();
    }
    /************************************************************************************************************
        @Name       :   previous
        @Description:    method to get the previous set of record
        @Parameters :   None
        @Returns    :   boolean
    ************************************************************************************************************/
    public void previous() {
        propertyInnerObj = obj.previous();
    }
    
}