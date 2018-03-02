/**
* @author       Ben Edwards (ben@edwards.nz)
* @description  Class to parse responses from Xero callouts
**/
public with sharing class XeroCalloutResponseParser {
	
	/**
    *   @author Ben Edwards (ben@edwards.nz)
    *   @description Method to convert JSON responses into Xero objects
    *   @return Returns a Xero wrapper class object from a given response body
    **/
    public static XeroContact parseContacts(String jsonBody) {

        // Re-serialize just the Contacts portion back to JSOn
       // String jsonSerialized = generateJsonStringForParsing (jsonBody, 'Contacts');
        
        // And finally parse the now re-serialized contact list back into Contact objects
        return (XeroContact) JSON.deserialize(jsonBody, XeroContact.class);
    }

    /**
    *   @author Ben Edwards (ben@edwards.nz)
    *   @description Method to convert JSON responses into Xero objects
    *   @return Returns a Xero wrapper class object from a given response body
    **/
    public static XeroOrganisation parseOrganisations(String jsonBody) {

        // Re-serialize just the Contacts portion back to JSOn
        System.debug('$$~$~$jsonBody'+jsonBody);
        //String jsonSerialized = generateJsonStringForParsing (jsonBody, 'Organisations');
        //System.debug('jsonSerialized'+jsonSerialized);
        System.debug('jsonSerialized final--->'+(XeroOrganisation) JSON.deserialize(jsonBody, XeroOrganisation.class));
        
        // And finally parse the now re-serialized contact list back into Contact objects
        return (XeroOrganisation) JSON.deserialize(jsonBody, XeroOrganisation.class);
    }

    /**
    *   @author Ben Edwards (ben@edwards.nz)
    *   @description Method to convert JSON responses into Xero objects
    *   @return Returns a Xero wrapper class object from a given response body
    **/
    public static XeroRevenueCodes parseRevenueCodes(String jsonBody) {

        // Re-serialize just the Contacts portion back to JSOn
        System.debug('$$~$~$jsonBody'+jsonBody);
        
        return (XeroRevenueCodes) JSON.deserialize(jsonBody, XeroRevenueCodes.class);
    }

    public static XeroInventory parseInventories(String jsonBody) {

        // Re-serialize just the Contacts portion back to JSOn
        
        return (XeroInventory) JSON.deserialize(jsonBody, XeroInventory.class);
    }

    /**
    *   @author Ben Edwards (ben@edwards.nz)
    *   @description Method to convert JSON responses into Xero objects
    *   @return Returns a Xero wrapper class object from a given response body
    **/
    public static XeroInvoice parseInvoices(String jsonBody) {

        // Re-serialize just the Contacts portion back to JSOn
        //String jsonSerialized = generateJsonStringForParsing (jsonBody, 'Invoices');
        // And finally parse the now re-serialized contact list back into Contact objects
        return (XeroInvoice) JSON.deserialize(jsonBody, XeroInvoice.class);
    }

    public static XeroPayment parsePayments(String jsonBody) {

        // Re-serialize just the Contacts portion back to JSOn
        //String jsonSerialized = generateJsonStringForParsing (jsonBody, 'Invoices');
        // And finally parse the now re-serialized contact list back into Contact objects
        return (XeroPayment) JSON.deserialize(jsonBody, XeroPayment.class);
    }

    /**
    *   @author Ben Edwards (ben@edwards.nz)
    *   @description Method to convert JSON responses into Xero objects
    *   @return Returns a Xero wrapper class object from a given response body
    **/
    public static List<XeroInvoice_Create> parseInvoicesCreate(String jsonBody) {

        // Re-serialize just the Contacts portion back to JSOn
        String jsonSerialized = generateJsonStringForParsing (jsonBody, 'Invoices');

        // And finally parse the now re-serialized contact list back into Contact objects
        return (List<XeroInvoice_Create>) JSON.deserialize(jsonSerialized, List<XeroInvoice_Create>.class);
    }

    /**
    *   @author Ben Edwards (ben@edwards.nz)
    *   @description Method to take the full JSON response and just return the object portion. Eg. The Contact and Invoice portion only
    *   @return JSON String with only specific object data
    **/
    private static String generateJsonStringForParsing (String jsonBody, String objectName) {

    	// Parse the JSON response
        Map<String, Object> jsonResponseMap = (Map<String, Object>) JSON.deserializeUntyped(jsonBody);

        // Re-serialize just the object portion back to JSON
        return JSON.serialize((List<Object>) jsonResponseMap.get(objectName));
    }



}