/**************************************************************************************************************************************
 * Author          : Ashish Sonawane
 * Date            : 9-Feb-2015
 * Description     : Add/Update MDU user Public group  
 * User Story      : 896
 * History Version : 1.0
 * PROJECT         : Mdu SFDC 
 * Updated By      : Sucheta Verma on 11-Dec- 2015 #US581655 : Automatic user to group association for CAR Managers
 * Updated By      : Rahul Prabhakar on 15-Dec- 2015 #US603057 :Add CAR automatically to "All CAR" public  group
 * Updated By      : Ashish Sonawane on 30-dec-2015 #US610402 :Add XC Quota: Baseline Quota creation for new AE & Region change
 * Updated By      : Suchita Sharma on 12-Feb-2016 #US625976 :Add/Update MDU User to Public Group based on Region.
 * Updated By      : Animesh Datta on 16-Nov-2016 #US799120,US799239,US799275 :Add/Remove Users to Chatter Group
 * Updated By      : Amit Kumar Pradhan on 02-May-2017 #US1086728:inserting Coaching Sharing record for person coach when user is reactivated.
 * Updated By     : Animesh Datta on 03-May-2017 #US1027533 :Resolve Mixed DML issue when both Manager and Profile are changed and there is an existing     feedbackrequest record. Commenting methods ManageChangeFeedbackRequest and ManageChangeFeedbackRequestforSDM in UserTRiggerController. Written new method shareFeedbackRequestWithNewMgr
 * Updated By      : Deepika Jain Naresh on 26-May-2017 #US1070845 :NSO - Create a new profile for Paralegals
 * Updated By      : Deepika Jain Naresh on 26-May-2017 #US1111118 :NSO - XC DT - Event Specialist 
 * Updated By      : Suchita Sharma on 19-June-2017 # US1115896 XC FIND - Auto-setup Groups for Regions
 * Updated By      : Deepika Jain Naresh on 24-July-2017 # US1144757 XC - Add a new profile for XOC AE
 * Updated By      : Suchita Sharma on 11-July-2017 # US1137333 XC FIND - Auto-setup Groups for Regions
 * Updated By	   : Amit Kumar on US1107195: MCAT - Auto deactivate User (RSA and XC User, User records in MCAT to automatically be deactivated when it get deactivated in Salesforce)
 * Updated By	   : Sagarika : (06-Sep-2017) : US1105085: MCAT - Auto Create User (Automatically create users in MCAT if the profile in Salesforce is a User that would need MCAT Access)
 * Updated By      : Deepika Jain Naresh on 14-Sept-2017 #US1186404 and #US1186405 : Adding the new profiles to add them in appropriate groups.
**************************************************************************************************************************************/
global class UserTriggerOperation{
    
    //Data Member      
    private static final string GOALTEMPLATE_DATE_CS = 'Default_Communities';
    private static final string MANAGER_GROUP_TYPE = 'Manager';
    private static final string XC_ACCOUNT_EXEC_PROFILE = 'XC Account Executive';
    private static final string GOAL_STATUS_PUBLISHED = 'Published';
    //private static final string METRIC_STATUS_BEHIND = 'Behind';
    private static final string METRIC_STATUS_NOTSTARTED = 'NotStarted';
    global static  List<Goal> goalList = new List<Goal>();
    global static  Map<String,List<Metric>> userIDMetricListMap = new Map<String,List<Metric>>();
    
    //Added By Amit Kumar Pradhan(Part of US1086728)-Start
    private static final string EDIT_ACCESS_COACHING = 'Edit';
    private static final string PROFILE_CHECK = 'ProfileCheckForCoachingSharing';
    private static final string COMMA_SEPARATION = ',';
    //Added By Amit Kumar Pradhan(Part of US1086728)-End

    /**    
    * @Description: Business logic to add CAR/CAR Manager/XC/ Direct users to respective public group.
    * @Author: Malay Desai, Accenture    
    * @Date: 23-Feb-2016  
    * @Param:  Trigger.New, Trigger.OldMap 
    * @Return: None 
    * @Last Modify: US1115896 XC FIND - Auto-setup Groups for Regions
    * @Last Modify Date: 19-June-2017   
    * @Last modified By: Deepika Jain Naresh
    * @Last modified Date: 24-July-2017 
    * @Description : Adding new profile XC XOC Account Executive to add it to the respective groups.
    * @User Story : US1144757 XC - Add a new profile for XOC AE     
    * @Last modified By: Deepika Jain Naresh
    * @Last modified Date: 14-Sept-2017 
    * @Description : Adding new profiles XC Car Sr Mgr/Director and XC AE Sr Mgr/Director to add it to the respective groups.
    * @User Story : #US1186404 and #US1186405 */              
    public static void addUsersToPublicGroup(List<User> userList, Map<Id, User> oldMap){
        try{
            Map<String, String> regionVsGroupName = new Map<String, String>();
            Map<String, Id> groupNameVsId  = new Map<String, Id>();
            Set<String> groupNamesXC = new Set<String>();
            Set<Id> groupIDsXC = new Set<Id>();
            List<GroupMember> groupMembers = new List<GroupMember>();
            List<Region_Profile_PublicGroups__c> regionProfileVsGroupNameCS = Region_Profile_PublicGroups__c.getAll().values();
            final Set<String> profileNames = new Set<String>{'Regional System Admin (RSA)',
                                                'XFINITY Sales Professional','Sales Development Manager','XFINITY Sales Executive','Area Sales Manager','Contractor Sales Professional',
                                                'Contractor Sales Leader','Community Account Manager','Community Account Representative​','Community Account Supervisor',
                                                'FIND Representative','FIND Manager','FIND Supervisor','XC Account Executive','XC AE Contractors','XC Analyst','XC Cabled Units',
                                                'XC Call Centers','XC Integration Profile','XC Manager','XC Portfolio AE','XC Sales Support','XC SME','Xfinity CAR','Xfinity CAR Manager',
                                                'XC Paralegals','XC Event Specialist','XC FIND Manager','XC FIND Representative', 'XC XOC Account Executive','XC/Direct Regional Lead',
                                                'CAR/XC Regional Lead','Direct Sales Director', 'XC CAR Sr Mgr/Director', 'XC AE Sr Mgr/Director'}; //Adding profiles-US1070845 ,US1111118 ,US1115896, US1144757 and US1137333, #US1186404 and #US1186405 
            for(Region_Profile_PublicGroups__c cs : regionProfileVsGroupNameCS){
                regionVsGroupName.put(cs.Region__c+cs.Profile_Channel__c, cs.Public_Group_Name__c);
                if(cs.Profile_Channel__c.equalsIgnoreCase(Label.XC_Prefix)){ // To handle Global region
                    groupNamesXC.add(cs.Public_Group_Name__c);
                }
            }
            
            for(Group grp : [SELECT id, Name FROM Group WHERE Name IN :regionVsGroupName.values()]){
                groupNameVsId.put(grp.Name, grp.Id);
                if(groupNamesXC.contains(grp.Name)){ // To handle Global region
                    groupIDsXC.add(grp.Id);
                }
            }
            
            for(User aUser: userList){
                List<GroupMember> groupMemberTobeAdded = new List<GroupMember>(); // Modify to list for US1115896
                if(aUser.Region__c != null && profileNames.contains(aUser.Profile_Name_Text__c)){    //Proceed ONLY if new Profile is one of the listed ones.
                    if(oldMap != null){ //Event: After Update 
                        if(aUser.ProfileId != oldMap.get(aUser.Id).ProfileId){// Profile updated 
                            if(aUser.Region__c != null && aUser.Region__c.equalsIgnoreCase(Label.Global_Division)){  // If region is Global and profile is XC add it to all XC Groups
                                    if((aUSer.Profile_Name_Text__c).startsWith(Label.XC_Prefix)){
                                        for(Id groupId : groupIDsXC){
                                            groupMembers.add(createGroupMember(aUser.Id,groupId));
                                        }
                                    }
                            } else{
                                groupMemberTobeAdded = addGroupMember(aUser,regionVsGroupName,groupNameVsId);                           
                                if(groupMemberTobeAdded != null)
                                    groupMembers.addAll(groupMemberTobeAdded); //Modify to addAll for US1115896
                            }
                        } else if(aUser.Region__c != oldMap.get(aUser.Id).Region__c){//If region is updated
                                if(aUser.Region__c != null && aUser.Region__c.equalsIgnoreCase(Label.Global_Division)){  // If region is Global and profile is XC add it to all XC Groups
                                    if((aUSer.Profile_Name_Text__c).startsWith(Label.XC_Prefix)){
                                        for(Id groupId : groupIDsXC){
                                            groupMembers.add(createGroupMember(aUser.Id,groupId));
                                        }
                                    }
                                } else{
                                     groupMemberTobeAdded = addGroupMember(aUser,regionVsGroupName,groupNameVsId);
                                     if(groupMemberTobeAdded != null){
                                     	system.debug('Inside Region Updated loop');
                                     	system.debug(groupMemberTobeAdded+' Deepika');
                                        groupMembers.addAll(groupMemberTobeAdded);//Modify to addAll for US1115896
                                     }
                                } 
                        } else if(aUser.UserRoleId != oldMap.get(aUser.Id).UserRoleId){ // Role is changed
                                groupMemberTobeAdded = addGroupMember(aUser,regionVsGroupName,groupNameVsId);
                                if(groupMemberTobeAdded != null)
                                    groupMembers.addAll(groupMemberTobeAdded); //Modify to addAll for US1115896
                            } 
                       // }
                }  else{ //Event: After Insert
                    if(aUser.Region__c != null && aUser.Region__c.equalsIgnoreCase(Label.Global_Division)){  // If region is Global and profile is XC add it to all XC Groups
                        if((aUSer.Profile_Name_Text__c).startsWith(Label.XC_Prefix)){
                            for(Id groupId : groupIDsXC){
                                groupMembers.add(createGroupMember(aUser.Id,groupId));
                            }
                        }
                    } 
                    else{ // For any other region
                        groupMemberTobeAdded = addGroupMember(aUser,regionVsGroupName,groupNameVsId);
                        if(groupMemberTobeAdded != null)
                            groupMembers.addAll(groupMemberTobeAdded); //Modify to addAll for US1115896
                    }              
                }
              }
            }            
            if(groupMembers.size() > 0){                
                Database.Insert(groupMembers,false);
            }
        }catch(Exception ex){system.debug('Exception: '+ex.getMessage());}     
    }
    
    private static List<GroupMember> addGroupMember(User aUser, Map<String, String> regionVsGroupName, Map<String, Id> groupNameVsId){
        Id groupId = null;
        Id groupId2 = null;
        Id groupId3 = null; //US1137333
        List<GroupMember> groupMember = new List<GroupMember>(); 
        
        if((aUser.Profile_Name_Text__c).startsWith(Label.XC_Prefix)){ // For all Communities profiles that start with 'XC'
            groupId = groupNameVsId.get(regionVsGroupName.get(aUser.Region__c + Label.XC_Prefix));      
         } else if((aUser.Profile_Name_Text__c).equalsIgnoreCase(Label.Xfinity_CARmanager_ProfileName)){ //For Xfinity CAR Manager
                groupId = groupNameVsId.get(regionVsGroupName.get(aUser.Region__c + Label.Xfinity_CARmanager_ProfileName.subString(8)));
         } else if((aUser.Profile_Name_Text__c).equalsIgnoreCase(Label.Xfinity_CAR_ProfileName) ){ 
                groupId = groupNameVsId.get(regionVsGroupName.get(aUser.Region__c + Label.Xfinity_CAR_ProfileName.subString(8))); 
                //For Xfinity CAR
         } else{
             groupId = groupNameVsId.get(regionVsGroupName.get(aUser.Region__c + Label.SubmitCaseControllerDirectSales));
         } // For Direct Sales and few other profiles
          
         //US1115896 Start
         if((aUser.Profile_Name_Text__c).equalsIgnoreCase(Label.XC_FIND_Manager) || (aUser.Profile_Name_Text__c).equalsIgnoreCase(Label.XC_FIND_Rep)){ //For XC FIND Manager and XC FIND Representative  
                groupId2 = groupNameVsId.get(regionVsGroupName.get(aUser.Region__c + Label.Xfinity_CAR_ProfileName.subString(8)));      
                if(groupId2 != null){
                    groupMember.add(createGroupMember(aUser.Id, groupId2));
                } 
        }
       
        if(GroupId != null){
            groupMember.add(createGroupMember(aUser.Id, groupId));
        }  
        //US1137333 Start
        if((aUser.Profile_Name_Text__c).equalsIgnoreCase(Label.XC_Direct_Regional_Lead)){ //For Cross Channel Lead 
                groupId2 = groupNameVsId.get(regionVsGroupName.get(aUser.Region__c + Label.Xfinity_CARmanager_ProfileName.subString(8)));
                groupId3 = groupNameVsId.get(regionVsGroupName.get(aUser.Region__c + Label.SubmitCaseControllerDirectSales));
                groupId = groupNameVsId.get(regionVsGroupName.get(aUser.Region__c + Label.XC_Prefix));      
                if(groupId2 != null){
                    groupMember.add(createGroupMember(aUser.Id, groupId2));
                } 
                if (groupId != null){
                    groupMember.add(createGroupMember(aUser.Id, groupId));
                } 
                if (groupId3 != null){
                    groupMember.add(createGroupMember(aUser.Id, groupId3));
                }
        }  
        if((aUser.Profile_Name_Text__c).equalsIgnoreCase(Label.CrossCARXCLeadProfileName)){ //For Cross Channel Lead 
                groupId2 = groupNameVsId.get(regionVsGroupName.get(aUser.Region__c + Label.Xfinity_CARmanager_ProfileName.subString(8)));
                groupId3 = groupNameVsId.get(regionVsGroupName.get(aUser.Region__c + Label.XC_Prefix));                 
                if(groupId2 != null){                   
                    groupMember.add(createGroupMember(aUser.Id, groupId2));
                } 
                if (groupId3 != null){                  
                    groupMember.add(createGroupMember(aUser.Id, groupId3));
                }                 
        }  
        //US1137333 end
       
        return groupMember;
    }
    
    private static GroupMember createGroupMember(Id userId, Id groupId){
        GroupMember groupMember = new GroupMember();
        groupMember.GroupId = groupId;
        groupMember.UserOrGroupId = userId;
    
        return groupMember;
    }
    
  /**    
    * @Description: Business logic to create new goals when new user is created with Account Executive and Region updated for existing users.
    * @Author: Ashish Sonawane, Accenture    
    * @Date: 30-Dec-2015   
    * @Param:  None    
    * @Return: None    
    */ 
    public static void CreateNewAEGoal(){
        try{
            Map<id,User> oldUserMap =  (Map<id,User>) Trigger.OldMap;
            Set<String> userRegionChangeSet = new  Set<String>();
            for(User user :(List<User>) Trigger.New){                      
                if(String.valueOf(user.ProfileId).contains(Label.XCAccountExecutive) && user.UserPermissionsWorkDotComUserFeature == True){             
                    if(Trigger.IsInsert && user.Region__c!= null){
                        userRegionChangeSet.add(user.id);
                    }
                    else if(Trigger.IsUpdate && user.Region__c!= oldUserMap.get(user.id).Region__c){                
                        userRegionChangeSet.add(user.id);     
                    }                            
                }  
            }  
            if(userRegionChangeSet.size() > 0){
                CreateNewAEGoalFuture(userRegionChangeSet);
            }
        }catch(Exception ex){system.debug('Exception: '+ex.getMessage());}
    }
    
   /**    
    *@Description: future method CreateNewAEGoalFuture use to create Goal records for XC Account Executive user in separate thread to skip setup and non-setup exception  
    * @Author: Ashish Sonawane, Accenture    
    * @Date: 30-Dec-2015   
    * @Param:  set of user id(userRegionChangeSet)     
    * @Return: None    
    */ 
    @future 
    global static void CreateNewAEGoalFuture(Set<String> userRegionChangeSet){
            String userProfileName;  
            String userRegion;
            Set<String> statusSet = new Set<String>{'Draft','Published'};
            Map<String,List<Goal>> ownerIdGoalUpdateListMap = new Map<String,List<Goal>>();         
            List<Goal> existGoalList = new List<Goal>();
            Map<String , Goal> goalSettingMap = new Map<String , Goal>();
            Map<String, Goal> goalMap = new Map<String, Goal>(); 
            List<Goal> goalUpdateFinalList = new  List<Goal>();         
            String xfinityCommunitiesRecordTypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get(system.label.Goal_Xfinity_Communities_Recordtype).getRecordTypeId();                      
            Map<Id,Id> userGroupMap = new Map<Id,Id>();
            String Goal_Template_RecordtypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get(system.label.Goal_Goal_Template_Recordtype).getRecordTypeId();
            List<Metric> metricInsertList = new List<Metric>();          
            Map<String,Map<String,List<Goal>>> ownerIdRegionGoalUpdateListMap = new Map<String,Map<String,List<Goal>>>();
            Map<String,Set<String>> ownerIdRegionListExistMap = new Map<String,Set<String>>();
            //Create start date and end date for new user goal
            Date preGoalStartDate = null;
            Date preGoalDueDate = null;
            DateTime preGoalStartDateTime = null;
            DateTime preGoalDueDateTime = null;
            Integer monthsCreated = 0;
            Integer todayDate = Date.Today().Day();
            Integer todayMonth = Date.Today().Month();         
            
            //Get the Fiscal Year Date period goal start/due dates            
            GoalTemplateDates__c goalDates = GoalTemplateDates__c.getInstance(GOALTEMPLATE_DATE_CS);
            
            if(goalDates != null){               
                if(todayDate>=22){              
                    preGoalStartDate = Date.newInstance(date.today().Year(), date.today().Month(), 22);  
                }else if(todayDate>=1 && todayDate<=21){
                    preGoalStartDate = Date.newInstance(date.today().Year(), date.today().Month()-1, 22); 
                }
                preGoalStartDateTime = preGoalStartDate; 
                
                preGoalDueDate =  preGoalStartDate.addMonths(1).AddDays(-1); //Date.newInstance(date.today().Year(), preGoalStartDate.addMonths(1), 21); 
                monthsCreated = preGoalStartDate.monthsBetween(goalDates.Current_Period_Start_Date__c);  
                preGoalDueDateTime = preGoalDueDate;       
            }
  
            //Use existing goal for region change if exist
            for(Goal goalObj: [SELECT OwnerId, Id, Region__c, Status FROM Goal WHERE OwnerId IN:userRegionChangeSet AND 
                                RecordTypeId =:xfinityCommunitiesRecordTypeId AND StartDate >=: preGoalStartDate AND Status  IN: statusSet AND
                                DueDate <: goalDates.Current_Period_Start_Date__c  ]){
                
                if(goalObj.Status == 'Published'){      
                    List<Goal> goalUpdateList = new List<Goal>();   
                    if(ownerIdGoalUpdateListMap.containsKey(goalObj.ownerid)){                                              
                        goalUpdateList = ownerIdGoalUpdateListMap.get(goalObj.ownerid);                                      
                    }
                    goalObj.Status = 'Draft';
                    goalUpdateList.add(goalObj);
                    ownerIdGoalUpdateListMap.put(goalObj.ownerId,goalUpdateList);
                    //ownerIdRegionGoalUpdateListMap.put(goalObj.ownerid,ownerIdGoalUpdateListMap); 
                }else if(goalObj.Status == 'Draft'){            
                    Set<String> regionSet = new Set<String>();
                    if(ownerIdRegionListExistMap.containsKey(goalObj.ownerId)){
                        regionSet = ownerIdRegionListExistMap.get(goalObj.ownerId);                        
                    }  
                    if(!regionSet.contains(goalObj.Region__c)){
                        regionSet.add(goalObj.Region__c);
                        ownerIdRegionListExistMap.put(goalObj.ownerId,regionSet);                           
                    }
                    
                }                            
            }
            //Store Goal Tempate for Community In Map 
            for(Goal gol : [SELECT Id,Template_Type__c,DueDate,Name,StartDate,Status,Profile_Name__c,Region__c,Sales_Rep_Type__c,Level__c,(SELECT Id,Name,TargetValue,Status,DueDate,Weight,LastComment from Metrics)  from Goal where Template_Type__c =: system.label.Goal_Template_Type_Communities and RecordtypeId =: Goal_Template_RecordtypeId LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) { 
                goalSettingMap.put((gol.Profile_Name__c + gol.Region__c).trim() , gol);            
                goalMap.put(gol.Id , gol);
            }
            // Generate Goal base on Profile Name And Region of User 
            for(User user :[SELECT Id, Region__c, FirstName, LastName,
                                         Sales_Rep_Type__c, Level__c, Profile.name, ManagerId FROM User WHERE Id In:userRegionChangeSet LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())])
            {
                Boolean isGoalExist = false;
                Set<String> regionList = new Set<String>();                   
                if(ownerIdRegionListExistMap.containsKey(user.id)){
                    regionList = ownerIdRegionListExistMap.get(user.id);
                    isGoalExist = regionList.contains(user.Region__c)?true:false;
                }                                           
                Boolean createNewGoal = false;
                if(ownerIdGoalUpdateListMap.containskey(user.Id)){
                    goalUpdateFinalList.addAll(ownerIdGoalUpdateListMap.get(user.Id));
                   
                    if(!isGoalExist){
                        createNewGoal = true;
                    }
                }else if(!isGoalExist){
                    createNewGoal = true;
                }
                if(createNewGoal &&  userRegionChangeSet.contains(user.id)){                   
                   
                    userProfileName = XC_ACCOUNT_EXEC_PROFILE;             
                    userRegion=user.Region__c;              
                    Date preGoalStartDateInner = preGoalStartDate;
                    Date preGoalDueDateInner = preGoalDueDate;
                    DateTime preGoalStartDateTimeInner = preGoalStartDateTime;
                    DateTime preGoalDueDateTimeInner = preGoalDueDateTime;
                    Goal goalInst = goalSettingMap.get((userProfileName+userRegion).trim());                    
                    
                    if(goalInst != null){
                        //Logic to create  monthly goal when new AE created/Region changed.                        
                        for(integer i=0;i<monthsCreated;i++){
                            String userIDGoalDueDate=String.valueOf(user.Id) + preGoalDueDateInner;
                            Goal getGoal= goalMap.get(goalInst.id);                         
                            Goal cloneGoal = new Goal();
                            List<Metric> metricList = new List<Metric>();                         
                            cloneGoal=getGoal.Clone(false,true,true,false);                                 
                            if(system.label.Goal_XC_AE.equalsIgnoreCase(userProfileName)) { // xc account executive
                                cloneGoal.OwnerId=user.Id;                            
                            }                                                       
                            cloneGoal.Region__c = user.Region__c;
                            cloneGoal.Sales_Rep_Type__c = user.Sales_Rep_Type__c;
                            cloneGoal.Level__c = user.Level__c;
                            cloneGoal.Status = GOAL_STATUS_PUBLISHED;                          
                            Date d = preGoalStartDateInner; // 22/12/2014
                            String dateString = d.month()+'-'+d.day()+'-'+d.year();                         
                            cloneGoal.Name=user.FirstName+' '+ user.LastName +' - '+ user.Region__c +' - '+preGoalDueDateTimeInner.formatGMT('MMMM yyyy');                         
                            //Put start and due date in the goal to be create                                           
                            cloneGoal.StartDate = preGoalStartDateInner; //22/12/2014    
                            cloneGoal.DueDate = preGoalDueDateInner;                         
                            cloneGoal.RecordTypeId = xfinityCommunitiesRecordTypeId ;
                            if(user.ManagerId != null){
                                cloneGoal.Reporting_Manager__c = user.ManagerId;
                            }
                            goalList.add(cloneGoal);       
                            for(Metric metr: cloneGoal.Metrics){
                                Metric mt = new Metric();
                                mt=metr.Clone(false,true,true,false);                               
                                if(system.label.Goal_XC_AE.equalsIgnoreCase(user.Profile.name)) { // xc account executive
                                    mt.OwnerId=user.Id;
                                }                                                          
                                mt.Status = METRIC_STATUS_NOTSTARTED;
                                mt.DueDate = preGoalDueDateInner;
                                metricList.add(mt);  
                            }    
                            userIDMetricListMap.put(userIDGoalDueDate.trim() , metricList);                       
                            preGoalStartDateInner = preGoalStartDateInner.addMonths(1);
                            preGoalDueDateInner = preGoalDueDateInner.addMonths(1);
                            preGoalStartDateTimeInner=preGoalStartDateTimeInner.addMonths(1);
                            
              preGoalDueDateTimeInner=preGoalDueDateTimeInner.addMonths(1);
                        }                                       
                    }
                    
                }  
               
            }      
            //Inserting new Goals records 
            Database.SaveResult[] insertGoals = Database.Insert(goalList,false);
            //Update existing Goal
            Database.SaveResult[] updateGoals = Database.update(goalUpdateFinalList,false);
            // Assigning metric to goal
            for(Goal goalObj : [SELECT id, OwnerId ,Assigned_To__c, DueDate , Name 
                                            FROM Goal WHERE Id In : goalList LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                if(userIDMetricListMap.get((String.valueOf(goalObj.OwnerId) + goalObj.DueDate).trim()) != null){
                   List<Metric> metricInsertList1 = new List<Metric>();
                   String userIDGoalDueDate=String.valueOf(goalObj.OwnerId) + goalObj.DueDate; 
                   for(Metric metricObj : (List<Metric>) userIDMetricListMap.get(userIDGoalDueDate.trim())){
                        metricObj.GoalId = goalObj.Id;
                        metricInsertList1.add(metricObj);                     
                   }
                   metricInsertList.addAll(metricInsertList1);               
                }              
                
            }
            
            //Inserting new Metrics
            MetricTriggerController.allowValidation = false; //This flag use to disable validation rule written on trigger 
            Database.SaveResult[] insertMetrics = Database.Insert(metricInsertList,false);     
        } 

    /**    
    *@Description: Updating "Reporting Manager" field of Goal(from next fisical month) record if AE manager changes
    * @Author: Amit Kumar Pradhan, Accenture    
    * @Date: 19-Oct-2016   
    * @User Story: US814546     
    * @Return: None    
    */      
    public static void updateReportingMgrForGoal(Map<id,User> oldUserMap,List<User> newUserList){
        try{
            List<Goal> toUpdateGoalList = new List<Goal>();
            Map<String,String> userIdMgrMap = new  Map<String,String>();
            Date dueTemplateDate = null;
            Date preGoalStartDate = null;        
            Integer todayDate = Date.Today().Day();
            
            String xfinityCommunitiesRecordTypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get(System.Label.Goal_Xfinity_Communities_Recordtype).getRecordTypeId();     
            //Get the Fiscal Year Date period goal start/due dates            
            GoalTemplateDates__c goalDates = GoalTemplateDates__c.getInstance(System.Label.QM_AnnualBaselineBatchContractorCusSetData);
             
            //Logic to find out next Fisical Month
            if(goalDates != null){
                dueTemplateDate = goalDates.Current_Period_Due_Date__c;
                if(todayDate>=22){              
                    preGoalStartDate = Date.newInstance(date.today().Year(), date.today().Month(), 22).addMonths(1);  
                }else if(todayDate>=1 && todayDate<=21){
                    preGoalStartDate = Date.newInstance(date.today().Year(), date.today().Month(), 22); 
                }                                   
            }
            
            for(User user : newUserList){
                
                if(Label.XCCommunitiesProfileId.contains(String.valueOf(user.ProfileId)) && user.UserPermissionsWorkDotComUserFeature == True && user.isActive == true){                            
                    if(user.ManagerId != null && user.ManagerId != oldUserMap.get(user.id).ManagerId){                
                        userIdMgrMap.put(user.id,user.ManagerId);     
                    }                            
                }  
            }  
            
            //Fetching the Goals from next fisical month
            for(Goal goalObj: [SELECT Id, OwnerId, Owner.Name, Region__c, Reporting_Manager__c, DueDate FROM Goal WHERE OwnerId IN:userIdMgrMap.keySet()
                               AND RecordTypeId =:xfinityCommunitiesRecordTypeId AND StartDate >=: preGoalStartDate AND DueDate <: dueTemplateDate]){
                                  
                goalObj.Reporting_Manager__c = userIdMgrMap.get(goalObj.OwnerId);
                toUpdateGoalList.add(goalObj);
            }
            
            //Updating the Goals
            if(!toUpdateGoalList.isEmpty()){
                database.update(toUpdateGoalList,false);
            }
        }catch(Exception ex){system.debug('Exception: '+ex.getMessage());}
    }
    
    /**    
    *@Description: Add/Remove Users from Chatter Group based on Chatter Group Vs Profile Data in Custom Settings ProfileVsChatterGroup__c
    * @Author: Animesh Datta, Accenture    
    * @Date: 16-Nov-2016   
    * @User Story: US799120,US799239,US799275     
    * @Return: None    
    */   
    public static void addUsersToChatterGroup(Map<Id,User> oldUserDetails,List<User> newUserDetail) {
        Set<ID> userIds = new Set<ID>();
        List<String> groupIdList = new List<String>();
        Map<Id,String> userIdVsChatterGroupMap = new Map<Id,String>();   
        Map<String, ProfileVsChatterGroup__c> customSettingMap = ProfileVsChatterGroup__c.getAll();
        
        try{
            if(trigger.oldMap!=null){
                for(User usr: newUserDetail){               
                    User oldUser = (User)Trigger.oldMap.get(usr.Id);
                    ProfileVsChatterGroup__c oldProfileVsChatterGroupsCS = customSettingMap.get(oldUser.Profile_Name_Text__c);
                    if(oldProfileVsChatterGroupsCS !=null && usr.Profile_Name_Text__c != oldUser.Profile_Name_Text__c){  
                        groupIdList.addAll(oldProfileVsChatterGroupsCS.Chatter_Group_Ids__c.split(','));
                        userIds.add(usr.Id);
                    }
                }
            }
            for(User userObj: newUserDetail){
                ProfileVsChatterGroup__c newProfileVsChatterGroupsCS = customSettingMap.get(userObj.Profile_Name_Text__c);
                if(newProfileVsChatterGroupsCS !=null){
                    userIdVsChatterGroupMap.put(userObj.Id, newProfileVsChatterGroupsCS.Chatter_Group_Ids__c);
                }
            }
            if((!userIds.isEmpty() && !groupIdList.isEmpty()) || userIdVsChatterGroupMap!=null){
                addAndRemoveChatterGroupMembers(groupIdList,userIds,userIdVsChatterGroupMap);
            }
        }catch(Exception ex){
            System.debug('*****Following exception has occurred*****'+ex.getMessage());
        } 
            
    }
    
    /**    
    *@Description: Calling this future method from method addAndRemoveChatterGroupMembers in this class. This method is written in Future context to avoid issue with Set up and Non Set up objects 
    * @Author: Animesh Datta, Accenture    
    * @Date: 16-Nov-2016   
    * @User Story: US799120,US799239,US799275     
    * @Return: None    
    */  
    @future
    global static void addAndRemoveChatterGroupMembers(List<String> groupIdList, Set<ID> userIds, Map<Id,String> userIdVsChatterGroupMap) {
        List<CollaborationGroupMember> oldGroupMembersList = new List<CollaborationGroupMember>();
        List<CollaborationGroupMember> collaborationGroupMemberList = new List<CollaborationGroupMember>();
        CollaborationGroupMember collaborationGroupMemberObj;
        
        try{
            if(!userIds.isEmpty() && !groupIdList.isEmpty()){
                for(CollaborationGroupMember members: [SELECT Id, CollaborationGroupId, MemberId FROM CollaborationGroupMember 
                                                            WHERE CollaborationGroupId IN :groupIdList AND MemberId IN :userIds]) {
                    oldGroupMembersList.add(members);
                }
                if(!oldGroupMembersList.isEmpty()){
                    Database.delete(oldGroupMembersList,false);
                }
            }
            if(userIdVsChatterGroupMap!=null){
                for(Id userId: userIdVsChatterGroupMap.keySet()){
                        for(String groupId:  userIdVsChatterGroupMap.get(userId).split(',')) {
                            collaborationGroupMemberObj = new CollaborationGroupMember();
                            collaborationGroupMemberObj.CollaborationGroupId = groupId;
                            collaborationGroupMemberObj.MemberId = userId;
                            collaborationGroupMemberList.add(collaborationGroupMemberObj);
                        }   
                }
                if(!collaborationGroupMemberList.isEmpty()) {
                    Database.insert(collaborationGroupMemberList,false);
                }
            }
        }catch(Exception ex){
            System.debug('*****Following exception has occurred*****'+ex.getMessage());
        }            
    }
    
    /**************************    
    * @Description: This method is for inserting Coaching Sharing record for person coach when user is reactivated.
                    It would work for XFINITY Sales Professional,Sales Development Manager,Area Sales Manager,Xfinity CAR,
                    Xfinity CAR Manager,Retail Sales Rep profile as these profile are added in Variable_Setting__c record.
    * @Author: Amit Kumar Pradhan, Accenture    
    * @Date: 02-May-2017   
    * @User Story: US1086728
    * @Param: Map<Id,User>, List<User>
    * @Return: None    
    ***************************/
    public static void createCoachingSharingForReactivedUser(Map<Id,User> oldUserMap, List<User> newUserList){
        Set<String> userIdSet = new Set<String>();
        Set<String> profileNameSet = new Set<String>();
        try{
            //Fetching profile list from Variable_Setting__c
            //It would work for XFINITY Sales Professional,Sales Development Manager,Area Sales Manager,Xfinity CAR,Xfinity CAR Manager,Retail Sales Rep profile as these profile are added in Variable_Setting__c record.
            Variable_Setting__c profileNames = Variable_Setting__c.getInstance(PROFILE_CHECK);
            if(profileNames != null){
                profileNameSet.addAll(profileNames.Value__c.split(COMMA_SEPARATION));//Splited by comma separate and add in a set for profile check
            }
            
            for(User user : newUserList){                       
                if(!oldUserMap.get(user.Id).isActive && user.isActive 
                    && !profileNameSet.isEmpty() && profileNameSet.contains(user.Profile_Name_Text__c)){//
                    userIdSet.add(user.Id);
                }           
            }
            
            if(!userIdSet.isEmpty()){
                //Calling insertCoachingShare method to create coaching sharing record.
                insertCoachingShare(userIdSet);
            }
        }catch(Exception e){System.debug('Exception********'+e.getMessage());}
    }
    
    /**************************    
    * @Description: Calling this future method from method createCoachingSharingForReactivedUser for creation of Coaching sharing record. 
                    This method is written in Future context to avoid issue with Set up and Non Set up objects 
    * @Author: Amit Kumar Pradhan, Accenture    
    * @Date: 02-May-2017   
    * @User Story: US1086728
    * @Param: Set<String>   
    * @Return: None    
    ***************************/
    @future
    global static void insertCoachingShare(Set<String> userIdSet){
        List<WorkCoachingShare> coachingSharingList = new List<WorkCoachingShare>();
        try{
            //Fetching all coaching records of reactivated user
            for(WorkCoaching coaching : [SELECT Id, Name, CoachedId, CoachId FROM WorkCoaching WHERE CoachedId IN: userIdSet 
                                                                LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                //Creating WorkCoachingShare record for every coaching relationship                                             
                WorkCoachingShare wcsRecord = new WorkCoachingShare();
                wcsRecord.ParentId = coaching.Id;
                wcsRecord.userorgroupId = coaching.CoachedId;
                wcsRecord.AccessLevel = EDIT_ACCESS_COACHING;//Edit access level
                wcsRecord.rowCause = Schema.WorkCoachingShare.rowCause.Manual;
                coachingSharingList.add(wcsRecord);
            }
            
            //Inserting coachingSharingList
            if(!coachingSharingList.isEmpty()){              
                Database.insert(coachingSharingList, false);
            }
        }catch(Exception e){System.debug('Exception********'+e.getMessage());}
    }
    /**
    * @Description: Resolving Mixed DML issue when both Manager and Profile are changed and there is an existing feedbackrequest record. Written new method shareFeedbackRequestWithNewMgr. Calling future method shareFeedbackRequestRecords from this method by passing map of user Id Vs. manager Id
    * @Author: Animesh Datta
    * @Date: 03-May-2017 
    * @Param: List<User>, Map<Id,User>  
    * @Return: void.
    */
    public static void shareFeedbackRequestWithNewMgr(List<User> newUserList, Map<Id,User> oldUserMap) {//trigger.new and trigger.oldMap
        try{
            Map<Id,Id> userVsNewManagerMap  = new Map<Id,Id>();//Rep Vs. new Manager
            //Fill the map userVsNewManagerMap if manager has changed and user has work.com access
            for(User newUser : newUserList) {
                if((newUser.ManagerId != null) && (newUser.ManagerId != oldUserMap.get(newUser.Id).ManagerId) && newUser.UserPermissionsWorkDotComUserFeature){  
                    userVsNewManagerMap.put(newUser.Id,newUser.ManagerId);//key: user, value: new manager
                }
            }
            //Call future method shareFeedbackRequestRecords
            if(!userVsNewManagerMap.isEmpty()){
                shareFeedbackRequestRecords(userVsNewManagerMap);
            }
        }catch(Exception ex){System.debug('Exception: '+ex.getMessage());}
    }
    
    /**
    * @Description: Resolving Mixed DML issue when both Manager and Profile are changed and there is an existing feedbackrequest record. Written new method shareFeedbackRequestWithNewMgr. Calling this future method from shareFeedbackRequestWithNewMgr method by passing map of user Id Vs. manager Id as parameter. Update Owner of FeedbackRequest to new manager. Delete all existing sharing records on FeedbackRequest and share records with Rep and Management Group.
    * @Author: Animesh Datta
    * @Date: 03-May-2017
    * @Param: Map<Id,Id>   
    * @Return: void.
    */
    @future
    global static void shareFeedbackRequestRecords(Map<Id,Id> userVsNewManagerMap) {//Parameter Map of User Id Vs. new Manager Id. //future annotation - to avoid issue between set up and non set up objects
        try{
            Set<Id> subjectIds = new Set<Id>();//variable to store Rep Id
            subjectIds.addAll(userVsNewManagerMap.keySet());//Get Rep Id
            List<WorkFeedbackRequestShare>feedbackRequestShareList = new List<WorkFeedbackRequestShare>();//list of FeedbackRequest Share records that needs to be inserted 
            Set<Id> feedbackRequestIdSet = new Set<Id>();//feedback request ids of FeedbackRequests where user(whose manager is being changed) is in Feedback To 
            List<WorkFeedbackRequestShare> shareRecordDeletionList;//old feedbackrequest share records that needs to be deleted
            Map<Id, Id> managerGroupMap = new Map<Id, Id>();// Map of Manager Group. RelatedId(Rep Id) Vs. GroupId
            List<WorkFeedBackRequest> feedbackRequestList;//Populate past 60 days feedback request and update same the in order to update Owner 
            //Iterate all feedback request where SubjectId is the user whose manager is changed
            //store feedback requests ids in a Set that will be used retrieve feedback request share records
            //Also share records with user(whose manager is changed)
            for(WorkFeedbackRequest feedbackRequestObj : [SELECT Id, OwnerId, SubjectId 
                                                            FROM WorkFeedBackRequest 
                                                                WHERE SubjectId IN : subjectIds LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                feedbackRequestIdSet.add(feedbackRequestObj.Id);    
                feedbackRequestShareList.add( new WorkFeedbackRequestShare(ParentID=feedbackRequestObj.Id,AccessLevel=ConstantHandler.SHARE_READ_ACCESS,RowCause=ConstantHandler.SHARING_REASON_MANUAL,UserOrGroupId=feedbackRequestObj.SubjectId));//share records with user(whose manager is changed)
            }
            //Get list of old share records
            if(!feedbackRequestIdSet.isEmpty()){
                shareRecordDeletionList = [SELECT Id, ParentID FROM WorkFeedbackRequestShare WHERE ParentID IN : feedbackRequestIdSet LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
            }
            //Delete list of old share records
            if(shareRecordDeletionList != null && !shareRecordDeletionList.isEmpty()){
                Database.delete(shareRecordDeletionList,false);
            }
            //Get management group record of Rep
            for(Group managerGroup : [SELECT Id, RelatedId,Type FROM Group WHERE Type = : ConstantHandler.MANAGER_GROUP_SHARING AND RelatedId IN: subjectIds LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                managerGroupMap.put(managerGroup.RelatedId, managerGroup.Id);
            }
            if (!managerGroupMap.isEmpty()){//Go inside if manager group is there
                //record of last 60 days needs to be shared. This is configurable
                Integer numberOfDays = integer.valueof(Label.LastTwoMonths);//value in the custom label is 60. This is 60 days
                System.debug('numberOfDays>>>>'+numberOfDays);
                String feedbackRequestQueryString  = 'SELECT Id, OwnerId, SubjectId FROM WorkFeedBackRequest WHERE SubjectId IN : subjectIds AND CreatedDate >= LAST_N_DAYS:'+numberOfDays;
                feedbackRequestList = database.query(feedbackRequestQueryString);//query database passing query string - getting records of last 60 days
                if(feedbackRequestList != null && !feedbackRequestList.isEmpty()){
                    for(WorkFeedBackRequest feedbackRequest : feedbackRequestList){//iterate over last 60 days records
                        System.debug('feedbackRequest>>>>'+feedbackRequest);
                        feedbackRequest.OwnerId = userVsNewManagerMap.get(feedbackRequest.SubjectId);//change owner id as new manager
                        //feedbackRequestShareList.add( new WorkFeedbackRequestShare(ParentID=feedbackRequest.Id,AccessLevel='Read',RowCause='Manual',UserOrGroupId=feedbackRequest.SubjectId));//this line is duplicate. record is already shared with Rep at the start in case code does not enter till this point
                        feedbackRequestShareList.add( new WorkFeedbackRequestShare(ParentID=feedbackRequest.Id,AccessLevel=ConstantHandler.SHARE_READ_ACCESS,RowCause=ConstantHandler.SHARING_REASON_MANUAL,UserOrGroupId=managerGroupMap.get(feedbackRequest.SubjectId)));//Share records with management hierarchy
                    }
                    if(Schema.sObjectType.WorkFeedBackRequest.isAccessible()) {
                        Database.update(feedbackRequestList,false);//Update feedbackrequest owner id
                    }
                }
                /*if(!feedbackRequestShareList.isEmpty()){
                    Database.insert(feedbackRequestShareList);// it should be outside so that at least record is shared with Rep
                }*/
            }
            if(!feedbackRequestShareList.isEmpty()){
                Database.insert(feedbackRequestShareList,false);//insert feedback request share records
            }
        }catch(Exception ex){System.debug('Exception: '+ex.getMessage());}
    }
    
    
    /**
    * @Description: Call webservice to create a user in MCAT if the profile in Salesforce is a User that would need MCAT Access.
    * @Author: Sagarika
    * @Date: 06-Sep-2017
    * @Param: User Id   
    * @Return: void.
    * @Details : US1105085: MCAT - Auto Create User : End (Added by Sagarika)
    */
    /*
    @future(callout = true)
    global static void addUserToMCAT(Id userId){
    	User user = [SELECT name, Profile_Name_Text__c, Phone, Region__c, email,FirstName, LastName, Username, Street, City, State, Country,PostalCode,FederationIdentifier from USER where id=:userId];
    	try{
    		MDU_UserServices mduUserServices = new MDU_UserServices();
	        boolean userExists = mduUserServices.userExistsInMcat(user);
	    	if(userExists)
	    	{
	    		mduUserServices.activateUserInMCAT(user);
	    	}
	    	else
	    	{
	        	mduUserServices.createUserInMCAT(user);
	    	}
	    	mduUserServices.addLogs();
    	}
    	catch(Exception e)
    	{
    		ApplicationLogUtil.insertApplogforexceptions(e, ConstantHandler.STR_CLASS, UserTriggerOperation.class.getName(), User.getSObjectType().getDescribe().getName(), false, user.FederationIdentifier, ConstantHandler.nonintegrationRTypeId);
    	}
    	
    }
    */
    
    
    //Start - US1105085
    /**
    * @Description: US1107195: MCAT - Auto deactivate User (This Method will make the callout to Suspend the User)
    * @Author: Amit Kumar
    * @Date: 04-Sep-2017
    * @Param: Id User  
    * @Return: void.
    */  
    @future(callout = true)
    public static void suspendusersfromMCAT(id UserId){
    	User user = [SELECT id,FederationIdentifier from USER where Id =:UserId LIMIT 1];
    	MDU_UserServices mduUserServices = new MDU_UserServices();
        mduUserServices.suspendUserInMCAT(user);
    }
    //End - US1105085
    
}