global class CompanyHouseCallout {

	private static final string searchURL = 'https://api.companieshouse.gov.uk/company';
	private static final string searchAllURL = 'https://api.companieshouse.gov.uk/search/companies';

	public class CompanyResponse {
		public String company_name;	//ASCENTIAL AMERICA LIMITED
		public String company_number;	//00234317
		public boolean has_been_liquidated;
		public String jurisdiction;	//england-wales
		public RegisteredAddress registered_office_address;
		public String date_of_creation;	//1928-10-25
		public String type;	//ltd
		public String company_status;	//active

	}

	public class RegisteredAddress {
		public String address_line_1;	//C/O Ascential Group Limited The Prow
		public String country;	//United Kingdom
		public String address_line_2;	//1 Wilder Walk
		public String postal_code;	//W1B 5AP
		public String locality;	//London
	}

	public class SearchCompaniesResponse {
		public Companies[] items;
	}

	public class Companies {
		public String company_status;	//dissolved
		public String description;	//09166849 - Dissolved on 18 August 2015
		public String address_snippet;	//16  Churchill Way, Cardiff, United Kingdom, CF10 2DX
		public String company_type;	//ltd
		public String company_number;	//09166849
		public String title;	//SALESFORCE LIMITED
		public String date_of_creation;	//2014-08-07
		//public Address address;
	}

	public class Address {
		public String country;	//United Kingdom
		public String postal_code;	//CF10 2DX
		public String premises;	//16 
		public String address_line_1;	//Churchill Way
		public String address_line_2;
		public String locality;	//Cardiff
	}

	public class OfficersResponse {
		public ContactDetails[] items;
	}

	public class ContactDetails {
		public String appointed_on;	//2008-06-06
		public Address address;
		public String nationality;	//British
		public String name;	//LOOI, Shanny
		public String officer_role;	//secretary
	}
	
	webservice static String syncAccount(String companyId) {

		String resultMessage = '';

		HttpResponse httpCalloutResponse;
		CompanyResponse finalResp ;

        try{
        	System.debug('companyId'+companyId);
        	System.debug('searchURLcompanyId'+searchAllURL);
            Http httpInstance = new Http();
            HttpRequest httpCalloutRequest = new HttpRequest();
            httpCalloutRequest.setEndpoint(searchURL+'/'+companyId);
            httpCalloutRequest.setMethod('GET');
            
            httpCalloutRequest.setTimeout(12000);

            Blob headerValue = Blob.valueOf('GwkZ5Feis6aJoTJzyCYrTpk09k-t9rqpGWPhjiyo:');
			System.debug('Header'+EncodingUtil.base64Encode(headerValue));
			String authorizationHeader = EncodingUtil.base64Encode(headerValue);
			httpCalloutRequest.setHeader('Authorization', 'Basic ' + authorizationHeader);

            httpCalloutResponse = httpInstance.send(httpCalloutRequest);
            System.debug('Response'+httpCalloutResponse.getBody());
        
            // Check response codes and handle any errors, by throwing custom error
            if(httpCalloutResponse.getStatusCode() != 200) {
                HttpCalloutException commonCalloutException = new HttpCalloutException();
                commonCalloutException.setMessage('A callout exception occurred with a status of: ' + httpCalloutResponse.getStatusCode());
                throw commonCalloutException;

            } else {
            	finalResp = (CompanyResponse)JSON.deserialize(httpCalloutResponse.getBody(), CompanyResponse.class);

            	Account accountToInsert = new Account();
	            accountToInsert.Name = finalResp.company_name;
	            accountToInsert.Company_Number__c = finalResp.company_number;
	            //accountToInsert.Country_Code__c = countryCode;
	            accountToInsert.Company_Type__c = finalResp.type;
	            accountToInsert.Duedil_Status__c = finalResp.company_status;
	            //accountToInsert.Website = companyVitalResponse.primaryWebsite;
	            accountToInsert.Registered_Area__c = finalResp.registered_office_address.address_line_1 + ','
	            										+ finalResp.registered_office_address.address_line_2 + ','
	            										+finalResp.registered_office_address.locality+ ',' + finalResp.registered_office_address.locality;
	            //accountToInsert.Incorporation_Date__c = Date.valueOf(incorporationDate);
	            System.debug('accountToInsert-->'+accountToInsert);
            	//upsert accountToInsert Company_Number__c;
            }

        } catch (Exception e) {
             // If logging enabled, output the Exception
            System.debug(LoggingLevel.INFO, 'Exception: ' + e.getTypeName());
        }
        
		resultMessage = 'Account got synced with salesforce';
		return resultMessage;
		
	}

	webservice static String massImport() {

		String resultMessage = '';
		SearchCompaniesResponse finalResp;
		HttpResponse httpCalloutResponse;

		Http httpInstance = new Http();
        HttpRequest httpCalloutRequest = new HttpRequest();
        httpCalloutRequest.setEndpoint(searchAllURL+'?q='+'Ascential');
        httpCalloutRequest.setMethod('GET');
        
        httpCalloutRequest.setTimeout(12000);

        Blob headerValue = Blob.valueOf('GwkZ5Feis6aJoTJzyCYrTpk09k-t9rqpGWPhjiyo:');
		System.debug('Header'+EncodingUtil.base64Encode(headerValue));
		String authorizationHeader = EncodingUtil.base64Encode(headerValue);
		httpCalloutRequest.setHeader('Authorization', 'Basic ' + authorizationHeader);

        httpCalloutResponse = httpInstance.send(httpCalloutRequest);
        System.debug('Response'+httpCalloutResponse.getBody());

        // Check response codes and handle any errors, by throwing custom error
        if(httpCalloutResponse.getStatusCode() != 200) {
            HttpCalloutException commonCalloutException = new HttpCalloutException();
            commonCalloutException.setMessage('A callout exception occurred with a status of: ' + httpCalloutResponse.getStatusCode());
            throw commonCalloutException;

        } else {
        	List<Account> massImportAccounts = new List<Account>();

        	finalResp = (SearchCompaniesResponse)JSON.deserialize(httpCalloutResponse.getBody(), SearchCompaniesResponse.class);

        	System.debug('finalResp'+finalResp);
        	
        	for(Companies comp : finalResp.items) {
        		Account accRec = new Account();
        		accRec.Name = comp.title;
        		accRec.Duedil_Status__c = comp.company_status;
        		accRec.Description = comp.description;
        		accRec.Company_Type__c = comp.company_type;
        		accRec.Incorporation_Date__c = Date.valueOf(comp.date_of_creation);
        		accRec.Company_Number__c = comp.company_number;
        		accRec.Registered_Area__c = comp.address_snippet;
        		massImportAccounts.add(accRec);
        	}

        	if(massImportAccounts != null && !massImportAccounts.isEmpty()) {

        		System.debug('massImportAccounts'+massImportAccounts);
        		Schema.SObjectField ftoken = Account.Fields.Company_Number__c;
        		Database.UpsertResult [] srList = Database.upsert(massImportAccounts,ftoken,false);
        		resultMessage = massImportAccounts.size() + ' Accounts got imported from Companies House';
        	}

        }
		return resultMessage;
	}

	webservice static String massImportOfficers(String companyId, String accountId) {
		String resultMessage = '';

		HttpResponse httpCalloutResponse;
		OfficersResponse finalResp ;

        try{
        	System.debug('companyId'+companyId);
        	System.debug('accountId'+accountId);
            Http httpInstance = new Http();
            HttpRequest httpCalloutRequest = new HttpRequest();
            httpCalloutRequest.setEndpoint(searchURL+'/'+companyId+'/officers');
            System.debug('Final URL' +searchURL+'/'+companyId+'/officers');

            httpCalloutRequest.setMethod('GET');
            
            httpCalloutRequest.setTimeout(12000);

            Blob headerValue = Blob.valueOf('GwkZ5Feis6aJoTJzyCYrTpk09k-t9rqpGWPhjiyo:');
			System.debug('Header'+EncodingUtil.base64Encode(headerValue));
			String authorizationHeader = EncodingUtil.base64Encode(headerValue);
			httpCalloutRequest.setHeader('Authorization', 'Basic ' + authorizationHeader);

            httpCalloutResponse = httpInstance.send(httpCalloutRequest);
            System.debug('Response'+httpCalloutResponse.getBody());
        
            // Check response codes and handle any errors, by throwing custom error
            if(httpCalloutResponse.getStatusCode() != 200) {
                HttpCalloutException commonCalloutException = new HttpCalloutException();
                commonCalloutException.setMessage('A callout exception occurred with a status of: ' + httpCalloutResponse.getStatusCode());
                throw commonCalloutException;

            } else {
            	finalResp = (OfficersResponse)JSON.deserialize(httpCalloutResponse.getBody(), OfficersResponse.class);
            	System.debug('Response finalResp'+finalResp);
            	List<Contact> conList = new List<Contact>();


            	for(ContactDetails conObj: finalResp.items) {

            		Contact conRec = new Contact();
            		conRec.LastName = conObj.name;
            		conRec.Nationality__c = conObj.nationality;
            		conRec.Officer_Role__c = conObj.officer_role;
            		conRec.accountId = accountId;
            		//conRec.Appointed_on__c = Date.valueOf(conObj.appointed_on);
            		conRec.Officer_Address__c = conObj.address.premises + ',' +
            									conObj.address.address_line_1 + ',' +
            									conObj.address.address_line_2 + ',' +
            									conObj.address.locality + ',' +
            									conObj.address.country + ',' +
            									conObj.address.postal_code;
            		conList.add(conRec);

            	}

            	if(conList != null && !conList.isEmpty()) {
            		System.debug('Response conList'+conList);
            		upsert conList;
            		resultMessage = conList.size() +'Contacts got synced into salesforce from companies house';
            	}
            }

        } catch (DmlException e) {
             // If logging enabled, output the Exception
            System.debug(LoggingLevel.INFO, 'Exception: ' + e.getTypeName());
            System.debug(LoggingLevel.INFO, 'Exception: ' + e.getMessage());
            System.debug(LoggingLevel.INFO, 'Exception: ' + e.getLineNumber());
        }
        
		//resultMessage = 'Contacts got synced with salesforce';
		return resultMessage;
	}
}