
package com.tools.footerDataGrid
{
	import mx.controls.AdvancedDataGrid;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridListData;
	import mx.controls.listClasses.BaseListData;
 
 	[DefaultProperty("footer")]
	public class AdvancedFooterDataGrid extends AdvancedDataGrid implements IFooterDataGrid
	{
		include "_footerDataGrid.as";
 
		public function createListData(text:String, dataField:String, i:int):BaseListData
		{
			return new AdvancedDataGridListData(text, dataField, i, null, this, -1);
		}
 
	}
}
