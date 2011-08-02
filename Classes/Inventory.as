package Classes
{
	[Bindable]
	public class Inventory
	{
		public var TOTAL_GUNS:Number;
		public var LONG_GUNS:Number;
		public var HAND_GUNS:Number;
		public var ROUGH_RIDERS:Number;
		public var DEALER_ID:Number;
		public var ATTENDANCE_ID:Number;
		
		public function Inventory()
		{
			this.TOTAL_GUNS = 0;
			this.LONG_GUNS  = 0;
			this.HAND_GUNS = 0;
			this.ROUGH_RIDERS = 0;
			this.DEALER_ID = 0;
			this.ATTENDANCE_ID = 0;
		}  
		public function fill(item:Object):void {
			for (var val:String in item) {
				trace("processing " + item.val);
				  this[val] = item.val;
			}
		}
	}
}