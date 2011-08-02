// ActionScript file
import com.Heritage.CALLSHEET;
import com.ace.DBTools;
import com.ace.Input.Utilities;
import flash.events.MouseEvent;
import flash.net.NetConnection;
import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.controls.dataGridClasses.DataGridColumn;
import mx.managers.CursorManager;
import mx.rpc.events.*;
import mx.rpc.remoting.mxml.RemoteObject;
import mx.events.CloseEvent;
import com.metrobg.Icons.Images;

[Bindable]
public var lookupValue:String;

public var acYesNo:ArrayCollection;

public var acRep:ArrayCollection;

public var acAgency:ArrayCollection;

public var acGroup:ArrayCollection;

public var acDealer:ArrayCollection;

public var acCallHistory:ArrayCollection;

private var dealerID:Number;

private var dealerName:String;

[Bindable]
public var callSheet:CALLSHEET;

public var acCallSheetWrapper:ArrayCollection;

private var dbTools:DBTools;

public var newCallsheet:Boolean = false;

public var cfService:RemoteObject;

public var gateway:NetConnection;

private var gateWayURL:String = "http://milo.metrobg.com/cf/com.Heritage.CALLSHEETGateway.cfc";

[Bindable]
public var mode:String = "Add";

[Bindable]
private var version:String = "1.3.3";

private function init():void
{
    moveToFront();
    acYesNo = new ArrayCollection();
    acYesNo.addItem({ DATA: "", LABEL: "Select" });
    acYesNo.addItem({ DATA: "Y", LABEL: "Yes" });
    acYesNo.addItem({ DATA: "N", LABEL: "No" });
    ORDER_TAKEN.dataProvider = acYesNo;
    ORDER_TAKEN.labelField = "LABEL";
    STOCKING_DEALER.dataProvider = acYesNo;
    STOCKING_DEALER.labelField = "LABEL";
    DISPLAY_REVOLVERS.dataProvider = acYesNo;
    DISPLAY_REVOLVERS.labelField = "LABEL";
    DISPLAY_LEATHER.dataProvider = acYesNo;
    DISPLAY_LEATHER.labelField = "LABEL";
    DISPLAY_GRIP.dataProvider = acYesNo;
    DISPLAY_GRIP.labelField = "LABEL";
    acDealer = new ArrayCollection();
    lcl.loadAgencyCombo();
    lcl.loadPurchaseGroupCombo();
    lcl.loadSalesRepCombo();
    this. /* ********************************************************** */ /* ********************************************************** */ /* ********************************************************** */ /* ********************************************************** */acCallSheetWrapper = new ArrayCollection();
}

private function repLabelFunction(item:Object):String
{
    var result:String;
    result = item["REP_FNAME"] + ' ' + item["REP_LNAME"];
    return result;
}

private function filterAgency():void
{
    toggleFilter();
    SALESREP.selectedIndex = 0;
}

private function filterPackets():void
{
}

private function toggleFilter():void
{
    if (SALESGROUP.selectedIndex > 0)
    {
        acRep.filterFunction = processFilter;
    }
    else
    {
        acRep.filterFunction = null;
    }
    acRep.refresh();
}

private function processFilter(item:Object):Boolean
{
    if (SALESGROUP.selectedItem.AGENCY_ID == item.REP_SALESGROUP)
    {
        return true;
    }
    else
    {
        return false;
    }
}

private function preLoadGrid():void
{
    cnv_CallSheet.enabled = false;
    if (cbx_state.selectedIndex != 0)
    {
        lookupValue = cbx_state.selectedItem.data;
        lcl.loadDealerAndRep(lookupValue);
    }
    else
    {
        mx.controls.Alert.show("Please select a state", "Stop");
    }
}

/* *******************************   CLEAR FIELDS AND CLEAR FORM ******************** */
private function clearForm():void
{
    Utilities.clearAll(cnv_CallSheet);
}

private function clearFields():void
{
    SALESGROUP.value = dgDealer.selectedItem.SALESGROUP;
    SALESREP.value = dgDealer.selectedItem.SALESREP;
    VISIT_DATE.text = '';
    PURCHASE_GROUP.selectedIndex = 0;
    STOCKING_DEALER.selectedIndex = 0;
    ORDER_TAKEN.selectedIndex = 0;
    FOLLOWUP_DATE.text = '';
    REVOLVERS_DISPLAYED.text = '';
    LEATHER_DISPLAYED.text = '';
    GRIPS_DISPLAYED.text = '';
    DISPLAY_REVOLVERS.selectedIndex = 0;
    DISPLAY_LEATHER.selectedIndex = 0;
    DISPLAY_GRIP.selectedIndex = 0;
    COMMENTS.text = '';
    VISIT_DATE.setDefault();
    FOLLOWUP_DATE.setDefault();
}

private function initForm():void
{
    btnAdd.label = "Add Entry";
    btnAdd.enabled = true;
    btnDelete.enabled = false;
    clearFields();
    btnSave.enabled = false;
    callSheet = null;
}

private function deleteHandler(event:MouseEvent):void
{
    if (event.currentTarget.id == "btnDelete")
    {
        Alert.show("Delete Callsheet Entry", "Delete Record", Alert.NO | Alert.YES, null, deleteConfirmed, Images.deleteIcon);
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
        mode = "Edit";
    }
}

private function deleteRecord():void
{
    var csg:RemoteObject = new RemoteObject();
    csg.destination = "ColdFusion";
    csg.source = "com.Heritage.CALLSHEETGateway";
    csg.addEventListener("result", onServiceDataReady);
    csg.addEventListener("fault", faultHandler);
    csg.deleteCallSheetById(callSheet.ID);
}

/* ***************************   SAVE / UPDATE RECORD ************************** */
private function saveRecord(event:MouseEvent):void
{
    if ((event.currentTarget.id == "btnAdd") && (btnAdd.label == "Add Entry"))
    {
        clearFields();
        mode = "Add";
        newCallsheet = true;
        callSheet = new CALLSHEET();
        DEALER_ID.text = dealerID.toString();
        btnSave.enabled = true;
        btnDelete.enabled = false;
        btnAdd.label = "Clear Entry";
        return;
    }
    else if ((event.currentTarget.id == "btnAdd") && (btnAdd.label == "Clear Entry"))
    {
        initForm();
        return;
    }
    dbTools = new DBTools();
    if (Utilities.validateAll(cnv_CallSheet))
    {
        if (!newCallsheet) // must be doing an update
        {
            dbTools.buildUpdateRecord(acCallSheetWrapper, 0, cnv_CallSheet, "");
            if (dbTools.updateFields.length > 0)
            {
                var vcallSheet:CALLSHEET = new CALLSHEET();
                vcallSheet = dbTools.acUpdateRecord[0] as CALLSHEET;
                saveCallSheet(vcallSheet);
            }
            else
            {
                Alert.show("Nothing to Update", "Nothing to do");
            }
        }
        else
        {
            acCallSheetWrapper.removeAll();
            acCallSheetWrapper.addItem(callSheet);
            dbTools.buildUpdateRecord(acCallSheetWrapper, 0, cnv_CallSheet, "");
            callSheet = dbTools.acUpdateRecord[0] as CALLSHEET;
            // CallSheetGateway.saveCallSheet(callSheet);
            saveCallSheet(callSheet);
        }
    }
    else
    {
        Alert.show("Please correct fields outlined in Red", "Errors on Form");
        return;
    }
}

private function saveCallSheet(value:CALLSHEET):void
{
    var csg:RemoteObject = new RemoteObject();
    csg.destination = "ColdFusion";
    csg.source = "com.Heritage.CALLSHEETGateway";
    csg.addEventListener("result", onServiceDataReady);
    csg.addEventListener("fault", faultHandler);
    csg.saveCallSheet(value);
}

/* *******************************     GATEWAY RESULT HANDLERS ******************** */
public function onServiceDataReady(event:ResultEvent):void
{
    CursorManager.removeBusyCursor();
    var act:Object = event.token;
    switch (act.message.operation)
    {
        case "deleteCallSheetById":
            btnDelete.enabled = false;
            dgCallHistroy.selectedIndex = -1;
            if (act.result.DEALER_ID == 0)
            {
                acCallHistory.removeItemAt(loc);
                acCallHistory.refresh();
                Alert.show("Callsheet Deleted", "Deleted");
            }
            else
            {
                Alert.show("Problem Deleting Callsheet", "Error");
            }
            break;
        case "getCallSheetsByDealer1":
            if (act.result.ID != 0)
            {
                callSheet = new CALLSHEET();
                callSheet = act.result[0] as CALLSHEET;
                break;
            }
            else
            {
                Alert.show("Record Not Found", "NIF");
                return;
            }
            break;
        case "getCallSheetsByDealer":
            if (act.result.length > 0)
            {
                acCallHistory = new ArrayCollection(act.result as Array);
                dgCallHistroy.dataProvider = acCallHistory;
                tn1.selectedIndex = 1;
                cnv_CallSheet.enabled = true;
            }
            break;
        case "saveCallSheet":
            callSheet = new CALLSHEET();
            callSheet = act.result as CALLSHEET;
            if (newCallsheet)
            {
                if ((acCallHistory == null) || (acCallHistory.length == 0))
                {
                    acCallHistory = new ArrayCollection();
                    dgCallHistroy.dataProvider = acCallHistory;
                }
                acCallHistory.addItemAt(callSheet, 0);
                Alert.show("Call Sheet Added", "Success", Alert.OK, null, null, Images.okIcon);
            }
            else
            {
                Alert.show("Call Sheet Updated", "Success", Alert.OK, null, null, Images.okIcon);
                var loc:int = dgCallHistroy.selectedIndex
                if (loc >= 0)
                {
                    acCallHistory.removeItemAt(loc);
                    acCallHistory.addItemAt(callSheet, loc);
                }
                else
                {
                    acCallHistory.addItem(callSheet);
                }
            }
            initForm();
            mode = "Edit";
            acCallHistory.refresh();
            newCallsheet = false;
            break;
    }
}

private function onServiceFault(event:FaultEvent):void
{
    // Or clock-cursor will spin forever (:
    CursorManager.removeBusyCursor();
    var act:Object = event.token;
    // Do your own error processing with event.fault.faultstring, etc...
    Alert.show(event.fault.faultString, 'Error');
}

private function loadHistory():void
{
    var csg:RemoteObject = new RemoteObject();
    csg.destination = "ColdFusion";
    csg.source = "com.Heritage.CALLSHEETGateway";
    csg.addEventListener("result", onServiceDataReady);
    csg.addEventListener("fault", faultHandler);
    csg.getCallSheetsByDealer(dealerID);
}

private function populateForm(record:CALLSHEET):void
{
    acCallSheetWrapper.removeAll();
    acCallSheetWrapper.addItem(record);
    dbTools = new DBTools();
    dbTools.loadFieldData(acCallSheetWrapper, 0, cnv_CallSheet, "");
    tn1.selectedIndex = 1;
    cnv_CallSheet.enabled = true;
    btnDelete.enabled = true;
    // superpanel1.title = "Call Sheet - " + mode;
}

private function gridDoubleClickHandler(event:MouseEvent):void
{
    if ((event.currentTarget.id == "dgDealer") && (dgDealer.selectedIndex >= 0))
    {
        dealerID = dgDealer.selectedItem.ID;
        dealerName = dgDealer.selectedItem.NAME;
        cnv_CallSheet.enabled = true;
        lblDealer.text = dealerName + " - " + dealerID;
        tn1.selectedIndex = 1;
        clearForm();
        SALESGROUP.value = dgDealer.selectedItem.SALESGROUP;
        SALESREP.value = dgDealer.selectedItem.SALESREP;
        btnSave.enabled = false;
        btnAdd.label = "Add Entry";
        mode = "Add";
        newCallsheet = true;
        loadHistory();
    }
    else if ((event.currentTarget.id == "dgCallHistroy") && (dgCallHistroy.selectedIndex >= 0))
    {
        callSheet = new CALLSHEET();
        callSheet = CALLSHEET(dgCallHistroy.selectedItem)
        populateForm(callSheet);
        mode = "Edit";
        // superpanel1.title = "Call Sheet - " + mode;
        btnSave.enabled = true;
        newCallsheet = false;
    }
}

private function formatHistoryDate(item:Object, column:DataGridColumn):String
{
    return df.format(item[column.dataField]);
}

private function fillComboBox_result(evt:ResultEvent):void
{
    switch (evt.currentTarget.name)
    {
        case "loadAgencyCombo":
            acAgency = new ArrayCollection();
            acAgency = ArrayCollection(evt.result);
            acAgency.addItemAt({ AGENCY_SHORT_NAME: "Select", AGENCY_ID: 0 }, 0);
            acAgency.refresh();
            // acAgency = parentApplication.acAgencyMain;
            SALESGROUP.labelField = "AGENCY_SHORT_NAME";
            SALESGROUP.dataField = "AGENCY_ID";
            SALESGROUP.dataProvider = acAgency;
            break;
        case "loadPurchaseGroupCombo":
            acGroup = new ArrayCollection();
            acGroup = ArrayCollection(evt.result);
            acGroup.addItemAt({ GROUP_COMPANY: "Select", GROUP_ID: 0 }, 0);
            acGroup.refresh();
            // acGroup = parentApplication.acGroupMain;
            PURCHASE_GROUP.labelField = "GROUP_COMPANY";
            PURCHASE_GROUP.dataField = "GROUP_ID";
            PURCHASE_GROUP.dataProvider = acGroup;
            break;
        case "loadSalesRepCombo":
            acRep = new ArrayCollection();
            acRep = ArrayCollection(evt.result);
            acRep.addItemAt({ REP_NAME: "Select", REP_ID: 0 }, 0);
            acRep.refresh();
            SALESREP.labelField = "REP_NAME"
            //SALESREP.labelFunction = repLabelFunction;
            SALESREP.dataField = "REP_ID";
            SALESREP.dataProvider = acRep;
            break;
        case "loadDealerByName":
            acDealer = ArrayCollection(evt.result);
            dgDealer.dataProvider = acDealer;
            break;
    }
}

private function fillComboBox_fault(evt:FaultEvent):void
{
    Alert.show("Error while loading State Data", "Stop");
}

private function resultHandler(event:ResultEvent):void
{
    acDealer = ArrayCollection(event.result);
    dgDealer.dataProvider = acDealer;
}

private function faultHandler(event:mx.rpc.events.FaultEvent):void
{
    Alert.show(event.fault.faultString);
}

private function lookupName(event:Event):void
{
    switch (event.currentTarget.id)
    {
        case "btn_Find":
            if (search_fld.text.length > 2)
            {
                cbx_state.selectedIndex = 0;
                loadDealer(search_fld.text);
            }
            else
            {
                Alert.show("Dealer lookup requires at least 3 characters", "Stop");
            }
            break;
        case "cbx_state":
            cnv_CallSheet.enabled = false;
            if (cbx_state.selectedIndex != 0)
            {
                lookupValue = cbx_state.selectedItem.data;
                loadDealer(lookupValue);
            }
            else
            {
                mx.controls.Alert.show("Please select a state", "Stop");
            }
            break;
    }
}

public function loadDealer(value:String):void
{
    cbx_state.selectedIndex = 0;
    var csg:RemoteObject = new RemoteObject();
    csg.destination = "ColdFusion";
    csg.source = "com.Heritage.DEALERGateway";
    csg.addEventListener("result", resultHandler);
    csg.addEventListener("fault", faultHandler);
    csg.loadDealerAndRep(value);
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