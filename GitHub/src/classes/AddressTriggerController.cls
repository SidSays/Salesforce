/***************************************************************************************************************************************
 * Author              : Amitkumar Bangad
 * Date                : 25-April-2013
 * Description         : Contains Supporting actions for Customer Address Triggers
 * Last Modified       : Malay Desai
 * Requirement         : US583744: Business Partner: Manager hierarchy access
 * Date                : 9-MAR-2015  
 * Modified By: Animesh
 * Modified Date: 25-Jul-2017
 * Modification Details: US1137083 - System Engineering : Apex CPU Limit Exceed Error when updating Plan Details. Bypassing trigger when PlanEdit is executed 
 * Modified By: Animesh
 * Modified Date: 05-September-2017
 * Modification Details: US1111592 - Territory - Trigger to handle Census Changes
 * Modified By: Srini Bhattiprolu
 * Modified Date: 6-Sep-2017
 * Modification Details: Defect Fix: US1129121 - Direct - Dynamic Turf and DSM Limits
 * Modified By: Animesh Datta
 * Modified Date: 27-Sep-2017
 * Modification Details: US1193816 - Direct: New Build
 * Modified By: Srini Bhattiprolu
 * Modified Date: 27-Sep-2017
 * Modification Details: US1188961 - Direct - Dynamically Remove HSI only to Non HSI Addresses from Turf
 * Modified By: Animesh Datta
 * Modified Date: 02-Oct-2017
 * Modification Details: US1193834 - Direct: New Build Targeted
 * Modified By: Srini Bhattiprolu
 * Modified Date: 03-Oct-2017
 * Modification Details: US1130517 - Territory - Remove 'Excluded from Territory' from Turf & Targeted
 * Modified Date: 10-Oct-2017
 * Modification Details: Changed the Logic to add EBI refresh issues for Bypassing the Dynamic turf assingnment 
 * Modified By: Srini Bhattiprolu
 * Modified Date: 11-Oct-2017
 * Modification Details: US1203051 - Dynamic Turf: No affect on Non Territory Model
 * Modified By: Animesh Datta
 * Modified Date: 20-Oct-2017
 * Modification Details: US1188913 - Direct - Dynamically Add Marketable Addresses to Turf
***************************************************************************************************************************************/
public class AddressTriggerController {
    private static final string STR_HSIONLYINCLUDED = 'HSI Only Included=false';
    private static final string STR_ADDRESSMAXLIMITPERTURF = 'AddressMaxLimitPerTurf'; //US1129121 - Added by Srini Bhattiprolu
    private static final string STR_TURFPLANNING = 'Turf Planning'; //US1129121 - Added by Srini Bhattiprolu
    private static final string STR_NONMARKETABLEEXCLUDED = 'Non-Marketable Addresses Excluded=true'; //US1159184 changes
    public static boolean byPassFromPlanEdit = true;// US1137083 - Animesh - 25-Jul-2017
    private static final string STR_SFU = 'SFU';
    private static final string STR_SINGLE_FAMILY_UNIT = 'Single Family Unit';
    private static final string STR_ACTIVE = 'Active';
    private static final string STR_A = 'A';
    private static final string STR_FORMER = 'Former';
    private static final string STR_UNDERSCORE = '_';
    private static final string STR_HSIONLYINCLUDEDTRUE = 'HSI Only Included=true';

    /**
    * @Description: This method sets the Disconnect Checkbox to True and clears the Complex Office Checkbox if Criteria are met.
    * @Author: Erin McGee, Acumen Solutions
    * @Date: 23-December-2014
    * @Param: Trigger.New
    * @Return: void.
    * @LastUpdatedBy : Malay Desai, Accenture
    * Modified By: Animesh
    * Modified Date: 25-Jul-2017
    * Modification Details: US1137083 - System Engineering : Apex CPU Limit Exceed Error when updating Plan Details. Added Try Catch
    */
    public static void setCheckboxes(List<Customer_Address__c> newAddressList) {
        try{
            List<Customer_Address__c> addressList= new List<Customer_Address__c>();
            for(Customer_Address__c addr: newAddressList){
                if(STR_FORMER.equalsIgnoreCase(addr.Status__c) && !addr.Disconnected__c){
                    addr.Disconnected__c=true;
                } else if (!STR_FORMER.equalsIgnoreCase(addr.Status__c) && addr.Disconnected__c){
                    addr.Disconnected__c=false;
                }else{}
            }
        }catch(Exception exp){System.debug('***Following error occurred***'+exp.getMessage());}
    }

    /**
    * @Description: This method sets the Address Standard Division.
    * @Author: Amitkumar Bangad, Accenture
    * @Date: 25-April-2013
    * @Param: Trigger.New
    * @Return: void.
    * Modified By: Animesh
    * Modified Date: 25-Jul-2017
    * Modification Details: US1137083 - System Engineering : Apex CPU Limit Exceed Error when updating Plan Details. Added Try Catch
    */
    public static void setAddressDivisionAndDisconnected(List<Customer_Address__c> newAddressList) {
        try{
            Set<Id> divisionIds = new Set<Id>();
            Set<String> divisionNames = new Set<String>();
            Map<String, Id> divisionIdbyName = new Map<String, Id> ();
            for(Customer_Address__c addr: newAddressList){
                if(addr.Region__c != null){
                    divisionNames.add(addr.Region__c);  
                } else{
                    divisionNames.add(Label.DivisionGlobal);
                }
            }
            if(!divisionNames.IsEmpty()){
                for(Division div: [SELECT Id, Name FROM Division WHERE name=: divisionNames]){
                    divisionIdbyName.put(div.name, div.Id);    
                }
                for(Customer_Address__c ad: newAddressList){
                    if(ad.Region__c != null){
                        ad.Division = divisionIdbyName.get(ad.Region__c); 
                    } else{
                        ad.Division = divisionIdbyName.get(Label.DivisionGlobal);  
                    }
                }
            }else{}
        }catch(Exception exp){System.debug('***Following error occurred***'+exp.getMessage());}
    }
    
    /**
    * @Description: US583744: Business Partner: Manager hierarchy access
    * @Author: Radhika Bansal, Accenture
    * @Date: 3-Nov-2015
    * @Param: Trigger.New
    * @Return: void
    * Modified By: Animesh
    * Modified Date: 25-Jul-2017
    * Modification Details: US1137083 - System Engineering : Apex CPU Limit Exceed Error when updating Plan Details. Added Try Catch
    */
    public static void addressShareAccess(List<Customer_Address__c> addressdata){
        try{
            List<User> newUsers = new List<User>(); // To create the list of users sepcific to Profile Contractor Sales Professional;
            List<Customer_Address__Share> addShares = new List<Customer_Address__Share>();
            Set<Id> ownerList = new Set<Id>();
            // To Create a list of owners for the Address records
            for(Customer_Address__c address : addressdata){
                ownerList.add(address.OwnerId);
            }
            String profileName = System.Label.Contractor_Direct_Sales_Representative;
            String manager = System.Label.Manager;
            newUsers= [Select id from user where Id IN :ownerList and Profile.name = :profileName  LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
            Map<Id, Id> groupMap = new Map<Id, Id>(); // To map the user id with its manager hierarchy
            for(Group g : [SELECT Id, RelatedId,Type FROM Group WHERE Type = :manager AND RelatedId IN :newUsers]){
                groupMap.put(g.RelatedId, g.Id);
            }
            // The below code assign the Address record access to the manager hierarchy of the user.
           Customer_Address__Share adRecord ;
            for(Customer_Address__c address : addressdata){
                if(!groupMap.isEmpty() && groupMap.get(address.OwnerId)!=null){
                     adRecord = new Customer_Address__Share();
                    adRecord.ParentId = address.Id;
                    adRecord.userorgroupId = groupMap.get(address.OwnerId);
                    adRecord.AccessLevel = System.Label.EditAddressTriggerController;
                    //adRecord.rowCause = Schema.Customer_Address__Share.rowCause.Manual;
                    addShares.add(adRecord);
                }else{}
            }
            if(!addShares.isEmpty()){
                Database.SaveResult[] CoachingShareInsertResult = Database.insert(addShares ,false);
            }
        }catch(Exception exp){System.debug('***Following error occurred***'+exp.getMessage());}
    }
    /*
    public static Map<String, Id> buildRegionGroupMap(){
        
        Map<String,String> groupRegionMap = new Map<String,String>(); // Map containing Public Group Name and correspodning Region
        Map<String, Id> groupMap = new Map<String, Id>(); // Map containing Region and corresponding Public Group's Id
        
        for(Address_Regional_Sharing__c record : Address_Regional_Sharing__c.getAll().values()){            
            if(record != null){
                groupRegionMap.put(record.Public_Group__c, record.Region__c);
            }
        }
        
        for(Group publicGroup : [SELECT id,Name FROM Group WHERE Name IN :groupRegionMap.keySet()  LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){            
            if(publicGroup!=null){
                groupMap.put(groupRegionMap.get(publicGroup.Name), publicGroup.Id); //Region vs corresponding GroupId
            }
        }
        return groupMap;
    }
    */
     /**
    * @Description: US596845: Address regional sharing: Part 1
    * @Author: Malay Desai, Accenture
    * @Date: 31-DEC-2015
    * @Param: List of Addresses to Share
    * @Return: null
    */
    /* Commented for US596845
    public static void shareAddressWithinRegionalGroups(List<Customer_Address__c> addressList){
        List<Customer_Address__Share> addressShareList = new List<Customer_Address__Share>();
        Map<String, Id> groupMap = buildRegionGroupMap();
        String rowCause = Schema.Customer_Address__Share.rowCause.Region__c;
        
        for(Customer_Address__c address : addressList){
            Customer_Address__Share addressShare = new Customer_Address__Share();
            addressShare.parentId = address.Id;
            addressShare.userorgroupId = groupMap.get(address.Region__c);
            Address_Regional_Sharing__c tempCS = Address_Regional_Sharing__c.getValues(address.Region__c);
            addressShare.AccessLevel = tempCS != null? tempCS.Access_Level__c:System.Label.EditAddressTriggerController;
            addressShare.rowCause = rowCause;
            addressShareList.add(addressShare);         
        }
        
        if(!addressShareList.isEmpty()){
          List<Database.SaveResult> srList = Database.insert(addressShareList,false);
    
            for(Database.SaveResult sr : srList){            
            if(!sr.isSuccess()){                                                 
                for(Database.Error error : sr.getErrors()){
                    System.Debug('Error Fields : '+ error.getFields());
                    System.Debug('Error Message : ' + error.getMessage());
                    System.Debug('Error Status Code : ' + error.getStatusCode());                                                              
                 }
            }
          }
      }
        
    }
    */
    
     /**
    * @Description: US596845: Address regional sharing: Part 1
    * @Author: Malay Desai, Accenture
    * @Date: 31-DEC-2015
    * @Param: List of Addresses for which sharing needs to be added or removed
    * @Return: null
    */
    /*
    public static void updateAddressSharingOnRegionChange(List<Customer_Address__c> addressList, Map<Id,Customer_Address__c> oldAddressMap){
        List<Customer_Address__c> newAddressList = new List<Customer_Address__c>();
        List<Customer_Address__c> oldAddressList = new List<Customer_Address__c>();
        for(Customer_Address__c address : addressList){
            if(address.Region__c != null && address.Region__c != oldAddressMap.get(address.Id).Region__c){
                newAddressList.add(address);
                oldAddressList.add(oldAddressMap.get(address.Id));
            }
        }
        unshareAddressWithRegionalGroups(oldAddressList);
        shareAddressWithinRegionalGroups(newAddressList);
    }
    */
    /**
    * @Description: US596845: Address regional sharing: Part 1
    * @Author: Malay Desai, Accenture
    * @Date: 31-DEC-2015
    * @Param: List of Addresses for which sharing needs to be removed
    * @Return: null
    */
    /*
     public static void unshareAddressWithRegionalGroups(List<Customer_Address__c> addressList){
        
        Set<Id> addressIds = new Set<Id>();
        List<Customer_Address__Share> addressShareList;
        for(Customer_Address__c address : addressList){
            addressIds.add(address.Id);
        }
        
        if(addressIds.size() > 0){
            addressShareList = [SELECT id FROM Customer_Address__Share WHERE parentId IN :addressIds];
        
        
        List<Database.DeleteResult> srList = Database.delete(addressShareList,false);
    
            for(Database.DeleteResult sr : srList){            
            if(!sr.isSuccess()){                                                 
                for(Database.Error error : sr.getErrors()){
                    System.Debug('Error Fields : '+ error.getFields());
                    System.Debug('Error Message : ' + error.getMessage());
                    System.Debug('Error Status Code : ' + error.getStatusCode());                                                              
                 }
            }
          }
        }
     }
    */ 
    /**
    * @Description: To set the Property__c lookup on Address records
    * @Author: Malay Desai, Accenture
    * @Date: 31-DEC-2015
    * @Param: Trigger.new
    * @Return: null
    * Modified By: Animesh
    * Modified Date: 25-Jul-2017
    * Modification Details: US1137083 - System Engineering : Apex CPU Limit Exceed Error when updating Plan Details. Added Try Catch
    */
    public static void setPropertyToAddress(List<Customer_Address__c> address){
        try{
            Map<Customer_Address__c, String> addressCodesMap = new Map<Customer_Address__c,String>();
            Map<String, Id> addressCodeIDMap;         
            for(Customer_Address__c addr:address){
                if(addr.Property_Code__c != null && addr.Corp__c !=null && addr.Region__c !=null)
                    addressCodesMap.put(addr,addr.Property_Code__c+STR_UNDERSCORE+addr.Corp__c+STR_UNDERSCORE+addr.Region__c );
            } 
            if(addressCodesMap.size() > 0){
                List<MDU_Property__c> properties = [SELECT Id,Address_Code__c FROM MDU_Property__c WHERE Address_Code__c IN:addressCodesMap.values()];
                if(properties != null && !properties.isEmpty()){
                    addressCodeIDMap = new Map<String, Id>();
                    for(MDU_Property__c property : properties){
                        addressCodeIDMap.put(property.Address_Code__c, property.Id);
                    }
                    for(Customer_Address__c cAddress :addressCodesMap.keySet()){
                        cAddress.property__c = addressCodeIDMap.get(addressCodesMap.get(cAddress));
                    }
                }
            }
            
             /*if(properties!= null && !properties.isEmpty()){
                 for(MDU_Property__c prop:properties){
                    for(Customer_Address__c cAddress :addressCodesMap.keySet()){
                        System.debug('*** addressCodesMap is null : ' + (addressCodesMap == null));
                        System.debug('*** addressCodesMap value: ' + addressCodesMap.get(cAddress));
                        if(addressCodesMap.get(cAddress).equalsIgnoreCase(prop.Address_Code__c)){
                            cAddress.property__c = prop.Id;
                        }
                    }
                 }
            } */
        }catch(Exception exp){System.debug('***Following error occurred***'+exp.getMessage());}
    }
    /**
    * @Description: To remove the Property__c lookup on Address records
    * @Author: Ashish Srivastava, Accenture
    * @Date: 18-March-2016
    * @Param: Trigger.new
    * @Return: null
    * Modified By: Animesh
    * Modified Date: 25-Jul-2017
    * Modification Details: US1137083 - System Engineering : Apex CPU Limit Exceed Error when updating Plan Details. Added Try Catch
    */
    public static void removePropertyFromAddress(List<Customer_Address__c> addressList){
        try{
            for(Customer_Address__c address : addressList){
                if(address.Property_Code__c == null || address.Corp__c== null || address.Region__c == null){
                        address.property__c = null;
                }
            }
        }catch(Exception exp){System.debug('***Following error occurred***'+exp.getMessage());}
    }
    /**
    * @Description: Create Property button parent validation
    * @Author: Shivani Gautam, Accenture
    * @Date: 17th Jan 2017
    * @Param: Trigger.new
    * @Return: null
    * Modified By: Animesh
    * Modified Date: 25-Jul-2017
    * Modification Details: US1137083 - System Engineering : Apex CPU Limit Exceed Error when updating Plan Details. Added Try Catch
    * Modified By: Animesh Datta
    * Modified Date: 27-Sep-2017
    * Modification Details: US1193816 - Direct: New Build - Set new field "New_Build__c" to true if newly added address is SFU
    * Modified By: Animesh Datta
    * Modified Date: 02-Oct-2017
    * Modification Details: US1193834 - Direct: New Build Targeted
    */
    public static void setIsNewOnAddress(List<Customer_Address__c> addressList){
        try{
            for(Customer_Address__c address : addressList){
                address.Is_New__c = true;
                //start - US1193816
                if(!String.isBlank(address.Dwelling_Type__c) && 
                STR_SFU.equalsIgnoreCase(address.Dwelling_Type__c) || STR_SINGLE_FAMILY_UNIT.equalsIgnoreCase(address.Dwelling_Type__c)){
                    address.New_Build__c = true;
                //end - US1193816
                //start - US1193834
                    if(!String.isBlank(address.Territory__c) && !(STR_ACTIVE.equalsIgnoreCase(address.Active_Inactive__c))){//can this formula value be null?
                        address.Targeted__c = true;
                    }
                    else if(!String.isBlank(address.Territory__c) &&  (STR_ACTIVE.equalsIgnoreCase(address.Active_Inactive__c))){
                        address.Targeted__c = false;
                        address.New_Build__c = false;
                    }
                    else{//mainly address does not have a territory
                        address.Targeted__c = false;
                    }
                //end - US1193834
                }
                
            }
        }catch(Exception exp){System.debug('***Following error occurred***'+exp.getMessage());}
    }
    /**
    * @Description: Direct: New Build Targeted(US1193834)
    * @Author: Animesh Datta, Accenture
    * @Date: 02-Oct-2017
    * @Param: Trigger.new, Trigger.oldMap
    * @Return: null
    */
    public static void setTargetedFlag(List<Customer_Address__c> addressList, Map<Id,Customer_Address__c> oldAddressMap){
        try{
            for(Customer_Address__c addr: addressList){
                //check for sfu and new build
                if(addr.New_Build__c && !String.isBlank(addr.Dwelling_Type__c) && 
                    STR_SFU.equalsIgnoreCase(addr.Dwelling_Type__c) || STR_SINGLE_FAMILY_UNIT.equalsIgnoreCase(addr.Dwelling_Type__c)){
                    if(!String.isBlank(addr.Territory__c) && String.isBlank(oldAddressMap.get(addr.Id).Territory__c)){
                        if(!addr.Targeted__c && !(STR_ACTIVE.equalsIgnoreCase(addr.Active_Inactive__c))){
                            addr.Targeted__c = true;
                        }
                        else if((STR_ACTIVE.equalsIgnoreCase(addr.Active_Inactive__c))){
                            addr.Targeted__c = false;
                            addr.New_Build__c = false;
                        }
                    }
                    else if(!String.isBlank(addr.Territory__c) && !String.isBlank(oldAddressMap.get(addr.Id).Territory__c) && 
                    !String.isBlank(addr.Account__c) && (STR_ACTIVE.equalsIgnoreCase(addr.Active_Inactive__c))){
                        if(addr.Targeted__c){
                            addr.Targeted__c = false;
                        }
                        if(addr.New_Build__c){
                            addr.New_Build__c = false;
                        }
                    }
                }
            }
        }catch(Exception exp){System.debug('Exception: '+exp.getMessage());}
    }
    /**
    * @Author: 
    * @Date: 
    * @Param: Trigger.new,Trigger.oldMap
    * @Return: null
    * Modified By: Animesh
    * Modified Date: 25-Jul-2017
    * Modification Details: US1137083 - System Engineering : Apex CPU Limit Exceed Error when updating Plan Details. Added Try Catch
    */
    public static void setFlagOnRemovingParentAddress(List<Customer_Address__c> addressList, Map<Id,Customer_Address__c> oldAddressMap){
        try{
        for(Customer_Address__c address : addressList){
            if(address.Parent_Address__c == null && oldAddressMap.get(address.Id).Parent_Address__c != null){
                address.Is_New__c = true;
            }
        }
        }catch(Exception exp){System.debug('***Following error occurred***'+exp.getMessage());}
    }
    
    /**
    * @Description: updating total no of worked field in Plan
    * @Author: Amit Kumar Pradhan, Accenture
    * @Date: 23-Feb-2017
    * @Param: Trigger.new, Trigger.oldMap
    * @Return: null
    * Modified By: Animesh
    * Modified Date: 25-Jul-2017
    * Modification Details: US1137083 - System Engineering : Apex CPU Limit Exceed Error when updating Plan Details. Added Try Catch
    */
    public static void updateTotalWorkedAddrOnPlan(List<Customer_Address__c> newAddrList, Map<Id,Customer_Address__c> oldAddrMap){   
        try{
            Map<String,Integer> planIdAndWorkedCountMap = new Map<String,Integer>();
            for(Customer_Address__c address : newAddrList){
                if(address.Plan__c != null && address.Worked__c != oldAddrMap.get(address.Id).Worked__c){
                    Integer tempCount = 0;
                    if(planIdAndWorkedCountMap.containsKey(address.Plan__c)){
                        tempCount = planIdAndWorkedCountMap.get(address.Plan__c);
                    }
                    
                    if(address.Worked__c){
                        tempCount++;
                    }else{
                        tempCount--;
                    }
                    planIdAndWorkedCountMap.put(address.Plan__c, tempCount);
                }
            }
            
            if(planIdAndWorkedCountMap != null && !planIdAndWorkedCountMap.isEmpty()){
                List<Plan__c> planList = new List<Plan__c>();
                for(Plan__c planobj : [SELECT Id, Total_Worked_Addresses__c FROM Plan__c WHERE Id IN:planIdAndWorkedCountMap.keySet()]){
                    if(planobj.Total_Worked_Addresses__c == null){
                        planobj.Total_Worked_Addresses__c = 0;
                        planobj.Total_Worked_Addresses__c += planIdAndWorkedCountMap.get(planobj.Id);
                    }
                    else{
                        planobj.Total_Worked_Addresses__c += planIdAndWorkedCountMap.get(planobj.Id);
                    }
                    
                    //planobj.Total_Worked_Addresses__c += planIdAndWorkedCountMap.get(planobj.Id);
                    if(planobj.Total_Worked_Addresses__c < 0){
                        planobj.Total_Worked_Addresses__c = 0;
                    }
                    planList.add(planobj);
                }
                //Srini Bhattiprolu: removed !=null for NovaSuite fixes
                if(!planList.isEmpty()){
                    database.update(planList,false);
                }
            }
        }catch(Exception e){system.debug('***Following exception has occured***: '+e.getMessage());}  
    }
     /**    
    * @Description: US1096534:Direct - Dynamically Remove Inactive to Active Addresses from Turf.
      As a West Division XSP when a Targeted Address in my “Assigned” Turf is no longer Targeted and the Address is removed from my Turf.
      As a Central/NED XSP when a non-HSI Only Targeted Address in my “Assigned” Turf is no longer Targeted and the Address is removed from my Turf 
    * @Author: Amit Kumar, Accenture    
    * @Date: 14-May-2017 
    * @Param:  Trigger.New, Trigger.OldMap    
    * @Return: None 
    * Modified By: Kiran Kumar
    * Modified Date: 09-Aug-2017
    * Modification Details: US1159184- Direct - Dynamically Remove Non Marketable Addresses from Turf
    * Modified By: Srini Bhattiprolu
    * Modified Date: 27-Sep-2017
    * Modification Details: US1188961 - Direct - Dynamically Remove HSI only to Non HSI Addresses from Turf
    * Modified By: Srini Bhattiprolu
    * Modified Date: 03-Oct-2017
    * Modification Details: US1130517 - Territory - Remove 'Excluded from Territory' from Turf & Targeted
    */
    public static void removeaddressfromplan(List<Customer_Address__c> newAddrList, Map<Id,Customer_Address__c> oldAddrMap){  
       User sharedData = [Select Id, Name from User where Name=:ConstantHandler.SHARED_DATA_USER_NAME LIMIT 1];
        try{
        // US1159184 changes Start
            boolean bypassinital  = bypassdynamicturfintial();
            Map<Id,Customer_address__c> mapOfAdd = new Map<Id,Customer_Address__c>([Select Id, Plan__r.Parameters__c from  Customer_Address__c where plan__c != null and Id in :oldAddrMap.keyset()]);
        // US1159184 changes End
        
        // US1188961 changes Start - Map to capture the associated account status of the address
            Map<Id,Customer_address__c> addressVsAccntStatusMap = new Map<Id,Customer_Address__c>([Select Id, Account__r.Customer_Status__c from  Customer_Address__c where Account__c != null and Id in :oldAddrMap.keyset()]);
        // US1188961 changes End            
            for(Customer_Address__c objaddress : newAddrList){
        // US1130517 changes starts
        // The following if block is to remove the address that is excluded from territory from the plan and marked it as not targeted          
               if(objaddress.Plan__c != null && objaddress.Territory__c != null && (objaddress.Excluded_from_Territory__c != oldAddrMap.get(objaddress.Id).Excluded_from_Territory__c || bypassinital) && objaddress.Excluded_from_Territory__c){
                  objaddress.Plan__c = null;
                  objaddress.OwnerId = sharedData.id;
                    if(objaddress.Team__c != null){
                        objaddress.Team__c = null;
                    }
                    if(objaddress.Targeted__c){
                        objaddress.Targeted__c = false;
                    }                   
                }
        // US1130517 changes ends
        // Srini B - Territory check added in the following else if block as part of US1203051
               else if(((objaddress.Targeted__c != oldAddrMap.get(objaddress.Id).Targeted__c && 
                   !objaddress.Targeted__c) ||bypassinital) && objaddress.Plan__c!=null && 
                   !(string.Isblank(objaddress.Comcast_Division__c)) && objaddress.Territory__c != null){
                    if(objaddress.Comcast_Division__c.equalsIgnoreCase(ConstantHandler.STR_WEST_NAME)){
                        objaddress.Plan__c = null;
                        objaddress.OwnerId = sharedData.id;
                        objaddress.Team__c = null; // Added as a part of US1177812
                    } else if(((objaddress.Comcast_Division__c.equalsIgnoreCase(ConstantHandler.STR_NORTHEAST_NAME)) || (objaddress.Comcast_Division__c.equalsIgnoreCase(ConstantHandler.STR_CENTRAL_NAME)))
                      &&(objaddress.HSI_Only__c).equalsIgnoreCase(ConstantHandler.STR_HSIONLY_NO_VAL)){
                        objaddress.Plan__c = null;
                        objaddress.OwnerId = sharedData.id;
                        objaddress.Team__c = null; // Added as a part of US1177812
                        }
                }
            // US1159184 changes start
            // Srini B - Territory check added in the if block as part of US1203051
                if(objaddress.Plan__c != null && !String.isBlank(mapOfAdd.get(objAddress.Id).Plan__r.Parameters__c) 
                && mapOfAdd.get(objAddress.Id).Plan__r.Parameters__c.containsIgnoreCase(STR_NONMARKETABLEEXCLUDED) 
                && objaddress.Non_Marketable__c == true && (objaddress.Non_Marketable__c != oldAddrMap.get(objaddress.Id).Non_Marketable__c || bypassinital) && objaddress.Territory__c != null){
                    objaddress.Plan__c = null;
                    objaddress.OwnerId = sharedData.id;
                    objaddress.Team__c = null; // Added as a part of US1177812
                }
            // US1159184 changes end
                
            // US1188961 changes Start
            //The following if block is to remove the address from the plan when address converts from HSI Only to Non-HSI
                if(objaddress.Plan__c != null && objaddress.Territory__c != null && (objaddress.HSI_Only_Address__c != oldAddrMap.get(objaddress.Id).HSI_Only_Address__c || bypassinital) && !objaddress.HSI_Only_Address__c && !objaddress.Targeted__c 
                   && !String.isBlank(addressVsAccntStatusMap.get(objAddress.Id).Account__r.Customer_Status__c) 
                   && (STR_ACTIVE.equalsIgnoreCase(addressVsAccntStatusMap.get(objAddress.Id).Account__r.Customer_Status__c) || STR_A.equalsIgnoreCase(addressVsAccntStatusMap.get(objAddress.Id).Account__r.Customer_Status__c))
                   ){
                    objaddress.Plan__c = null;
                    objaddress.OwnerId = sharedData.id;
                    if(objaddress.Team__c != null){
                        objaddress.Team__c = null;
                    }
                }
            // US1188961 changes End
            }  
            
        }catch(Exception e){system.debug('***Following exception has occured***: '+e.getMessage());}       
    
    }
    
      /**    
    * @Description: US1096537- Dynamically Add Targeted Address to Turf.
      As an XSP when an Address in my Territory becomes Targeted and meets the parameters of an “Assigned” Turf add the 
      Address to my Assigned Turf so that I can work the most recently Targeted Addresses in my Territory.
    * @Author: Kiran Kumar, Accenture    
    * @Date: 06-June-2017 
    * @Param:Trigger.New, Trigger.OldMap    
    * @Return: None 
    * @Modified On: 9-Aug-2017
    * @Modified By: Srini Bhattiprolu
    * @User Story: US1129121: Direct - Dynamic Turf and DSM Limits
    * @Chnage: Added logic to prevent the dynamic addition of targeted/HSI only address to the turf if the turf already had 1200 addresses
    * Modified By: Animesh
    * Modified Date: 05-September-2017
    * Modification Details: US1111592 - Territory - Trigger to handle Census Changes
    * Modified By: Srini Bhattiprolu
    * Modified Date: 6-Sep-2017
    * Modification Details: Defect Fix: US1129121 - Direct - Dynamic Turf and DSM Limits
    * Modified By: Srini Bhattiprolu
    * Modified Date: 03-Oct-2017
    * Modification Details: US1130517 - Territory - Remove 'Excluded from Territory' from Turf & Targeted
    * Modified By: Animesh Datta
    * Modified Date: 20-Oct-2017
    * Modification Details: US1188913 - Direct - Dynamically Add Marketable Addresses to Turf
    */ 
    public static void addAddressToPlan(List<Customer_Address__c> newAddrList, Map<Id,Customer_Address__c> oldAddrMap){ 
        Set<Id> territoriesIds = new Set<Id>();   
        Map<String,Plan__c> mapCensusPlan = new map<String,Plan__c>();
        Map<String,List<Customer_Address__c>> mapcensusaddress = new Map<String,List<Customer_Address__c>>(); 
        list<Customer_Address__c> lsttemp;
        list<Customer_Address__c> lstfilteredaddress = new list<Customer_Address__c>();
        Map<Id,Decimal> planVsAvailableCountMap = new map<Id,Decimal>();
        SystemProperties sysProps = new SystemProperties(); //Srini Bhattiprolu: Defined the instace of this class for using Custom Mata Data Type - AddressMaxLimitPerTurf
        //User sharedData = [Select Id, Name from User where Name=:ConstantHandler.SHARED_DATA_USER_NAME LIMIT 1];
        string bypassaddition = label.ByPassDynamicAddition; //Yes/NO based on Yes addition logic will work for user who has been added in another custom label named 'ByPassDynamicTurf'
        boolean marketableHSIOnly = false;
        boolean marketableTargeted = false;
        try{
            // extracting census tract, territoriesIds from address
            boolean bypassinital  = bypassdynamicturfintial();
            for(Customer_Address__c objAddress : newAddrList){
                //Filtering address based on condition
                // US1097310 starts : Added by Kiran 
                if(
                    (
                        ( 
                            (
                                oldAddrMap!=null &&
                                objaddress.HSI_Only_Address__c && 
                                ((oldAddrMap.get(objaddress.Id).HSI_Only_Address__c != objaddress.HSI_Only_Address__c) || (bypassinital && bypassaddition!=null && bypassaddition =='Yes'))
                            ) ||
                            (
                                oldAddrMap==null &&
                                objaddress.HSI_Only_Address__c
                            )
                        ) && 
                        (
                            (objaddress.Comcast_Division__c.equalsIgnoreCase(ConstantHandler.STR_NORTHEAST_NAME)) ||
                            (objaddress.Comcast_Division__c.equalsIgnoreCase(ConstantHandler.STR_CENTRAL_NAME))
                        ) 
                        //US1130517 - Added a check to prevent from dynamically adding the addresses that were excluded from territory
                        && !objaddress.Excluded_from_Territory__c) || 
                    (
                        oldAddrMap!=null && 
                        objaddress.Targeted__c && 
                        ((objaddress.Targeted__c != oldAddrMap.get(objaddress.Id).Targeted__c) || (bypassinital && bypassaddition!=null && bypassaddition =='Yes')) && 
                        !objaddress.Excluded_from_Territory__c
                    )||
                    (!objaddress.Excluded_from_Territory__c && objaddress.Targeted__c && oldAddrMap ==null) ||
                    (oldAddrMap!=null && oldAddrMap.get(objaddress.Id).Plan__c != null && objaddress.Territory__c != null && 
                    ((objaddress.Territory__c != oldAddrMap.get(objaddress.Id).Territory__c) || (bypassinital && bypassaddition!=null && bypassaddition =='Yes'))) || //added this check for US1111592
                    //start - US1188913 - Direct - Dynamically Add Marketable Addresses to Turf
                    (oldAddrMap!=null && oldAddrMap.get(objaddress.Id).Plan__c == null && !objaddress.Excluded_from_Territory__c 
                    && objaddress.Targeted__c && !objaddress.Non_Marketable__c && 
                    ((objaddress.Non_Marketable__c != oldAddrMap.get(objaddress.Id).Non_Marketable__c) || (bypassinital && bypassaddition!=null && bypassaddition =='Yes'))
                    ) ||
                    (oldAddrMap!=null && oldAddrMap.get(objaddress.Id).Plan__c == null && 
                    !objaddress.Excluded_from_Territory__c && !objaddress.Non_Marketable__c && 
                    ((objaddress.Non_Marketable__c != oldAddrMap.get(objaddress.Id).Non_Marketable__c) || (bypassinital && bypassaddition!=null && bypassaddition =='Yes')) && objaddress.HSI_Only_Address__c && 
                        (   (objaddress.Comcast_Division__c.equalsIgnoreCase(ConstantHandler.STR_NORTHEAST_NAME)) ||
                            (objaddress.Comcast_Division__c.equalsIgnoreCase(ConstantHandler.STR_CENTRAL_NAME))
                        ) 
                    )
                    //end - US1188913 - Direct - Dynamically Add Marketable Addresses to Turf
                )
                {
                    // US1097310 Ends : Added by Kiran
                    if(objAddress.Territory__c != null){ 
                        territoriesIds.add(objAddress.Territory__c);
                    }
                    if(objAddress.Census_Tract__c != null){
                        if(mapcensusaddress.containsKey(objAddress.Census_Tract__c)){
                            lsttemp = new list<Customer_Address__c>();
                                lsttemp = mapcensusaddress.get(objAddress.Census_Tract__c);
                                lsttemp.add(objAddress);
                                mapcensusaddress.put(objAddress.Census_Tract__c, lsttemp);
                        }else{
                            mapcensusaddress.put(objAddress.Census_Tract__c, new List<Customer_Address__c>{objAddress});
                        }
                        lstfilteredaddress.add(objAddress);
                    }
                }
            }
            // to get all assigned plans,users,teams based on territory
            if(mapcensusaddress.size()> 0 ){ 
                for(Plan__c ObjPlan : [Select Assigned_Team__c,Assigned_Team__r.supervisor__c,User__c, Census_Tracts__c ,Plan_Status__c, Territory__c, Createddate, Parameters__c, Number_of_Addresses__c, True_count_of_Addresses__c from  plan__c where Plan_Status__c =: Label.PlanStatusAssigned And Territory__c in : territoriesIds ]){
                    for(string objcensus : mapcensusaddress.keyset()){
                        if((objPlan.Census_Tracts__c)!= null && (objPlan.Census_Tracts__c).contains(objcensus)){
                            if(!mapCensusPlan.containskey(objcensus)){
                                mapCensusPlan.put(objcensus,objPlan);
                            }else{
                              //To check for latest created plan
                                if(objPlan.Createddate>mapCensusPlan.get(objcensus).createddate){
                                    mapCensusPlan.put(objcensus,objPlan);
                                }
                            }
                        }
                    }
                }
                /* US1129121:Added by Srini Bhattiprolu: This if block is to capture the no.of addresses that each of the Turf in the
                    above "mapCensusPlan" can hold. This is implementedted to restrict the Turf to 1200 addresses
                */
                if(!mapCensusPlan.isEmpty()){
                    for (Plan__c planAndCount : mapCensusPlan.values()){
                        if (!planVsAvailableCountMap.containsKey(planAndCount.Id)){
                            planVsAvailableCountMap.put(planAndCount.Id,(Decimal.valueOf(sysProps.getSytemProperty(STR_ADDRESSMAXLIMITPERTURF,STR_TURFPLANNING)))-planAndCount.True_count_of_Addresses__c);
                        }
                    }
                }
                // Assigning plans,owner  to filtered address 
                for(Customer_Address__c objAddress : lstfilteredaddress){
                    marketableHSIOnly = false;
                    marketableTargeted = false;
                    //start - US1188913 - Direct - Dynamically Add Marketable Addresses to Turf
                    if(oldAddrMap!=null && mapCensusPlan.get(objAddress.Census_Tract__c) != null && oldAddrMap.get(objaddress.Id).Plan__c == null && 
                            planVsAvailableCountMap.get(mapCensusPlan.get(objAddress.Census_Tract__c).Id) > 0 && !objaddress.Non_Marketable__c && 
                            ((objaddress.Non_Marketable__c != oldAddrMap.get(objaddress.Id).Non_Marketable__c) || (bypassinital && bypassaddition!=null && bypassaddition =='Yes')) && 
                            !String.isBlank(mapCensusPlan.get(objAddress.Census_Tract__c).Parameters__c) &&
                            mapCensusPlan.get(objAddress.Census_Tract__c).Parameters__c.containsIgnoreCase(STR_NONMARKETABLEEXCLUDED))
                    {
                        if(objaddress.HSI_Only_Address__c && mapCensusPlan.get(objAddress.Census_Tract__c).Parameters__c.containsIgnoreCase(STR_HSIONLYINCLUDEDTRUE) &&
                                (   
                                    (objaddress.Comcast_Division__c.equalsIgnoreCase(ConstantHandler.STR_NORTHEAST_NAME)) ||
                                    (objaddress.Comcast_Division__c.equalsIgnoreCase(ConstantHandler.STR_CENTRAL_NAME))
                                )
                        ){
                            marketableHSIOnly = true;   
                        }
                        if(objaddress.Targeted__c)
                        {
                            marketableTargeted = true;  
                        }
                    }
                    //end - US1188913 - Direct - Dynamically Add Marketable Addresses to Turf
                    
                    if(oldAddrMap!=null && oldAddrMap.get(objaddress.Id).Plan__c != null && ((objaddress.Territory__c != null 
                        && objaddress.Territory__c != oldAddrMap.get(objaddress.Id).Territory__c) || (bypassinital && bypassaddition!=null && bypassaddition =='Yes'))){//US1111592 - if territory has changed
                        
                        //US1130517 - Added a check to prevent from dynamically adding the addresses that were excluded from territory
                        if(mapCensusPlan.get(objAddress.Census_Tract__c) != null 
                            && planVsAvailableCountMap.get(mapCensusPlan.get(objAddress.Census_Tract__c).Id) > 0 && !objAddress.Excluded_from_Territory__c){//if there is a matching plan
                            objAddress.Plan__c = mapCensusPlan.get(objAddress.Census_Tract__c).Id;
                            if(mapCensusPlan.get(ObjAddress.Census_Tract__c).User__c != null){//if plan is assigned to a user
                                objAddress.OwnerId = mapCensusPlan.get(ObjAddress.Census_Tract__c).User__c;
                            }else{//if plan is not assigned to user, it must be assigned to team
                                objAddress.OwnerId = mapCensusPlan.get(ObjAddress.Census_Tract__c).Assigned_Team__r.supervisor__c;
                                objAddress.Team__c = mapCensusPlan.get(ObjAddress.Census_Tract__c).Assigned_Team__c;
                            }
                            decimal availableCount = planVsAvailableCountMap.get(mapCensusPlan.get(objAddress.Census_Tract__c).Id)-1;
                            planVsAvailableCountMap.put(mapCensusPlan.get(objAddress.Census_Tract__c).Id, availableCount);
                        }else{//if there is no matching plan
                            objaddress.Plan__c = null;
                            objaddress.OwnerId = Label.SharedDataUserId;//sharedData.id;
                            objaddress.Team__c = null;
                        }
                 
                    }else if(marketableHSIOnly || marketableTargeted || (mapCensusPlan.get(objAddress.Census_Tract__c) != null && objaddress.Targeted__c && planVsAvailableCountMap.get(mapCensusPlan.get(objAddress.Census_Tract__c).Id) > 0 ) || 
                    (mapCensusPlan.get(objAddress.Census_Tract__c) != null && objaddress.HSI_Only_Address__c && !mapCensusPlan.get(objAddress.Census_Tract__c).Parameters__c.containsIgnoreCase(STR_HSIONLYINCLUDED ) && planVsAvailableCountMap.get(mapCensusPlan.get(objAddress.Census_Tract__c).Id) > 0)){
                        objAddress.Plan__c = mapCensusPlan.get(objAddress.Census_Tract__c).Id;
                        if(mapCensusPlan.get(ObjAddress.Census_Tract__c).User__c != null){
                            objAddress.OwnerId = mapCensusPlan.get(ObjAddress.Census_Tract__c).User__c;
                        }else{
                            objAddress.OwnerId = mapCensusPlan.get(ObjAddress.Census_Tract__c).Assigned_Team__r.supervisor__c;
                            ObjAddress.Team__c = mapCensusPlan.get(ObjAddress.Census_Tract__c).Assigned_Team__c;
                        }
                        decimal availableCount = planVsAvailableCountMap.get(mapCensusPlan.get(objAddress.Census_Tract__c).Id)-1;
                        planVsAvailableCountMap.put(mapCensusPlan.get(objAddress.Census_Tract__c).Id, availableCount);
                    }
                }
            }
        }catch(QueryException qe){system.debug('***Following exception has occured***: '+ qe.getMessage());}
    }
    /**
    * @Description: Updating No.of Addresses and No.of Addresses Currently on Plan attributes on the Plan when the address is added to the Turf
    * @Author: Srini Bhattiprolu, Accenture
    * @Date: 15-Jun-2017
    * @User Story: US1105183 - Direct - Update Plan 'Address Details' when Turf Updates
    * @Param: Trigger.new, Trigger.oldMap
    * @Return: void
    * Modified By: Animesh
    * Modified Date: 25-Jul-2017
    * Modification Details: US1137083 - System Engineering : Apex CPU Limit Exceed Error when updating Plan Details.Optimazised Code. Added Try Catch
    * Modified By : Kiran Kumar
    * Modification Details : US1186031 - Direct - Update Plan 'Address Details' 
    */
   public static void updatePlanOnAddressAddToTurf(List<Customer_Address__c> newAddrList, Map<Id,Customer_Address__c> oldAddrMap){
        try{
            if(!TurfPlanningController.TurfPlanningPlanUpdate){
                List<Plan__c> planToUpdateList = new List<Plan__c>();
                Set<Id> planIdSet = new Set<Id>();
                for (Customer_Address__c address : newAddrList){
                    if (address.Plan__c != null && oldAddrMap.get(address.Id).Plan__c ==null){
                        planIdSet.add(address.Plan__c);
                    }
                    // Changes start for US1186031
                    if (oldAddrMap.get(address.Id).Plan__c !=null && address.Plan__c == null){
                        planIdSet.add(oldAddrMap.get(address.Id).Plan__c);
                    }
                    // Changes End for US1186031
                    if (oldAddrMap.get(address.Id).Plan__c !=null && address.Plan__c != null && oldAddrMap.get(address.Id).Plan__c != address.Plan__c&& !PlanTriggerController.bypassPlansUpdateOnPlaylistDelete )
                     {
                        planIdSet.add(oldAddrMap.get(address.Id).Plan__c);
                         planIdSet.add(Address.Plan__c);
                    }
                }
                if(!planIdSet.isEmpty()){
                    planToUpdateList = [SELECT Id FROM Plan__c WHERE Id IN: planIdSet 
                                        LIMIT :(Limits.getLimitQueryRows()-Limits.getQueryRows())];
                }               
                if (!planToUpdateList.isEmpty() && !TurfPlanningController.TurfPlanningPlanUpdate){
                    database.update(planToUpdateList, false);
                }
            }
        }catch(Exception exp){System.debug('***Following error occurred***'+exp.getMessage());}
    } 
    /**
    * @Description: Updating No.of Addresses and No.of Addresses Currently on Plan attributes on the Plan when the address is removed from the Turf
    * @Author: Srini Bhattiprolu, Accenture
    * @Date: 15-Jun-2017
    * @User Story: US1105183 - Direct - Update Plan 'Address Details' when Turf Updates
    * @Param: Trigger.new, Trigger.oldMap
    * @Return: void
    * Modified By: Animesh
    * Modified Date: 25-Jul-2017
    * Modification Details: US1137083 - System Engineering : Apex CPU Limit Exceed Error when updating Plan Details.Optimazised Code. Added Try Catch
    * Modified By : Kiran ( Commenting this method to update 'Plan'details)
    */
  /**  public static void updatePlanOnAddressRemovalFromTurf(List<Customer_Address__c> newAddrList, Map<Id,Customer_Address__c> oldAddrMap){
        try{
            if(!TurfPlanningController.TurfPlanningPlanUpdate){
                List<Plan__c> planToUpdateList = new List<Plan__c>();
                Set<Id> planIdSet = new Set<Id>();
                for (Customer_Address__c address : newAddrList){
                    if (oldAddrMap.get(address.Id).Plan__c !=null && address.Plan__c == null){
                        planIdSet.add(oldAddrMap.get(address.Id).Plan__c);
                    }
                }
                if(!planIdSet.isEmpty()){
                    planToUpdateList = [SELECT Id FROM Plan__c WHERE Id IN: planIdSet 
                                        LIMIT :(Limits.getLimitQueryRows()-Limits.getQueryRows())];
                }
                if (!planToUpdateList.isEmpty() && !TurfPlanningController.TurfPlanningPlanUpdate){ 
                    PlanTriggerController.dynamicallyRemovedAddress = true;
                    database.update (planToUpdateList, false);      
                }
            }
        }catch(Exception exp){System.debug('***Following error occurred***'+exp.getMessage());}
    }*/
    /**
    * @Description: Check the bypass logic for a USer for Dynamic Turf
    * @Author: Amit Kumar, Accenture
    * @Date: 10-Oct-2017
    * @User Story: US1206503 - System Engineering: EBI Refresh Bypass for Dynamic Turf Assignment
    * @Param: 
    * @Return: boolean
    */
    public static boolean bypassdynamicturfintial(){
        string struserId =  (UserInfo.getUserId()).substring(0,15); 
        string strbypassuser = label.ByPassDynamicTurf ;
        boolean btriggeron =false;
        if(!string.Isblank(strbypassuser) && strbypassuser.equals(struserId)){
                btriggeron =true;
            }
                return btriggeron;
    }
}