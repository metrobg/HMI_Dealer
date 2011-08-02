package Classes
{

    [Bindable]
    public class Group
    {
        public var DEALER_ID:Number;

        public var GROUP_ID:Number;

        public var CUSTOMER_NUMBER:String;

        public var GROUP_NAME:String;

        public function Group()
        {
            this.DEALER_ID = 0;
            this.GROUP_ID = 0;
            this.CUSTOMER_NUMBER = "0";
            this.GROUP_NAME = "";
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