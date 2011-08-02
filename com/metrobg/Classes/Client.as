package com.metrobg.Classes
{
	[Bindable]
	public class Client
	{
		public var id:String;
		public var name:String;
		public var address:String;
		public var suite:String;
		public var city:String;
		public var state:String;
		public var zipcode:String;
		public var phone:String;
	 
	
	public function getClientAsXml():String {
		 var returnString:String = ""; 
		 returnString += "<client>";
         returnString += " <id>" + this.id + "</id>";
         returnString += " <name>" + this.name + "</name>";
         returnString += " <address>" + this.address + "</address>";
         returnString += " <suite>" + this.suite + "</suite>";
         returnString += " <city>"+ this.city + "</city>";
         returnString += " <state>" + this.state + "</state>";
         returnString += " <zipcode>" + this.zipcode + "</zipcode>";
         returnString += " <phone>" + this.phone + "</phone>";
         returnString += "</client>";
         return returnString;
 }
	}
}