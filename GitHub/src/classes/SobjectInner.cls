/*************************************************************************************
    Name             : SobjectInner.cls
    Description      : Wrapper global class for Property and select checkbox
    Created By       : Accenture
    Created Date     : 10/18/2017
    User Story		 : US1202725: XC Car Modules Properties Related List
 
************************************************************************************/
global Class SobjectInner{
    public boolean isSelected {get;set;}
    public MDU_Property__c propertyInnerObj {get;set;}
   /************************************************************************************************************
        @Name       :   SobjectInner
        @Description:   Constructor for the class
        @Parameters :   None
        @Returns    :   None
    ************************************************************************************************************/
    public SobjectInner(boolean isSelected, MDU_Property__c propertyInnerObj){
        this.isSelected = isSelected;
        this.propertyInnerObj = propertyInnerObj;
    }
    
}