/***************************************************************************************************************************************
 * Author     : Gaurav Aggarwal
 * Date       : 15-May-2013
 * Description: Contains Supporting actions for User Triggers
 * Requirement: 270
 * History
     Version             : 1.0
     Author Last Updated : Gaurav Aggarwal
     PROJECT             : Direct Sales
     
     Version             : 2.0
     Author Last Updated : Ashish Sonawane
     PROJECT             : Comcast Resi AD
     
* Updated By      : Animesh Datta on 16-Nov-2016 #US799120,US799239,US799275 :Add/Remove Users to Chatter Group
* Updated By      : Amit Kumar Pradhan on 02-May-2017 #US1086728:inserting Coaching Sharing record for person coach when user is reactivated.
* Updated By      : Animesh Datta on 03-May-2017 #US1027533 :Resolve Mixed DML issue when both Manager and Profile are changed and there is an existing feedbackrequest record. Commenting methods ManageChangeFeedbackRequest and ManageChangeFeedbackRequestforSDM. Written new method shareFeedbackRequestWithNewMgr
* Updated By	  : Amit Kumar on US1107195: MCAT - Auto deactivate User (RSA and XC User, User records in MCAT to automatically be deactivated when it get deactivated in Salesforce)
* Updated By	  : Sagarika : (06-Sep-2017) : US1105085: MCAT - Auto Create User (Automatically create users in MCAT if the profile in Salesforce is a User that would need MCAT Access)    
***************************************************************************************************************************************/
public Class UserTriggerController{
                                           
   /**
    * @Description: This method sets standard division on the basis of region provided.
    * @Author: Amitkumar Bangad, Accenture
    * @Date: 17-May-2013
    * @Param: NewList, OldMap
    * @Return: void.
    */
    public static string strCarProfile = 'Xfinity CAR';
    public static string strCarMgrProfile = 'Xfinity CAR Manager';
    public static String propertyLabRecordTypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Property Lab').getRecordTypeId();
    public static Date todaysDate = System.Today();
    public static String GOAL_STATUS_COMPLETE = 'Completed';
    
    public static Set<String> aeProfiles = new Set<String> {'XC Account Executive','XC AE Contractors','XC Manager','XC Portfolio AE','XC SME','System Administrator'};
    
    
    public static void setUserRegion(List<User> newUserList, Map<Id, User> oldUserMap){
        Set<String> divisionNames = new Set<String>();
        Map<String, Id> divisionIdbyName = new Map<String, Id> ();

        for(User usr: newUserList){
            if(Trigger.IsInsert || (Trigger.IsUpdate && usr.Region__c != oldUserMap.get(usr.Id).Region__c)){
                if(usr.Region__c != null){
                    divisionNames.add(usr.Region__c);    
                }
            }
        }
        if(!divisionNames.IsEmpty()){
            for(Division div : [Select Id, Name from Division where name =: divisionNames]){
                divisionIdbyName.put(div.name, div.Id);    
            }         
            for(User usr : newUserList){
                if(usr.Region__c != null){
                    usr.DefaultDivision = divisionIdbyName.get(usr.Region__c);
                }
            }
        }  
    }
    
    /**
    * @Description: This method removes user from all the public groups he is part of, when his Profile/Role/Region changes.
    * @Author: Amitkumar Bangad, Accenture
    * @Date: 17-May-2013
    * @Param: NewList, OldMap
    * @Return: void.
    * @Last Modified: Malay Desai, Accenture
    */
    
    public static void removeFromOldpublicGroup(Map<Id,User> oldUserDetails,List<User> newUserDetails){
        List<GroupMember> groupMemberList = new List<GroupMember>();
        List<GroupMember> oldGroupMembers = new List<GroupMember>();
        
        for(list<GroupMember> usergrouplist : [Select Id, UserOrGroupId From GroupMember Where UserOrGroupId IN :oldUserDetails.keySet()] ){
            oldGroupMembers.addAll(usergrouplist);
        }
        
       for(User newUser : newUserDetails){
            User oldUser = oldUserDetails.get(newUser.Id);
            if(oldUser.Region__c != newUser.Region__c || oldUser.UserRoleId != newUser.UserRoleId || oldUser.ProfileId != newUser.ProfileId){
                for(GroupMember gm : oldGroupMembers){
                    if(gm.UserOrGroupId == oldUser.Id){
                        groupMemberList.add(gm);
                    }
                }
            }
       }
        try{
            delete groupMemberList;
        }catch(System.DmlException e){
            for(Integer i = 0; i < e.getNumDml(); i++){
                System.debug(e.getDmlMessage(i)); 
            }
        }
    }
  
    public static void addClaimsUsersToGroups(List<User> users){
        Id affiliateClaimsUserProfileId,affiliateEscalationUserProfileId,claimsUserProfileId,claimsManagerProfileId,escalationUserProfileId;
        Set<Id> partnerProfileIdSet = new Set<Id>();
        Boolean doNotProceed = false;
        List<User> affiliateClaimsUsers,affiliateEscalationUsers, claimsUsers, claimsManagers, escalationUsers; 
        
        for(Profile pr : [SELECT Name, Id FROM Profile WHERE Name IN 
                                                    ('Affiliate Claims User','Affiliate Escalation User','Claims User','Claims Manager','Escalation User')]){
            if(pr.Name.equalsIgnoreCase('Affiliate Claims User')){
                affiliateClaimsUserProfileId = pr.Id;
                partnerProfileIdSet.add(pr.Id);
            } else if(pr.Name.equalsIgnoreCase('Affiliate Escalation User')){
                affiliateEscalationUserProfileId = pr.Id;
                partnerProfileIdSet.add(pr.Id);
            } else if(pr.Name.equalsIgnoreCase('Claims User')){
                claimsUserProfileId = pr.Id;
                partnerProfileIdSet.add(pr.Id);
            } else if(pr.Name.equalsIgnoreCase('Claims Manager')){
                claimsManagerProfileId = pr.Id;
                partnerProfileIdSet.add(pr.Id);
            } else if(pr.Name.equalsIgnoreCase('Escalation User')){
                escalationUserProfileId = pr.Id;
                partnerProfileIdSet.add(pr.Id);
            }
        }                                               
        
        for(User u : users){
            if(partnerProfileIdSet.contains(u.ProfileId)){
                if(u.ProfileId == affiliateClaimsUserProfileId){
                    if(affiliateClaimsUsers == null) affiliateClaimsUsers = new List<User>();
                    affiliateClaimsUsers.add(u);
                } else if(u.ProfileId == affiliateEscalationUserProfileId){
                    if(affiliateEscalationUsers == null) affiliateEscalationUsers = new List<User>();
                    affiliateEscalationUsers.add(u);
                } else if(u.ProfileId == claimsUserProfileId){
                    if(claimsUsers == null) claimsUsers = new List<User>();
                    claimsUsers.add(u);
                } else if(u.ProfileId == claimsManagerProfileId){
                    if(claimsManagers == null) claimsManagers = new List<User>();
                    claimsManagers.add(u);
                } else if(u.ProfileId == claimsManagerProfileId){
                    if(escalationUsers == null) escalationUsers = new List<User>();
                    escalationUsers.add(u);
                }
            } else{
                doNotProceed = true;
            }
        }

        if(!doNotProceed){
            
            List<GroupMember> newGroupMembers = new List<GroupMember>();
            GroupMember gm;
        
            if(affiliateClaimsUsers != null){
                Group affiliateClaimGroup = new Group();
                affiliateClaimGroup = [Select Id From Group Where Name = 'Affiliate Claim Group'];
                for(User u : affiliateClaimsUsers){
                    gm = new GroupMember();
                    gm.GroupId = affiliateClaimGroup.Id;
                    gm.UserOrGroupId = u.Id;
                    newGroupMembers.add(gm);
                }
            }
            if(affiliateEscalationUsers != null){
                Group affiliateEscalationGroup  = [Select Id From Group Where Name = 'Affiliate Escalation Group'];
                List<Group> affiliateEscalationGroupList = [Select Id, Name From Group Where Name LIKE : '%_Escalation Group' AND Name != 'Affiliate Escalation Group'];
                List<UserRole> partnerRoleList = new List<UserRole>();
                List<String> roleIds = new List<String>();
                for(User u : affiliateEscalationUsers){
                    roleIds.add(u.UserRoleId);
                }
                partnerRoleList = [Select Id, Name From UserRole Where Id IN : roleIds];
    
    
                for(User u : affiliateEscalationUsers){
                    for(Group g : affiliateEscalationGroupList){
                        for(UserRole role : partnerRoleList){
                            if(u.UserRoleId == role.Id && g.Name.substring(0,g.Name.indexOf(' ')) == role.Name.substring(0,role.Name.indexOf(' '))){
                                gm = new GroupMember();
                                gm.GroupId = g.Id;
                                gm.UserOrGroupId = u.Id;
                                newGroupMembers.add(gm);
                            }
                        }
                    }
                    gm = new GroupMember();
                    gm.GroupId = affiliateEscalationGroup.Id;
                    gm.UserOrGroupId = u.Id;
                    newGroupMembers.add(gm);
                }
            }
            if(claimsUsers != null){
                Group claimInvestigationGroup = new Group();
                claimInvestigationGroup = [Select Id From Group Where Name = 'Claim Investigation Group'];
                for(User u : claimsUsers){
                    gm = new GroupMember();
                    gm.GroupId = claimInvestigationGroup.Id;
                    gm.UserOrGroupId = u.Id;
                    newGroupMembers.add(gm);
                }
            }
            if(claimsManagers != null){
                Group claimApprovalGroup = new Group();
                claimApprovalGroup = [Select Id From Group Where Name = 'Claim Approval Group'];
                for(User u : claimsManagers){
                    gm = new GroupMember();
                    gm.GroupId = claimApprovalGroup.Id;
                    gm.UserOrGroupId = u.Id;
                    newGroupMembers.add(gm);
                }
            }
            if(escalationUsers != null){
                Group escalationGroup = new Group();
                escalationGroup = [Select Id From Group Where Name = 'Escalation Group'];
                for(User u : escalationUsers){
                    gm = new GroupMember();
                    gm.groupId = escalationGroup.Id;
                    gm.UserOrGroupId = u.Id;
                    newGroupMembers.add(gm);
                }
            }
    
            if(!newGroupMembers.isEmpty()){
                try{
                    insert newGroupMembers;
                }catch(System.DmlException e){
                    for(Integer i = 0; i < e.getNumDml(); i++){
                        System.debug(e.getDmlMessage(i)); 
                    }
                }
            }
        }
    }
    
    /**
    * @Description: Check users to check if the user is eligible to have user created in MCAT.
    * @Author: Sagarika
    * @Date: 06-Sep-2017
    * @Param: users  
    * @Return: void.
    * @Details : US1105085: MCAT - Auto Create User : End (Added by Sagarika)
    *//*
    public static void addUsersToMCAT(List<User> users){
    	for(User user : users)
    	{
    		if(Label.PROFILES_FOR_MCAT_AUTO_CREATE.contains(user.Profile_Name_Text__c) && user.IsActive == true)
    		{
    			UserTriggerOperation.addUserToMCAT(user.id);
    		}    	
    	}   
    }
    */
  
        
   /**
    * @Description: Check if users are updated to active.
    * @Author: Sagarika
    * @Date: 06-Sep-2017
    * @Param: users  
    * @Return: void.
    * @Details : US1105085: MCAT - Auto Create User : End (Added by Sagarika)
    */
    /*
    public static void addUpdatedUsersToMCAT(List<User> newUserList, Map<Id,User>oldUserMap) {//calling this method from UserTrigger
        List<User> users = new List<User>();
        if(!newUserList.Isempty()){ 
        	for(User objuser:newUserList){
        		
        		String newProfile = objuser.Profile_Name_Text__c;
        		String oldProfile = oldUserMap.get(objuser.id).Profile_Name_Text__c;
        		if(objuser.Isactive && !(oldUserMap.get(objuser.id)).IsActive || !aeProfiles.contains(oldProfile) && aeProfiles.contains(newProfile)){
        			users.add(objuser);
        		}	
        	}
        }
        
        if(!users.Isempty()){  
        	addUsersToMCAT(users);
        }
    }
    */
    
    /**
    * @Description: This method create new goals for newly inserted Users with their profile AE and Region change.
    * @Author: Laxman Raj, Accenture
    * @Date: 30-Dec-2015    
    * @Return: void.
    */
  
    public static void CreateNewAE(){
        UserTriggerOperation.CreateNewAEGoal();
        
    }
    
    /**    
    * @Description: Business logic to add CAR/CAR Manager/XC/ Direct users to respective public group.
    * @Author: Malay Desai, Accenture    
    * @Date: 23-Feb-2016   
    * @Param:  Trigger.New, Trigger.OldMap    
    * @Return: None */ 
    
     public static void addUsersToGroup(List<User> userList, Map<Id, User> oldMap){
        List<User> actveUserList =  new List<User>();
        for(User u : userList){
            if(u.IsActive == true)
                  actveUserList.add(u);
        }
        UserTriggerOperation.addUsersToPublicGroup(actveUserList, oldMap);
    }
    
    
    
     /**
    * @Description: This method use to show custom validation to add federation Id as mandetory field
    * @Author: Amit Kumar Pradhan, Accenture
    * @Date: 24-July-2015    
    * @Return: void.
    */
    public static void userTriggerForFederationID() {                       
        for(User usr:(List<User>)Trigger.new){                          
            if(usr.FederationIdentifier == NULL || usr.FederationIdentifier == '' ){
                usr.addError('Please enter the NT Login or BP ID of the user in Federation ID. If the user has not been assigned an NT Login or BP ID then please enter the email address of the user.');
            }
            else{
               usr.FederationIdentifier= usr.FederationIdentifier.toLowerCase();
            }            
         }                 
    }  
    
    /**
    * @Description: This method use to create new  Coaching Record if user's manager's changes  and Any prior coaching relationships for that user are manually shared with the new manager in "Read only" mode 
    * @Author: Amit Kumar Pradhan, Accenture
    * @Date: 9-Oct-2015    
    * @Return: void.
    * Modified: US816242: Coach: Changing Manager Defect Resolution
    * Modified Date: 30/11/2016
    * Author: Radhika Bansal and Omkar 
    */
    public static void changeManagerForCoaching(List<User> newUserDetails,Map<Id,User> oldUserMap){       
        List<WorkCoachingShare> workCoachShareUpdateList = new List<WorkCoachingShare>();
        Set<Id> userIdSet = new Set<Id>();
        Set<Id> workCoachingIdSet = new Set<Id>();
        List<WorkCoaching> workCoachingdataAdd = new List<WorkCoaching>();
        Set<Id> userIdworkCoachSet = new Set<Id>();
        //Start : Added By Omkar for Coach record access US#:
        Set<Id> existingWorkCoachIdset = new Set<Id>();
        //End
        List<WorkCoaching>  workCoachingRecordList = new List<WorkCoaching>();
        Set<Id> managerIdSet = new Set<Id>();
        Map<Id,User> ManagerIdMap = new Map<Id,User>();
    
        
        for(User userTemp : newUserDetails)
        {
            if((userTemp.Profile_Name_Text__c ==system.label.DSRProfileName) || (userTemp.Profile_Name_Text__c ==system.label.DS_Supervisor) || (userTemp.Profile_Name_Text__c =='Xfinity CAR') )
            {
                if(oldUserMap.get(userTemp.Id).ManagerId != userTemp.ManagerId){  
                    userIdSet.add(userTemp.Id);
                    managerIdSet.add(userTemp.ManagerId);
                }
            }
        }
       
        if(!managerIdSet.isEmpty()){
           for(User managerList : [select ID,UserPermissionsWorkDotComUserFeature,Terms_and_Conditions_Accepted__c from User where ID IN :managerIdSet]){
                ManagerIdMap.put(managerList.Id,managerList);
            }
        }           
       
        if(!userIdSet.isEmpty()){
            for(WorkCoaching coaching : [select ID,OwnerId,Name,CoachedId,CoachId from WorkCoaching where CoachedId IN :userIdSet]){
                workCoachingIdSet.add(coaching.Id); 
                if(managerIdSet.contains(coaching.CoachId)){
                    existingWorkCoachIdset.add(coaching.Id);
                }else{
                    userIdworkCoachSet.add(coaching.CoachedId); 
                }          
            }
        }
        
        for(User userTemp : newUserDetails){
            if((!ManagerIdMap.isEmpty()) && (ManagerIdMap.containsKey(userTemp.ManagerId)) && (ManagerIdMap.get(userTemp.ManagerId).Terms_and_Conditions_Accepted__c!=NULL)){
                if( (userIdworkCoachSet.contains(userTemp.Id)) && (userTemp.UserPermissionsWorkDotComUserFeature) && (ManagerIdMap.get(userTemp.ManagerId).UserPermissionsWorkDotComUserFeature)){ 
                    WorkCoaching newCoachingRecord = new WorkCoaching();
                    newCoachingRecord.CoachId = userTemp.ManagerId;
                    newCoachingRecord.CoachedId = userTemp.Id;              
                    workCoachingdataAdd.add(newCoachingRecord);    
                }
            }
            else if((!ManagerIdMap.isEmpty()) && (ManagerIdMap.containsKey(userTemp.ManagerId)) && (ManagerIdMap.get(userTemp.ManagerId).Terms_and_Conditions_Accepted__c==NULL))
            {
               userTemp.addError('Cannot change manager as Managers Chatter Terms and conditions are not accepted.');
            }       
        }

   
        for(WorkCoachingShare workCoachShar : [SELECT Id,ParentId,AccessLevel FROM WorkCoachingShare WHERE ParentId IN : workCoachingIdSet AND RowCause = 'Manual'])
        {
                //Start : Added By Omkar for Coach record access US#:
                if(!(existingWorkCoachIdset.contains(workCoachShar.ParentId))){
                        workCoachShar.AccessLevel = 'Read';
                        workCoachShareUpdateList.add(workCoachShar);
                }
                else if(existingWorkCoachIdset.contains(workCoachShar.ParentId)){
                        workCoachShar.AccessLevel = 'Edit';
                        workCoachShareUpdateList.add(workCoachShar);
                }   
                //End 
        }
        
        Database.saveResult[] srInsertList = Database.Insert(workCoachingdataAdd, false);
        
        if(srInsertList.size() > 0){
        
            for(Database.saveResult sr : srInsertList){
                if(!sr.isSuccess()){
                    Database.error[] erList = sr.getErrors();
                    for(Database.error er : erList){
                        System.debug('Error Field : ' + er.getFields());
                        System.debug('Error Message : ' + er.getMessage());
                        System.debug('Error Status code : ' + er.getStatusCode());                                                
                    }
                
                }
            
            }
        } 
        
        Database.saveResult[] srUpdateList = Database.Update(workCoachShareUpdateList, false);
        
        if(srUpdateList .size() > 0){
        
            for(Database.saveResult sr : srUpdateList ){
                if(!sr.isSuccess()){
                    Database.error[] erList = sr.getErrors();
                    for(Database.error er : erList){
                        System.debug('Error Field : ' + er.getFields());
                        System.debug('Error Message : ' + er.getMessage());
                        System.debug('Error Status code : ' + er.getStatusCode());                                                
                    }
                
                }
            
            }
        } 
    }

    
    /**
    * @Description: This method use to validate Manager having Quota Record OR Not 
    * @Author: Ashish Sonawane, Accenture 
    * @Date: 18-Jan-2016    
    * @Return: void.
    */
     public static void changeMgrForAE(List<User> userList, Map<Id,User> oldUserMap){
        Set<String> userMgrSet = new Set<String>();
        Set<String> goalOwnerIdSet = new Set<String>();
        String Goal_Template_RecordtypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get(system.label.Goal_Xfinity_Communities_Recordtype).getRecordTypeId();
        
        for(User newUser : userList){
            if(String.valueOf(newUser.ProfileId).contains(Label.XCAccountExecutive) && newUser.UserPermissionsWorkDotComUserFeature == true){
                if(newUser.managerId != NULL){
                    userMgrSet.add(newUser.managerId);
                }              
            }  
        }
        
        for(Goal mgrGoal : [SELECT Id,OwnerID FROM Goal WHERE OwnerID IN :userMgrSet AND StartDate <= :System.Today()  AND DueDate >= :System.Today() 
                                                   AND RecordtypeId =: Goal_Template_RecordtypeId  
                                                   LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
            goalOwnerIdSet.add(mgrGoal.OwnerID);                                              
        } 
        for(User newUser : userList){         
            if(String.valueOf(newUser.ProfileId).contains(Label.XCAccountExecutive) && newUser.UserPermissionsWorkDotComUserFeature == true){                
                if(Trigger.isInsert || (Trigger.isUpdate && oldUserMap.get(newUser.Id).ManagerId != newUser.ManagerId)){
                    if(newUser.managerId != NULL){
                        if(!goalOwnerIdSet.contains(newUser.managerId)){
                            newUser.addError(Label.ErrMsgForChangeMgrOfAE);
                        } 
                    }   
                }
            
            }           
        }
       
    } 
    
    /**
    * @Description: This method is to update fields in user object when user Activated and Deactivated. 
    * @Author: Laxman Raj Janapatla, Accenture 
    * @Date: 27-Jan-2016    
    * @Return: void.
    */
    Public static void UserActiveDeActiveUpadte(List<User> UsrList){
        List<User> UserUpdateList = new List<User>();    
        for(user usr : UsrList){  
            if(usr.IsActive==true)
            {       
                usr.Deactivation_Status__c = null; 
            }
            else if(usr.IsActive== false )
            {
                usr.Last_Deactivation_Date__c = System.today();
                usr.Deactivation_Reason__c = Label.Deactivation_Reason_Manual+' '+ UserInfo.getUserName();
                usr.Deactivation_Status__c = Label.Success_Deactivate_users;        
                usr.Deactivation_Failure_Reason__c = null;       
            } 
        }
    }  
    
    /**
    * @Description: This method is to provide a permission set to the Property Lab users. 
    * @Author: Akanksha Singhal, Accenture 
    * @Modify By : Ashish Sonawane
    * @Date: 07-March-2016    
    * @Return: void.
    */
    public static void assignPermissionSet(List<User> NewUserList, List<User> OldUserList){   
        
        Map<id,User> oldUserMap =  (Map<id,User>)  Trigger.OldMap; 
        Map<id,User> newUserMap =  (Map<id,User>)  Trigger.newMap;
        Set<String> profileNames = new Set<String>();   
        List<User_Feature_Permission__mdt> UserFeaturePermissionList = [SELECT Channel__c, Feature__c,Permission_set_Name__c,Region__c,Status__c,Profile_Name__c FROM User_Feature_Permission__mdt  LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        Map<Id, String> userPermissionSetNameMap = new Map<Id, String>();
        Set<Id> userMatchedwithProfileSet = new Set<Id>();
        Map<String, Profile> profileNameProfileMap = new Map<String, Profile>();
        //Map<String, Id> regionProfileMap = new Map<String, Id>();
        Map<String,ID> PermissionSetNameIDMap = new Map<string, ID>();
        List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>(); 
        Map<Id,Set<Id>> userIdPermSetIdMap = new Map<Id,Set<Id>>();
        Map<Id, User> idUserforDeleteionMap = new Map<Id, User>();
        Map<Id, User> idUserCMTDeleteionMap = new Map<Id, User>();
        Map<String, User_Feature_Permission__mdt> regionCustomMetdataMap = new Map<String, User_Feature_Permission__mdt>();
        Map<String, User_Feature_Permission__mdt> cmtPSNameMap = new Map<String, User_Feature_Permission__mdt>();
        List<PermissionSetAssignment> psaDeletionList = new List<PermissionSetAssignment>();
        
        for(User_Feature_Permission__mdt cmt : UserFeaturePermissionList){
            profileNames.add((cmt.Profile_Name__c).trim());
        }
        for(Profile pro : [SELECT Id, Name FROM Profile WHERE name IN : profileNames]){
            profileNameProfileMap.put(pro.Name.trim(), pro);
        }
        
        /*for(User_Feature_Permission__mdt cmt : UserFeaturePermissionList){
            regionProfileMap.put(cmt.Region__c, (profileNameProfileMap.get(cmt.Profile_Name__c.trim())).id);
        }*/ 
        
        for(User userObj : NewUserList){
            if((Trigger.isInsert && userObj.Region__c != null) || (Trigger.isUpdate && (oldUserMap.get(userObj.Id).Region__c != userObj.Region__c || oldUserMap.get(userObj.Id).ProfileId != userObj.ProfileId))){    
                for(User_Feature_Permission__mdt cmt : UserFeaturePermissionList){                    
                    //if(userObj.Region__c == cmt.Region__c && regionProfileMap.get(cmt.Region__c) == userObj.ProfileId && cmt.Status__c != 'InActive' ){
                    if(userObj.Region__c == cmt.Region__c && profileNameProfileMap.get(cmt.Profile_Name__c).Id == userObj.ProfileId && cmt.Status__c != 'InActive' ){
                        userPermissionSetNameMap.put(userObj.Id, cmt.Permission_set_Name__c.trim());
                    }
                }
            }               
        }
        if(!userPermissionSetNameMap.isEmpty()){
            for(PermissionSet permSetObj : [Select ID, label  from PermissionSet where label  IN: userPermissionSetNameMap.values()  LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                PermissionSetNameIDMap.put(permSetObj.label.Trim(),permSetObj.Id);
            }
            
            for(PermissionSetAssignment permissionAssignee : [SELECT PermissionSetId, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId IN: userPermissionSetNameMap.keySet()  LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                Set<Id> permissionSetIDSet = new Set<Id>();
                if(userIdPermSetIdMap.containsKey(permissionAssignee.AssigneeId)){
                    permissionSetIDSet = userIdPermSetIdMap.get(permissionAssignee.AssigneeId);
                }
                permissionSetIDSet.add(permissionAssignee.PermissionSetId);
                userIdPermSetIdMap.put(permissionAssignee.AssigneeId,permissionSetIDSet);
            }
            for(Id userId : userPermissionSetNameMap.keySet()){               
                Id permSetId =  PermissionSetNameIDMap.get(userPermissionSetNameMap.get(userId));
                if(permSetId != null && !userIdPermSetIdMap.get(userId).contains(permSetId)){
                    PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = permSetId, AssigneeId = userId);
                    permissionList.add(psa) ;                     
                }                                
            }
            Database.insert(permissionList);
        }
        
        //for deletion        
        for(User_Feature_Permission__mdt cmdt : UserFeaturePermissionList){
                regionCustomMetdataMap.put((cmdt.Region__c).trim(), cmdt);  
                cmtPSNameMap.put((cmdt.Permission_set_Name__c).trim(), cmdt);
        }
        
        for(User userObj : NewUserList){
            if(Trigger.isUpdate && (oldUserMap.get(userObj.Id).Region__c != userObj.Region__c)){
                if(!regionCustomMetdataMap.containsKey(userObj.Region__c.trim())){
                    idUserforDeleteionMap.put(userObj.id, userObj);
                }else if(regionCustomMetdataMap.containsKey(oldUserMap.get(userObj.Id).Region__c.trim()) && regionCustomMetdataMap.containsKey(userObj.Region__c.trim())){
                    idUserCMTDeleteionMap.put(userObj.id, userObj);
                }
            }
        }
        if(!idUserforDeleteionMap.isEmpty() && Trigger.isUpdate){
            Map<Id, PermissionSetAssignment> permissionAsgmtMap = new Map<Id, PermissionSetAssignment>();            
            for(PermissionSetAssignment psAssignmt :[SELECT PermissionSetId, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId IN: idUserforDeleteionMap.keySet()  LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                permissionAsgmtMap.put(psAssignmt.PermissionSetId, psAssignmt);
            }
            for(PermissionSet ps : [SELECT id, label, IsOwnedByProfile  FROM PermissionSet WHERE Id IN : permissionAsgmtMap.keySet()]){
                if(!ps.IsOwnedByProfile && cmtPSNameMap.containsKey((ps.label).trim())){
                    psaDeletionList.add(permissionAsgmtMap.get(ps.id));
                }
            }
        }    
        
        if(!idUserCMTDeleteionMap.isEmpty() && Trigger.isUpdate){
            Map<Id, PermissionSetAssignment> permissionAsgmtMap = new Map<Id, PermissionSetAssignment>();
            Map<Id, User> userSelectedforDeletionMap = new Map<Id, User>();
            for(Id uId : idUserCMTDeleteionMap.keySet()){
                if(regionCustomMetdataMap.get(idUserCMTDeleteionMap.get(uId).region__c.trim()).Permission_set_Name__c.trim() != regionCustomMetdataMap.get(oldUserMap.get(uId).region__c.trim()).Permission_set_Name__c.trim()){
                    userSelectedforDeletionMap.put(uId, idUserCMTDeleteionMap.get(uId));
                }
            }
            for(PermissionSetAssignment psAssignmt :[SELECT PermissionSetId, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId IN: userSelectedforDeletionMap.keySet()  LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                permissionAsgmtMap.put(psAssignmt.PermissionSetId, psAssignmt);
            }
            for(PermissionSet ps : [SELECT id, label, IsOwnedByProfile  FROM PermissionSet WHERE Id IN : permissionAsgmtMap.keySet()]){
                if(!ps.IsOwnedByProfile && cmtPSNameMap.containsKey((ps.label).trim())){
                    psaDeletionList.add(permissionAsgmtMap.get(ps.id));
                }
            }
        }
        if(!psaDeletionList.isEmpty()){
            delete psaDeletionList;
        }                  
    }    
    
    //START  - Animesh - Commenting code to refractor it and fixing Mised DML issue US1027533. New method: shareFeedbackRequestWithNewMgr
    /**
    * @Description: This method is to change owner of FeedbackRequests. 
    * @Author: Revan Bhadange, Accenture 
    * @Date: 08-Feb-2016    
    * @Return: void.
    */
    /*Public static void ManageChangeFeedbackRequest(List<User> newUserList, Map<Id,User>oldUserMap){
        try{
        ManageChangeFeedbackRequestforSDM(newUserList,oldUserMap);
        Set<Id> subjectIds=new Set<Id>();
        Map<Id,Id>newMapSubjectId  = new Map<Id,Id> ();
        for(User itNewUser : newUserList) {
             if((itNewUser.ManagerId != oldUserMap.get(itNewUser.Id).ManagerId)&& (itNewUser.ManagerId!=NULL) && itNewUser.UserPermissionsWorkDotComUserFeature == true) {  
              newMapSubjectId.put(itNewUser.Id,itNewUser.ManagerId);
           }
        }
        subjectIds.addAll(newMapSubjectId.keySet());
        List<WorkFeedbackRequestShare>wfrs = new List<WorkFeedbackRequestShare> ();
        List<WorkFeedbackRequest> wfrlist =  [SELECT Id, OwnerId, SubjectId FROM WorkFeedBackRequest WHERE SubjectId IN : subjectIds];
        set<Id>strWrkFeedback = new set<Id> ();
        for(WorkFeedbackRequest itrWrkf : wfrlist) {
            strWrkFeedback.add(itrWrkf.Id);    
            wfrs.add( new WorkFeedbackRequestShare(ParentID=itrWrkf.Id,AccessLevel='Read',RowCause='Manual',UserOrGroupId=itrWrkf.SubjectId));
        }
        List<WorkFeedbackRequestShare>lstShareWorkFeedBack = [SELECT Id, ParentID FROM WorkFeedbackRequestShare WHERE ParentID IN : strWrkFeedback];
        database.Delete(lstShareWorkFeedBack,false);
        Map<Id, Id> groupMap = new Map<Id, Id>();
        for(Group g : [SELECT Id, RelatedId,Type FROM Group WHERE Type = 'Manager' AND RelatedId IN: subjectIds]){
            groupMap.put(g.RelatedId, g.Id);
        }
        if (!groupMap.isEmpty()) {
            integer months = integer.valueof(Label.LastTwoMonths);
            string str  = 'SELECT Id, OwnerId, SubjectId FROM WorkFeedBackRequest WHERE SubjectId IN : subjectIds AND CreatedDate >= LAST_N_DAYS:'+months;
            
            List<WorkFeedBackRequest> lstFeedBackRequest = database.query(str); 
            for(WorkFeedBackRequest itFeedBackReq : lstFeedBackRequest) {
                itFeedBackReq.OwnerId = newMapSubjectId.get(itFeedBackReq.SubjectId);  
                wfrs.add( new WorkFeedbackRequestShare(ParentID=itFeedBackReq.Id,AccessLevel='Read',RowCause='Manual',UserOrGroupId=itFeedBackReq.SubjectId));
                wfrs.add( new WorkFeedbackRequestShare(ParentID=itFeedBackReq.Id,AccessLevel='Read',RowCause='Manual',UserOrGroupId=groupMap.get(itFeedBackReq.SubjectId)));
            }
            
            if(!lstFeedBackRequest.isEmpty() && Schema.sObjectType.WorkFeedBackRequest.isAccessible()) {
                Database.update(lstFeedBackRequest);
               
            }
            Database.Insert(wfrs);
        }
        }catch(System.DmlException e){
            for(Integer i = 0; i < e.getNumDml(); i++){
                System.debug(e.getDmlMessage(i)); 
            }
            }
            
    }*/
    
   /**
    * @Description: This method is to change owner of FeedbackRequests. 
    * @Author: Sucheta Verma, Accenture 
    * @Date: 10-March-2016    
    * @Return: void.
    */
     /*Public static void ManageChangeFeedbackRequestforSDM(List<User> newUserList, Map<Id,User>oldUserMap){
        try{
        Map<Id,Id> subjectIds=new Map<Id,Id>();
        Map<Id,Id> newMapSubjectId  = new Map<Id,Id> ();
        Map<Id,Id> newMapSDMId = new Map<Id,Id> ();
        Set<Id> subjectId=new Set<Id>();
        Set<Id> ASMId=new Set<Id>();
        for(User itNewUser : newUserList) {
           if((itNewUser.ManagerId != oldUserMap.get(itNewUser.Id).ManagerId) && (itNewUser.Profile_Name_Text__c == Label.DS_Supervisor) && itNewUser.UserPermissionsWorkDotComUserFeature == true){  
               newMapSDMId.put(itNewUser.Id,oldUserMap.get(itNewUser.Id).ManagerId);
           }
        }
            if(!newMapSDMId.isEmpty()){
            for(User XSPUser : [Select Id,Name,ManagerId From User where ManagerId IN: newMapSDMId.keyset() ]){
            subjectIds.put(XSPUser.Id,XSPUser.ManagerId);
    }
    
         subjectId.addAll(subjectIds.keySet());    
         ASMId.addAll(newMapSDMId.values());
         Map<Id, Id> groupMap = new Map<Id, Id>();
         for(Group g : [SELECT Id, RelatedId,Type FROM Group WHERE Type = 'Manager' AND RelatedId IN: subjectId]){
            groupMap.put(g.RelatedId, g.Id);
        }
        if (!groupMap.isEmpty()) {
        integer months = integer.valueof(Label.LastTwoMonths);
          string str  = 'SELECT Id, OwnerId, SubjectId FROM WorkFeedBackRequest WHERE SubjectId IN : subjectId AND OwnerId IN: ASMId AND CreatedDate >= LAST_N_DAYS:'+months ;
          List<WorkFeedBackRequest> lstFeedBackRequest = database.query(str); 
          List<WorkFeedbackRequestShare>wfrs = new List<WorkFeedbackRequestShare> ();
          for(WorkFeedBackRequest itFeedBackReq : lstFeedBackRequest) {
          itFeedBackReq.OwnerId = subjectIds.get(itFeedBackReq.SubjectId);
           wfrs.add( new WorkFeedbackRequestShare(ParentID=itFeedBackReq.Id,AccessLevel='Read',RowCause='Manual',UserOrGroupId=itFeedBackReq.SubjectId));
           wfrs.add( new WorkFeedbackRequestShare(ParentID=itFeedBackReq.Id,AccessLevel='Read',RowCause='Manual',UserOrGroupId=groupMap.get(itFeedBackReq.SubjectId)));
            }
            if(!lstFeedBackRequest.isEmpty()) {
                Database.update(lstFeedBackRequest);
                Database.Insert(wfrs);
            }

        } 
        }
     }catch(System.DmlException e){
            for(Integer i = 0; i < e.getNumDml(); i++){
                System.debug(e.getDmlMessage(i)); 
            }
     }
    
  }*/
    //END - Animesh - Commenting code to refractor it and fixing Mised DML issue US1027533. New method: shareFeedbackRequestWithNewMgr
  
    /**
    * @Description: This method is to change permission set for car and car manager. 
    * @Author: Revan Bhadange, Accenture 
    * @Date: 17-June-2016    
    * @Return: void.
    */
    public static void assignCarCarManagerPerSet(List<User> NewUserList, Map<id,User> oldUserMap ) {
        Map<String,String>ProfilePerMap = new Map<String,String> ();
        Map<String,String>ProfilePerMap1 = new Map<String,String> ();
        for(Permission_Set_Assignment__mdt itre : [SELECT Permission_set_Name__c, Profile_Name__c FROM Permission_Set_Assignment__mdt  LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) {
            if(itre.Profile_Name__c.equals(strCarProfile) || itre.Profile_Name__c.equals(strCarMgrProfile)) {
                ProfilePerMap.put(itre.Profile_Name__c,itre.Permission_set_Name__c);
            }
            else {
               ProfilePerMap1.put(itre.Profile_Name__c,itre.Permission_set_Name__c);
            }
        }
        Set<Id>ProfileSetId = new Set<Id> ();
        Set<Id>ProfileSetId1 = new Set<Id> ();
        for(Profile itrprofile : [SELECT id,Name FROM Profile WHERE Name IN : ProfilePerMap.keyset()]) {
                ProfileSetId.add(itrprofile.Id);
        }
        for(Profile itrprofile : [SELECT id,Name FROM Profile WHERE Name IN : ProfilePerMap1.keyset()]) {
                ProfileSetId1.add(itrprofile.Id);
        }
        PermissionSet objPermissionSet = new PermissionSet();
        if(!ProfilePerMap.isEmpty()) {
            objPermissionSet = [SELECT id,Name FROM PermissionSet WHERE Label IN : ProfilePerMap.values()];
        }
        PermissionSet objPermissionSet1 = new PermissionSet();
        if(!ProfilePerMap1.isEmpty()) {
            objPermissionSet1 = [SELECT id,Name FROM PermissionSet WHERE Label IN : ProfilePerMap1.values()];
        }    
        List<PermissionSetAssignment> lstitrPermissionSetAssetInsert = new List<PermissionSetAssignment> ();
        List<PermissionSetAssignment> lstitrPermissionSetAssetDelete = new List<PermissionSetAssignment> ();
        List<PermissionSetAssignment> lstitrPermissionSetAssetInsert1 = new List<PermissionSetAssignment> ();
        List<PermissionSetAssignment> lstitrPermissionSetAssetDelete1 = new List<PermissionSetAssignment> ();
        for(User itrUserValue : NewUserList) {
         if(trigger.isUpdate){
            if(!oldUserMap.isEmpty() && oldUserMap.get(itrUserValue.Id).ProfileId != itrUserValue.ProfileId) {
                if(!ProfileSetId.isEmpty() && ProfileSetId.Contains(itrUserValue.ProfileId)) {
                    PermissionSetAssignment objStr = new PermissionSetAssignment ();
                    objStr.assigneeid= itrUserValue.Id;
                    objStr.permissionsetid= objPermissionSet.id; 
                    lstitrPermissionSetAssetInsert.add(objStr);
                }
                
                if(ProfileSetId1.Contains(itrUserValue.ProfileId)) {
                    PermissionSetAssignment objStr = new PermissionSetAssignment ();
                    objStr.assigneeid= itrUserValue.Id;
                    objStr.permissionsetid= objPermissionSet1.id; 
                    lstitrPermissionSetAssetInsert1.add(objStr);
                }
            }
          }  
         //  if(newUserMap.get(itrUserValue.Id).ProfileId != itrUserValue.ProfileId) {
         if(trigger.isInsert){
                if(!ProfileSetId.isEmpty() && ProfileSetId.Contains(itrUserValue.ProfileId)) {
                    PermissionSetAssignment objStr = new PermissionSetAssignment ();
                    objStr.assigneeid= itrUserValue.Id;
                    objStr.permissionsetid= objPermissionSet.id; 
                    lstitrPermissionSetAssetInsert.add(objStr);
                }
                
                if(!ProfileSetId1.isEmpty() && ProfileSetId1.Contains(itrUserValue.ProfileId)) {
                    PermissionSetAssignment objStr = new PermissionSetAssignment ();
                    objStr.assigneeid= itrUserValue.Id;
                    objStr.permissionsetid= objPermissionSet1.id; 
                    lstitrPermissionSetAssetInsert1.add(objStr);
                } 
        }
        }
        
        Database.Upsert(lstitrPermissionSetAssetInsert,false);
        Database.Upsert(lstitrPermissionSetAssetInsert1,false);
        for(User itrUserValue : NewUserList) {
           if(trigger.isUpdate){
            if(oldUserMap.get(itrUserValue.Id).ProfileId != itrUserValue.ProfileId) {
                if(!ProfileSetId.Contains(itrUserValue.ProfileId)) {
                    for(PermissionSetAssignment itrPermissionSetAss :[SELECT ID FROM PermissionSetAssignment WHERE AssigneeId=:itrUserValue.Id and
                                                       PermissionSetId=:objPermissionSet.id]) {
                        lstitrPermissionSetAssetDelete.add(itrPermissionSetAss);  
                    } 
                }
                if(!ProfileSetId1.Contains(itrUserValue.ProfileId)) {
                    for(PermissionSetAssignment itrPermissionSetAss :[SELECT ID FROM PermissionSetAssignment WHERE AssigneeId=:itrUserValue.Id and
                                                       PermissionSetId=:objPermissionSet1.id]) {
                        lstitrPermissionSetAssetDelete1.add(itrPermissionSetAss);  
                    } 
                }
            }
        }
        
     }   
        Database.delete(lstitrPermissionSetAssetDelete);
        Database.delete(lstitrPermissionSetAssetDelete1);
    
    }
    
      /**
    * @Description: This method is to assign Wave Permission Set and License to XC users. 
    * @Author: Shalaka Kadwade, Accenture 
    * @Date: 20-June-2016    
    * @Return: void.
    */

    public static void waveAccessToNewXCUsers(List<user>NewUserList,Map<Id, User> oldUserMap){
       Map<String,String>PerLiceAss = new Map<String,String> ();
       Map<String,String>PerSetAss = new Map<String,String> ();
       Set<String>strSet = new Set<String> ();
       for(Permission_Set_License_Assign__mdt itre : [SELECT Id,Label,License__c FROM Permission_Set_License_Assign__mdt]) {
           PerLiceAss.put(itre.License__c ,itre.Label);
       }
       for(Wave_Permission_Set_Assignment__mdt itrWave : [SELECT Id,Label,Permission_Set_Name__c FROM Wave_Permission_Set_Assignment__mdt]) { 
           PerSetAss.put(itrWave.Permission_Set_Name__c, itrWave.Label);   
           strSet.add(itrWave.Label);             
       }
       Set<Id>PerLicenseSetId = new Set<Id> ();
       Set<Id>PermissionSetId = new Set<Id> ();
       Set<Id>ProfileSetId = new Set<Id> ();
       if(!PerLiceAss.isEmpty ()) {
           for(PermissionSetLicense itrPerLicense : [select Id,MasterLabel FROM PermissionSetLicense WHERE MasterLabel IN : PerLiceAss.KeySet()]) {
                    PerLicenseSetId.add(itrPerLicense.Id);
           }
       }
       if(!PerSetAss.isEmpty()) {
           for(PermissionSet itrPerSet : [SELECT Id,Label FROM PermissionSet WHERE Label IN : PerSetAss.KeySet()]) {
               PermissionSetId.add(itrPerSet.Id);    
           }
       }
       if(!strSet.isEmpty ()) {
           for(Profile objProfile : [SELECT Id, Name FROM Profile WHERE Name IN : strSet]) {
               ProfileSetId.add(objProfile.Id);      
           }
       }
       List<PermissionSetLicenseAssign>lstPerSetLicAss = new List<PermissionSetLicenseAssign> ();
       List<PermissionSetAssignment>lstPerSetAss = new List<PermissionSetAssignment> ();
       List<PermissionSetLicenseAssign>lstPerSetLicAss1 = new List<PermissionSetLicenseAssign> ();
       List<PermissionSetAssignment>lstPerSetAss1 = new List<PermissionSetAssignment> ();
       for(User itrUserValue : NewUserList) {
            if(trigger.isInsert) {
            if(!ProfileSetId.isEmpty() && ProfileSetId.Contains(itrUserValue.ProfileId)) {
               for(Id itrLicense : PerLicenseSetId) {
                    PermissionSetLicenseAssign objPerLicAss = new PermissionSetLicenseAssign ();
                    objPerLicAss.assigneeid = itrUserValue.Id;
                    objPerLicAss.PermissionSetLicenseId = itrLicense; 
                    lstPerSetLicAss.add(objPerLicAss);
                }
                for(Id itrPerSet : PermissionSetId) {
                    PermissionSetAssignment objPerAss = new PermissionSetAssignment ();
                    objPerAss.assigneeid= itrUserValue.Id;
                    objPerAss.permissionsetid= itrPerSet; 
                    lstPerSetAss.add(objPerAss);
                }
                
            }
         }
         if(trigger.isUpdate) {   
             if(!oldUserMap.isEmpty() && oldUserMap.get(itrUserValue.Id).ProfileId != itrUserValue.ProfileId) {
                    if(ProfileSetId.Contains(itrUserValue.ProfileId)) {
                       for(Id itrLicense : PerLicenseSetId) {
                            PermissionSetLicenseAssign objPerLicAss = new PermissionSetLicenseAssign ();
                            objPerLicAss.assigneeid = itrUserValue.Id;
                            objPerLicAss.PermissionSetLicenseId = itrLicense; 
                            lstPerSetLicAss.add(objPerLicAss);
                        }
                        for(Id itrPerSet : PermissionSetId) {
                            PermissionSetAssignment objPerAss = new PermissionSetAssignment ();
                            objPerAss.assigneeid= itrUserValue.Id;
                            objPerAss.permissionsetid= itrPerSet; 
                            lstPerSetAss.add(objPerAss);
                        }
                    }
                    else {
                       for(PermissionSetAssignment itrPermissionSetAss :[SELECT ID FROM PermissionSetAssignment WHERE AssigneeId=:itrUserValue.Id and
                                                                         PermissionSetId IN : PermissionSetId]) {
                            lstPerSetAss1.add(itrPermissionSetAss);  
                       } 
                       for(PermissionSetLicenseAssign itrPerLicAss :[SELECT ID FROM PermissionSetLicenseAssign WHERE AssigneeId=:itrUserValue.Id and
                                                                         PermissionSetLicenseId IN : PerLicenseSetId]) {
                            lstPerSetLicAss1.add(itrPerLicAss);  
                       } 
                    }
                }
            }
       }
       Database.Upsert(lstPerSetLicAss,false);
       Database.Upsert(lstPerSetAss,false);
       Database.Delete(lstPerSetAss1,false);
       Database.Delete(lstPerSetLicAss1,false);   
    }
    
    /**    
    *@Description: Updating "Reporting Manager" field of Goal(from next fisical month) record if AE manager changes
    * @Author: Amit Kumar Pradhan, Accenture    
    * @Date: 19-Oct-2016   
    * @User Story: US814546     
    * @Return: None    
    */  
    public static void updateGoalForAE(Map<Id,User> oldUserMap,List<User> newUserList){
        UserTriggerOperation.updateReportingMgrForGoal(oldUserMap,newUserList);
    }
    
     /**    
    *@Description: This method updates the User's Email encoding field and sets it to UTF-8 
    * @Author: Shivani Gautam,Accenture 
    * @Date: 19-Oct-2016   
    * @User Story: US778046
    * @Return: void
    */
    
     public static void updateEmailEncodingField(List<User> userList){
      try{
      if(!userList.isEmpty()){
        for(User usr : userList){
            if(usr.EmailEncodingKey != 'UTF-8'){
                usr.EmailEncodingKey = 'UTF-8';
             }     
           }
         } 
       }
       catch(Exception e)
       {
        System.debug(e.getMessage());
       }
    }
    
    /**    
    *@Description: Add/Remove Users from Chatter Group based on Chatter Group Vs Profile Data in Custom Settings ProfileVsChatterGroup__c
    * @Author: Animesh Datta, Accenture    
    * @Date: 16-Nov-2016   
    * @User Story: US799120,US799239,US799275     
    * @Return: None    
    */
    
    public static void addUsersToChatterGroup(Map<Id,User> oldUserDetails,List<User> newUserDetail) {
        UserTriggerOperation.addUsersToChatterGroup(oldUserDetails,newUserDetail);   
    }
    
    public static void updateMonthlyCARGoals(Map<Id,User> oldUserMap,List<User> newUserList){
        Set<Id> newMgrSet = new Set<Id>();
        Set<Id> oldMgrSet = new Set<Id>();
        List<Metric> updateMetrics = new List<Metric>();
        Map<Id,Integer> newMgrUserCountMap = new Map<Id,Integer>();
        Map<Id,Integer> oldMgrUserCountMap = new Map<Id,Integer>();
        
        /*Map<Id,User> newCARMap = new Map<Id,User>([SELECT Id, ManagerId FROM User WHERE Isactive=TRUE AND 
        Profile.Name =: Label.Xfinity_CAR_ProfileName AND ManagerId IN : newUserList 
        LIMIT :(Limits.getLimitQueryRows()-Limits.getQueryRows())]);
        
        Map<Id,User> oldCARMap = new Map<Id,User>([SELECT Id, ManagerId FROM User WHERE Isactive=TRUE AND 
        Profile.Name =: Label.Xfinity_CAR_ProfileName AND ManagerId IN : oldUserMap.values()
        LIMIT :(Limits.getLimitQueryRows()-Limits.getQueryRows())]);*/
    
        /*for(User usr : newCARMap.values()){
            if(usr.ManagerId != null && usr.Manager.isActive){
                newMgrSet.add(usr.ManagerId);
            }
        }
        for(User usr : oldCARMap.values()){
            if(usr.ManagerId != null && usr.Manager.isActive){
                oldMgrSet.add(usr.ManagerId);
            }
        }*/
        
        for(User usr : newUserList){
            if(usr.isActive && usr.Profile_Name_Text__c == Label.Xfinity_CAR_ProfileName){              
                //For new record
                if(Trigger.isInsert || (Trigger.isUpdate && usr.ManagerId != oldUserMap.get(usr.Id).ManagerId)){
                    if(usr.ManagerId != null){
                        Integer tempCountNew = 0;
                        if(newMgrUserCountMap.containsKey(usr.ManagerId)){
                            tempCountNew = newMgrUserCountMap.get(usr.ManagerId);
                        }
                        tempCountNew++;
                        newMgrUserCountMap.put(usr.ManagerId,tempCountNew);
                    }
                }               
                //for old record               
                if(Trigger.isUpdate && usr.ManagerId != oldUserMap.get(usr.Id).ManagerId){
                    User oldUserRecord = oldUserMap.get(usr.Id);
                    if(oldUserRecord.ManagerId != null){                        
                        Integer tempCountOld = 0;
                        if(oldMgrUserCountMap.containsKey(oldUserRecord.ManagerId)){
                            tempCountOld = oldMgrUserCountMap.get(oldUserRecord.ManagerId);
                        }
                        tempCountOld++;
                        oldMgrUserCountMap.put(oldUserRecord.ManagerId,tempCountOld);
                    }
                }
            }           
        }
        if(!newMgrUserCountMap.isEmpty() || !oldMgrUserCountMap.isEmpty()){
            for(Goal goal : [SELECT Id, OwnerId, Name, (SELECT Id,Name,TargetValue, CurrentValue FROM Metrics) FROM Goal WHERE (OwnerId IN: newMgrUserCountMap.keySet() OR OwnerId IN: oldMgrUserCountMap.keySet()) AND StartDate <=: todaysDate AND DueDate >=: todaysDate AND RecordTypeId = :propertyLabRecordTypeId AND Status !=: GOAL_STATUS_COMPLETE AND Owner.isActive = true]){
                
                if(!newMgrUserCountMap.isEmpty() && newMgrUserCountMap.containsKey(goal.OwnerID)){
                    for(Metric metric : goal.Metrics){
                        if(metric.Name == System.Label.Metric_Name_TotalPropertyVisitsperMonth){
                            if(metric.TargetValue == 1){
                                metric.TargetValue = metric.TargetValue + (newMgrUserCountMap.get(goal.OwnerID)*Integer.valueOf(System.Label.Target_TotalPropertyVisitsperMonth)) - 1;
                            }
                            else{
                                metric.TargetValue = metric.TargetValue + (newMgrUserCountMap.get(goal.OwnerID)*Integer.valueOf(System.Label.Target_TotalPropertyVisitsperMonth));
                            }
                        }
                        if(metric.Name == System.Label.Metric_Name_AveragePropertyVisitsperDay){
                            if(metric.TargetValue == 1){
                                metric.TargetValue = metric.TargetValue + (newMgrUserCountMap.get(goal.OwnerID)*Integer.valueOf(System.Label.Target_AveragePropertyVisitsperDay)) - 1;
                            }
                            else{
                                metric.TargetValue = metric.TargetValue + (newMgrUserCountMap.get(goal.OwnerID)*Integer.valueOf(System.Label.Target_AveragePropertyVisitsperDay));
                            }   
                        }
                        if(metric.Name == System.Label.Metric_Name_Events){
                            if(metric.TargetValue == 1){
                                metric.TargetValue = metric.TargetValue + (newMgrUserCountMap.get(goal.OwnerID)*Integer.valueOf(System.Label.Target_Events)) -1;
                            }
                            else{
                                metric.TargetValue = metric.TargetValue + (newMgrUserCountMap.get(goal.OwnerID)*Integer.valueOf(System.Label.Target_Events)); 
                            }
                        }
                        updateMetrics.add(metric);
                    }
                }
                else if(!oldMgrUserCountMap.isEmpty() && oldMgrUserCountMap.containsKey(goal.OwnerID)){
                    
                    for(Metric metric : goal.Metrics){
                        if(metric.Name == System.Label.Metric_Name_TotalPropertyVisitsperMonth){
                            metric.TargetValue = (metric.TargetValue - (oldMgrUserCountMap.get(goal.OwnerID)*Integer.valueOf(System.Label.Target_TotalPropertyVisitsperMonth))) >0 ? (metric.TargetValue - (oldMgrUserCountMap.get(goal.OwnerID)*Integer.valueOf(System.Label.Target_TotalPropertyVisitsperMonth))) : 1;
                        }
                        if(metric.Name == System.Label.Metric_Name_AveragePropertyVisitsperDay){
                            metric.TargetValue = (metric.TargetValue - (oldMgrUserCountMap.get(goal.OwnerID)*Integer.valueOf(System.Label.Target_AveragePropertyVisitsperDay))) > 0 ? (metric.TargetValue - (oldMgrUserCountMap.get(goal.OwnerID)*Integer.valueOf(System.Label.Target_AveragePropertyVisitsperDay))) : 1;                       
                        }
                        if(metric.Name == System.Label.Metric_Name_Events){
                            metric.TargetValue = (metric.TargetValue - (oldMgrUserCountMap.get(goal.OwnerID)*Integer.valueOf(System.Label.Target_Events))) >0 ? (metric.TargetValue - (oldMgrUserCountMap.get(goal.OwnerID)*Integer.valueOf(System.Label.Target_Events))) : 1;                      
                        }
                        updateMetrics.add(metric);
                    }
                }
            }
        }
        
        if(!updateMetrics.isEmpty()){
            Database.update(updateMetrics,false);
        }
    }
    
    /**    
    *@Description: This method updates the User's NTID field and sets it to Federation ID
    * @Author: Amit Kumar,Accenture 
    * @Date: 27-March-2017   
    * @User Story:  US1049770
    * @Return: void
    */
    public static void updateNTID(List<User> userList){
        try{
            list<User> lstupdateduser = new list<User>();
            if(!userList.isEmpty()){
                for(User objuser : userList){
                    if(objuser.FederationIdentifier!=null){
                        if((objuser.FederationIdentifier).length() <= integer.valueof(Variable_Setting__c.getInstance('NTIDFieldLimit') != null ? Variable_Setting__c.getInstance('NTIDFieldLimit').Value__c : '20')){
                            objuser.NTLogin__c= objuser.FederationIdentifier;
                        }else{
                            objuser.NTLogin__c= (objuser.FederationIdentifier).substring(0,integer.valueof(Variable_Setting__c.getInstance('NTIDFieldLimit') != null ? Variable_Setting__c.getInstance('NTIDFieldLimit').Value__c : '20'));
                        }     
                    }
                } 
           }
        }catch(Exception e){
            
        }
    }
     
    /**************************    
    * @Description: This method is for inserting Coaching Sharing record for person coach when user is reactivated.                 
    * @Author: Amit Kumar Pradhan, Accenture    
    * @Date: 02-May-2017   
    * @User Story: US1086728
    * @Param: Map<Id,User>, List<User>
    * @Return: None    
    ***************************/
    public static void insertCoachingSharingForReactivedUser(Map<Id,User> oldUserMap, List<User> newUserList){
        //Calling createCoachingSharingForReactivedUser method of UserTriggerOperation class for creating coaching sharing record
        UserTriggerOperation.createCoachingSharingForReactivedUser(oldUserMap,newUserList); 
    }
    
    /**    
    *@Description: Resolving Mixed DML issue when both Manager and Profile are changed and there is an existing feedbackrequest record. Commenting methods ManageChangeFeedbackRequest and ManageChangeFeedbackRequestforSDM. Written new method shareFeedbackRequestWithNewMgr. Logic is written in UserTriggerOperation
    * @Author: Animesh Datta, Accenture    
    * @Date: 03-May-2017
    * @User Story: #US1027533
    * @Return: None    
    */  
    public static void shareFeedbackRequestWithNewMgr(List<User> newUserList, Map<Id,User>oldUserMap) {//calling this method from UserTrigger
        UserTriggerOperation.shareFeedbackRequestWithNewMgr(newUserList, oldUserMap);//pass trigger.new and trigger.oldMap as parameters
    }
    /**
    * @Description: US1107195: MCAT - Auto deactivate User (This Method will call a future method to suspend the user fron MCAT.)
    * @Author: Amit Kumar
    * @Date: 04-Sep-2017
    * @Param: List<User> newUserList, Map<Id,User>oldUserMap 
    * @Return: void.
    */ 
    public static void suspendUserFromEmptoris(List<User> newUserList, Map<Id,User>oldUserMap) {//calling this method from UserTrigger
        string struserid;
        if(!newUserList.Isempty() && newUserList.size() ==1){ //Bulk User deactivation is not in scope of US and only single user get deactivated at a time.
        	for(User objuser:newUserList){
        		if(!objuser.Isactive && (oldUserMap.get(objuser.id)).IsActive && LABEL.MCAT_USER_PROFILE.contains((oldUserMap.get(objuser.id)).Profile_Name_Text__c)){
        			struserid = objuser.id;
        		}	
        	}
        }
        
        if(!String.isBlank(struserid) ){  
        	UserTriggerOperation.suspendusersfromMCAT(struserid);
        }
    }
}