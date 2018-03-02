public without sharing class XeroAddInvoiceExtension {

  public Xero_Invoices__c invObj {get;set;}
    private Integer counter;
    public List<InvoiceItemWrapper> invItemWrapperList {get;set;}
    public String invItemAmount {get;set;}
    public Integer inventoryUnitPrice {get;set;}
    public Decimal subtotal {get;set;}
    public Decimal vat {get;set;}
    public Decimal total {get;set;}


    public XeroAddInvoiceExtension(ApexPages.StandardController stdController) {
         
        //this.mysObject = (sObject)stdController.getRecord();
        invItemAmount = string.valueOf(0.00);
        invObj = new Xero_Invoices__c();  
        subtotal = 0.00;
        total = 0.00;
        vat = 0.00;
        counter = 0;
        invItemWrapperList = new List<InvoiceItemWrapper>();
        for(Integer i=0 ; i< 2; i++) {
               InvoiceItemWrapper invItemWrap = new InvoiceItemWrapper(new Xero_Invoice_Line_Items__c()); 
               counter++;
               invItemWrap.counterWrap = counter;
               invItemWrap.inventorySalesPrice = String.valueof(0.00);
               invItemWrap.inventoryNameAsDescription = '';
               invItemWrap.invItemQuantity = String.valueof(0);
               invItemWrap.invItemAmount = String.valueof(0.00);
               invItemWrapperList.add(invItemWrap); 
               
        }
        System.debug('@@@@invItemWrapperList invItemWrapperList'+invItemWrapperList);
   
    }

    /*
    public List<SelectOption> getCurrencyValues() {
      List<SelectOption> options = new List<SelectOption>();

       Schema.DescribeFieldResult fieldResult = Invoice__c.CurrencyIsoCode.getDescribe();

       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

       for( Schema.PicklistEntry f : ple) {
          //Concatinating currency values like  ( value "USD" label "U.S. Dollar" ) 
          string finalvalue= f.getValue() + '-' + f.getLabel() ;

          options.add(new SelectOption(finalvalue, finalvalue));
       }       
       return options;
    }*/

    public PageReference addInvoiceLineItemRow(){
        InvoiceItemWrapper invItemWrap = new InvoiceItemWrapper(new Xero_Invoice_Line_Items__c()); 
        
        counter++;
        invItemWrap.counterWrap = counter;
        invItemWrap.inventorySalesPrice = String.valueof(0.00);
        invItemWrap.inventoryNameAsDescription = '';
        invItemWrap.invItemQuantity = String.valueof(0);
        invItemWrap.invItemAmount = String.valueof(0.00); 
        invItemWrapperList.add(invItemWrap);
        System.debug('@@@@invItemWrapperList Size'+counter);
        System.debug('@@@@invItemWrapperList'+invItemWrapperList);
        System.debug('@@@@invItemWrapperList Size'+invItemWrapperList.size()); 
        return null;    
    }
    public void deleteInvoiceLineItemRow(){
    
        Integer param = Integer.valueOf(Apexpages.currentpage().getParameters().get('rowIndex'));
        System.debug('param--->'+param);
        
        for(Integer i = 0; i < invItemWrapperList.size(); i++){
            if(invItemWrapperList[i].counterWrap == param ){
                invItemWrapperList.remove(i);     
            }
        }
        counter --;
    }

    public class InvoiceItemWrapper{
        public Xero_Invoice_Line_Items__c invItem{get;set;}
        public String inventorySalesPrice {get;set;}
        public String invItemAmount {get;set;}
        public String invItemQuantity {get;set;}
        public String inventoryNameAsDescription {get;set;}
        public Integer counterWrap{get;set;}
        
        public InvoiceItemWrapper(Xero_Invoice_Line_Items__c invItem){
            this.invItem = invItem;  
        }
    }
    /*
    public void getInventoryRecords() {
        //InvoiceItemWrapper invItemWrap = new InvoiceItemWrapper(new Invoice_Item__c());
        String inventoryId = ApexPages.currentPage().getParameters().get('inventoryId');

        Product_Master__c invtObjRec = [Select Id, 
                                            Name,
                                            Sales_Price__c
                                            From Product_Master__c where Id =:inventoryId];
                                            /*
        InvoiceItemWrapper invItemWrap = new InvoiceItemWrapper(new Invoice_Item__c(Unit_Price__c = invtObjRec.Sales_Price__c, 
                                                Description__c = invtObjRec.Name,
                                                Quantity__c = 1));

        invItemWrapperList.add(invItemWrap);
        Integer indexNumber = Integer.valueOf(Apexpages.currentpage().getParameters().get('rowIndex'));
        invItemWrapperList[indexNumber-1].inventorySalesPrice = String.valueof(invtObjRec.Sales_Price__c);
        invItemWrapperList[indexNumber-1].inventoryNameAsDescription = invtObjRec.Name;
        invItemWrapperList[indexNumber-1].invItemQuantity = String.valueOf(1);
        invItemWrapperList[indexNumber-1].invItemAmount = String.valueof(invtObjRec.Sales_Price__c * 1);
        System.debug('invItemWrapperList'+invItemWrapperList);

        System.debug(LoggingLevel.INFO,'indexNumber '+indexNumber);
        System.debug(LoggingLevel.INFO,'InventoryID '+inventoryId);
        System.debug(LoggingLevel.INFO,'invtObjRec Record '+invItemWrapperList);
    }*/

    /*
    public void getUpdatedAmount() {
        Integer indexNumber = Integer.valueOf(Apexpages.currentpage().getParameters().get('rowIndex'));


        System.debug(LoggingLevel.INFO,'Quantity '+Integer.valueOf(Apexpages.currentpage().getParameters().get('quantity')));
        System.debug(LoggingLevel.INFO,'SP '+Apexpages.currentpage().getParameters().get('salesprice'));

        if(Apexpages.currentpage().getParameters().get('quantity') != '') {

            invItemWrapperList[indexNumber].invItemAmount = String.valueof(Integer.valueof(invItemWrapperList[indexNumber].inventorySalesPrice) *
                                                                Integer.valueOf(Apexpages.currentpage().getParameters().get('quantity')));

        } else if(Apexpages.currentpage().getParameters().get('salesprice') != '') {
            invItemWrapperList[indexNumber].invItemAmount = String.valueOf(Integer.valueof(Apexpages.currentpage().getParameters().get('salesprice')) *
                                                                Integer.valueof(invItemWrapperList[indexNumber].invItemQuantity));
        } else {
            invItemWrapperList[indexNumber].invItemAmount = String.valueof(0.00);
        }
        System.debug(LoggingLevel.INFO,'invItemWrapperList[indexNumber].invItemAmount '+invItemWrapperList[indexNumber].invItemAmount);
        
        Integer quantity = Integer.valueOf(Apexpages.currentpage().getParameters().get('quantity'));
        Decimal salesPrice = Decimal.valueOf(Apexpages.currentpage().getParameters().get('salesprice'));

        System.debug(LoggingLevel.INFO,'indexNumber '+indexNumber);
        System.debug(LoggingLevel.INFO,'indexNumber Salesprice '+invItemWrapperList[indexNumber].inventorySalesPrice);
        System.debug(LoggingLevel.INFO,'indexNumber invItemQuantity '+invItemWrapperList[indexNumber].invItemQuantity);
        invItemWrapperList[indexNumber].invItemAmount = String.valueOf(Integer.valueOf(invItemWrapperList[indexNumber].inventorySalesPrice) 
                                                    * Integer.valueOf(invItemWrapperList[indexNumber].invItemQuantity));
        
    }*/

   
    public PageReference saveInvoice() {
    
        PageReference pageRef = null;
        Decimal subTotalUpdated = Decimal.valueOf(Apexpages.currentpage().getParameters().get('subtotal'));
        Decimal totalUpdated = Decimal.valueOf(Apexpages.currentpage().getParameters().get('total'));

        System.debug(LoggingLevel.INFO,'subTotal '+subTotal);
        System.debug(LoggingLevel.INFO,'total '+total);

        List<Xero_Invoice_Line_Items__c> invItemsToInsert = new List<Xero_Invoice_Line_Items__c>();
        System.debug(LoggingLevel.INFO,'Invoice to Insert '+invObj);
        System.debug(LoggingLevel.INFO,'Invoice Item Wrapper'+invItemWrapperList);
        Savepoint sp = Database.setSavepoint();

        try {
        
            if(invObj != null) {
                //String currencyCode = invObj.CurrencyIsoCode.substringBefore('-');
                //System.debug('$$$$$currencyCode'+currencyCode);
                //invObj.CurrencyIsoCode = currencyCode;
                invObj.SubTotal__c = subTotalUpdated;
                invObj.Total__c = totalUpdated;
                insert invObj;


                if(invObj.Id != null) {
                    if(invItemWrapperList != null && !invItemWrapperList.isEmpty()) {
                        for(InvoiceItemWrapper item : invItemWrapperList) {
                            Xero_Invoice_Line_Items__c invItemRec = new Xero_Invoice_Line_Items__c();
                            invItemRec.Xero_Revenue_Code__c = item.invItem.Xero_Revenue_Code__c;
                            invItemRec.Description__c =  item.invItem.Description__c;
                            invItemRec.Quantity__c =  Integer.valueOf(item.invItemQuantity);

                            invItemRec.Tax_Rate__c =  item.invItem.Tax_Rate__c;
                            invItemRec.UnitAmount__c =  Integer.valueOf(item.inventorySalesPrice);
                            invItemRec.Account_Code__c = item.invItem.Xero_Revenue_Code__r.Code__c;
                            //invItemRec.Discount__c =  item.invItem.Discount__c;
                            invItemRec.Xero_Invoice__c = invObj.Id;
                            //invItemRec.CurrencyIsoCode = currencyCode;
                            invItemsToInsert.add(invItemRec);
                        }
                        if(invItemsToInsert != null && !invItemsToInsert.isEmpty()) {
                            System.debug(LoggingLevel.INFO,'Invoice Items to Insert '+invItemsToInsert);
                            insert invItemsToInsert;

                            pageRef = new PageReference('/' + invObj.Id); 
                        }
                    }
                    if(invObj.Id != null) {
                        createInvoiceInXero(invObj.Id);
                    }
                }
            }
        } catch (DmlException dmlexcep) {
            Database.rollback(sp);
            System.debug('Error while saving invoice items due to :'+dmlexcep.getMessage());
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, dmlexcep.getMessage()));
            pageRef = null;
            //Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, dmlexcep.getCause()));
            //Apexpages.addMessage(new ApexPages.Message(Apexpages.Severity.Error, dmlexcep.getLineNumber()));
        }            

        return pageRef;
    }

    public static void createInvoiceInXero(Id invObjId) {

        String consumerKey ;
        Xero_Setting__mdt[] xeroSettings = [SELECT MasterLabel, 
                                                QualifiedApiName,
                                                DeveloperName, 
                                                Endpoint_URL__c, 
                                                Xero_Consumer_Key__c
                                                FROM Xero_Setting__mdt];
        Xero_Invoices__c xeroInvc = [Select Id,
                                        Name,
                                        Date__c,
                                        Due_Date__c,
                                        Invoice_Number__c,
                                        Status__c,
                                        SubTotal__c, 
                                        Total__c,
                                        Type__c,
                                        Xero_Contact__r.Xero_Account__c,
                                        Xero_Contact__r.Xero_Contact_Id__c, 
                                        Xero_Contact__c from Xero_Invoices__c Where Id =: invObjId];

        System.debug('$$$$xeroInvc'+xeroInvc);

        List<Xero_Invoice_Line_Items__c> lstInvoiceItem = new list<Xero_Invoice_Line_Items__c>();
        lstInvoiceItem =[Select Id,
                            Name,
                            Account_Code__c,
                            Description__c, 
                            LineItem_Id__c, 
                            Quantity__c, 
                            Tax_Rate__c, 
                            UnitAmount__c,
                            Xero_Invoice__c, 
                            Xero_Revenue_Code__c,
                            Xero_Revenue_Code__r.Code__c
                            From Xero_Invoice_Line_Items__c 
                            Where Xero_Invoice__r.Id  =: xeroInvc.Id];

        System.debug('$$$$lstInvoiceItem'+lstInvoiceItem);


        if(xeroInvc.Xero_Contact__r.Xero_Account__c == 'Chargifi UK') {
            consumerKey = getConsumerKey('UK_Org');
        } else if(xeroInvc.Xero_Contact__r.Xero_Account__c == 'Chargifi US') {
            consumerKey = getConsumerKey('US_Org');
        }
        list<XeroInvoice_Create> lstXeroInvoiceToSend = new list<XeroInvoice_Create>();
            
        XeroInvoice_Create newInvoice = new XeroInvoice_Create();
        
        Date invDate = xeroInvc.Date__c;
        Date payDate = xeroInvc.Due_Date__c;

        
        Datetime dt = datetime.newInstance(invDate.year(), invDate.month(),invDate.day());
        newInvoice.Date1 = datetime.newInstance(invDate.year(), invDate.month(),invDate.day()).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss');
        newInvoice.DueDate = datetime.newInstance(payDate.year(), payDate.month(),payDate.day()).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss');
        
        newInvoice.Type = xeroInvc.Type__c;
        //newInvoice.LineAmountTypes = xeroInvc.Line_Amount_Type__c;
        //newInvoice.CurrencyCode = xeroInvc.CurrencyISOCode;
        newInvoice.Status = xeroInvc.Status__c;
        //newInvoice.DueDate = xeroInvc.Due_Date__c;

        System.debug('$$$$xeroInvc.Xero_Contact__r.Xero_Contact_Id__c'+xeroInvc.Xero_Contact__r.Xero_Contact_Id__c);
        XeroContact_Create newContact = new XeroContact_Create(); 
        newContact.ContactID = xeroInvc.Xero_Contact__r.Xero_Contact_Id__c;
        
        
        newInvoice.Contact = newContact;


        List<XeroInvoice_Create.LineItem> lstInvoicelineItem = new List<XeroInvoice_Create.LineItem>();

        for(Xero_Invoice_Line_Items__c invoiceLineitemForVar : lstInvoiceItem){
            XeroInvoice_Create.LineItem lineItemVar = new XeroInvoice_Create.LineItem();
            
            lineItemVar.Name = invoiceLineitemForVar.Name;
            lineItemVar.IsSold = true;
            lineItemVar.Description = invoiceLineitemForVar.Description__c;
            lineItemVar.UnitAmount = invoiceLineitemForVar.UnitAmount__c;
            lineItemVar.Quantity = invoiceLineitemForVar.Quantity__c;
            //lineItemVar.TaxAmount = invoiceLineitemForVar.Tax__c;
            //lineItemVar.DiscountRate=invoiceLineitemForVar.Discount__c;
            lineItemVar.AccountCode = invoiceLineitemForVar.Xero_Revenue_Code__r.Code__c;
            //lineItemVar.Code = invoiceLineitemForVar.Product_Code__c;
            //lineItemVar.ItemCode = invoiceLineitemForVar.Product_Code__c;
            lstInvoicelineItem.add(lineItemVar);
        }
        newInvoice.LineItems = lstInvoicelineItem;
        System.debug('$$$$consumerKey'+consumerKey);
        System.debug('$$$$newInvoice'+newInvoice);
        lstXeroInvoiceToSend.add(newInvoice);
            
        String xmlInvoiceString = XeroXmlUtility.serialize(lstXeroInvoiceToSend[0], 'Invoice');
        xmlInvoiceString = xmlInvoiceString.replace('Date1','Date');
        System.debug('XML Invoice'+xmlInvoiceString);

        if(!lstInvoicelineItem.isEmpty()) {
            createCalloutToXero(xmlInvoiceString, xeroInvc.Id,consumerKey);
        }
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

    @Future(callout=true)
    public static void createCalloutToXero(string xmlInvoiceString,
                                                Id invoiceIdToSync,
                                                String consumerKey) {
        try { 

            Xero_Invoices__c invoiceToUdpateInSF = new Xero_Invoices__c();
            invoiceToUdpateInSF.Id = invoiceIdToSync;

            System.debug('XML Invoice'+xmlInvoiceString);
            // Send Invoice to Xero
            XeroInvoice_Create createdInvoice = XeroAccountingAPI.createInvoice(xmlInvoiceString,consumerKey);
            System.debug('Invoice Response-->'+createdInvoice);

            invoiceToUdpateInSF.Xero_Invoice_Id__c = createdInvoice.InvoiceId;
            invoiceToUdpateInSF.Invoice_Number__c = createdInvoice.InvoiceNumber;

            update invoiceToUdpateInSF;
            
        } catch(Exception e) {
            // If logging enabled, output the Exception
            System.debug(LoggingLevel.INFO, 'Exception1: ' + e.getTypeName());
            System.debug(LoggingLevel.INFO, 'Exception2: ' + e.getLineNumber());
            System.debug(LoggingLevel.INFO, 'Exception3: ' + e.getCause());
            System.debug(LoggingLevel.INFO, 'Exception4: ' + e.getMessage());
            System.debug(LoggingLevel.INFO, 'Exception5: ' + e.getStackTraceString());
        }

    }
    
}