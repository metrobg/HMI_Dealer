// ActionScript file
import flash.events.Event;
import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.events.*;
import mx.rpc.events.*;
import mx.rpc.remoting.RemoteObject;

private var lookupValue:String;

private var lookupField:String;

public var acResult:ArrayCollection;

private function init():void
{
    moveToFront();
    acResult = new ArrayCollection();
    lookupField = "SERIALNO";
    lookupValue = "123";
}

private function buttonHandler(event:MouseEvent):void
{
    if ((event.currentTarget.id == "btnFind"))
    {
        if (fldSearch.text.length >= 3)
        {
            lookupValue = fldSearch.text;
            lookupField = searchField.selectedValue.toString();
            lookupRecord();
        }
        else
        {
            Alert.show("Search Field requires at least 3 charachers", "Error");
            return;
        }
    }
}

private function lookupRecord():void
{
    var csg:RemoteObject = new RemoteObject();
    csg.destination = "ColdFusion";
    csg.source = "com.Heritage.WARRANTYGateway";
    csg.addEventListener("result", onServiceDataReady);
    csg.addEventListener("fault", faultHandler);
    csg.loadWarrantyGrid(lookupField, lookupValue);
}

private function searchFieldChanged(event:Event):void
{
    if (event.type == "change")
    {
        lookupField = event.currentTarget.selectedValue;
    }
    else if (event.type == "click")
    {
        lookupField = event.currentTarget.value;
    }
    lookupValue = fldSearch.text;
}

public function onServiceDataReady(event:ResultEvent):void
{
    var act:Object = event.token;
    switch (act.message.operation)
    {
        case "loadWarrantyGrid":
            var acResult:ArrayCollection = act.result;
            dgResult.dataProvider = acResult;
            break;
    }
}

private function faultHandler(event:mx.rpc.events.FaultEvent):void
{
    Alert.show(event.fault.faultString);
}

private function closeModule():void
{
    parentApplication.removeModule(this.owner.name);
}

private function moveToFront():void
{
    // move the shape to the front by moving it to the front-most
    // index (which is always numChildren - 1)
    if (this)
        if (this.owner)
            if (this.owner.name)
                if (parentApplication)
                    parentApplication.setChildIndex(parentApplication.getChildByName(this.owner.name), parentApplication.numChildren - 1);
}