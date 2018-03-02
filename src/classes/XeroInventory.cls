public with sharing class XeroInventory {
	public Items[] Items;
	public string ProviderName;
	public class Items {
		public String ItemID;	//161c3410-46d0-42b6-aab9-5c303847cabd
		public String Code;	//141
		public String Description;	//Chargifi Solution
		//public cls_PurchaseDetails PurchaseDetails;
		public SalesDetails SalesDetails;
		public String Name;	//Chargifi Solution
		public boolean IsTrackedAsInventory;
		public boolean IsSold;
		public boolean IsPurchased;
		public Integer QuantityOnHand;
	}

	public class SalesDetails {
		public Decimal UnitPrice;	//100
		public String AccountCode;	//205
		public String TaxType;	//OUTPUT2
	}
}