package com.metrobg.Classes
{
	[Bindable]
	public class RepairCode
	{
	  public var id:Number;
	  public var code:String;	  	
	  public var description:String;
	  public var amount:Number;
	 
		 
		public function RepairCode(obj:Object=null)
		{
			if (obj != null)
			{
				fill(obj);
			}
		}
		
		
		
	
		
		public function fill(obj:Object):void 
		{
			this.id = obj.id;
			this.code = obj.code;
			this.description = obj.description;
			this.amount = obj.amount
			
		}
		
		public function toString():String {
			var result:String;
			result = this.code + " " + this.description + " " +this.amount;
			return result;
		}
	}
}