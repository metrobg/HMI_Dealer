// ActionScript file
import com.Heritage.AGENCY;
import com.Heritage.PURCHASE_GROUP;
import com.Heritage.SALESREP;
import com.ace.DBTools;
import com.ace.Input.Utilities;
import flash.events.MouseEvent;
import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.controls.dataGridClasses.DataGridColumn;
import mx.managers.CursorManager;
import mx.rpc.events.*;
import mx.rpc.remoting.RemoteObject;

public var salesRep:SALESREP;

public var agency:AGENCY;

public var group:PURCHASE_GROUP;

public var acRep:ArrayCollection;

public var acAgency:ArrayCollection;

public var acGroup:ArrayCollection;

public var acTmp:ArrayCollection;

public var acRepWrapper:ArrayCollection;

public var acAgencyWrapper:ArrayCollection;

public var acGroupWrapper:ArrayCollection;

public var newSalesRep:Boolean = false;

private var newAgency:Boolean = false;

public var newGroup:Boolean = false;

private var mode:String = "Search";

private var dbTools:DBTools;

public var userID:String;

private function init():void
{
    dgReps.dataProvider = acRep;
    acAgency = new ArrayCollection();
    acGroup = new ArrayCollection();
    acTmp = new ArrayCollection();
    acRepWrapper = new ArrayCollection();
    acAgencyWrapper = new ArrayCollection();
    acGroupWrapper = new ArrayCollection();
    dbTools = new DBTools();
    REP_STATE.dataProvider = acState;
    GROUP_STATE.dataProvider = acState;
    AGENCY_STATE.dataProvider = acState;
    userID = mx.core.Application.application.parameters.userID;
    superpanel1.status = mode;
    moveToFront();
    dgAgency.dataProvider = acAgency;
    cbx_AGENCY.dataProvider = acAgency;
    cbx_AGENCY.labelField = "AGENCY_SHORT_NAME";
    cbx_AGENCY.dataField = "AGENCY_ID";
    REP_SALESGROUP.dataProvider = acGroup;
    acGroup.refresh();
    dgGroup.dataProvider = acGroup;
    loadAgencies();
    //Agencygateway.getAllAgency();
    loadSalesRep();
}

private function loadAgencies():void
{
    var csg:RemoteObject = new RemoteObject();
    csg.destination = "ColdFusion";
    csg.source = "com.Heritage.AGENCYGateway";
    csg.addEventListener("result", onServiceDataReady);
    csg.addEventListener("fault", onServiceFault);
    csg.getAllAgency();
}

private function saveAgency(value:AGENCY):void
{
    var csg:RemoteObject = new RemoteObject();
    csg.destination = "ColdFusion";
    csg.source = "com.Heritage.AGENCYGateway";
    csg.addEventListener("result", onServiceDataReady);
    csg.addEventListener("fault", onServiceFault);
    csg.saveAgency(value);
}

private function loadSalesRep():void
{
    var csg:RemoteObject = new RemoteObject();
    csg.destination = "ColdFusion";
    csg.source = "com.Heritage.SALESREPGateway";
    csg.addEventListener("result", onServiceDataReady);
    csg.addEventListener("fault", onServiceFault);
    csg.getAllReps();
}

private function saveSalesRep(value:SALESREP):void
{
    var csg:RemoteObject = new RemoteObject();
    csg.destination = "ColdFusion";
    csg.source = "com.Heritage.SALESREPGateway";
    csg.addEventListener("result", onServiceDataReady);
    csg.addEventListener("fault", onServiceFault);
    csg.saveRep(value);
}

private function loadGroups():void
{
    var csg:RemoteObject = new RemoteObject();
    csg.destination = "ColdFusion";
    csg.source = "com.Heritage.PURCHASE_GROUPGateway";
    csg.addEventListener("result", onServiceDataReady);
    csg.addEventListener("fault", onServiceFault);
    csg.getAllGroups();
}

private function saveGroup(value:PURCHASE_GROUP):void
{
    var csg:RemoteObject = new RemoteObject();
    csg.destination = "ColdFusion";
    csg.source = "com.Heritage.PURCHASE_GROUPGateway";
    csg.addEventListener("result", onServiceDataReady);
    csg.addEventListener("fault", onServiceFault);
    csg.saveGroup(value);
}

public function onServiceDataReady(event:ResultEvent):void
{
    var act:Object = event.token;
    switch (act.message.operation)
    {
        case "getRepById":
            if (act.result.REP_ID != 0)
            {
                salesRep = new SALESREP();
                salesRep = act.result as SALESREP;
                populateRepForm(salesRep);
                break;
            }
            else
            {
                Alert.show("Record Not Found", "NIF");
                return;
            }
            break;
        case "saveRep":
            salesRep = new SALESREP();
            salesRep = act.result as SALESREP;
            populateRepForm(salesRep);
            if (dgReps.selectedIndex >= 0)
            {
                acRep.removeItemAt(dgReps.selectedIndex);
                acRep.addItem(salesRep);
                acRep.refresh();
            }
            Alert.show("Sales Rep Record Updated", "Success");
            newSalesRep = false;
            break;
        case "saveAgency":
            agency = new AGENCY();
            agency = act.result as AGENCY;
            populateAgencyForm(agency);
            if (dgAgency.selectedIndex >= 0)
            {
                acAgency.removeItemAt(dgAgency.selectedIndex);
                dgAgency
                acAgency.addItem(agency);
            }
            // loadAllAgency(); // reload the list of Rep AGENCIES
            Alert.show("Agency Record Updated", "Success");
            acAgency.refresh();
            newAgency = false;
            break;
        case "saveGroup":
            group = new PURCHASE_GROUP();
            group = act.result as PURCHASE_GROUP;
            populateGroupForm(group);
            if (dgGroup.selectedIndex >= 0)
            {
                acGroup.removeItemAt(dgGroup.selectedIndex);
                acGroup.addItem(group);
                acGroup.refresh();
            }
            //loadAllGroups(); // reload the list of Rep AGENCIES
            Alert.show("Group Record Updated", "Success");
            newGroup = false;
            break;
        case "getAllAsQuery":
            acRep = act.result as ArrayCollection
            break;
        case "getAllReps":
            acRep = new ArrayCollection(act.result as Array);
            dgReps.dataProvider = acRep;
            acRep.refresh();
            break;
        case "getAllAgency":
            acAgency = new ArrayCollection(act.result as Array);
            acAgency.addItemAt({ AGENCY_ID: "0", AGENCY_SHORT_NAME: "All" }, 0);
            dgAgency.dataProvider = acAgency;
            cbx_AGENCY.dataProvider = acAgency;
            cbx_AGENCY.labelField = "AGENCY_SHORT_NAME";
            cbx_AGENCY.dataField = "AGENCY_ID";
            REP_SALESGROUP.dataProvider = acAgency;
            REP_SALESGROUP.labelField = "AGENCY_SHORT_NAME";
            REP_SALESGROUP.dataField = "AGENCY_ID";
            acAgency.refresh();
            break;
        case "getAllGroups":
            acGroup = new ArrayCollection(act.result as Array);
            dgGroup.dataProvider = acGroup;
            acGroup.refresh();
            break;
    }
    CursorManager.removeAllCursors();
}

private function onServiceFault(event:FaultEvent):void
{
    // Or clock-cursor will spin forever (:
    CursorManager.removeBusyCursor();
    var act:Object = event.token;
    // Do your own error processing with event.fault.faultstring, etc...
    Alert.show(event.fault.faultString, 'Error');
}

private function loadAllAgency():void
{
    loadAgencies();
    dgAgency.visible = true;
    dgReps.visible = false;
    dgGroup.visible = false;
    cbx_AGENCY.enabled = false;
    searchText.enabled = false;
    searchText.text = '';
}

private function loadAllReps():void
{
    loadSalesRep();
    dgReps.visible = true;
    dgAgency.visible = false;
    dgGroup.visible = false;
    cbx_AGENCY.enabled = true;
    cbx_AGENCY.selectedIndex = 0;
    searchText.enabled = true;
    searchText.text = '';
    dgReps.dataProvider = acRep;
}

private function loadAllGroups():void
{
    loadGroups()
    dgGroup.visible = true;
    dgReps.visible = false;
    dgAgency.visible = false;
    cbx_AGENCY.enabled = false;
    searchText.enabled = false;
    searchText.text = '';
    dgGroup.dataProvider = acGroup;
}

/* ****************************   LOAD GRIDS AND COMBOBOXES *************************************** */
private function loadAgencyForm():void
{
    if (dgAgency.selectedItem.AGENCY_ID != 0)
    {
        agency = new com.Heritage.AGENCY();
        agency.fill(dgAgency.selectedItem);
        populateAgencyForm(agency);
        superpanel1.status = "Edit";
        mode = "Edit";
        tn1.selectedIndex = 2;
    }
}

private function loadGroupForm():void
{
    if (dgGroup.selectedIndex >= 0)
    {
        group = new PURCHASE_GROUP();
        group.fill(dgGroup.selectedItem);
        populateGroupForm(group);
        superpanel1.status = "Edit";
        mode = "Edit";
        btn_saveGroup.enabled = true;
        tn1.selectedIndex = 3;
    }
}

private function loadSalesRepForm():void
{
    if (dgReps.selectedIndex >= 0)
    {
        salesRep = new SALESREP();
        salesRep.fill(dgReps.selectedItem);
        populateRepForm(salesRep);
        superpanel1.status = "Edit";
        mode = "Edit";
        tn1.selectedIndex = 1;
    }
}

/* *************************   POPULATE FORMS ************************************** */
private function populateRepForm(record:SALESREP):void
{
    acRepWrapper.removeAll();
    acRepWrapper.addItem(record);
    dbTools.loadFieldData(acRepWrapper, 0, cnv_Rep, "");
}

private function populateAgencyForm(record:AGENCY):void
{
    acAgencyWrapper.removeAll();
    acAgencyWrapper.addItem(record);
    dbTools.loadFieldData(acAgencyWrapper, 0, cnv_Agency, "");
}

private function populateGroupForm(record:PURCHASE_GROUP):void
{
    acGroupWrapper.removeAll();
    acGroupWrapper.addItem(record);
    dbTools.loadFieldData(acGroupWrapper, 0, cnv_Group, "");
}

private function tabSelected():void
{
}

/* ****************************   ADD RECORD FUNCTIONS *************************/
private function addAgencyRecord(event:MouseEvent):void
{
    Utilities.clearAll(cnv_Agency);
    agency = new AGENCY();
    superpanel1.status = "Add";
    newAgency = true;
    mode = "Add";
    AGENCY_COMPANY.setFocus();
}

private function addGroupRecord(event:MouseEvent):void
{
    Utilities.clearAll(cnv_Group);
    group = new PURCHASE_GROUP();
    superpanel1.status = "Add";
    newGroup = true;
    mode = "Add";
    GROUP_COMPANY.setFocus();
    btn_saveGroup.enabled = true;
}

private function addRepRecord(event:MouseEvent):void
{
    Utilities.clearAll(cnv_Rep);
    newSalesRep = true;
    salesRep = new SALESREP();
    superpanel1.status = "Add";
    mode = "Add";
}

/* ***************       SAVE FUNCTIONS                 **************************/
private function saveGroupRecord(event:MouseEvent):void
{
    dbTools = new DBTools();
    if (Utilities.validateAll(cnv_Group))
    {
        if (!newGroup) // must be doing an update
        {
            dbTools.buildUpdateRecord(acGroupWrapper, 0, cnv_Group, "");
            if (dbTools.updateFields.length > 0)
            {
                var vgroup:PURCHASE_GROUP = new PURCHASE_GROUP();
                vgroup = dbTools.acUpdateRecord[0] as PURCHASE_GROUP;
                saveGroup(vgroup);
            }
            else
            {
                Alert.show("Nothing to Update", "Nothing to do");
            }
        }
        else
        {
            acGroupWrapper.removeAll();
            acGroupWrapper.addItem(group);
            dbTools.buildUpdateRecord(acGroupWrapper, 0, cnv_Group, "");
            group = dbTools.acUpdateRecord[0] as PURCHASE_GROUP;
            saveGroup(group);
        }
    }
    else
    {
        Alert.show("Please correct fields outlined in Red", "Errors on Form");
        return;
    }
}

private function saveAgencyRecord(event:MouseEvent):void
{
    dbTools = new DBTools();
    if (Utilities.validateAll(cnv_Agency))
    {
        if (!newAgency) // must be doing an update
        {
            dbTools.buildUpdateRecord(acAgencyWrapper, 0, cnv_Agency, "");
            if (dbTools.updateFields.length > 0)
            {
                var vagency:AGENCY = new AGENCY();
                vagency = dbTools.acUpdateRecord[0] as AGENCY;
                //Agencygateway.saveAgency(vagency);
                saveAgency(vagency);
            }
            else
            {
                Alert.show("Nothing to Update", "Nothing to do");
            }
        }
        else
        {
            acAgencyWrapper.removeAll();
            acAgencyWrapper.addItem(agency);
            dbTools.buildUpdateRecord(acAgencyWrapper, 0, cnv_Agency, "");
            agency = dbTools.acUpdateRecord[0] as AGENCY;
            //Agencygateway.saveAgency(agency);
            saveAgency(vagency);
        }
    }
    else
    {
        Alert.show("Please correct fields outlined in Red", "Errors on Form");
        return;
    }
}

private function saveRepRecord(event:MouseEvent):void
{
    dbTools = new DBTools();
    if (Utilities.validateAll(cnv_Rep))
    {
        if (!newSalesRep) // must be doing an update
        {
            dbTools.buildUpdateRecord(acRepWrapper, 0, cnv_Rep, "");
            if (dbTools.updateFields.length > 0)
            {
                var vsalesRep:SALESREP = new SALESREP();
                vsalesRep = dbTools.acUpdateRecord[0] as SALESREP;
                saveSalesRep(vsalesRep);
            }
            else
            {
                Alert.show("Nothing to Update", "Nothing to do");
            }
        }
        else
        {
            acRepWrapper.removeAll();
            acRepWrapper.addItem(salesRep);
            dbTools.buildUpdateRecord(acRepWrapper, 0, cnv_Rep, "");
            salesRep = dbTools.acUpdateRecord[0] as SALESREP;
            saveSalesRep(salesRep);
        }
    }
    else
    {
        Alert.show("Please correct fields outlined in Red", "Errors on Form");
        return;
    }
}

/* ******************************  FILTER FUNCTION  ******************************************** */
private function filterPhrase():void
{
    acRep.filterFunction = filterFirst;
    acRep.refresh();
}

private function filterFirst(row:Object):Boolean
{
    if (searchText.length == 0)
    {
        return true;
    }
    var columnName:String;
    var columnValue:String;
    var keywords:Array = searchText.text.split(" ");
    var wordFound:Boolean;
    // Loop Over Words
    for (var word:int = 0; word < keywords.length; word++)
    {
        wordFound = false;
        // Loop Over Columns
        for (var column:int = 0; column < dgReps.columnCount; column++)
        {
            columnName = dgReps.columns[column].dataField;
            if (row[columnName] != null)
            {
                columnValue = row[columnName];
                columnValue = columnValue.toLowerCase();
                if (columnValue.search(keywords[word].toLowerCase()) >= 0)
                {
                    wordFound = true;
                    break;
                }
            }
        }
        if (!wordFound)
            return false;
    }
    return true;
}

// grid label function
private function showAgency(item:Object, column:DataGridColumn):String
{
    var result:String;
    var df:String = cbx_AGENCY.dataField;
    for (var i:int = 0; i < cbx_AGENCY.dataProvider.length; i++)
    {
        if (item[column.dataField] == cbx_AGENCY.dataProvider[i]["AGENCY_ID"])
        {
            result = cbx_AGENCY.dataProvider[i]["AGENCY_COMPANY"];
        }
    }
    return result;
}

private function filterAgency():void
{
    toggleFilter();
}

private function filterPackets():void
{
}

private function toggleFilter():void
{
    if (cbx_AGENCY.selectedIndex > 0)
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
    if (cbx_AGENCY.selectedItem.AGENCY_ID == item.REP_SALESGROUP)
    {
        return true;
    }
    else
    {
        return false;
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