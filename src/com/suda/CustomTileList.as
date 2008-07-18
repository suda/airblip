package com.suda
{
	import mx.controls.TileList;
	import mx.core.IFactory;
	import flash.display.Graphics;
    import flash.display.Sprite;
    import mx.controls.listClasses.IListItemRenderer;

	public class CustomTileList extends TileList
	{
		public function CustomTileList()
		{
			super();
		}
		
		override protected function drawSelectionIndicator(
	                           indicator:Sprite, xx:Number, yy:Number,
	                           ignoredWidth:Number, h:Number, color:uint,
	                           ignoredRenderer:IListItemRenderer):void
	    {
	        var w:int = unscaledWidth - viewMetrics.left - viewMetrics.right;
	        //ScrawlUtil.drawCrossHatch(Sprite(indicator).graphics, w, h, color, 1.0);           
	        indicator.x = xx;
	        indicator.y = yy;
	        indicator.graphics.beginFill(this.parentDocument.fxGlowRed.color, 1);
	        indicator.graphics.drawRoundRect(5,5, 33, 33, 6,6);
	        indicator.filters  = [this.parentDocument.fxGlowRed];
	        //ignoredRenderer.filters = [this.parentDocument.fxGlowRed];
	    }
		
	}
}