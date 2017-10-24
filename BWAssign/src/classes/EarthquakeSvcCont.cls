/*
* This apex class is a controller for the "earthquake" visualforce page, created for a Bluewolf coding assignment.
* The class provides methods for using a text input from the visualforce page to make calls to the google maps API
* and the Geonames recent earthquakes API to plot a map of earthquakes in the vicinity of the supplied location.
*/
public class EarthquakeSvcCont {

    /** Declaration of variables that will be included in the viewstate and displayed on the visualforce page **/
    
    public string               selectedCity    {get;set;}   //string to  location input
    public List<SelectOption>   cities          {get;set;}   //picklist options for cities
    public List<City__c> 		GetCityList		{get;set;}	 //To get all the records in City Object
    public List<City__c> 		currentCity		{get;set;}	 //To get Current City based on 
    public List<String> 		citiesStr		{get;set;}	 //To store the cities in String for Autocomplete
	public Decimal 				latitude 		{get;set;}   //To save latitude information
	public Decimal 				longitude 		{get;set;}   //To save longitude information
			

    /*
    * Constructor
    */
    public EarthquakeSvcCont() 
    {
        //initialize defaults
        cities          = new List<SelectOption>();		//To store all the cities stored in the City Object on UI
        GetCityList		= new List<City__c>();			//To store all the cities stored in the City Object		
        citiesStr		= new List<String>();			//Hold the list of cities
        latitude		=	0.0;						//Set Default
        longitude		=	0.0;						//Set Default

        //Get the list of cities dyamically from the custom object rather than hardcoding the values
        GetCityList  = [select c.City_Name__c, c.Geolocation__latitude__s, c.Geolocation__longitude__s from City__c c where c.City_Name__c<>NULL];
        // Best practice to check empty list
        if(!GetCityList.isEmpty()){							
        	for (City__c CityElement : GetCityList) {
    			// Iterate through the list and add the City Names to the options that will be displayed on the visualforce page.    			
    			citiesStr.add(CityElement.City_Name__c);
				}		
        }
        
    }   
    /*
    * Method that is bound to the action attribute of the search button on the visualforce page.    
    */
    public void search(){
    	/*search method
    	 Check the current City Chosen by the user on UI in the variable selectedCity
       	 Fetch the latitude and longitude of this selected City from the Custom Object Record
       	 Best Practice to limit the query to  a single record */    		
		currentCity = [select Geolocation__latitude__s, Geolocation__longitude__s  from City__c where City_Name__c =: selectedCity LIMIT 1];
		system.debug(currentCity);
		if(!currentCity.isEmpty()){
			latitude 	=	currentCity[0].Geolocation__latitude__s; 
       		longitude 	= 	currentCity[0].Geolocation__longitude__s;
			}
       	else if(currentCity.isEmpty()){
       		// The City is not in the database, need to invoke the Google GeoCodingAPI for User's Input
       		getCityGeocode(selectedCity);       		
       	}   		
    }

    /*
    Get the City Geolocation by publishing a Callout to Google Maps Geocoding API
    Webservice Type : REST 
	Url : maps.googleapis.com/maps/api/geocode/json?
	Parameters : Selected City 
    */ 
     public void getCityGeocode(String geoCity){
  		// build callout
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('http://maps.googleapis.com/maps/api/geocode/json?address='+geoCity+'&sensor=false');
        req.setMethod('GET');
        req.setTimeout(60000); 
        try{
            // callout
            HttpResponse res = h.send(req);
            // parse coordinates from response
            JSONParser parser = JSON.createParser(res.getBody());
            double lat = null;
            double lon = null;
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
                    (parser.getText() == 'location')){
                       parser.nextToken(); // object start
                       while (parser.nextToken() != JSONToken.END_OBJECT){
                           String txt = parser.getText();
                           //system.debug('getCityGeocode_Response:'+txt);
                           parser.nextToken();
                           if (txt == 'lat')
                               lat = parser.getDoubleValue();
                           else if (txt == 'lng')
                               lon = parser.getDoubleValue();
                       }
                }
            }
            /* 1. Persist the city and geolocation data to the sObject "City"
               2. Check if the retun value from Google is a valid city before Inserting
            */ 
            if (lat != null){
            	latitude = lat;
                longitude = lon;
            	City__c newCity = new City__c();
            	newCity.Geolocation__Latitude__s = lat;
                newCity.Geolocation__Longitude__s = lon;
                newCity.City_Name__c = geoCity;
                newCity.Name = geoCity;
                insert newCity;
            }
		// Perform error handling
        } catch (System.CalloutException e) {
				System.debug(LoggingLevel.INFO, 'ERROR:' + e.getMessage());
            	//return null;        		
        		}
  	}
  	
    /*
    Use Javascript Remoting to fetch the JSON request from GeoNames and pass it onto the Visualforce page to display on Map
    Webservice Type : REST 
	Url : api.geonames.org/earthquakesJSON?
	Parameters : north,south,east,west : coordinates of bounding box 
    */

	@RemoteAction
    public static String getResponse(Double lat, Double lng) {
        String north = String.valueOf(lat + 2);
        String south = String.valueOf(lat - 2);
        String east = String.valueOf(lng + 2);
        String west = String.valueOf(lng - 2);
        // Callout
        HttpRequest GeoRequest = new HttpRequest();
        GeoRequest.setMethod('GET');
        GeoRequest.setEndpoint('http://api.geonames.org/earthquakesJSON?north='+north+'&south='+south+'&east='+east+'&west='+west+'&username=Sid8');
        try {
            Http http = new Http(); 
            HTTPResponse GeoResponse = http.send(GeoRequest);
            //System.debug(GeoResponse.getBody());
            	return GeoResponse.getBody();                   
        } catch(System.CalloutException e) {
            System.debug(LoggingLevel.INFO, 'ERROR:' + e.getMessage());
            return null;
        }
    }

}