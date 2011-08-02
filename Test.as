// ActionScript file
/*
   2/21/2009	1.1.3 modified the DealerUpdateWindow by changing the action of the
   action buttons Add Delete and Update.

   7/12/2009	added function scrollAndSelect to better handle scorlling to updated record after saving.

   11/9/2009	added additional entry "Dist Promo" to the source combo box component
   11/18/2009	disabled the update inventory button in the dealer update window if the security level lt 3
   3/3/2011		1.4.0 added the ability to select the show year from the dealer update window.
   3/17/2011 	1.5.2	Added ability to process Canadian Dealers. Changed state combo to VACombo.
   4/14/2011 	1.7.0 added a new update window which allows the user to maintain the dealers
   sales agency as well as the buying group or distributor
   4/21/2011		1.81 added additional field to the dealer record HMI_ID.
   5/05/2011	Reworked to now use validated components.
   6/3/2011     2.3.1 modified so that loading grid does not return an array ofDealer Objects but
   instead an array collection of the fields needed for the grid.
   upon selection of a dealer another query is run to get the Dealer Object and populate the from.

   import com.metrobg.Icons.Images;
 */
[Bindable]
public var version:String = "2.3.1";
import Classes.Inventory;
import Classes.ModuleHandlerClass;
import ascb.util.*;
import com.Heritage.DEALER;
import com.ace.DBTools;
import com.ace.Input.Utilities;
import flash.events.Event;
import flash.events.MouseEvent;
import mx.collections.ArrayCollection;
import mx.collections.IViewCursor;
import mx.controls.Alert;
import mx.events.CloseEvent;
import mx.events.MenuEvent;
import mx.events.ValidationResultEvent;
import mx.managers.PopUpManager;
import mx.printing.*;
import mx.rpc.events.*;
import mx.rpc.remoting.mxml.RemoteObject;
import com.metrobg.Icons.Images;

public var dealerUpdateWindow:DealerUpdateWindow;

public var agencyUpdateWindow:DealerUpdateWindowII;

[Bindable]
public var action:String = "";

[Bindable]
public var dealerRO:DEALER;

public var acDealerWrapper:ArrayCollection;

[Bindable]
public var inventory:Inventory;

public var vResult:ValidationResultEvent;

private var moduleHandlerClass:ModuleHandlerClass;

private var lastSearchWasByName:Boolean = false;

[Bindable]
private var lookupValue:String = "";

[Bindable]
private var random:Number;

[Bindable]
private var vshow_id:Number;

[Bindable]
private var vdate_attended:String;

private var vshowKey:String = "0";

private var vshowMode:String = "Add";

private var showAC:ArrayCollection;

[Bindable]
public var DealershowAC:ArrayCollection;

private var inventoryAC:ArrayCollection;

private var showWindowOpen:Boolean = false;

[Bindable]
private var generalAC:ArrayCollection;

public var lastEditRecord:Number = 0;

public var security:Number;

public var newDealer:Boolean = false;

public var stateAC:ArrayCollection;

private var dbTools:DBTools;

private function buttonHandler(event:MouseEvent):void
{
    switch (event.currentTarget.id)
    {
        case "btn_Add":
            clearFields();
            this.action = "Add";
            disableButtons(false);
            NAME.setFocus();
            HMI_ID.text = "0";
            dealerRO = new DEALER();
            newDealer = true;
            break;
        case "btn_Save":
            saveRecord(event);
            break;
        case "btn_Delete":
            if (dealerRO != null)
            {
                saveRecord(event);
            }
            break;
        //saveRecord(event);
        /*  Alert.show("Delete not Allowed", "Sorry");
         break; */
        case "btn_Cancel":
            cancelUpdate();
            break;
    }
}

private function init():void
{
    generalAC = new ArrayCollection();
    showAC = new ArrayCollection();
    DealershowAC = new ArrayCollection();
    inventory = new Inventory();
    dealerRO = new DEALER;
    this.disableButtons(true); // disable save and delete buttons
    moveToFront();
    superpanel1.title += " ver: " + version;
    focusManager.setFocus(state_cb);
    this.x = (parentApplication.width - this.width) / 2
    security = this.parentApplication.security;
    // moduleHandlerClass = new ModuleHandlerClass(this);
    stateAC = new ArrayCollection();
    lcl.loadStates();
    SOURCE.dataProvider = sourceList;
    acDealerWrapper = new ArrayCollection();
}

private function showUpdateWindow(event:MouseEvent):void
{
    if (dealerGrid.selectedIndex < 0)
    {
        return;
    }
    if (event.currentTarget.id == "btn_Agency")
    {
        agencyUpdateWindow = DealerUpdateWindowII(PopUpManager.createPopUp(this, DealerUpdateWindowII, true));
        agencyUpdateWindow.showCloseButton = true;
        agencyUpdateWindow.addEventListener(CloseEvent.CLOSE, AgencycloseHandler);
        agencyUpdateWindow.currentDealer = dealerRO;
        // agencyUpdateWindow.currentDealer = dealerRO;
        showWindowOpen = true;
    }
    if (event.currentTarget.id == "btn_Update")
    {
        dealerUpdateWindow = DealerUpdateWindow(PopUpManager.createPopUp(this, DealerUpdateWindow, true));
        dealerUpdateWindow.showCloseButton = true;
        dealerUpdateWindow.addEventListener(CloseEvent.CLOSE, closeHandler);
        dealerUpdateWindow.currentDealer = dealerRO;
        showWindowOpen = true;
        dealerUpdateWindow.security = security;
    }
}

private function cloneArrayCollection(acIn:ArrayCollection, acOut:ArrayCollection):ArrayCollection
{
    //var acTemp:ArrayCollection = new ArrayCollection;
    acOut.removeAll();
    for each (var item:Object in acIn)
    {
        acOut.addItem(item);
    }
    acOut.refresh();
    return acOut;
}

//  window close handler
private function closeHandler(event:CloseEvent):void
{
    cloneArrayCollection(event.target.showAC, DealershowAC);
    PopUpManager.removePopUp(dealerUpdateWindow);
    showWindowOpen = false;
    if (dealerUpdateWindow.refreshParent) // show item added or stock updated
        this.loadDealerShow.send();
    return;
}

private function AgencycloseHandler(event:CloseEvent):void
{
    PopUpManager.removePopUp(agencyUpdateWindow);
}

private function saveRecord(event:MouseEvent):void
{
    if (event.currentTarget.id == "btn_Delete")
    {
        Alert.show("Delete Dealer: " + dealerRO.NAME, "Delete Record", Alert.NO | Alert.YES, null, deleteConfirmed);
        return;
    }
    dbTools = new DBTools();
    if (Utilities.validateAll(update_pnl))
    {
        if (!newDealer) // must be doing an update
        {
            dbTools.buildUpdateRecord(acDealerWrapper, 0, update_pnl, "");
            if (dbTools.updateFields.length > 0)
            {
                var vdealer:DEALER = new DEALER();
                vdealer = dbTools.acUpdateRecord[0] as DEALER;
                saveDealer(vdealer);
            }
            else
            {
                Alert.show("Nothing to Update", "Nothing to do");
            }
        }
        else
        {
            //acDealerWrapper.removeAll();
            if (acDealerWrapper.length > 0)
            {
                acDealerWrapper.removeAll();
            }
            acDealerWrapper.addItem(dealerRO);
            dbTools.buildUpdateRecord(acDealerWrapper, 0, update_pnl, "");
            dealerRO = dbTools.acUpdateRecord[0] as DEALER;
            saveDealer(dealerRO);
        }
    }
    else
    {
        Alert.show("Please correct fields outlined in Red", "Errors on Form");
        return;
    }
}

private function deleteConfirmed(event:CloseEvent):void
{
    if (event.detail == Alert.YES)
    {
        deleteRecord();
    }
    else
    {
        Alert.show("Delete Cancelled", "Cancel");
        action = "Update";
    }
}

private function deleteRecord():void
{
    var csg:RemoteObject = new RemoteObject();
    csg.destination = "ColdFusion";
    csg.source = "com.Heritage.DEALERGateway";
    csg.addEventListener("result", onServiceDataReady);
    csg.addEventListener("fault", faultHandler);
    csg.deleteDealerById(dealerRO.ID);
    action = "Delete";
    //saveDealerRecord();
}

private function cancelUpdate():void
{
    clearFields();
    action = "Update";
    disableButtons(true);
}

private function makeRandom():Number
{
    var rn:Number;
    rn = NumberUtilities.getUnique();
    return rn;
}

/*
   private function preLoadGrid():void
   {
   if (state_cb.selectedIndex != 0)
   {
   action = "";
   this.setLastSearchWasByName(false);
   this.loadGrid.send();
   // getDealerList.ListDealersByState();
   }
   else
   {
   mx.controls.Alert.show("Please select a state", "Stop");
   }
   }
 */
private function getDealerRecord():void
{
    if (dealerGrid.selectedIndex < 0)
        return;
    var csg:RemoteObject = new RemoteObject();
    csg.destination = "ColdFusion";
    csg.showBusyCursor = true;
    csg.source = "com.Heritage.DEALERGateway";
    csg.addEventListener("result", onServiceDataReady);
    csg.addEventListener("fault", faultHandler);
    csg.getDealerById(dealerGrid.selectedItem.ID);
}

private function populateDealerForm(value:DEALER = null):void
{
    focusManager.setFocus(NAME);
    if (dealerGrid.selectedIndex < 0)
        return;
    dbTools = new DBTools();
    acDealerWrapper = new ArrayCollection();
    if (value == null)
    {
        dealerRO = new DEALER();
        dealerRO = dealerGrid.selectedItem as DEALER;
        acDealerWrapper.addItem(dealerRO);
    }
    else
    {
        acDealerWrapper.addItem(value);
    }
    dbTools.loadFieldData(acDealerWrapper, 0, update_pnl, "");
    this.action = "Update";
    newDealer = false;
    this.disableButtons(false);
    this.lastEditRecord = dealerGrid.selectedIndex;
    this.vid.text = String(dealerRO.ID)
    loadDealerShow.send();
}

/*
   private function lookupName():void
   {
   if (search_fld.text.length > 2)
   {
   setLastSearchWasByName(true);
   action = "";
   state_cb.selectedIndex = 0;
   lookupDealer.send();
   }
   else
   {
   Alert.show("Dealer lookup requires at least 3 characters", "Stop");
   }
 } */
private function clearFields():void
{
    this.vid.text = String(9999);
    this.NAME.text = "";
    this.ADDRESS.text = "";
    this.CITY.text = "";
    this.STATE.selectedIndex = 0;
    this.ZIP.text = "";
    this.PHONE.text = "";
    this.EMAIL.text = "";
    this.URL.text = "";
    this.SOURCE.selectedIndex = 0;
    this.LOCATOR.selected = false;
    // show_cnvs.visible = false;
    this.CONTACT.text = "";
    this.HMI_ID.text = "0";
    this.showGrid.dataProvider = null;
    lastEditRecord = 0;
    this.FFL_EXPIRY.text = '';
    this.FFL_NUMBER.text = '';
}

private function getResultOk(r:Number, evt:Event):void
{
    var recordCount:Number;
    switch (r)
    {
        /*  case 1:
           disableButtons(true);
           if (loadGrid.lastResult.dealerlist.recordcount == "0")
           {
           generalAC.removeAll();
           }
           if (loadGrid.lastResult.dealerlist.recordcount == "1")
           {
           generalAC.removeAll();
           // generalAC.addItemAt(makeOneDealer(loadGrid.lastResult.dealerlist.record), 0);
           generalAC.refresh();
           dealerGrid.dataProvider = generalAC;
           }
           else
           {
           generalAC = loadGrid.lastResult.dealerlist.record;
           dealerGrid.dataProvider = generalAC;
           if (this.action == "Update")
           {
           scrollAndSelect();
           }
           }
           dealer_pnl.status = loadGrid.lastResult.dealerlist.recordcount + " Record(s) found";
           clearFields();
           setLastSearchWasByName(false);
           break;
           case 3:
           if (this.addDealer.lastResult.root.status == "1")
           {
           this.loadGrid.send();
           clearFields();
           //Alert.show("Record Added","Success");
           }
           else
           {
           Alert.show("Problem Adding Record", "Update Failed");
           }
           break;
           case 4:
           if (this.deleteDealer.lastResult.root.status == "1")
           {
           this.loadGrid.send();
           clearFields();
           action = "Update";
           Alert.show("Record Deleted", "Success");
           }
           else
           {
           Alert.show("Problem Deleting Record", "Delete Failed");
           }
           break;
           case 5: // lookupDealer service call
           disableButtons(true);
           if (lookupDealer.lastResult.dealerlist.recordcount == "1")
           {
           generalAC.removeAll();
           //  generalAC.addItemAt(makeOneDealer(lookupDealer.lastResult.dealerlist.record), 0);
           generalAC.refresh();
           dealerGrid.dataProvider = generalAC;
           }
           else
           {
           generalAC = lookupDealer.lastResult.dealerlist.record;
           dealerGrid.dataProvider = generalAC;
           }
           dealer_pnl.status = lookupDealer.lastResult.dealerlist.recordcount + " Record(s) found";
           clearFields();
           setLastSearchWasByName(true);
         break; */
        case 6:
            //showAC = loadShow.lastResult.showlist.record;
            // vshow.dataProvider = showAC;
            break;
        case 7:
            DealershowAC.removeAll();
            recordCount = Number(loadDealerShow.lastResult.showlist.recordcount);
            if (recordCount > 0)
            {
                if (recordCount == 1)
                {
                    DealershowAC.addItem({ id: loadDealerShow.lastResult.showlist.show.id, location: loadDealerShow.lastResult.showlist.show.location, date: loadDealerShow.lastResult.showlist.show.date, dealer_id: loadDealerShow.lastResult.showlist.show.dealer_id, total_guns: loadDealerShow.lastResult.showlist.show.total_guns, long_guns: loadDealerShow.lastResult.showlist.show.long_guns, hand_guns: loadDealerShow.lastResult.showlist.show.hand_guns, rough_riders: loadDealerShow.lastResult.showlist.show.rough_riders, dealer_show: loadDealerShow.lastResult.showlist.show.attendance_id });
                    DealershowAC.refresh();
                    showGrid.dataProvider = DealershowAC;
                }
                else
                {
                    DealershowAC = loadDealerShow.lastResult.showlist.show;
                    showGrid.dataProvider = DealershowAC;
                }
            }
            /* if(this.showWindowOpen) // update the dealer show list in the popup window
             this.dealerUpdateWindow.AC1 = this.DealershowAC; */
            break;
    }
}

private function displayStock():void
{
    if (this.showGrid.selectedIndex < 0)
    {
        return;
    }
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

private function disableButtons(value:Boolean):void
{
    btn_Save.enabled = !value;
    btn_Delete.enabled = !value;
}

private function enterKeyHandler(event:Event):void
{
    if (event.type == "enter")
    {
        lookupNameRO(event);
    }
    else
    {
        return;
    }
}

private function formatDealerPhone(item:Object, column:DataGridColumn):String
{
    var ph:String;
    if (item.PHONE != null)
    {
        ph = pf.format(item.PHONE);
    }
    return ph;
}

private function closeThisModule():void
{
    parentApplication.removeModule(this.owner.name);
}

private function setLastSearchWasByName(value:Boolean):void
{
    if (value)
    {
        lastSearchWasByName = true;
        lookupValue = search_fld.text;
        state_cb.selectedIndex = 0;
    }
    else
    {
        lastSearchWasByName = false;
        lookupValue = state_cb.selectedItem.DATA;
        search_fld.text = '';
    }
}

public function menuItemSelected(event:MenuEvent):void
{
    var action:Number = Number(event.item.@value);
    switch (action)
    {
        case 0: // mainview menu item
            closeThisModule();
            //variables.currentModule.unloadModule();
            break;
        case 310:
            break;
        case 20:
            break;
        case 10:
            var strNewModule:String = moduleHandlerClass.getNextModule();
            trace("module " + strNewModule);
            if (strNewModule != null)
            {
                trace("action: " + event.item.@action + " " + strNewModule);
                moduleHandlerClass.addModule(event.item.@action, this[strNewModule]);
            }
            break;
        case 41:
            break;
        case -2: // mainview menu item
            navigateToURL(new URLRequest("http://www.goodlifecredit.com/admin17/Docs/index.cfm"));
            break;
        case -1: // logout menuitem
            //menu_pm.visible = false;	   			   			   			   			   			   			   			   			   			
            break;
        default:
            Alert.show("Unknown menu selection", "Error");
    }
/* var action:String = "styles/" + event.item.@value;
 changeCSS(event.item.@value); */
}

private function DealerList_result(evt:ResultEvent):void
{
    var tAC:ArrayCollection;
    tAC = ArrayCollection(evt.result);
    // this.dealerGrid.dataProvider = evt.result;  
    dealerGrid.dataProvider = tAC;
    disableButtons(true);
    dealer_pnl.status = tAC.length + " Record(s) found";
    clearFields();
    //setLastSearchWasByName(true);		              
}

private function DealerList_fault(evt:FaultEvent):void
{
    Alert.show("Error while loading Data", "Stop");
}

private function showsAttended_result(evt:ResultEvent):void
{
    this.DealershowAC = ArrayCollection(evt.result);
    showGrid.dataProvider = DealershowAC;
}

private function showsAttended_fault(evt:FaultEvent):void
{
    Alert.show(evt.type.toString());
}

private function scrollAndSelect():void
{
    var cursor:IViewCursor;
    var idx:int;
    cursor = generalAC.createCursor();
    while (!cursor.afterLast)
    {
        cursor.moveNext();
        if (cursor.current.ID == dealerRO.ID)
        {
            idx = generalAC.getItemIndex(cursor.current);
            dealerGrid.scrollToIndex(idx);
            dealerGrid.selectedItem = cursor.current;
            break
        }
    }
}

private function fillComboBox_result(evt:ResultEvent):void
{
    var tmpAC:ArrayCollection;
    tmpAC = new ArrayCollection();
    stateAC = ArrayCollection(evt.result);
    for (var i:int = 0; i < stateAC.length; i++)
    {
        if (stateAC[i].FLAG == "Y")
            tmpAC.addItem(stateAC[i]);
    }
    tmpAC.addItemAt({ LABEL: "State/Country", DATA: 0 }, 0);
    tmpAC.addItemAt({ LABEL: "Canada", DATA: "99" }, 1);
    state_cb.dataProvider = tmpAC;
    state_cb.labelField = "LABEL";
    stateAC.addItemAt({ LABEL: "State/Province", DATA: 0 }, 0);
    STATE.dataProvider = stateAC;
}

private function fillComboBox_fault(evt:FaultEvent):void
{
    Alert.show("Error while loading State Data", "Stop");
}

private function lookupNameRO(event:Event):void
{
    switch (event.currentTarget.id)
    {
        case "btn_Find":
            if (search_fld.text.length > 2)
            {
                state_cb.selectedIndex = 0;
                loadDealerRO(search_fld.text);
            }
            else
            {
                Alert.show("Dealer lookup requires at least 3 characters", "Stop");
            }
            break;
        case "state_cb":
            if (state_cb.selectedIndex != 0)
            {
                lookupValue = state_cb.selectedItem.DATA;
                loadDealerRO(state_cb.selectedItem.DATA);
            }
            else
            {
                mx.controls.Alert.show("Please select a state", "Stop");
            }
            break;
    }
}

public function loadDealerRO(value:String):void
{
    state_cb.selectedIndex = 0;
    var csg:RemoteObject = new RemoteObject();
    csg.destination = "ColdFusion";
    csg.showBusyCursor = true;
    csg.source = "com.Heritage.DEALERGateway";
    csg.addEventListener("result", onServiceDataReady);
    csg.addEventListener("fault", faultHandler);
    csg.loadDealerGrid(value);
}

private function saveDealer(value:DEALER):void
{
    var csg:RemoteObject = new RemoteObject();
    csg.destination = "ColdFusion";
    csg.source = "com.Heritage.DEALERGateway";
    csg.addEventListener("result", onServiceDataReady);
    csg.addEventListener("fault", faultHandler);
    csg.saveDealer(value);
}

public function onServiceDataReady(event:ResultEvent):void
{
    var act:Object = event.token;
    switch (act.message.operation)
    {
        case "deleteDealerById":
            if (lastEditRecord >= 0)
            {
                generalAC.removeItemAt(lastEditRecord);
                lastEditRecord = -1;
                dealerRO = null;
                action = "";
                clearFields();
            }
            break;
        case "getAllDealers":
            generalAC = new ArrayCollection(act.result as Array);
            dealerGrid.dataProvider = generalAC;
            dealer_pnl.status = generalAC.length + " Record(s) found";
            clearFields();
            setLastSearchWasByName(false);
            break;
        case "loadDealerGrid":
            // generalAC = new ArrayCollection(act.result as Array);
            generalAC = act.result;
            dealerGrid.dataProvider = generalAC;
            dealer_pnl.status = generalAC.length + " Record(s) found";
            clearFields();
            setLastSearchWasByName(false);
            break;
        case "getDealerById":
            // generalAC = new ArrayCollection(act.result as Array);
            dealerRO = new DEALER();
            dealerRO = act.result as DEALER;
            populateDealerForm(dealerRO);
            break;
        case "saveDealer":
            newDealer = false;
            if (action == "Update")
            {
                Alert.show("Record Updated", "Success");
                dealerRO = new DEALER();
                dealerRO = act.result as DEALER;
                generalAC.removeItemAt(lastEditRecord);
                generalAC.addItemAt(dealerRO, 0);
            }
            else if (action == "Add")
            {
                Alert.show("Record Added", "Success");
                dealerRO = act.result as DEALER;
                generalAC.addItemAt(dealerRO, 0);
                generalAC.refresh();
                dealerGrid.selectedIndex = 0;
                populateDealerForm(dealerRO);
            }
            //scrollAndSelect();
            break;
    }
}

private function faultHandler(event:mx.rpc.events.FaultEvent):void
{
    Alert.show(event.fault.faultString);
}