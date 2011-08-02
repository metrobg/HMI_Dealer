// ActionScript file
import Classes.Agency;
import Classes.Group;
import com.Heritage.DEALER;
import flash.events.MouseEvent;
import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.managers.PopUpManager;
import mx.rpc.events.*;
import com.metrobg.Icons.Images;

public var acREP:ArrayCollection;

public var acGROUP:ArrayCollection;

public var currentDealer:DEALER;

public var refreshParent:Boolean = false;

[Bindable]
public var vMode:String = "Update";

private var messageText:String;

public var security:Number = 0;

[Bindable]
public var agency:Agency;

[Bindable]
public var group:Group;

private function init():void
{
    lcl.loadGroupComboBox();
    title = "Mode: " + vMode;
    lbl_Dealer_Name.text = currentDealer.NAME + " - " + String(currentDealer.ID);
    lcl.loadAgencyComboBox();
    /*  lcl.loadRepComboBox();
     lcl.loadDealerRep(currentDealer.id); */
    lcl.loadGroupGrid(currentDealer.ID);
    acGROUP = new ArrayCollection();
    cbx_AGENCY.dataField = "DATA";
    cbx_REP.dataField = "DATA";
}

private function reset():void
{
    btn_AddGroup.enabled = false;
    btn_DeleteGroup.enabled = false;
    groupGrid.selectedIndex = -1;
    cbx_Group.selectedIndex = 0;
    strCustNumber.text = '';
}

public function enableButtons():void
{
    if (cbx_Group.selectedIndex > 0)
    {
        btn_AddGroup.enabled = true;
        btn_DeleteGroup.enabled = true;
    }
    else
    {
        btn_AddGroup.enabled = false;
        btn_DeleteGroup.enabled = false;
    }
}

private function setMode(value:String):void
{
    this.vMode = value;
    this.title = "Mode: " + vMode;
}

private function gridItemSelected():void
{
    if (groupGrid.selectedIndex >= 0)
    {
        vMode = "Delete";
        btn_DeleteGroup.enabled = true;
    }
    else
    {
        btn_DeleteGroup.enabled = false;
    }
}

private function filterReps():void
{
    toggleFilter();
}

private function toggleFilter():void
{
    if (cbx_AGENCY.selectedIndex > 0)
    {
        acREP.filterFunction = processFilter;
    }
    else
    {
        acREP.filterFunction = null;
    }
    acREP.refresh();
    cbx_REP.selectedIndex = 0;
}

private function processFilter(item:Object):Boolean
{
    if (cbx_AGENCY.selectedItem.DATA == item.REP_SALESGROUP)
    {
        return true;
    }
    else
    {
        return false;
    }
} 

private function saveGroup(event:MouseEvent):void
{
    if (event.currentTarget.id == "btn_Agency")
    {
        agency = new Agency();
        agency.AGENCY_ID = cbx_AGENCY.selectedItem.DATA
        agency.DEALER_ID = currentDealer.ID;
        agency.REP_ID = cbx_REP.selectedItem.DATA;
        vMode = "Update";
    }
    if (event.currentTarget.id == "btn_AddGroup")
    {
        group = new Group();
        group.DEALER_ID = currentDealer.ID;
        group.GROUP_ID = cbx_Group.selectedItem.DATA;
        group.CUSTOMER_NUMBER = strCustNumber.text;
        group.GROUP_NAME = cbx_Group.selectedItem.LABEL;
        vMode = "Add";
        for (var i:int = 0; i < acGROUP.length; i++)
        {
            if ((acGROUP[i].DEALER_ID == group.DEALER_ID) && (acGROUP[i].GROUP_ID == group.GROUP_ID) && (acGROUP[i].CUSTOMER_NUMBER == group.CUSTOMER_NUMBER))
            {
                return;
            }
        }
    }
    if ((event.currentTarget.id == "btn_DeleteGroup") && (groupGrid.selectedIndex >= 0))
    {
        group = new Group();
        group.CUSTOMER_NUMBER = groupGrid.selectedItem.CUSTOMER_NUMBER;
        group.DEALER_ID = groupGrid.selectedItem.DEALER_ID;
        group.GROUP_ID = groupGrid.selectedItem.GROUP_ID;
        group.GROUP_NAME = groupGrid.selectedItem.GROUP_NAME;
        vMode = "Delete";
    }
    if (vMode == "Add" || vMode == "Delete")
    {
        lcl.updateDealerGroup();
    }
    else
    {
        lcl.updateRepGroup();
    }
}

/*   web service result handlers  */
private function fillGroupComboBox_result(evt:ResultEvent):void
{
    var tmpAC:ArrayCollection;
    tmpAC = ArrayCollection(evt.result);
    tmpAC.addItemAt({ LABEL: "Select Group", DATA: 0 }, 0);
    cbx_Group.labelField = "LABEL";
    cbx_Group.dataProvider = tmpAC;
}

private function fillGroupComboBox_fault(evt:FaultEvent):void
{
    Alert.show("Error while loading Data", "Stop");
}

private function fillRepComboBox_result(evt:ResultEvent):void
{
    var tmpAC:ArrayCollection;
    acREP = ArrayCollection(evt.result);
    acREP.addItemAt({ LABEL: "Select Rep", DATA: 0 }, 0);
    cbx_REP.labelField = "LABEL";
    cbx_REP.dataProvider = acREP;
    lcl.loadDealerRep(currentDealer.ID);
}

private function fillAgencyComboBox_result(evt:ResultEvent):void
{
    var tmpAC:ArrayCollection;
    tmpAC = ArrayCollection(evt.result);
    tmpAC.addItemAt({ LABEL: "Select Agency", DATA: 0 }, 0);
    cbx_AGENCY.labelField = "LABEL";
    cbx_AGENCY.dataProvider = tmpAC;
    lcl.loadRepComboBox();
}

private function fillGroupGrid_result(evt:ResultEvent):void
{
    acGROUP = ArrayCollection(evt.result);
    acGROUP.refresh();
    groupGrid.dataProvider = acGROUP;
}

private function fillGroupGrid_fault(evt:FaultEvent):void
{
    Alert.show("Error while loading Data", "Stop");
}

private function updateRecord_result(evt:ResultEvent):void
{
    if (vMode == "Add")
    {
        acGROUP.addItem(group);
        acGROUP.refresh();
        groupGrid.dataProvider = acGROUP;
    }
    else if (vMode == "Delete")
    {
        acGROUP.removeItemAt(groupGrid.selectedIndex);
        acGROUP.refresh();
    }
    reset();
}

private function updateRecord_fault(evt:FaultEvent):void
{
    Alert.show(evt.type.toString());
}

private function getResultOk(r:Number, event:Event):void
{
}

private function closeWindow():void
{
    PopUpManager.removePopUp(this);
}

private function dealerRep_result(evt:ResultEvent):void
{
    var tmpAC:ArrayCollection;
    tmpAC = ArrayCollection(evt.result);
    if (tmpAC.length > 0)
    {
        cbx_AGENCY.value = tmpAC[0].AGENCY_ID;
        cbx_REP.value = tmpAC[0].REP_ID;
    }
    else
    {
        cbx_AGENCY.selectedIndex = 0;
        cbx_REP.selectedIndex = 0;
    }
}

private function dealerRep_fault(evt:FaultEvent):void
{
    Alert.show("Error while loading Data", "Stop");
}