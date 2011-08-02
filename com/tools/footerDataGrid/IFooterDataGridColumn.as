 
package com.tools.footerDataGrid
{
    import mx.controls.listClasses.IListItemRenderer;
    import mx.core.IFactory;
    
    public interface IFooterDataGridColumn
    {
        function set label(value:String):void
        function get label():String
        function set dataColumn(value:Object):void
        function get dataColumn():Object
        function get column():Object
        function set column(value:Object):void
        function set labelFunction(value:Function):void
        function get labelFunction():Function
        function get itemRenderer():IFactory
        function get footer():SummaryFooter
        function set footer(value:SummaryFooter):void
        function set renderer(value:IListItemRenderer):void
        function get renderer():IListItemRenderer
        function get useColumnItemRenderer():Boolean;
        function set useColumnItemRenderer(value:Boolean):void;
    }
}
