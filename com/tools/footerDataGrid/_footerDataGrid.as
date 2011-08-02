
import com.tools.footerDataGrid.SummaryFooter;   

import flash.display.Sprite;
import flash.events.Event;

import mx.collections.ArrayCollection;
import mx.collections.ListCollectionView;
import mx.core.UIComponent;
 
private var _footer:Array = null;
public var footerHeight:int = 0;
public var totalFooterHeight:int = 0;
private var footerDirty:Boolean = false;
private var _rowColorFunction:Function;
 
override public function set dataProvider(value:Object):void
{
	if (value is ListCollectionView)
		value.addEventListener('collectionChange', onCollectionChange);
 
	super.dataProvider = value;
}
 
/**
	 * A user-defined function that will return the correct color of the
	 * row. Usually based on the row data.
	 * 
	 * expected function signature:
	 * public function F(item:Object, defaultColor:uint):uint
	 **/
	public function set rowColorFunction(f:Function):void
	{
		this._rowColorFunction = f;
	}
	
	public function get rowColorFunction():Function
	{
		return this._rowColorFunction;
	}
	
private function onCollectionChange(event:Event):void
{
	dispatchEvent(new Event('collectionChange'));
}
 
public function set footer(value:Array):void
{
    footerHeight = 22;
    
    // need to clear out any old footer children that might exist
    if(_footer != null)
    {
        for each (var child:UIComponent in _footer)
        {
             if(this.contains(child))
             {
                 removeChild(child);
             }
        }
    }
    
    _footer = value;
    footerDirty = true;
    invalidateProperties();
    invalidateList();
}
 
public function get footer():Array
{
	return _footer;
}
 
override protected function commitProperties():void
{
    super.commitProperties();
 
    if (footerDirty)
    {
        footerDirty = false;
        
        for each (var child:UIComponent in footer)
        {
            if(!(child is SummaryFooter))
            {
                throw new Error("All Footers must be SummaryFooter");
            }
            
            var childFooter:SummaryFooter = child as SummaryFooter;
            childFooter.styleName = this;
            childFooter.dataGrid = this;
            addChild(childFooter);
        }
    }
}
 
 
override protected function adjustListContent(unscaledWidth:Number = -1, unscaledHeight:Number = -1):void
{
    if(footer != null && footer.length > 0)
    {
        if(!isNaN(rowHeight))
        {
            footerHeight = rowHeight;
            totalFooterHeight = 0;
	        for each (var child:UIComponent in footer)
	        {
        		var intHeight:int = footerHeight;
        		if (footerHeight > child.maxHeight)intHeight = child.maxHeight;
        		totalFooterHeight += intHeight;
        	}
//            totalFooterHeight = rowHeight * footer.length;
        }
    }
    
    super.adjustListContent(unscaledWidth, unscaledHeight);
 
    if(footer != null && footer.length > 0)
    {
        listContent.setActualSize(unscaledWidth, unscaledHeight - totalFooterHeight);
        
        var offset:int = 0;
        for each (child in footer)
        {
        	intHeight = footerHeight;
        	if (footerHeight > child.maxHeight)intHeight = child.maxHeight;
            child.setActualSize(unscaledWidth - 2, intHeight);
            child.move(listContent.x, unscaledHeight - totalFooterHeight - 1 + offset);
            offset += intHeight; 
        }
    }
}
 
override public function invalidateDisplayList():void
{
    super.invalidateDisplayList();
    
    if(footer && footer.length >= 0)
    {
        for each (var child:UIComponent in footer)
        {
            child.invalidateDisplayList();
        }
    }
}

override protected function drawRowBackground(s:Sprite, rowIndex:int,
										y:Number, height:Number, color:uint, dataIndex:int):void
{
	if( this.rowColorFunction != null )
	{
		if( dataIndex < (this.dataProvider as ArrayCollection).length )
		{
    		var item:Object = (this.dataProvider as ArrayCollection).getItemAt(dataIndex);
    		color = this.rowColorFunction.call(this, item, color);
		}
	}
	
	super.drawRowBackground(s, rowIndex, y, height, color, dataIndex);
}

