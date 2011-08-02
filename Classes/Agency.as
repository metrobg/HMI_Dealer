package Classes
{

    [Bindable]
    public class Agency
    {
        public var DEALER_ID:Number;

        public var REP_ID:Number;

        public var AGENCY_ID:Number;

        public function Agency()
        {
            this.DEALER_ID = 0;
            this.REP_ID = 0;
            this.AGENCY_ID = 0;
        }

        public function fill(item:Object):void
        {
            for (var val:String in item)
            {
                trace("processing " + item.val);
                this[val] = item.val;
            }
        }
    }
}