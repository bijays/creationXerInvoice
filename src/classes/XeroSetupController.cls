global without sharing class XeroSetupController {

	public List<String> xeroOrganisationNames {get;set;}

	public XeroSetupController() {

		xeroOrganisationNames = new List<String> ();
		List<XeroOrganisation> xeroOrgs = XeroAccountingAPI.getOrganisations();

		try {
			if(xeroOrgs != null && !xeroOrgs.isEmpty()) {
				for(XeroOrganisation xeroOrg : xeroOrgs) {
					xeroOrganisationNames.add(xeroOrg.Organisations[0].Name);
				}

			} else {
				Apexpages.addMessage(new ApexPages.Message(Apexpages.severity.Info, 'Currently there no Xero Accounts Linked'));
			}
		} catch(Exception e) {
			 // If logging enabled, output the Exception
            System.debug(LoggingLevel.INFO, 'Exception: ' + e.getTypeName());
            Apexpages.addMessage(new ApexPages.Message(Apexpages.severity.error, e.getMessage()));
		}
	}

	public void importRevenueCodes() {

		try {
			List<XeroRevenueCodes> xeroRevCodes = XeroAccountingAPI.getXeroRevenueCodes();
			List<Xero_Revenue_Code__c> revenueCodeToInsert = new List<Xero_Revenue_Code__c>();

			if(xeroRevCodes != null && !xeroRevCodes.isEmpty()) {
				for(XeroRevenueCodes xeroWrap : xeroRevCodes) {
					System.debug(LoggingLevel.INFO, 'xeroWrap: ' + xeroWrap);
					System.debug(LoggingLevel.INFO, 'xeroWrap.Accounts: ' + xeroWrap.Accounts);
					for(XeroRevenueCodes.Accounts revenCodeDetail : xeroWrap.Accounts) {

						Xero_Revenue_Code__c rcRec = new Xero_Revenue_Code__c();
						rcRec.Code__c = revenCodeDetail.code;
						rcRec.Name__c = revenCodeDetail.Name;
						rcRec.Type__c = revenCodeDetail.Type;
						rcRec.AccountId__c = revenCodeDetail.AccountId;

						if(xeroWrap.ProviderName == 'USA') {
							rcRec.Xero_Account__c = 'Chargifi USA';
						} else if(xeroWrap.ProviderName == 'UK') {
							rcRec.Xero_Account__c = 'Chargifi UK';
						}
						rcRec.Composite_Key__c = (revenCodeDetail.code + rcRec.Xero_Account__c).deleteWhitespace();
						revenueCodeToInsert.add(rcRec);
					}
				}

				if(revenueCodeToInsert != null && !revenueCodeToInsert.isEmpty()) {
					System.debug(LoggingLevel.INFO, 'revenueCodeToInsert: ' + revenueCodeToInsert);
					System.debug(LoggingLevel.INFO, 'revenueCodeToInsert: ' + revenueCodeToInsert.size());
					upsert revenueCodeToInsert AccountId__c;
				}
			}
		} catch(Exception e) {
			// If logging enabled, output the Exception
            System.debug(LoggingLevel.INFO, 'Exception: ' + e.getTypeName());
            Apexpages.addMessage(new ApexPages.Message(Apexpages.severity.error, e.getMessage()));
		}
	}

	public void importXeroContacts() {
		try {
			List<XeroContact> xeroContacts = XeroAccountingAPI.getContacts();
			List<Xero_Contact__c> xeroContactObjList = new List<Xero_Contact__c>();



			if(xeroContacts != null && !xeroContacts.isEmpty()) {
				for(XeroContact xeroContact : xeroContacts) {
					for(XeroContact.Contacts conDetails: xeroContact.Contacts) {
						Xero_Contact__c xcRec = new Xero_Contact__c();
						xcRec.Name = conDetails.Name;
						xcRec.FirstName__c = conDetails.FirstName;
						xcRec.Last_Name__c = conDetails.LastName;
						xcRec.EmailAddress__c = conDetails.EmailAddress;
						xcRec.BankAccountDetails__c = conDetails.BankAccountDetails;
						xcRec.Xero_Contact_Id__c = conDetails.ContactID;

						if(xeroContact.ProviderName == 'USA') {
							xcRec.Xero_Account__c = 'Chargifi USA';
						} else if(xeroContact.ProviderName == 'UK') {
							xcRec.Xero_Account__c = 'Chargifi UK';
						}

						xeroContactObjList.add(xcRec);
					}
				}

				if(xeroContactObjList != null && !xeroContactObjList.isEmpty()) {
					System.debug(LoggingLevel.INFO, 'xeroContactObjList: ' + xeroContactObjList);
					System.debug(LoggingLevel.INFO, 'xeroContactObjList size: ' + xeroContactObjList.size());
					upsert xeroContactObjList Xero_Contact_Id__c;
				}
			}
		} catch(Exception e) {
			// If logging enabled, output the Exception
            System.debug(LoggingLevel.INFO, 'Exception: ' + e.getTypeName());
            Apexpages.addMessage(new ApexPages.Message(Apexpages.severity.error, e.getMessage()));
		}
	}

	public void importXeroInvoices() {
		try {

			List<XeroInvoice> xeroInvoices = XeroAccountingAPI.getInvoices();
			List<Xero_Invoices__c> xeroInvoicesToInsert = new List<Xero_Invoices__c>();
			//List<String> xeroContactIds = new List<String>();
			Map<String, Xero_Contact__c> mapContactId = new Map<String, Xero_Contact__c>();
			Set<String> xeroContactIds = new Set<String>();
			List<XeroInvoice.LineItem> lineItems = new List<XeroInvoice.LineItem>();
			Map<Id, List<XeroInvoice.LineItem>> mapInvIdLineItems = new Map<Id, List<XeroInvoice.LineItem>>();

			for(XeroInvoice xInv : xeroInvoices) {
	            System.debug(LoggingLevel.INFO, 'xInv.Invoices: ' + xInv.Invoices);

	            for(XeroInvoice.Invoices inv: xInv.Invoices) {
	                Xero_Invoices__c xInvRec = new Xero_Invoices__c();
	                xInvRec.Amount_Due__c = inv.AmountDue;
	                xInvRec.Amount_Paid__c = inv.AmountPaid;
	                xInvRec.Date__c = Date.valueOf(inv.DateString);
	                /*
	                if(Date.valueOf(inv.DueDateString) != null) {
	                	xInvRec.Due_Date__c = Date.valueOf(inv.DueDateString);
	                }*/
	                
	                xInvRec.Invoice_Number__c = inv.InvoiceNumber;
	                xInvRec.Status__c = inv.Status;
	                xInvRec.SubTotal__c = inv.SubTotal;
	                xInvRec.Total__c = inv.Total;
	                xInvRec.Type__c = inv.Type;
	                xInvRec.Xero_Contact_Id__c = inv.Contact.ContactID;
	                xInvRec.Xero_Invoice_Id__c = inv.InvoiceID;
	                xeroInvoicesToInsert.add(xInvRec);
	                xeroContactIds.add(inv.Contact.ContactID);
	                //lineItems.
	                System.debug(LoggingLevel.INFO, 'inv.Contact.ContactID: ' + inv.Contact.ContactID);
	            }
	        }

			System.debug(LoggingLevel.INFO, 'xeroContactIds: ' + xeroContactIds);
			System.debug(LoggingLevel.INFO, 'xeroInvoicesToInsert: ' + xeroInvoicesToInsert);
			if(xeroInvoicesToInsert != null && !xeroInvoicesToInsert.isEmpty()) {
				System.debug(LoggingLevel.INFO, 'xeroInvoicesToInsert: ' + xeroInvoicesToInsert);
				System.debug(LoggingLevel.INFO, 'xeroInvoicesToInsert size: ' + xeroInvoicesToInsert.size());
				upsert xeroInvoicesToInsert Xero_Invoice_Id__c;
			}
			if(xeroContactIds != null && !xeroContactIds.isEmpty()) {
				for(Xero_Contact__c xcObj : [Select Id,
												Xero_Contact_Id__c
												From Xero_Contact__c
												Where Xero_Contact_Id__c IN :xeroContactIds]) {
					mapContactId.put(xcObj.Xero_Contact_Id__c, xcObj);
				}
			}
			System.debug(LoggingLevel.INFO, 'mapContactId: ' + mapContactId);
			if(xeroInvoicesToInsert != null && !xeroInvoicesToInsert.isEmpty()) {
				System.debug(LoggingLevel.INFO, 'xeroInvoicesToInsert after insert: ' + xeroInvoicesToInsert);

				for(Xero_Invoices__c invRec : xeroInvoicesToInsert) {
					invRec.Xero_Contact__c = mapContactId.get(invRec.Xero_Contact_Id__c).Id;
				}
				System.debug(LoggingLevel.INFO, 'xeroInvoicesToInsert after update: ' + xeroInvoicesToInsert);
				update xeroInvoicesToInsert;
			}
		} catch(Exception e) {
			// If logging enabled, output the Exception
            System.debug(LoggingLevel.INFO, 'Exception: ' + e.getTypeName());
            System.debug(LoggingLevel.INFO, 'Exception: ' + e.getLineNumber());
            System.debug(LoggingLevel.INFO, 'Exception: ' + e.getCause());
            System.debug(LoggingLevel.INFO, 'Exception: ' + e.getMessage());
            Apexpages.addMessage(new ApexPages.Message(Apexpages.severity.error, e.getMessage()));
		}
	}

	public void importXeroInventories() {
		try {

			List<XeroInventory> xeroInventories = XeroAccountingAPI.getInventories();
			List<Product2> xeroInventoriesToInsert = new List<Product2>();
			Set<String> xeroRevenueCompositeKey = new Set<String>();

			//List<String> xeroContactIds = new List<String>();
			Map<String, Xero_Revenue_Code__c> mapRevenueId = new Map<String, Xero_Revenue_Code__c>();
			Set<String> xeroContactIds = new Set<String>();

			for(XeroInventory xInvt : xeroInventories) {
	            System.debug(LoggingLevel.INFO, 'xInvt.Items: ' + xInvt.Items);

	            for(XeroInventory.Items inv: xInvt.Items) {

	            	Product2 xeroProds = new Product2();
	            	xeroProds.Name = inv.Name;
	            	xeroProds.Description = inv.Description;
	            	xeroProds.ProductCode = inv.Code;
	                xeroProds.Xero_Inventory_Id__c = inv.ItemID;
	                xeroProds.Quantity_OnHand__c = inv.QuantityOnHand;
	                xeroProds.Unit_Price__c = inv.SalesDetails.UnitPrice;
	                xeroProds.Xero_Account_Code__c = inv.SalesDetails.AccountCode;
	                xeroProds.IsActive = true;

	                if(xInvt.ProviderName == 'USA') {
						xeroProds.Xero_Account__c = 'Chargifi USA';
						//xeroProds.CurrencyIsoCode = 'USD';
					} else if(xInvt.ProviderName == 'UK') {
						xeroProds.Xero_Account__c = 'Chargifi UK';
						//xeroProds.CurrencyIsoCode = 'GBP';
					}
	                String key = (inv.SalesDetails.AccountCode + xeroProds.Xero_Account__c).deleteWhitespace();
	                xeroProds.Composite_Key__c = key;
	                xeroRevenueCompositeKey.add(key);
	                
	                xeroInventoriesToInsert.add(xeroProds);
	                //.add(inv.Contact.ContactID);
	               // System.debug(LoggingLevel.INFO, 'inv.Contact.ContactID: ' + inv.Contact.ContactID);
	            }
	        }

			System.debug(LoggingLevel.INFO, 'xeroRevenueCompositeKey: ' + xeroRevenueCompositeKey);
			System.debug(LoggingLevel.INFO, 'xeroInvoicesToInsert: ' + xeroInventoriesToInsert);
			
			if(xeroInventoriesToInsert != null && !xeroInventoriesToInsert.isEmpty()) {
				System.debug(LoggingLevel.INFO, 'xeroInventoriesToInsert: ' + xeroInventoriesToInsert);
				System.debug(LoggingLevel.INFO, 'xeroInventoriesToInsert size: ' + xeroInventoriesToInsert.size());
				upsert xeroInventoriesToInsert Xero_Inventory_Id__c;
			}
			if(xeroRevenueCompositeKey != null && !xeroRevenueCompositeKey.isEmpty()) {
				for(Xero_Revenue_Code__c xrObj : [Select Id,
													Composite_Key__c
													From Xero_Revenue_Code__c
													Where Composite_Key__c IN :xeroRevenueCompositeKey]) {
					mapRevenueId.put(xrObj.Composite_Key__c, xrObj);
				}
			}
			System.debug(LoggingLevel.INFO, 'mapRevenueId: ' + mapRevenueId);
			if(xeroInventoriesToInsert != null && !xeroInventoriesToInsert.isEmpty()) {
				System.debug(LoggingLevel.INFO, 'xeroInventoriesToInsert after insert: ' + xeroInventoriesToInsert);

				for(Product2 prodRec : xeroInventoriesToInsert) {
					prodRec.Xero_Revenue_Code__c = mapRevenueId.get(prodRec.Composite_Key__c).Id;
				}
				System.debug(LoggingLevel.INFO, 'xeroInventoriesToInsert after update: ' + xeroInventoriesToInsert);
				update xeroInventoriesToInsert;
			}
		} catch(Exception e) {
			// If logging enabled, output the Exception
            System.debug(LoggingLevel.INFO, 'Exception: ' + e.getTypeName());
            System.debug(LoggingLevel.INFO, 'Exception: ' + e.getLineNumber());
            System.debug(LoggingLevel.INFO, 'Exception: ' + e.getCause());
            System.debug(LoggingLevel.INFO, 'Exception: ' + e.getMessage());
            Apexpages.addMessage(new ApexPages.Message(Apexpages.severity.error, e.getMessage()));
		}
	}

	webservice static String importPaymentForInvoices(String invXeroId) {
	//public void importPaymentForInvoices (String invXeroId) {

		String paymentMessage = '';
		XeroInvoice xeroInvoice;
		String consumerKey;
		List<Xero_Payment__c> xeroPayments = new List<Xero_Payment__c>();

		Xero_Invoices__c xeroInvc = [Select Id,
										Xero_Invoice_Id__c,
										Xero_Account__c,
										Amount_Paid__c,
										Amount_Due__c,
										Status__c
										from Xero_Invoices__c
										Where Xero_Invoice_Id__c =: invXeroId];
		if(xeroInvc.Xero_Account__c == 'Chargifi UK') {
            consumerKey = getConsumerKey('UK_Org');
        } else if(xeroInvc.Xero_Account__c == 'Chargifi US') {
            consumerKey = getConsumerKey('US_Org');
        }
        if(String.isNotBlank(consumerKey)) {
        	xeroInvoice = XeroAccountingAPI.getInvoice(invXeroId, consumerKey);
        }
		//XeroInvoice 
		System.debug('$$$$xeroInvoice'+xeroInvoice);
		for(XeroInvoice.Invoices inv : xeroInvoice.Invoices) {

			xeroInvc.Amount_Paid__c = inv.AmountPaid;
			xeroInvc.Amount_Due__c = inv.AmountDue;
			xeroInvc.Status__c = inv.Status;
			xeroInvc.Amount_Paid__c = inv.AmountPaid;
			xeroInvc.Amount_Paid__c = inv.AmountPaid;

			System.debug('$$$$xeroInvoice'+inv.AmountPaid);
			if(inv.Payments != null && !inv.Payments.isEmpty()) {
				for(XeroInvoice.Payment xeroPayment: inv.Payments) {
					Xero_Payment__c xpRec = new Xero_Payment__c();
					xpRec.Amount__c = xeroPayment.Amount;
					xpRec.Payment_Id__c = xeroPayment.PaymentID;
					xpRec.Reference__c = xeroPayment.Reference;
					//xpRec.Date__c = Date.parse(xeroPayment.Date1);
					System.debug('xeroPayment.Status'+ xeroPayment.Status);
					xpRec.Status__c = xeroPayment.Status;
					xpRec.Xero_Invoice__c = xeroInvc.Id;
					xeroPayments.add(xpRec);
				}
			}

		}

		update xeroInvc;
		System.debug('$$$$xeroInvc'+ xeroInvc);
		if(xeroPayments != null && !xeroPayments.isEmpty()) {
			System.debug('$$$$xeroPayments'+ xeroPayments);
			upsert xeroPayments Payment_Id__c;
			paymentMessage = 'Payment details are updated';

		}

	return paymentMessage;
	}

	

	private static String getConsumerKey (String orgName) {

        Xero_Setting__mdt xeroSetting = [SELECT MasterLabel, 
                                            QualifiedApiName,
                                            DeveloperName, 
                                            Endpoint_URL__c, 
                                            Xero_Consumer_Key__c
                                            FROM Xero_Setting__mdt Where DeveloperName =: orgName];
        return xeroSetting.Xero_Consumer_Key__c;
    }
}