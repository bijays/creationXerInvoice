/**
* @author       
* @description  Class to handle API calls for the Xero Accounting API resources
**/
public with sharing class XeroAccountingApi {

    // Ordering ENUM
    public enum SortOrder {ASCENDING, DESCENDING}

    /**
    *   @author 
    *   @description Method to return ALL contacts for your Xero environment
    *   @return List of Xero Contact wrapper classes
    **/
    public static List<XeroContact> getContacts () {

        List<XeroContact> xeroContacts = new List<XeroContact>();

        // Execute the callout to the Contacts resource
        List<HttpResponse> responses = XeroCalloutUtility.executeOrgCallout('GET', 'Contacts', null);

        for(HttpResponse resp : responses) {

            //System.debug('responses-->'+resp);
            // If successful response
            if (resp.getStatusCode() == 200) {
                System.debug('esp.getBody()'+resp.getBody());
                // Use the parser to convert the response into Xero objects
                xeroContacts.add(XeroCalloutResponseParser.parseContacts(resp.getBody()));
            } else {

                // Raise error
                throw new XeroAccountingApiException(resp.getStatusCode() + ': ' + resp.getBody());
            }
        }
        System.debug('$$$$xeroContacts'+xeroContacts);
        /*
        for(XeroContact xc : xeroContacts) {
            System.debug('Xero ProviderName'+xc.ProviderName);
            
            for(XeroContact.Contacts conObj: xc.Contacts) {
                System.debug('Xero ProviderName'+conObj.Name);
                System.debug('Xero ProviderName'+conObj.FirstName);
            }
        }*/

        

        return xeroContacts;
    }

    /**
    *   @author 
    *   @description Method to return ALL contacts for your Xero environment
    *   @return List of Xero Contact wrapper classes
    **/
    /*
    public static XeroContact getContact (String xeroContactId) {

        XeroContact xeroContact = new XeroContact();

        // Execute the callout to the Contacts resource
        HttpResponse response = XeroCalloutUtility.executeCallout('GET', 'Contacts/' + xeroContactId, null);

        // If successful response
        if (response.getStatusCode() == 200) {

            // Use the parser to convert the response into Xero objects
            xeroContact = XeroCalloutResponseParser.parseContacts(response.getBody())[0];
        }
        else {

            // Raise error
            throw new XeroAccountingApiException(response.getStatusCode() + ': ' + response.getBody());
        }

        return xeroContact;
    }
    */

    /**
    *   @author 
    *   @description Method to create a Contact in Xero. 
    *   @return Returns the Contact Id of the Contact created in Xero
    **/
    /*
    public static XeroContact createContact (String contactBody) {

        // The created contact to return
        XeroContact createdContact;

        // Execute the callout to the Contacts resource
        HttpResponse response = XeroCalloutUtility.executeCallout('POST', 'Contacts', contactBody);
        System.debug('contactBody--->'+contactBody);
        System.debug('response.getStatusCode()--->'+response.getStatusCode());
        // If successful response
        if (response.getStatusCode() == 200) {

            // Use the parser to convert the response into Xero objects
            createdContact = XeroCalloutResponseParser.parseContacts(response.getBody())[0];
        }
        else {

            // Raise error
            throw new XeroAccountingApiException(response.getStatusCode() + ': ' + response.getBody());
        }

        return createdContact;
    }
    */

    /**
    *   @author 
    *   @description Method to return ALL invoices for your Xero environment
    *   @return List of Xero Invoice wrapper classes
    **/
    public static List<XeroInvoice> getInvoices () {

        return getInvoices(null, null);
    }

    /**
    *   @author 
    *   @description Method to return ALL invoices for your Xero environment
    *   @return List of Xero Invoice wrapper classes
    **/
    public static List<XeroInvoice> getInvoices (String orderBy, XeroAccountingApi.SortOrder sortOrder) {

        List<XeroInvoice> xeroInvoices = new List<XeroInvoice>();

        String endpoint = 'Invoices';

        // Add any ordering parameters
        if (String.isNotBlank(orderBy)) {

            endpoint += '?order=' + orderBy;
        }

        // Set a sort order if exists
        // Only bothering with descending, as ascending is done by default
        if (sortOrder != null && sortOrder == XeroAccountingApi.SortOrder.DESCENDING) {

            endpoint += '%20DESC';
        }

        // Execute the callout to the Invoice resource
        List<HttpResponse> responses = XeroCalloutUtility.executeOrgCallout('GET', endpoint, null);

        for(HttpResponse resp : responses) {

            // If successful response
            if (resp.getStatusCode() == 200) {
                // Use the parser to convert the response into Xero objects
                xeroInvoices.add(XeroCalloutResponseParser.parseInvoices(resp.getBody()));
            } else {
                // Raise error
                throw new XeroAccountingApiException(resp.getStatusCode() + ': ' + resp.getBody());
            }
        }
        /*
        for(XeroInvoice xc : xeroInvoices) {
            for(XeroInvoice.Invoices inv : xc.Invoices) {
                System.debug('inv-->'+inv.InvoiceNumber);
                System.debug('inv 1-->'+inv.Total);
                System.debug('inv DueDate-->'+inv.DueDateString);
                System.debug('inv Date-->'+inv.DateString);

                System.debug(LoggingLevel.INFO, 'inv.Contact.ContactID: ' + inv.Contact.ContactID);
            }
        }*/
       
        return xeroInvoices;

    }

    /**
    *   @author 
    *   @description Method to return a single invoice for your Xero environment for a given Xero Invoice
    *   @return Single Xero Invoice
    **/
    
    public static XeroInvoice getInvoice (String invoiceId, String consumerKey) {

        //String consumerKey;

        XeroInvoice xeroInvoice = new XeroInvoice();

        Xero_Invoices__c xeroInvc = [Select Id, Xero_Invoice_Id__c, Xero_Account__c from Xero_Invoices__c Where Xero_Invoice_Id__c =: invoiceId];

        /*
        if(xeroInvc.Xero_Account__c == 'Chargifi UK') {
            consumerKey = getConsumerKey('UK_Org');
        } else if(xeroInvc.Xero_Account__c == 'Chargifi US') {
            consumerKey = getConsumerKey('US_Org');
        }
        */
        // Execute the callout to the Invoice resource
        HttpResponse response = XeroCalloutUtility.executeInvoiceCallout('GET', 'Invoices/' + invoiceId, null, consumerKey);

        System.debug('Invoice Response '+response.getBody());

        // If successful response
        if (response.getStatusCode() == 200) {

            String responseString = response.getBody();

            //'"currency":', '"fsCurrency":'
            responseString = responseString.replace('"Date":','"Date1":');
            System.debug('Invoice With Date1 '+responseString);

            // Use the parser to convert the response into Xero objects
            xeroInvoice = XeroCalloutResponseParser.parseInvoices(responseString);
        }
        else {

            // Raise error
            throw new XeroAccountingApiException(response.getStatusCode() + ': ' + response.getBody());
        }

        System.debug('xeroInvoice Response '+xeroInvoice);

        return XeroInvoice;
    }


    public static String getConsumerKey (String orgName) {

        Xero_Setting__mdt xeroSetting = [SELECT MasterLabel, 
                                            QualifiedApiName,
                                            DeveloperName, 
                                            Endpoint_URL__c, 
                                            Xero_Consumer_Key__c
                                            FROM Xero_Setting__mdt Where DeveloperName =: orgName];
        return xeroSetting.Xero_Consumer_Key__c;
    }


    public static XeroPayment getPayment (String paymentId) {

        XeroPayment xeroPaymt = new XeroPayment();

        // Execute the callout to the Invoice resource
        HttpResponse response = XeroCalloutUtility.executeCallout('GET', 'Payments/' + paymentId, null);

        System.debug('Payment Response '+response.getBody());

        // If successful response
        if (response.getStatusCode() == 200) {

            // Use the parser to convert the response into Xero objects
            xeroPaymt = XeroCalloutResponseParser.parsePayments(response.getBody());
        }
        else {

            // Raise error
            throw new XeroAccountingApiException(response.getStatusCode() + ': ' + response.getBody());
        }
        System.debug('Payment xeroPaymt '+xeroPaymt);
        return xeroPaymt;
    }

    /**
    *   @author 
    *   @description Method to return all invoices for a given Contact Id
    *   @return List of Xero Invoice wrapper classes
    **/
    /*
    public static List<XeroInvoice> getInvoicesForContact (String xeroContactId) {

        List<XeroInvoice> xeroInvoices = new List<XeroInvoice>();

        // Execute the callout to the Invoice resource with the Contact ID filter
        HttpResponse response = XeroCalloutUtility.executeCallout('GET', 'Invoices?where=Contact.ContactID%20%3D%20Guid%28%22' + xeroContactId + '%22%29', null);

        // If successful response
        if (response.getStatusCode() == 200) {

            // Use the parser to convert the response into Xero objects
            xeroInvoices = XeroCalloutResponseParser.parseInvoices(response.getBody());
        }
        else {

            // Raise error
            throw new XeroAccountingApiException(response.getStatusCode() + ': ' + response.getBody());
        }

        return xeroInvoices;
    }
    */

    /**
    *   @author 
    *   @description Method to create an invoice in Xero. 
    *   @return Returns the invoice Id of the invoice created in Xero
    **/
     
    public static XeroInvoice_Create createInvoice (String invoiceBody, String consumerKey) {

        // The created invoice to return
        XeroInvoice_Create createdInvoice;

        // Execute the callout to the Contacts GET resource
        HttpResponse response = XeroCalloutUtility.executeInvoiceCallout('POST', 'Invoices', invoiceBody, consumerKey);
       System.debug('response.getStatusCode()'+response.getStatusCode());
       System.debug('response.getBody()'+response.getBody());
        // If successful response
        if (response.getStatusCode() == 200) {
             System.debug('response.getBody()'+response.getBody());
            // Use the parser to convert the response into Xero objects
            createdInvoice = XeroCalloutResponseParser.parseInvoicesCreate(response.getBody())[0];
        }
        else {
            System.debug('response.getStatusCode()'+response.getStatusCode());
            // Raise error
            throw new XeroAccountingApiException(response.getStatusCode() + ': ' + response.getBody());
        }
        return createdInvoice;
    }

    /**
    *   @author 
    *   @description Method to return ALL contacts for your Xero environment
    *   @return List of Xero Contact wrapper classes
    **/
    public static List<XeroOrganisation> getOrganisations () {

        List<XeroOrganisation> xeroOrganizations = new List<XeroOrganisation>();

        // Execute the callout to the Contacts resource
        List<HttpResponse> responses = XeroCalloutUtility.executeOrgCallout('GET', 'Organisations', null);
        System.debug('responses-->'+responses);
        for(HttpResponse resp : responses) {
            // If successful response
            if (resp.getStatusCode() == 200) {

                // Use the parser to convert the response into Xero objects
                xeroOrganizations.add(XeroCalloutResponseParser.parseOrganisations(resp.getBody()));
            }
            else {

                // Raise error
                throw new XeroAccountingApiException(resp.getStatusCode() + ': ' + resp.getBody());
            }
        }
        for(XeroOrganisation xerOrg : xeroOrganizations) {

            System.debug('Name -->'+xerOrg.Organisations[0].Name);
        }

        
        return xeroOrganizations;
    }

    /**
    *   @author 
    *   @description Method to return ALL contacts for your Xero environment
    *   @return List of Xero Contact wrapper classes
    **/
    public static List<XeroRevenueCodes> getXeroRevenueCodes () {

        List<XeroRevenueCodes> xeroRevCodesList = new List<XeroRevenueCodes>();

        XeroRevenueCodes xeroRevCodes = new XeroRevenueCodes();
        // Execute the callout to the Contacts resource
        List<HttpResponse> responses = XeroCalloutUtility.executeOrgCallout('GET', 'Accounts', null);

        System.debug('Xero Accounts'+responses);
        

        for(HttpResponse resp : responses) {

            System.debug('responses-->'+resp);
            // If successful response
            if (resp.getStatusCode() == 200) {

                // Use the parser to convert the response into Xero objects
                xeroRevCodesList.add(XeroCalloutResponseParser.parseRevenueCodes(resp.getBody()));
            } else {

                // Raise error
                throw new XeroAccountingApiException(resp.getStatusCode() + ': ' + resp.getBody());
            }
        }
        /*
        // If successful response
        if (resp.getStatusCode() == 200) {

            // Use the parser to convert the response into Xero objects
            xeroRevCodesList = XeroCalloutResponseParser.parseRevenueCodes(resp.getBody());
        }
        else {
            // Raise error
            throw new XeroAccountingApiException(resp.getStatusCode() + ': ' + resp.getBody());
        }*/
        return xeroRevCodesList;
    }

    /**
    *   @author 
    *   @description Method to return ALL contacts for your Xero environment
    *   @return List of Xero Contact wrapper classes
    **/
    public static String getXeroPayments () {

        List<XeroRevenueCodes> xeroRevCodesList = new List<XeroRevenueCodes>();

        XeroRevenueCodes xeroRevCodes = new XeroRevenueCodes();
        // Execute the callout to the Contacts resource
        List<HttpResponse> responses = XeroCalloutUtility.executeOrgCallout('GET', 'Accounts', null);

        System.debug('Xero Accounts'+responses);
        

        for(HttpResponse resp : responses) {

            System.debug('responses-->'+resp);
            // If successful response
            if (resp.getStatusCode() == 200) {

                // Use the parser to convert the response into Xero objects
                xeroRevCodesList.add(XeroCalloutResponseParser.parseRevenueCodes(resp.getBody()));
            } else {

                // Raise error
                throw new XeroAccountingApiException(resp.getStatusCode() + ': ' + resp.getBody());
            }
        }
        /*
        // If successful response
        if (resp.getStatusCode() == 200) {

            // Use the parser to convert the response into Xero objects
            xeroRevCodesList = XeroCalloutResponseParser.parseRevenueCodes(resp.getBody());
        }
        else {
            // Raise error
            throw new XeroAccountingApiException(resp.getStatusCode() + ': ' + resp.getBody());
        }*/
        return 'True';
    }

     /**
    *   @author 
    *   @description Method to return ALL invoices for your Xero environment
    *   @return List of Xero Invoice wrapper classes
    **/
    public static List<XeroInventory> getInventories () {

        List<XeroInventory> xeroInventories = new List<XeroInventory>();

        //List<String> responseList = new List<String>();

        // Execute the callout to the Invoice resource
        List<HttpResponse> responses = XeroCalloutUtility.executeOrgCallout('GET', 'Items', null);

        for(HttpResponse resp : responses) {

            // If successful response
            if (resp.getStatusCode() == 200) {
                System.debug('Resp Inventory-->'+resp.getBody());
                //responseList.add(resp.getBody());
                // Use the parser to convert the response into Xero objects
                xeroInventories.add(XeroCalloutResponseParser.parseInventories(resp.getBody()));
            } else {
                // Raise error
                throw new XeroAccountingApiException(resp.getStatusCode() + ': ' + resp.getBody());
            }
        }
        
        for(XeroInventory xc : xeroInventories) {
            for(XeroInventory.Items invent : xc.Items) {
                
                System.debug('inv Account Code-->'+invent.SalesDetails.AccountCode);
                System.debug('inv Description-->'+invent.Description);
            }
        }
       
        return xeroInventories;

    }

    /**
    *   @author 
    *   @description Custom exception class to throw errors for web service callouts
    **/
    public class XeroAccountingApiException extends Exception {}

    

}