public without sharing class DuedilController {

	public Account accountInfo {get; set;}
    public List<AccountResponseWrapper> accountList {get;set;}
    public String selectedStatus {get;set;}
    //public static List<AccountResponseWrapper> accountListForMassImport {get;set;}
    public String companyNumber {get; set;}
    public String accountName {get; set;}
    public String countryCode {get; set;}
    public String status {get;set;}
    public Account accountToInsert {get;set;}
    public AccountResponseWrapper accountWrapper {get;set;}
    public Boolean resultMesg {get;set;}
    public String accountId ;
    public Boolean findAndEnrichPanel {get;set;}
    public Boolean selectedAll {get;set;}
    public Boolean renderMassImportInfoMessage {get;set;}

    public final Integer pageSize {get; set;}
    public Long totalNumberOfPages{get; set;}
    public apexPages.StandardSetController stdSetCon {get; set;}
    public Integer totalRowCount {get; set;}

    public static final String api_key = 'c4584ef10569aca2022a15ea64b87393';
    public static final String endpointURISearch = 'https://duedil.io/v4/search/';
    public static final String endpointURICompanyVital = 'https://duedil.io/v4/company/';

    //gb/05236274/registered-names.json;

    public class SearchCompanyRequest {
        public Criteria criteria;
    
    }
    public class Criteria {
        public String name; //Acme
        public Status simplifiedStatuses;
        public CountryCode countryCodes;
    }

    public class CountryCode {
        public String[] values;
        public String mode; //any
    }

    public class Status {
        public String[] values;
        public String mode; //any
    }
    public class Values {
        public string statusValue;
    }

    public class SearchCompanyResponse {
        //public cls_filters filters;
        public Companies[] companies;
    }
    public class Companies {
        public String countryCode;  //GB
        public String companyId;    //05669526
        public String name; 
        public String type; //Private limited with share capital
        public String incorporationDate;    //2006-01-09
        public String officialStatus;   //Dissolved
        public String simplifiedStatus; //Closed
    }

    public class AccountResponseWrapper {
        public string countryCode {get;set;}
        public string companyId {get;set;}
        public string name {get;set;}
        public string type {get;set;}
        public Date incorporationDate {get;set;}
        public String active {get;set;}
        public Boolean isSelected {get;set;}

        public AccountResponseWrapper(String name, 
                                        String countryCode, 
                                        String companyId , 
                                        String type, 
                                        Date incorporationDate,
                                        String active,
                                        Boolean isSelected) {
            this.isSelected = isSelected;
            this.countryCode = countryCode;
            this.companyId = companyId;
            this.name = name;
            this.type = type;
            this.incorporationDate = incorporationDate;
            this.active = active;
        }
    }

    public class RegisteredNameResponse {

        public String countryCode;
        public String companyId;
        public String name;
        public String type;
        public String incorporationDate;
        public String simplifiedStatus;
        public String primaryWebsite;   //http://www.girasole.fr
        public RegisteredAddress registeredAddress;
    }

    public class RegisteredAddress {
        public String fullAddress;  //45 Milden Gardens, Frimley Green, Camberley, Surrey, GU16 6PU
        //public cls_structuredAddress structuredAddress;
        //public cls_geolocation geolocation;
    }

    public class DueDilExceptionResponseWrap {

        public String httpCode;
        public String errorCode;
        public String message;
    }

    public DuedilController(ApexPages.StandardController stdController) {
        findAndEnrichPanel = false;
        renderMassImportInfoMessage= false;
        String response;
        RegisteredNameResponse matchingResponse;
        SearchCompanyResponse finalResp ;
        accountInfo = new Account();
        accountList = new List<AccountResponseWrapper>();
        //accountListForMassImport = new List<AccountResponseWrapper>();
        if(String.isNotBlank(Apexpages.currentPage().getParameters().get('AccountId'))) {
            accountId = Apexpages.currentPage().getParameters().get('AccountId');
            System.debug('accountId-->'+accountId);
            accountInfo = [Select Id,
                                Name,
                                Company_Number__c,
                                Country_Code__c,
                                Company_Type__c,
                                Registered_Area__c,
                                Incorporation_Date__c,
                                Duedil_Status__c,
                                Description,
                                SIC_2003__c,
                                SIC_2007__c,
                                Website   
                                From Account
                                Where Id =: accountId];
            System.debug('accountInfo-->'+accountInfo);
            findAndEnrichPanel = true;

            if(String.isNotBlank(accountInfo.Country_Code__c) && String.isNotBlank(accountInfo.Company_Number__c)) {

                String uriFormat = accountInfo.Country_Code__c.toLowerCase() + '/'+ accountInfo.Company_Number__c+'.json';
                accountListToDisplay(uriFormat, 'GET');
                /*
                response = dueDilCallout(endpointURICompanyVital, uriFormat, '', 'GET');
                System.debug(LoggingLevel.INFO,'Company Vital Response '+response);

                if(String.isNotBlank(response)) {
                    matchingResponse = (RegisteredNameResponse)JSON.deserialize(response, RegisteredNameResponse.class);
                    AccountResponseWrapper accountObjRec = new AccountResponseWrapper(
                                                                            matchingResponse.name,
                                                                            matchingResponse.countryCode,
                                                                            matchingResponse.companyId,
                                                                            matchingResponse.type,
                                                                            Date.valueOf(matchingResponse.incorporationDate),
                                                                            matchingResponse.simplifiedStatus);
                    System.debug(LoggingLevel.INFO,'matchingResponse '+matchingResponse.primaryWebsite);
                    System.debug(LoggingLevel.INFO,'matchingResponse '+matchingResponse.registeredAddress.fullAddress);
                    accountList.add(accountObjRec);
                    */
                //}
                System.debug(LoggingLevel.INFO,'accountList '+accountList);
            } else if(String.isBlank(accountInfo.Company_Number__c) && String.isBlank(accountInfo.Country_Code__c)) {

                 String jsonPostBody = createCompanyRequestWrapper(accountInfo.Name);

                response = dueDilCallout(endpointURISearch,'companies.json',jsonPostBody, 'POST');
                if(String.isNotBlank(response)) {
                    finalResp = (SearchCompanyResponse)JSON.deserialize(response, SearchCompanyResponse.class);
                }
                //System.debug('Response finalResp-->'+finalResp.companyId);
                System.debug('Response finalResp-->'+finalResp.companies);
                
                if(finalResp.companies != null && !finalResp.companies.isEmpty()) {
                    for(Companies comp : finalResp.companies) {
                        System.debug('comp.Name-->'+comp.Name);
                        //System.debug('Date.valueOf(comp.incorporationDate)-->'+Date.valueOf(comp.incorporationDate));
                        AccountResponseWrapper accountObjRec = new AccountResponseWrapper(
                                                                                comp.Name,
                                                                                comp.countryCode,
                                                                                comp.companyId,
                                                                                comp.type,
                                                                                Date.valueOf(comp.incorporationDate) == null?null:Date.valueOf(comp.incorporationDate),
                                                                                comp.simplifiedStatus,
                                                                                false);
                        accountList.add(accountObjRec);
                    }
                    
                }
                System.debug('Account List to Display'+accountList);
                resultMesg = false;
            }

        }
        resultMesg = true;
    }

    public DuedilController () {}

    public List<SelectOption> getStatuses() {

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('--None--','--None--'));
        options.add(new SelectOption('Active','Active'));
        options.add(new SelectOption('Closed','Closed'));
        return options;
    }

    /*
    public apexPages.Standardsetcontroller fetchStdSetExchangeResults(List<DuedilController.AccountResponseWrapper> accountResponseWrapperList) {

        if(!accountResponseWrapperList.isEmpty() && accountResponseWrapperList != null) {
            // Adding results to standard set controller
            stdSetCon = new ApexPages.StandardSetController(accountResponseWrapperList);
            // total records for pagination
            totalRowCount = stdSetCon.getResultSize();
            // Total number of pages 
            totalNumberOfPages = accountResponseWrapperList.size()/pageSize;
            Integer remainder = Math.mod(totalRowCount, pageSize);
            
            if (remainder > 0) {
                totalNumberOfPages ++;
            }
            // Seting page size
            stdSetCon.setPageSize(pageSize);
            return stdSetCon;
        }
        return null;
    }*/
    //Adding to Account List based on search 
    private void accountListToDisplay(String uriFormat, String calloutMethod) {

        String response;
        RegisteredNameResponse matchingResponse;
        response = dueDilCallout(endpointURICompanyVital, uriFormat, '', calloutMethod);
        System.debug(LoggingLevel.INFO,'Company Vital Response '+response);

        if(String.isNotBlank(response)) {
            matchingResponse = (RegisteredNameResponse)JSON.deserialize(response, RegisteredNameResponse.class);
            AccountResponseWrapper accountObjRec = new AccountResponseWrapper(
                                                                    matchingResponse.name,
                                                                    matchingResponse.countryCode,
                                                                    matchingResponse.companyId,
                                                                    matchingResponse.type,
                                                                    Date.valueOf(matchingResponse.incorporationDate),
                                                                    matchingResponse.simplifiedStatus,
                                                                    false);
            System.debug(LoggingLevel.INFO,'matchingResponse '+matchingResponse.primaryWebsite);
            System.debug(LoggingLevel.INFO,'matchingResponse '+matchingResponse.registeredAddress.fullAddress);
            accountList.add(accountObjRec);
            System.debug(LoggingLevel.INFO,'accountList '+accountList);
        
        }

    }
    private String createCompanyRequestWrapper(String accountName) {
            //Criteria Request Mapping
            Criteria dueDillRequest = new Criteria();
            dueDillRequest.name = accountName;
            SearchCompanyRequest scRequest = new SearchCompanyRequest();
            scRequest.criteria = dueDillRequest;

            String jsonPostBody = JSON.serialize(scRequest);
            System.debug('JSONPOSTBody'+jsonPostBody);

            return jsonPostBody;
    }
    public void findAccount() {
        System.debug('Selected value'+selectedStatus);
        String jsonPostBody;
        SearchCompanyResponse finalResp ;
        String response;
        accountList = new List<AccountResponseWrapper>();
        //accountListForMassImport = new List<AccountResponseWrapper>();

        try {

            if(String.isNotBlank(accountId)) {
                findAndEnrichPanel = true;
            }
            if(String.isNotBlank(accountName) && selectedStatus.equalsIgnoreCase('--None--')) {

                //jsonPostBody = createCompanyRequestWrapper(accountName);
                jsonPostBody = createRequestForDuedill(accountName,'', '',1);
                response = dueDilCallout(endpointURISearch,'companies.json',jsonPostBody, 'POST');

                if(String.isNotBlank(response)) {
                    finalResp = (SearchCompanyResponse)JSON.deserialize(response, SearchCompanyResponse.class);
                }
                //System.debug('Response finalResp-->'+finalResp.companyId);
                System.debug('Response finalResp-->'+finalResp.companies);
                
                for(Companies comp : finalResp.companies) {
                    System.debug('comp.Name-->'+comp.Name);
                    AccountResponseWrapper accountObjRec = new AccountResponseWrapper(
                                                                            comp.Name,
                                                                            comp.countryCode,
                                                                            comp.companyId,
                                                                            comp.type,
                                                                            Date.valueOf(comp.incorporationDate),
                                                                            comp.simplifiedStatus,
                                                                            false);
                    accountList.add(accountObjRec);
                }
                System.debug('Account List to Display'+accountList);
                System.debug('Account List Size'+accountList.size());
                //System.debug('Account List 22'+accountListForMassImport);
                
                //System.debug('Account List 11'+accountListForMassImport);
                //System.debug('Account List Size11'+accountListForMassImport.size());
                resultMesg = false;

            } else if(String.isNotBlank(companyNumber) && String.isNotBlank(countryCode) 
                && (String.isBlank(accountName) || String.isNotBlank(accountName)) ){

                System.debug('companyNumber'+companyNumber);
                System.debug('countryCode'+countryCode);
                String uriFormat = countryCode.toLowerCase() + '/'+ companyNumber+'.json';
                accountListToDisplay(uriFormat, 'GET');

            } else if(String.isNotBlank(accountName) 
                && (selectedStatus.equalsIgnoreCase('Active') || selectedStatus.equalsIgnoreCase('Closed'))) {

                jsonPostBody = createRequestForDuedill(accountName,selectedStatus, '',3);
                response = dueDilCallout(endpointURISearch,'companies.json',jsonPostBody, 'POST');
                if(String.isNotBlank(response)) {
                    finalResp = (SearchCompanyResponse)JSON.deserialize(response, SearchCompanyResponse.class);
                }
                //System.debug('Response finalResp-->'+finalResp.companyId);
                System.debug('Response finalResp-->'+finalResp.companies);
                
                for(Companies comp : finalResp.companies) {
                    System.debug('comp.Name-->'+comp.Name);
                    AccountResponseWrapper accountObjRec = new AccountResponseWrapper(
                                                                            comp.Name,
                                                                            comp.countryCode,
                                                                            comp.companyId,
                                                                            comp.type,
                                                                            Date.valueOf(comp.incorporationDate),
                                                                            comp.simplifiedStatus,
                                                                            false);
                    accountList.add(accountObjRec);
                }
            }


        } catch (Exception e) {
             // If logging enabled, output the Exception
            System.debug(LoggingLevel.INFO, 'Exception: ' + e.getTypeName());
            Apexpages.addMessage(new ApexPages.Message(Apexpages.severity.error, e.getMessage()));
        }
    }

    private String createRequestForDuedill (String accountName,
                                                String status,
                                                String countryCode, 
                                                Integer scenarioNumber) {
        String jsonPostBody = '';
        System.debug('status'+status);
        Criteria dueDillRequest = new Criteria();
        if(scenarioNumber == 1) {
            dueDillRequest.name = accountName;
        }
        if(scenarioNumber == 3) {
            dueDillRequest.name = accountName;
            //Values val = new Values();
            //val.statusValue = status;
            List<String> vals = new List<String>();
            vals.add(status);
            Status stats = new Status();
            stats.values =vals;
            stats.mode = 'any';
            dueDillRequest.simplifiedStatuses = stats;
            //dueDillRequest.countryCodes = null;
        }
        SearchCompanyRequest scRequest = new SearchCompanyRequest();
        scRequest.criteria = dueDillRequest;
        jsonPostBody = JSON.serialize(scRequest, true);
        System.debug('JSONPOSTBody'+jsonPostBody);
        return jsonPostBody;
    }

    private static String dueDilCallout(String endpointURI, 
                                            String uriFormat,
                                            String jsonBody,
                                            String methodType) {
        HttpResponse httpCalloutResponse;
        //SearchCompanyResponse accountResponse;
        try{
            Http httpInstance = new Http();
            HttpRequest httpCalloutRequest = new HttpRequest();
            httpCalloutRequest.setEndpoint(endpointURI+'/'+uriFormat);
            httpCalloutRequest.setMethod(methodType);
            if(String.isNotBlank(jsonBody)) {
                httpCalloutRequest.setBody(jsonBody);
            }
            httpCalloutRequest.setTimeout(12000);
            httpCalloutRequest.setHeader('X-AUTH-TOKEN',api_key);
            httpCalloutResponse = httpInstance.send(httpCalloutRequest);
            System.debug('Response'+httpCalloutResponse.getBody());
        
            // Check response codes and handle any errors, by throwing custom error
            if(httpCalloutResponse.getStatusCode() != 200) {
                HttpCalloutException commonCalloutException = new HttpCalloutException();
                commonCalloutException.setMessage('A callout exception occurred with a status of: ' + httpCalloutResponse.getStatusCode());
                throw commonCalloutException;
            }

            ///accountResponse = (SearchCompanyResponse)JSON.deserialize(httpCalloutResponse.getBody(), SearchCompanyResponse.class);
            //System.debug('Response resgisteredNameResp'+accountResponse);
            
        } catch (Exception e) {
             // If logging enabled, output the Exception
            System.debug(LoggingLevel.INFO, 'Exception: ' + e.getTypeName());
            Apexpages.addMessage(new ApexPages.Message(Apexpages.severity.error, e.getMessage()));
        }
        return httpCalloutResponse.getBody();

    }

    @RemoteAction
    public static String insertAccount(String name,
                                        String companyId,
                                        String countryCode,
                                        String type,
                                        String active,
                                        String incorporationDate ) {

        String response;
        RegisteredNameResponse companyVitalResponse;

        if(String.isNotBlank(companyId) && String.isNotBlank(countryCode)) {
            String uriFormat = countryCode.toLowerCase() + '/'+ companyId+'.json';
            response = dueDilCallout(endpointURICompanyVital, uriFormat, '', 'GET');
            System.debug(LoggingLevel.INFO,'Company Vital Response '+response);

            if(String.isNotBlank(response)) {
                companyVitalResponse = (RegisteredNameResponse)JSON.deserialize(response, RegisteredNameResponse.class);
                System.debug(LoggingLevel.INFO,'Company Vital primaryWebsite '+companyVitalResponse.primaryWebsite);
                System.debug(LoggingLevel.INFO,'Company Vital fullAddress '+companyVitalResponse.registeredAddress.fullAddress);
            }
        }

        String resultMessage = '';
        try {
            Account accountToInsert = new Account();
            accountToInsert.Name = name;
            accountToInsert.Company_Number__c = companyId;
            accountToInsert.Country_Code__c = countryCode;
            accountToInsert.Company_Type__c = type;
            accountToInsert.Duedil_Status__c = active;
            accountToInsert.Website = companyVitalResponse.primaryWebsite;
            accountToInsert.Registered_Area__c = companyVitalResponse.registeredAddress.fullAddress;
            //accountToInsert.Incorporation_Date__c = Date.valueOf(incorporationDate);
            System.debug('accountToInsert-->'+accountToInsert);
            upsert accountToInsert Company_Number__c;
            resultMessage = 'Account got successfully synced';
        } catch(DmlException dmlExcep) {
            resultMessage = 'Some isssue with Account insertion due to :' +dmlExcep.getMessage();
            System.debug('Exception while inserting account'+dmlExcep.getMessage());
        }
        return resultMessage;
    }

    public PageReference navigateToAccountStdLayout() {
        PageReference pageRef = null;
        String accountName = Apexpages.currentPage().getParameters().get('accName');
        String accountCompanyId = Apexpages.currentPage().getParameters().get('accCompanyId');
        String accountCountryCode = Apexpages.currentPage().getParameters().get('accCountryCode');
        String accountType = Apexpages.currentPage().getParameters().get('accType');
        String accountStatus = Apexpages.currentPage().getParameters().get('accActive');
        pageRef = new pageReference('/001/e?retURL=%2F001%2Fo');
        pageref.getParameters().put('acc2',accountName);
        pageref.getParameters().put('00N0N00000DZ4mU',accountCompanyId);
        pageref.getParameters().put('00N0N00000DZ4me',accountType);
        pageref.getParameters().put('00N0N00000DZRCs',accountCountryCode);
        pageref.getParameters().put('00N0N00000DZjhV',accountStatus);
        pageref.getParameters().put('nooverride','1');
        System.debug(LoggingLevel.INFO,'pageref'+pageref);
        pageRef.setRedirect(false);
         
        System.debug(LoggingLevel.INFO,'AccountName'+accountName);
        return pageRef;
    }

    //@RemoteAction
    public void massImportAccountsFromDueDil() {   

        String result = '';
        Boolean isValueSelected = false;
        System.debug(LoggingLevel.INFO, 'accountList-->'+accountList);
        System.debug(LoggingLevel.INFO, 'accountList-->'+accountList.size());
        String response;
        RegisteredNameResponse companyVitalResponse;
        List<Account> massInsertAccounts = new List<Account>();
        
        if(accountList != null && !accountList.isEmpty()) {
            for(AccountResponseWrapper accWrap: accountList) {

                if(String.isNotBlank(accWrap.companyId) && String.isNotBlank(accWrap.countryCode)) {
                    String uriFormat = accWrap.countryCode.toLowerCase() + '/'+ accWrap.companyId+'.json';
                    response = dueDilCallout(endpointURICompanyVital, uriFormat, '', 'GET');
                    System.debug(LoggingLevel.INFO,'Company Vital Response '+response);

                    if(String.isNotBlank(response)) {
                        companyVitalResponse = (RegisteredNameResponse)JSON.deserialize(response, RegisteredNameResponse.class);
                        System.debug(LoggingLevel.INFO,'Company Vital primaryWebsite '+companyVitalResponse.primaryWebsite);
                        System.debug(LoggingLevel.INFO,'Company Vital fullAddress '+companyVitalResponse.registeredAddress.fullAddress);
                    }
                }

                Account accountToInsert = new Account();
                accountToInsert.Name = accWrap.name;
                accountToInsert.Company_Number__c = accWrap.companyId;
                accountToInsert.Country_Code__c = accWrap.countryCode;
                accountToInsert.Company_Type__c = accWrap.type;
                accountToInsert.Duedil_Status__c = accWrap.active;
                accountToInsert.Website = companyVitalResponse.primaryWebsite != ''?companyVitalResponse.primaryWebsite:'';
                accountToInsert.Registered_Area__c = companyVitalResponse.registeredAddress.fullAddress != ''? companyVitalResponse.registeredAddress.fullAddress:'';
                //accountToInsert.Incorporation_Date__c = Date.valueOf(incorporationDate);
                System.debug('accountToInsert-->'+accountToInsert);
                massInsertAccounts.add(accountToInsert);
                    //result = 'Selected records got successfully imported to Salesforce';
            }
            System.debug('massInsertAccounts-->'+massInsertAccounts);
            Schema.SObjectField ftoken = Account.Fields.Company_Number__c;
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Update successful'));
            renderMassImportInfoMessage = true;
            System.debug('massInsertAccounts-->'+renderMassImportInfoMessage);
            
            Database.UpsertResult [] srList = Database.upsert(massInsertAccounts,ftoken,false);

            for (Database.UpsertResult sr : srList) {
                if (sr.isSuccess()) {
                    Apexpages.addMessage(new ApexPages.Message(Apexpages.severity.Info, 'Successfully imported the records'));
                    System.debug('Accounts that got inserted'+sr.getId());
                } else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('error has occurred.' + err.getStatusCode() + ': ' + err.getMessage());                    
                        System.debug('fields that affected this error: ' + err.getFields());
                        
                    }
                }
            }
            
        }
        
        //result = 'Selected records got successfully imported to Salesforce';
        //System.debug(LoggingLevel.INFO, 'accountRespWrapSelected-->'+accountRespWrapSelected);
        //return result;
    }
}