package com.isometric {
	
	import flash.display.DisplayObject;
	
	public class GraphicTile extends IsoObject {
		
		// Constants:
		
		// Public Properties:
		
		// Private Properties:
	
		// Initialization:
		public function GraphicTile( size:Number, classRef:Class, xoffset:Number, yoffset:Number ) : void 
		{
			super( size );
			
			var gfx:DisplayObject = new classRef() as DisplayObject;
			gfx.x = -xoffset;
			gfx.y = -yoffset;
			
			addChild( gfx );
		}
	
	
		// Public Methods:
		override public function toString() : String {
            return "GraphicTile";
        }
		
		
		// Protected Methods:
		
		
	}
	
}