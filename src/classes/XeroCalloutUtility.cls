/**
* @author       Ben Edwards (ben@benedwards.co.nz)
* @description  Handles the physical callout to the Xero API
**/
public with sharing class XeroCalloutUtility {

	/**
	* 	@author Ben Edwards (ben@benedwards.co.nz)
	*	@description Query the custom object for the Xero Account Settings
	* 	@return Returns a single Xero_Setting__c record
	**/
	public static Xero_Settings__c xeroSettings {

		get {

			if (xeroSettings == null) {
				
				xeroSettings = Xero_Settings__c.getInstance();
			}
			return xeroSettings;
		}
		set;
	}
	
	
	/**
	* 	@author Ben Edwards (ben@benedwards.co.nz)
	*	@description Execute the physical callout and return the response
	* 	@return Returns the HttpResponse from the Xero API
	**/
	public static HttpResponse executeCallout (String method, String resourceName, String requestBody) {

		// Instantiate a new request
		HttpRequest request = new HttpRequest();

		// Set request parameters
		request.setMethod(method);
		System.debug('xeroSettings.Endpoint__c'+xeroSettings.Endpoint__c);
		request.setEndpoint(xeroSettings.Endpoint__c + resourceName);

		// Accept a JSON response from the call
		request.setHeader('Accept', 'application/json');

		// If the callout includes a body (POST and PUT requests)
		if (String.isNotBlank(requestBody)) {

			// Set the body to the callout
			request.setBody(requestBody);

			// Set the content to XML
			request.setHeader('Content-Type', 'text/xml');
		}
		System.debug('xeroSettings.Endpoint__c'+xeroSettings.Consumer_Key__c);
		// Sign the request based on OAuth 1.0a
		request = XeroOAuthUtility.signRequest(request, xeroSettings.Consumer_Key__c);

		// Execute callout and return
		return new Http().send(request);
	}

	public static HttpResponse executeInvoiceCallout (String method, String resourceName, String requestBody, String consumerKey) {
   
	    HttpRequest request = new HttpRequest();

	    request.setMethod(method);
	   
	    request.setEndpoint('https://api.xero.com/api.xro/2.0/'+resourceName);

	    // Accept a JSON response from the call
	    request.setHeader('Accept', 'application/json');

	    // If the callout includes a body (POST and PUT requests)
	    if (String.isNotBlank(requestBody)) {
	      // Set the body to the callout
	      request.setBody(requestBody);
	    System.debug(request.getBody());
	      // Set the content to XML
	      request.setHeader('Content-Type', 'text/xml');
	    }

	    // Sign the request based on OAuth 1.0a
	    request = XeroOAuthUtility.signRequest(request, consumerKey);
	    System.debug('<<>> request<<>>'+request);
	    // Execute callout and return
	    return new Http().send(request);
      
  }


	/**
	* 	@author Ben Edwards (ben@benedwards.co.nz)
	*	@description Execute the physical callout and return the response
	* 	@return Returns the HttpResponse from the Xero API
	**/
	public static List<HttpResponse> executeOrgCallout (String method,
														String resourceName,
														String requestBody) {

		List<HttpResponse> responseList = new List<HttpResponse>();
		HttpResponse response = new HttpResponse();

		List<Xero_Setting__mdt>  xeroOrgSettings = getXeroCustomMetadataSettings();
		System.debug('xeroOrgSettings-->'+xeroOrgSettings);

		for(Xero_Setting__mdt csXeroOrg : xeroOrgSettings) {
			// Instantiate a new request
			Http http = new Http();
			HttpRequest request = new HttpRequest();

			// Set request parameters
			request.setMethod(method);
			System.debug('xeroSettings.Endpoint_URL__c'+csXeroOrg.Endpoint_URL__c);
			request.setEndpoint(csXeroOrg.Endpoint_URL__c + resourceName);

			// Accept a JSON response from the call
			request.setHeader('Accept', 'application/json');

			// If the callout includes a body (POST and PUT requests)
			if (String.isNotBlank(requestBody)) {

				// Set the body to the callout
				request.setBody(requestBody);

				// Set the content to XML
				request.setHeader('Content-Type', 'text/xml');
			}
			System.debug('xeroSettings.Endpoint__c'+csXeroOrg.Xero_Consumer_Key__c);
			// Sign the request based on OAuth 1.0a
			request = XeroOAuthUtility.signRequest(request, csXeroOrg.Xero_Consumer_Key__c);
			response =  http.send(request);
			responseList.add(response);

		}
		
		// Execute callout and return
		return responseList;
	}

	private static List<Xero_Setting__mdt> getXeroCustomMetadataSettings() {
        Xero_Setting__mdt[] xeroSettings = [SELECT MasterLabel, 
                                                QualifiedApiName,
                                                DeveloperName, 
                                                Endpoint_URL__c, 
                                                Xero_Consumer_Key__c
                                                FROM Xero_Setting__mdt];

        return xeroSettings;
    }

}