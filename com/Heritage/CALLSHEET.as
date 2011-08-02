package com.Heritage
{

    [RemoteClass(alias="com.Heritage.CALLSHEET")]
    [Bindable]
    public class CALLSHEET
    {
        public var ID:Number = 0;

        public var SALESGROUP:Number = 0;

        public var SALESREP:Number = 0;

        public var VISIT_DATE:Date = null;

        public var PURCHASE_GROUP:Number = 0;

        public var DEALER_ID:Number = 0;

        public var STOCKING_DEALER:String = "";

        public var ORDER_TAKEN:String = "";

        public var FOLLOWUP_DATE:Date = null;

        public var DISPLAY_REVOLVERS:String = "";

        public var DISPLAY_LEATHER:String = "";

        public var DISPLAY_GRIP:String = "";

        public var REVOLVERS_DISPLAYED:String = "";

        public var LEATHER_DISPLAYED:String = "";

        public var GRIPS_DISPLAYED:String = "";

        public var COMMENTS:String = "";

        public function CALLSHEET()
        {
        }
    }
}