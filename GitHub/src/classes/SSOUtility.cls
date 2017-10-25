/********************************************** 
* @Class Name : SSOUtility 
* @Description : Utility class SSO login for universal web to case
* @Author : Amit Kumar Pradhan, Accenture
* @User Story : US1176660(SSO Access for Universal Web to Case Form)
**********************************************/ 
public class SSOUtility
{   
    //Constant variable 
    private static final String DOT = '.';
    private static final String POST = 'POST';
    private static final String BLANK_STR = '';
    private static final String UTF = 'UTF-8';
    private static final String CLINT_ID = 'clientId';
    private static final String CLINT_SECRET = 'clientSecret';
    private static String REDIRECT = 'redirect_uri';
    private static final String END_POINT = 'endPoint';
    private static final String CODE_EQUAL = 'code=';
    private static final String GRANT_TYPE_EQUAL = '&grant_type=';
    private static final String CLINT_ID_EQUAL = '&client_id=';
    private static final String CLINT_SECRET_EQUAL = '&client_secret=';
    private static final String REDIRECT_URI_EQUAL = '&redirect_uri=';
    private static final String AUTH_CODE_STR = 'authorization_code';
    private static final String CONTENT_TYPE_STR = 'Content-Type';
    private static final String HEADER = 'application/x-www-form-urlencoded';
    private static final String REDIRECT_XH= 'redirect_uri_XH';

    
    public static String clientId = BLANK_STR;
    public static String clientSecret = BLANK_STR;
    public static String redirect_uri = BLANK_STR ;
    public static String endPointURL = BLANK_STR;
    
    /******************************
    * @Description: This method is to set constant variable.
    * @Param: String
    * @Return: void
    * @Date: 05-Sept-2017 
    * @Author: Amit Kumar Pradhan, Accenture
    * @US1176660(SSO Access for Universal Web to Case Form)
    *******************************/
    public static void setVariables(){ 
        Map<String, String> mapOfParamNameAndValue = new Map<String , String>();    
        for(SSO_Setting__c objectCS : SSO_Setting__c.getall().values()){
            if(objectCS.Param_Name__c != null && objectCS.Param_Value__c != null){
                mapOfParamNameAndValue.put(objectCS.Param_Name__c,objectCS.Param_Value__c);                
            }
        }
        clientId = mapOfParamNameAndValue.get(CLINT_ID);
        clientSecret = mapOfParamNameAndValue.get(CLINT_SECRET);
        redirect_uri = mapOfParamNameAndValue.get(REDIRECT);
        endPointURL = mapOfParamNameAndValue.get(END_POINT);
    }
    
    /******************************
    * @Description: This method is to get token from auth code.
    * @Param: String
    * @Return: String
    * @Date: 05-Sept-2017 
    * @Author: Amit Kumar Pradhan, Accenture
    * @US1176660(SSO Access for Universal Web to Case Form)
    *******************************/
    public static String getToken(String code){
        setVariables();
        String returnToken = BLANK_STR;      
        try{
            if(code != null || code != BLANK_STR)
            {    
                //api call and get auth token
                HttpRequest req = new HttpRequest();
                req.setMethod(POST);
                req.setHeader(CONTENT_TYPE_STR,HEADER);             
                String bodyStr = CODE_EQUAL+EncodingUtil.urlEncode(code,UTF)+GRANT_TYPE_EQUAL+EncodingUtil.urlEncode(AUTH_CODE_STR,UTF)+CLINT_ID_EQUAL+EncodingUtil.urlEncode(clientId,UTF)+CLINT_SECRET_EQUAL+EncodingUtil.urlEncode(clientSecret,UTF);
                bodyStr += REDIRECT_URI_EQUAL+redirect_uri;                           
                req.setBody(bodyStr);               
                req.setEndpoint(endPointURL);
                Http http = new Http();
                HTTPResponse res = http.send(req);
                returnToken = res.getBody();                         
            }
        }catch(Exception e){
            System.debug('Exception: '+e.getMessage()); 
        }
        return returnToken;
    }
    /******************************
    * @Description: This method is to get token from auth code.
    * @Param: String
    * @Return: String
    * @Date: 21-Oct-2017 
    * @Author: Kiran Kumar, Accenture
    * @US1197171(SSO Access for XH Form)
    *******************************/
    public static String getToken(String code, String redirect_xh){
        REDIRECT = String.isEmpty(redirect_xh) ? REDIRECT_XH:redirect_xh;
        setVariables();
        String returnToken = BLANK_STR;      
        try{
            if(code != null || code != BLANK_STR)
            {    
                //api call and get auth token
                HttpRequest req = new HttpRequest();
                req.setMethod(POST);
                req.setHeader(CONTENT_TYPE_STR,HEADER);             
                String bodyStr = CODE_EQUAL+EncodingUtil.urlEncode(code,UTF)+GRANT_TYPE_EQUAL+EncodingUtil.urlEncode(AUTH_CODE_STR,UTF)+CLINT_ID_EQUAL+EncodingUtil.urlEncode(clientId,UTF)+CLINT_SECRET_EQUAL+EncodingUtil.urlEncode(clientSecret,UTF);
                bodyStr += REDIRECT_URI_EQUAL+redirect_uri;                           
                req.setBody(bodyStr);               
                req.setEndpoint(endPointURL);
                Http http = new Http();
                HTTPResponse res = http.send(req);
                returnToken = res.getBody();                         
            }
        }catch(Exception e){
            System.debug('Exception: '+e.getMessage()); 
        }
        return returnToken;
    }
    
    /******************************
    * @Description: This method is for parsing the Token.
    * @Param: String
    * @Return: SSOToken
    * @Date: 05-Sept-2017 
    * @Author: Amit Kumar Pradhan, Accenture
    * @US1176660(SSO Access for Universal Web to Case Form)
    *******************************/
    public static SSOToken parseToken(String json) 
    {
        SSOToken accessToken = null;
        try{
            accessToken = (SSOToken) System.JSON.deserialize(json, SSOToken.class);
        }catch(Exception e){
            System.debug('Exception: '+e.getMessage());
        }
        return accessToken;
    }
    
    /******************************
    * @Description: This method is to decode the token value.
    * @Param: String
    * @Return: SSOUserToken
    * @Date: 05-Sept-2017 
    * @Author: Amit Kumar Pradhan, Accenture
    * @US1176660(SSO Access for Universal Web to Case Form)
    *******************************/
    public static SSOUserToken decodePayload(String tokenValue)
    {
        Integer result = tokenValue.indexOf(DOT);
        //String firstPart = tokenValue.substring(0,result);
        String middlePart = tokenValue.substring(result+1, tokenValue.length());
        result = middlePart.indexOf(DOT);
        middlePart = middlePart.substring(0,result);        
        //String endPart = tokenValue.substring(result+1, tokenValue.length());       
        Blob b = EncodingUtil.base64Decode(middlePart);
        String decodeToken = b.toString();        
        SSOUserToken returnToken = SSOUserToken.parse(decodeToken);
        return returnToken ;
    }
}