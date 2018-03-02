public with sharing class XeroPayment {
	public Payments[] Payments;

	public class Payments {
		public String PaymentID;	//ab1b7a77-d9aa-4837-afd0-db8cfb8ddad1
		public String Date1;	///Date(1519689600000+0000)/
		public Double Amount;	//20611.2
		public String Reference;	//545454
		public InvoiceDetails Invoice;
	}

	public class InvoiceDetails {
		public String Status;	//PAID
		public String InvoiceID;
		public Integer AmountDue;	//0
		public Double AmountPaid;	//20611.2
	}

}