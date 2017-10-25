/************************************************************************************************************************************************************
Name: MDU_EmptorisUtility 
Description: This class is used as a utility class for Emptoris Integration User Services.
Author: Accenture
Date PRJ/DFCT/ENHC# Summary of Changes 
09-04-2017 US1107195    MCAT - Auto deactivate User (RSA and XC User, User records in MCAT to automatically be deactivated when it get deactivated in Salesforce)
09-04-2017 US1105085    MCAT - Auto Create User (A User an be automatically created in MCAT if the profile in Salesforce is a User that would need MCAT Access)
--------------- ------------------ ------------------------------

*************************************************************************************************************************************************************/
public with sharing class MDU_UserServices {
    
    private static final String EMPTY_STRING = '';
    private static String executionLog = '';
    private static boolean isEligibleForAppLogging = true;
    public String userNameForWebService = null;
    public String password = null;
    public String userServicesEndpoint= null ;
    private static DateTime startTime;
    
    /*
    //Endpoints for services
    
    public String searchUserServicesEndpoint= null ;
    public String groupServicesEndpoint= null ;
    
    //Roles and groups which are added to user
    public static final Set<String> rolesToAdd = new Set<String>{'Web Services Access', 'System Administrator'};
    public static final String SYSTEM_ADMIN_ROLE = 'System Administrator';
    public static final Set<String> groupsToAdd = new Set<String>{'MDU Account Executive','System Admin'};
    public static final String SYSTEM_ADMIN_GROUP = 'System Admin';
 	
 	//Stores all log objects to insert at the end
    private static List<Application_Log__c> logsForTransaction = new List<Application_Log__c>();
    
    //Strings used for replace and search operations
    public static final String RESPONSE_GROUP_TAG = 'group';
    public static final String RESPONSE_ROLE_TAG = 'role';
    public static final String RESPONSE_INTERNAL_ID = 'internalId';
    public static final String REPLACE_INTERNAL_ID = 'INTERNAL_ID';
    public static final String RESPONSE_NAME = 'name';
    
    public static final String APPLICATION_IS_ENABLED = 'IS_ENABLED';
    public static final String USER_REQUEST_APPLICATION_NAME = 'APPLICATION_NAME';
    public static final String GROUPS_TAG = 'GROUPS_TAG';
    public static final String GROUPS_TO_ADD = 'GROUPS_TO_ADD';
    public static final String APPLICATION_TAG = 'APPLICATION_TAG';
    
    //These tags must be removed from request in case there is no data in them.
    public static final Set<String> addressInvalidTags = new Set<String>{'<addressLine1></addressLine1>','<city></city>','<countryCode></countryCode>','<stateName></stateName>','<postalCode></postalCode>'};
    */
    
    /*
	* Name: MDU_UserServices 
	* Created by: Sagarika
	* Description: US1105085 : MCAT - Auto Create User - Constructor is used to get the data from MDU_EmptorisIntegrationCS__c and initialize fields
	*/        
    public MDU_UserServices()
    {
        Map<String, String> mapOfParamNameAndValue = new Map<String , String>();
        
        for(MDU_EmptorisIntegrationCS__c objectCS : MDU_EmptorisIntegrationCS__c.getall().values()){
            if(objectCS.Param_Name__c != null){
                if(objectCS.Param_Value__c != null){
                    mapOfParamNameAndValue.put(objectCS.Param_Name__c,objectCS.Param_Value__c);
                   
                }else{
                    mapOfParamNameAndValue.put(objectCS.Param_Name__c, EMPTY_STRING);
                }
            }
        }
        userNameForWebService = mapOfParamNameAndValue.get(MDU_Constants.USER_FOR_USER_SERVICES);
        password = mapOfParamNameAndValue.get(MDU_Constants.PWD_FOR_USER_SERVICES);
        userServicesEndpoint = mapOfParamNameAndValue.get(MDU_Constants.CREATE_INDIVIDUAL_ENDPOINT);
        //groupServicesEndpoint= mapOfParamNameAndValue.get(MDU_Constants.GROUP_SERVICES_ENDPOINT);
        //searchUserServicesEndpoint = mapOfParamNameAndValue.get(MDU_Constants.GETCONTRACTUSER_ENDPOINT);
    }

    /*
	* Name: userExistsInMcat 
	* Created by: Sagarika
	* Description: US1105085 : MCAT - Auto Create User - Check if the user already has a user created in MCAT
	* Parameter : user
    * @return: void 
	*/   
	/*  
    public boolean userExistsInMcat(User user){  
        
        boolean userExistsInMCAT = false;
        startTime = System.Now();
        String responseString = EMPTY_STRING;
        
        String soapMsg = MDU_EmptorisEnvelopeTemplate.CHECK_USER_IN_MCAT;
        List<String> params = null;
        params = new List<String>();
        params.add(userNameForWebService);
        params.add(password);
        params.add(user.FederationIdentifier);
        soapMsg = String.format(soapMsg, params); 
        
        HTTPResponse response = MDU_EmptorisUtility.requestMethod(soapMsg,searchUserServicesEndpoint); 
        Dom.Document responseBody = response.getBodyDocument();  
        Dom.XMLNode rootElement = responseBody.getRootElement();  
        String responseStatus = String.valueof(response.getStatusCode());
        
        if(response.getStatusCode() == MDU_Constants.SUCCESSSTATUSCODE){
            userExistsInMCAT = true;
            responseString = responseStatus;
        } 
        else
        {
            String  errorResponseData = EMPTY_STRING;
            responseString = MDU_EmptorisUtility.responseErrorLog(rootElement);  
        }     
        createLog(MDU_Constants.SEARCH_USER_PROCESS + startTime + MDU_Constants.USER_ID+ user.FederationIdentifier+MDU_Constants.NEXT_LINE_OPERATOR +MDU_Constants.USER_REQUEST_START +MDU_Constants.NEXT_LINE_OPERATOR + soapMsg +EMPTY_STRING +MDU_Constants.NEXT_LINE_OPERATOR +MDU_Constants.RESPONSE +responseString+ MDU_Constants.NEXT_LINE_OPERATOR + MDU_Constants.SEARCH_USER_REQUEST_COMPLETED,  isEligibleForAppLogging , startTime, System.now()); 
        return userExistsInMCAT;
    }  
	*/
	
    /*
	* Name: activateUserInMCAT 
	* Created by: Sagarika
	* Description: US1105085 : MCAT - Auto Create User - Activate MCAT internal users
	* Parameter : user
    * @return: void 
	*/      
	/*
     public void activateUserInMCAT(User user){      
       
        String responseString = EMPTY_STRING;
        startTime = System.Now();
        String header = MDU_EmptorisEnvelopeTemplate.HEADER_USER_SERVICES;
        List<String> params = null;
        params = new List<String>();
        params.add(userNameForWebService);
        params.add(password);
        params.add(MDU_EmptorisUtility.GenerateToken(userNameForWebService,MDU_EmptorisUtility.setTimeWithMilliSec()));
        params.add(MDU_EmptorisUtility.SetGMT());
        header = String.format(header, params); 
        
        String soapMsg = MDU_EmptorisEnvelopeTemplate.ACTIVATE_USER;
        params = new List<String>();
        params.add(header);
        params.add(user.FederationIdentifier);
        soapMsg = String.format(soapMsg, params); 
        
        HTTPResponse response = MDU_EmptorisUtility.requestMethod(soapMsg,userServicesEndpoint);  
        Dom.Document responseBody = response.getBodyDocument();  
        Dom.XMLNode rootElement = responseBody.getRootElement();  
        String responseStatus = String.valueof(response.getStatusCode());
        
        if(response.getStatusCode() == MDU_Constants.SUCCESSSTATUSCODE){
           responseString = responseStatus;
        } 
        else
        {
            String  errorResponseData = EMPTY_STRING;
            responseString = MDU_EmptorisUtility.responseErrorLog(rootElement);  
        }      
        createLog(MDU_Constants.ACTIVATE_USER_PROCESS + startTime + MDU_Constants.USER_ID+ user.FederationIdentifier+MDU_Constants.NEXT_LINE_OPERATOR +MDU_Constants.USER_REQUEST_START +MDU_Constants.NEXT_LINE_OPERATOR + soapMsg +EMPTY_STRING +MDU_Constants.NEXT_LINE_OPERATOR +MDU_Constants.RESPONSE +responseString+ MDU_Constants.NEXT_LINE_OPERATOR + MDU_Constants.ACTIVATE_USER_REQUEST_COMPLETED,  isEligibleForAppLogging , startTime, System.now()); 
    }
    */
    
    /*
	* Name: createUserInMCAT 
	* Created by: Sagarika
	* Description: US1105085 : MCAT - Auto Create User - Create MCAT internal users
	* Parameter : user
    * @return: void 
	*/    
	/*
     public void createUserInMCAT(User user){      
        
        String responseString = EMPTY_STRING;
        
        startTime = System.now();
        
        String requestContent = MDU_EmptorisEnvelopeTemplate.CREATE_USER_REQUEST_CONTENT;
        
        String applications = MDU_EmptorisEnvelopeTemplate.CREATE_USER_APPLICATIONS_TAG;
        applications =  applications.replace(APPLICATION_IS_ENABLED, MDU_Constants.TRUE_STRING);
        applications =  applications.replace(USER_REQUEST_APPLICATION_NAME,MDU_Constants.ECM);
        
        String groupTagForRequest = updateGroupsForUser(user);
        if(!String.isBlank(groupTagForRequest))
        {
	        applications =  applications.replace(GROUPS_TAG, groupTagForRequest);
        }
        else
        {
        	applications =  applications.replace(GROUPS_TAG, EMPTY_STRING);
        }
        requestContent = requestContent.replace(APPLICATION_TAG, applications);
        
        List<String> params = null;
        params = new List<String>();
        params.add(user.name);
        params.add(user.email);
        params.add(user.FirstName);
        params.add(user.LastName);
        params.add(user.FederationIdentifier);
        params.add(!String.isBlank(user.Street) ? user.Street : EMPTY_STRING);
        params.add(!String.isBlank(user.City) ? user.City : EMPTY_STRING);
        params.add(!String.isBlank(user.Country) ? user.Country : EMPTY_STRING);
        params.add(!String.isBlank(user.State) ? user.State : EMPTY_STRING);
        params.add(!String.isBlank(user.PostalCode) ? user.PostalCode : EMPTY_STRING); 
        params.add(!String.isBlank(user.Phone) ? user.Phone : EMPTY_STRING);      
        requestContent = String.format(requestContent, params); 
        requestContent = removeInvalidTagsFromRequest(requestContent);
        
        String bodyContent = MDU_EmptorisEnvelopeTemplate.BODY_USER_SERVICES;
        params = new List<String>();
        params.add(requestContent);   
        bodyContent = String.format(bodyContent, params); 
        
        String header = MDU_EmptorisEnvelopeTemplate.HEADER_USER_SERVICES;
        params = new List<String>();
        params.add(userNameForWebService);
        params.add(password);
        params.add(MDU_EmptorisUtility.GenerateToken(userNameForWebService,MDU_EmptorisUtility.setTimeWithMilliSec()));
        params.add(MDU_EmptorisUtility.SetGMT());
        header = String.format(header, params); 
        
        String requestString = header + bodyContent;
        
        params = new List<String>();
        params.add(requestString);
        
        String soapMsg = MDU_EmptorisEnvelopeTemplate.SOAP_ENV_USER_SERVICES;
        soapMsg = String.format(soapMsg, params);         
        HTTPResponse response = MDU_EmptorisUtility.requestMethod(soapMsg,userServicesEndpoint); 
        
        Dom.Document responseBody = response.getBodyDocument();  
        Dom.XMLNode rootElement = responseBody.getRootElement();  
        String responseStatus = String.valueof(response.getStatusCode());
        
        if(response.getStatusCode() == MDU_Constants.SUCCESSSTATUSCODE){
           responseString = responseStatus;
           addRolesToUser(user);
        } 
        else
        {
            String  errorResponseData = EMPTY_STRING;
            responseString = MDU_EmptorisUtility.responseErrorLog(rootElement);  
        }      
        createLog(MDU_Constants.CREATE_USER_PROCESS + startTime + MDU_Constants.USER_ID+ user.FederationIdentifier+MDU_Constants.NEXT_LINE_OPERATOR +MDU_Constants.USER_REQUEST_START +MDU_Constants.NEXT_LINE_OPERATOR + soapMsg +EMPTY_STRING +MDU_Constants.NEXT_LINE_OPERATOR +MDU_Constants.RESPONSE +responseString+ MDU_Constants.NEXT_LINE_OPERATOR + MDU_Constants.CREATE_USER_REQUEST_COMPLETED,  isEligibleForAppLogging , startTime, System.Now()); 
    }
    */
    
    /*
	* Name: addRolesToUser 
	* Created by: Sagarika
	* Description: US1105085 : MCAT - Auto Create User - Add roles to MCAT internal users
	* Parameter : user
    * @return: void 
	*/ 
	/*
    public void addRolesToUser(User user){      
        
        String responseString = EMPTY_STRING;
        
        Map<String,String> roles = getRoles();
        
        startTime = System.now();
        
        if(!roles.isEmpty())
        {
            String roleTag = MDU_EmptorisEnvelopeTemplate.ROLE_TAG;
            String roleTagForRequest = EMPTY_STRING;
            String soapMsg = MDU_EmptorisEnvelopeTemplate.SOAP_ENV_USER_SERVICES;
            String header = MDU_EmptorisEnvelopeTemplate.HEADER_USER_SERVICES;         
            
            String requestContent = MDU_EmptorisEnvelopeTemplate.ADD_ROLES_REQUEST;
            List<String> params = new List<String>();
            params.add(user.FederationIdentifier);
            for(String role : roles.keyset())
            {
            	if(rolesToAdd.contains(role))
            	{
            		if(SYSTEM_ADMIN_ROLE.equalsIgnoreCase(role))
	                {
	                    if(salesforceSystemAdmins.contains(user.Profile_Name_Text__c))
	                    {
	                        roleTagForRequest = roleTagForRequest + roleTag.replace(MDU_Constants.PLACEHOLDER_0, roles.get(role)); 
																
	                    }
	                }
	                else
	                {
	                    roleTagForRequest = roleTagForRequest + roleTag.replace(MDU_Constants.PLACEHOLDER_0, roles.get(role)); 
															   
	                }
            	}
            }
            params.add(roleTagForRequest);
            requestContent = String.format(requestContent, params); 
            
            params = new List<String>();
            params.add(userNameForWebService);
            params.add(password);
            params.add(MDU_EmptorisUtility.GenerateToken(userNameForWebService,MDU_EmptorisUtility.setTimeWithMilliSec()));
            params.add(MDU_EmptorisUtility.SetGMT());
            
            header = String.format(header, params); 
            
            String body = MDU_EmptorisEnvelopeTemplate.BODY_USER_SERVICES;
            params = new List<String>();
            params.add(requestContent);
            body = String.format(body, params);         
            
            params = new List<String>();
            params.add(header + body);
            
            soapMsg = String.format(soapMsg, params);         
            HTTPResponse response = MDU_EmptorisUtility.requestMethod(soapMsg,userServicesEndpoint); 
            
            Dom.Document responseBody = response.getBodyDocument();  
            Dom.XMLNode rootElement = responseBody.getRootElement();  
            String responseStatus = String.valueof(response.getStatusCode());
            
            if(response.getStatusCode() == MDU_Constants.SUCCESSSTATUSCODE){
               responseString = responseStatus;
            } 
            else
            {
                String  errorResponseData = EMPTY_STRING;
                responseString = MDU_EmptorisUtility.responseErrorLog(rootElement);  
            } 
            createLog(MDU_Constants.ADD_ROLES_PROCESS + startTime +MDU_Constants.NEXT_LINE_OPERATOR +MDU_Constants.USER_REQUEST_START +MDU_Constants.NEXT_LINE_OPERATOR + soapMsg +EMPTY_STRING +MDU_Constants.NEXT_LINE_OPERATOR +MDU_Constants.RESPONSE +responseString+ MDU_Constants.NEXT_LINE_OPERATOR + MDU_Constants.ADD_ROLES_REQUEST_COMPLETED,  isEligibleForAppLogging , startTime, System.Now());
        }     
    }
    */
    
	/*
	* Name: suspendUserInMCAT 
	* Description: US1107195: MCAT - Auto deactivate User (RSA and XC User, User records in MCAT to automatically be deactivated when it get deactivated in Salesforce)
	* Modified by: Amit Kumar
	* Modification History: 
	*/
    public void suspendUserInMCAT(User user){ 
        //Define the Variables
        startTime = System.Now();    
        String requestContent = MDU_EmptorisEnvelopeTemplate.SUSPEND_USER_REQUEST_CONTENT;
        String bodyContent = MDU_EmptorisEnvelopeTemplate.BODY_USER_SERVICES;
        String header = MDU_EmptorisEnvelopeTemplate.HEADER_USER_SERVICES;
        String soapMsg = MDU_EmptorisEnvelopeTemplate.SOAP_ENV_USER_SERVICES;
        String resstatus;
        List<String> params = null;
        //Set the Request Body
        params = new List<String>();
        params.add(user.FederationIdentifier);
        requestContent = String.format(requestContent, params); 
        
        params = new List<String>();
        params.add(requestContent);   
               
        bodyContent = String.format(bodyContent, params); 
        //Set the Header
        params = new List<String>();
        params.add(userNameForWebService);
        params.add(password);
        params.add(MDU_EmptorisUtility.GenerateToken(userNameForWebService,MDU_EmptorisUtility.SetNow()));
        params.add(MDU_EmptorisUtility.SetGMT());
        
        header = String.format(header, params); 
        
        String requestString = header + bodyContent;
        
        params = new List<String>();
        params.add(requestString);
        //Format the SOAP Request
        soapMsg = String.format(soapMsg, params);         
             
        //Get the Response   
        HTTPResponse res = MDU_EmptorisUtility.requestMethod(soapMsg,userServicesEndpoint);
        Dom.Document docActive = res.getBodyDocument();
        Dom.XMLNode searchAciveNodeDoc = docActive.getRootElement();
        if(res.getStatusCode() == MDU_Constants.SUCCESSSTATUSCODE ){                   
            resstatus = string.valueof(res.getStatusCode());
            executionLog = resstatus;
        } else {
            String  errorResponseData = EMPTY_STRING;
            executionLog = MDU_EmptorisUtility.responseErrorLog(searchAciveNodeDoc);  
           
        }
          Mdu_ApplicationLogger.createLog(MDU_Constants.SUSPEND_USER_PROCESS + startTime + MDU_Constants.SUSPEND_USER_ID+ user.FederationIdentifier+MDU_Constants.NEXT_LINE_OPERATOR +MDU_Constants.SUSPEND_USER_REQUEST_START +MDU_Constants.NEXT_LINE_OPERATOR + soapMsg +EMPTY_STRING +MDU_Constants.NEXT_LINE_OPERATOR +MDU_Constants.SUSPEND_USER_RESPONSE +executionLog+ MDU_Constants.NEXT_LINE_OPERATOR + MDU_Constants.SUSPEND_USER_REQUEST_COMPLETED,  isEligibleForAppLogging , startTime, System.Now()); 
    }

    /*
	* Name: getGroups 
	* Created by: Sagarika
	* Description: US1105085 : MCAT - Auto Create User - Get all available groups from MCAT
	* Parameter : none
    * @return: void 
	*/  
	/*     
    public Map<String, String> getGroups(){  
        
        String responseString = EMPTY_STRING;
        Map<String, String> groups = new Map<String, String>();
        startTime = System.now();
        try{   
	        String header = MDU_EmptorisEnvelopeTemplate.HEADER_USER_SERVICES;
	        String soapMsg = MDU_EmptorisEnvelopeTemplate.GET_GROUPS_REQUEST;
	        
	        List<String> params = null;
	        
	        params = new List<String>();
	        params.add(userNameForWebService);
	        params.add(password);
	        params.add(MDU_EmptorisUtility.GenerateToken(userNameForWebService,MDU_EmptorisUtility.setTimeWithMilliSec()));
	        params.add(MDU_EmptorisUtility.SetGMT());
	        
	        header = String.format(header, params); 
	        
	        params = new List<String>();
	        params.add(header);
	        
	        soapMsg = String.format(soapMsg, params); 
	        
	        HTTPResponse response = MDU_EmptorisUtility.requestMethod(soapMsg,groupServicesEndpoint); 
	        
	        Dom.Document responseBody = response.getBodyDocument();  
	        Dom.XMLNode rootElement = responseBody.getRootElement();  
	        String responseStatus = String.valueof(response.getStatusCode());
	        
	        if(response.getStatusCode() == MDU_Constants.SUCCESSSTATUSCODE){
	           responseString = responseStatus;
	           Dom.Document doc = response.getBodyDocument();       
	        	Dom.XMLNode groupsResponse = doc.getRootElement();        
	        	if(response.getStatusCode() == MDU_Constants.SUCCESSSTATUSCODE){
	           		Dom.XmlNode node = groupsResponse.getChildElement(MDU_Constants.BODY_NODE, MDU_Constants.NODE_FUNCTION); 
	            	for (Dom.XMLNode child: node.getChildren()) {          
	               		recursivelyGetInfo(child, groups, RESPONSE_GROUP_TAG);
	            	}   
	        	}     
	        } 
	        else
	        {
	            String  errorResponseData = EMPTY_STRING;
	            responseString = MDU_EmptorisUtility.responseErrorLog(rootElement);  
	        }     
	        createLog(MDU_Constants.GET_GROUPS_PROCESS + startTime +MDU_Constants.NEXT_LINE_OPERATOR +MDU_Constants.USER_REQUEST_START +MDU_Constants.NEXT_LINE_OPERATOR + soapMsg +EMPTY_STRING +MDU_Constants.NEXT_LINE_OPERATOR +MDU_Constants.RESPONSE +responseString+ MDU_Constants.NEXT_LINE_OPERATOR + MDU_Constants.GET_GROUPS_REQUEST_COMPLETED,  isEligibleForAppLogging , startTime, System.Now()); 
        }
        catch(Exception e)
        {
        	createLog(MDU_Constants.GET_ROLES_PROCESS + startTime +MDU_Constants.NEXT_LINE_OPERATOR +MDU_Constants.GROUPS_REQUEST_ERROR,  isEligibleForAppLogging , startTime, System.now()); 
        	groups = new Map<String, String>();
        } 
        return groups;
    }  
    */

    /*
	* Name: getGroups 
	* Created by: Sagarika
	* Description: US1105085 : MCAT - Auto Create User - Create a formatted string with all eligible groups for users
	* Parameter : User
    * @return: String 
	*/       
	/*
    public String updateGroupsForUser(User user)
    {
    	String updatedGroupsTag = EMPTY_STRING;
    	try{
    		Map<String,String> groups = getGroups();
    		String multipleGroupsTag = EMPTY_STRING;
    		String singleGroupTag = MDU_EmptorisEnvelopeTemplate.CREATE_USER_APPLICATION_SINGLE_GROUP_TAG;
	        
	        for(String groupName : groups.keySet())
	        {
	        	if(groupsToAdd.contains(groupName))
	        	{
	        		if(SYSTEM_ADMIN_GROUP.equalsIgnoreCase(groupName))
	        		{
	        			if(Label.SystemAdminProfileName.equalsIgnoreCase(user.Profile_Name_Text__c))
	        			{
	        				multipleGroupsTag = multipleGroupsTag + singleGroupTag.replace(REPLACE_INTERNAL_ID,groups.get(groupName));
	        			}
	        		}
	        		else
	        		{
	        			multipleGroupsTag = multipleGroupsTag + singleGroupTag.replace(REPLACE_INTERNAL_ID,groups.get(groupName));
	        		}
	        	}
	        }
	        if(!String.isBlank(multipleGroupsTag))
	        {
	        	updatedGroupsTag = MDU_EmptorisEnvelopeTemplate.CREATE_USER_APPLICATION_GROUPS_TAG.replace(GROUPS_TO_ADD, multipleGroupsTag);
	        }
    	}
    	catch(Exception e)
    	{
    		updatedGroupsTag = MDU_EmptorisEnvelopeTemplate.CREATE_USER_APPLICATION_GROUPS_TAG.replace(GROUPS_TO_ADD, EMPTY_STRING);
    	}
    	return updatedGroupsTag;
    }
    */

    /*
	* Name: getRoles 
	* Created by: Sagarika
	* Description: US1105085 : MCAT - Auto Create User - Get all available roles from MCAT
	* Parameter : none
    * @return: void 
	*/   
	/*
    public Map<String, String> getRoles(){  
        
        Map<String, String> roles = new Map<String, String>();
        String responseString = EMPTY_STRING;
        startTime = System.now(); 
        try{
	        String header = MDU_EmptorisEnvelopeTemplate.HEADER_USER_SERVICES;
	        String soapMsg = MDU_EmptorisEnvelopeTemplate.GET_ROLES_REQUEST;
	        
	        List<String> params = null;
	        
	        params = new List<String>();
	        params.add(userNameForWebService);
	        params.add(password);
	        params.add(MDU_EmptorisUtility.GenerateToken(userNameForWebService,MDU_EmptorisUtility.setTimeWithMilliSec()));
	        params.add(MDU_EmptorisUtility.SetGMT());
	        
	        header = String.format(header, params); 
	        
	        params = new List<String>();
	        params.add(header);
	        
	        soapMsg = String.format(soapMsg, params); 
	        system.debug('soapmsg'+soapMsg);
	        system.debug(groupServicesEndpoint+'Endpoint for roles');
	        
	        HTTPResponse response = MDU_EmptorisUtility.requestMethod(soapMsg,groupServicesEndpoint); 
	        Dom.Document responseBody = response.getBodyDocument();  
	        Dom.XMLNode rootElement = responseBody.getRootElement();  
	        String responseStatus = String.valueof(response.getStatusCode());
	        system.debug(responseStatus+' Response from getroles');
	        
	        if(response.getStatusCode() == MDU_Constants.SUCCESSSTATUSCODE){
	           responseString = responseStatus;
	           Dom.Document doc = response.getBodyDocument();       
	        	Dom.XMLNode groupsResponse = doc.getRootElement();        
	        	if(response.getStatusCode() == MDU_Constants.SUCCESSSTATUSCODE){
	           		Dom.XmlNode node = groupsResponse.getChildElement(MDU_Constants.BODY_NODE, MDU_Constants.NODE_FUNCTION); 
	            	for (Dom.XMLNode child: node.getChildren()) {          
	               		recursivelyGetInfo(child, roles, RESPONSE_ROLE_TAG);
	            	}   
	        	}     
	        } 
	        else
	        {
	            String  errorResponseData = EMPTY_STRING;
	            responseString = MDU_EmptorisUtility.responseErrorLog(rootElement);  
	        } 
	        createLog(MDU_Constants.GET_ROLES_PROCESS + startTime +MDU_Constants.NEXT_LINE_OPERATOR +MDU_Constants.USER_REQUEST_START +MDU_Constants.NEXT_LINE_OPERATOR + soapMsg +EMPTY_STRING +MDU_Constants.NEXT_LINE_OPERATOR +MDU_Constants.RESPONSE +responseString+ MDU_Constants.NEXT_LINE_OPERATOR + MDU_Constants.GET_ROLES_REQUEST_COMPLETED,  isEligibleForAppLogging , startTime, System.Now()); 
        }
        catch(Exception e)
        {
       		createLog(MDU_Constants.GET_ROLES_PROCESS + startTime +MDU_Constants.NEXT_LINE_OPERATOR +MDU_Constants.ROLES_REQUEST_ERROR,  isEligibleForAppLogging , startTime, System.now()); 
       		roles = new Map<String, String>();
        }   
        return roles;
    }  
    */
    

    /*
	* Name: recursivelyGetInfo 
	* Created by: Sagarika
	* Description: US1105085 : MCAT - Auto Create User - Use this method to iterate and get names and internal ids from response
	* Parameter : node, mapToStore, nodeName
    * @return: void 
	*/   
	/*  
    public static Map<String, String> recursivelyGetInfo(Dom.XMLNode node, Map<String, String> mapToStore, String nodeName){        
       String name = null;
       String internalId = null;
       if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {                       
            if(!nodeName.equalsIgnoreCase(node.getName())){                  
                for(Dom.XMLNode childField : node.getChildElements()){                                 
                   recursivelyGetInfo(childField, mapToStore, nodeName);                     
                }         
            }else{  
                for(Dom.XMLNode child : node.getChildElements()){  
                    if(RESPONSE_NAME.equalsIgnoreCase(child.getName())) 
                    {
                        name = child.getText();
                    }  
                    else if(RESPONSE_INTERNAL_ID.equalsIgnoreCase(child.getName())) 
                    {
                        internalId = child.getText();
                    } 
                }  
                mapToStore.put(name, internalId);
            }
        }
        return mapToStore;
    }    
    */
    
    /*
	* Name: suspendUserInMCAT 
	* Created by: Sagarika
	* Description: US1105085 : MCAT - Auto Create User - remove invalid tags from request
	* Parameter : request string
    * @return: Formatted request string 
	*/
	/*
    public String removeInvalidTagsFromRequest(String request){                
        String formattedRequest = request;
        for(String invalidTag : addressInvalidTags)
        {
        	formattedRequest = formattedRequest.remove(invalidTag);
        }
        return formattedRequest;
    }
    */
       
    
    /*
	* Name: suspendUserInMCAT 
	* Created by: Sagarika
	* Description: US1105085 : MCAT - Auto Create User - Create application log objects to insert
	* Parameter : finalLogMessage  , executionLog , isApplicationFlagEnable, startTime, endTime
    * @return: void 
	*/
	/*
    public static void createLog(String finalLogMessage , boolean isApplicationFlagEnable 
                                 , DateTime startTime , DateTime endTime){                
        if(isApplicationFlagEnable){
            Application_Log__c objApplicationLog = new Application_Log__c();
            objApplicationLog.Start_Time__c = startTime;
            objApplicationLog.End_Time__c = endTime;
           
            Integer len= Application_Log__c.Log_Message__c.getDescribe().getLength();
            if(finalLogMessage.length()>len){
                finalLogMessage =  finalLogMessage.Substring(0, len);
            }
            
            objApplicationLog.Log_Message__c = finalLogMessage;
            objApplicationLog.Elapsed_time__c = String.valueOf(endTime.getTime() - startTime.getTime());
            logsForTransaction.add(objApplicationLog);
        }                     
    }
    */
    
    /*
	* Name: addLogs 
	* Created by: Sagarika
	* Description: US1105085 : MCAT - Auto Create User - Add all application log objects
	* Parameter : none
    * @return: void 
	*/ 
	/*
    public void addLogs(){                
        if(isEligibleForAppLogging){
            if(!logsForTransaction.isEmpty())
            {
            	Database.insert(logsForTransaction,false);
            }
        }                     
    }
    */

    
    
}