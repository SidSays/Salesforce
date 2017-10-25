/*************************************************************************************
    Name             : CustomIterableForPagination.cls
    Description      : Class for custom pagination for Assing and unassign property
    Created By       : Accenture
    Created Date     : 10/18/2017
    User Story		 : US1202725: XC Car Modules Properties Related List
 
************************************************************************************/
global class CustomIterableForPagination implements Iterator<list<SobjectInner>>{ 

   List<MDU_Property__c> lstproperty {get; set;} 
   list<SobjectInner> propertyInnerList {get; set;} 
   list<SobjectInner> propertyInnerListRequested {get; set;} 
   SobjectInner propInnerObj;
   Integer i {get; set;} 
   public Integer setPageSize {get; set;} 
   /************************************************************************************************************
        @Name       :   CustomIterableForPagination
        @Description:   Constructor for the Class
        @Parameters :   string, boolean	
        @Returns    :   void
    ************************************************************************************************************/
   public CustomIterableForPagination(string strregion,boolean scope){ 
       if(!scope){  //IF condition for Assigning Property
           lstproperty = database.query(strregion);
           propertyInnerList = new list<SobjectInner>(); 
           propertyInnerListRequested = new list<SobjectInner>();     
           for(MDU_Property__c a : lstproperty) {
                propInnerObj = new SobjectInner(false, a);
                propertyInnerList.add(propInnerObj);
                
           }
           setPageSize = 10;
           i = 0; 
     }else{   //Else condition for Un-Assigning Property
           propertyInnerList = new list<SobjectInner>(); 
           propertyInnerListRequested = new list<SobjectInner>();     
           for(MDU_Property__c a : [SELECT Name, Assigned_CAR__r.Name,Property_Rank__c,Property_Rank_Status__c,Modules__r.Name,
           							Modules__c,City__c,MDU_State__c FROM MDU_Property__c where Modules__c =:strregion  
           							LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) {
                propInnerObj = new SobjectInner(false, a);
                propertyInnerList.add(propInnerObj);
                
           } 
           setPageSize = 10;
           i = 0; 
       }
   }
  /************************************************************************************************************
        @Name       :   hasnext
        @Description:   method to get the next set of record
        @Parameters :   None
        @Returns    :   boolean
    ************************************************************************************************************/
   global boolean hasNext(){ 
       if(i >= propertyInnerList.size()) {
           return false; 
       } else {
           return true; 
       }
   } 
    /************************************************************************************************************
        @Name       :   hasPrevious
        @Description:   method to get the previous set of record
        @Parameters :   None
        @Returns    :   boolean
    ************************************************************************************************************/
   global boolean hasPrevious(){ 
       if(i <= setPageSize) {return false; } else {return true; }
   }   
 /************************************************************************************************************
        @Name       :   next
        @Description:   method to get the previous set of record
        @Parameters :   None
        @Returns    :   list of sObjectInner
    ************************************************************************************************************/
   global list<SobjectInner> next(){       
       propertyInnerListRequested = new list<SobjectInner>(); 
       integer startNumber;
       integer size = propertyInnerList.size();
       if(hasNext())
       {  
           if(size <= (i + setPageSize))
           {
               startNumber = i;
               i = size;
           }
           else
           {
               i = (i + setPageSize);
               startNumber = (i - setPageSize);
           }
                     
           for(integer start = startNumber; start < i; start++)
           {
               propertyInnerListRequested.add(propertyInnerList[start]);
           }
       } 
       return propertyInnerListRequested;
   } 
  /************************************************************************************************************
        @Name       :   previous
        @Description:   method to get the previous set of record
        @Parameters :   None
        @Returns    :   list of sObjectInner 
    ************************************************************************************************************/
   global list<SobjectInner> previous(){      
       propertyInnerListRequested = new list<SobjectInner>(); 
       integer size = propertyInnerList.size(); 
       if(i == size)
       {
           if(math.mod(size, setPageSize) > 0)
           {    
               i = size - math.mod(size, setPageSize);
           }
           else
           {
               i = (size - setPageSize);
           } 
       }
       else
       {
           i = (i - setPageSize);
       }
       
       for(integer start = (i - setPageSize); start < i; ++start)
       {
           propertyInnerListRequested.add(propertyInnerList[start]);
       } 
       return propertyInnerListRequested;
   }   
}