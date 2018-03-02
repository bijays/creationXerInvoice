global with sharing class SmartAccountCreateCtlr {
    public SmartAccountCreateCtlr(ApexPages.StandardController ctlr) {
        
    }

    @RemoteAction
    public static List<AccountWrapper> search(String keyword) {
        DuedilController.Criteria crit=new DuedilController.Criteria();
        crit.name=keyword;
        String critJson='{"criteria":{"name":"'+keyword+'"}}';
        System.debug(JSON.serialize(crit));
//        DuedilController.SearchCompanyResponse resp=DuedilController.dueDilCallout('https://duedil.io/v4/search/', JSON.serialize(crit));
        DuedilController.SearchCompanyResponse resp=DuedilController.dueDilCallout('companies.json', critJson);
        List<SmartAccountCreateCtlr.AccountWrapper> result = new List<SmartAccountCreateCtlr.AccountWrapper>();
        if(resp != null && resp.companies != null) {
            for(DuedilController.Companies comp: resp.companies) {
                result.add(new AccountWrapper(comp.countryCode, comp.companyId, comp.name, comp.incorporationDate, comp.officialStatus));
            }
        }
        /*result.add(new AccountWrapper('GB', '00100991', 'Ascential America (Holdings) Limited', '1909-01-05', 'Active'));
        result.add(new AccountWrapper('GB', '00234317', 'Ascential America Limited', '1928-10-25', 'Active'));
        result.add(new AccountWrapper('GB', '07814172', 'Ascential Events (Europe) Limited', '2011-10-18', 'Active'));
        */
		return result;
    }

    public class AccountWrapper {
        public String countryCode {get; set;}
        public String companyId {get; set;}
        public String name {get; set;}
        public String incorporationDate {get; set;}
        public String officialStatus {get; set;}

        public AccountWrapper(String countryCode, String companyId, String name, 
            String inDate, String oStatus) {

            this.countryCode = countryCode;
            this.companyId = companyId;
            this.name = name;
            this.incorporationDate = inDate;
            this.officialStatus = oStatus;
        }
    }
}