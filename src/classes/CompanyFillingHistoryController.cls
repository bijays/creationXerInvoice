public without sharing class CompanyFillingHistoryController {

    public class FillingHistoryWrapper {
        public String dateOfFillingHistory {get;set;}
        public String description {get;set;}
        public String fillingHistoryURL {get;set;}

        public FillingHistoryWrapper(String dateOfFillingHistory, String description, String fillingHistoryURL) {
            this.dateOfFillingHistory = dateOfFillingHistory;
            this.description = description;
            this.fillingHistoryURL = fillingHistoryURL;
        }
    }

    public class FillingHistoryResponse {
        public FillingHistoryDetail[] items;
    }

    public class FillingHistoryDetail {
        public String dateFL; //2018-02-05
        public String description;  //capital-allotment-shares
        public Links links;
    }

    public class Links {
        public String document_metadata;    //https://document-api.companieshouse.gov.uk/document/WUhMUuZ0tgq33g1dyT-ax_p-OoANsENAKAKxoFLz8f4

    }


	private final sObject mysObject;

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public CompanyFillingHistoryController(ApexPages.StandardController stdController) {
        this.mysObject = (sObject)stdController.getRecord();
    }

    public String getRecordName() {
        return 'Hello ' + (String)mysObject.get('name') + ' (' + (Id)mysObject.get('Id') + ')';
    }
}