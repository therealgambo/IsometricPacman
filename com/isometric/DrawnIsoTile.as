package com.isometric {
	
	public class DrawnIsoTile extends IsoObject {
		
		// Constants:
		
		// Public Properties:
		
		// Private Properties:
		protected var _height:Number;
		protected var _color:uint;
		
		
		// Initialization:
		public function DrawnIsoTile( size:Number, color:uint, height:Number = 0, teleport:Boolean = false ) : void
		{
			super(size);
			_color = color;
			_height = height;
			_teleport = teleport;
			draw();
		}
	
	
		// Public Methods:
		override public function toString() : String {
            return "DrawnIsoTile";
        }
		
		
		/**
		 * Sets / gets the height of this object. Not used in this class, but can be used in subclasses.
		 */
		override public function set height( value:Number ) : void
		{
			_height = value;
			draw();
		}
		override public function get height() : Number
		{
			return _height;
		}
		
		/**
		 * Sets / gets the color of this tile.
		 */
		public function set color( value:uint ) : void
		{
			_color = value;
			draw();
		}
		public function get color() : uint
		{
			return _color;
		}
		
		/**
		 * Sets / gets the teleport state of this tile.
		 */
		public function set teleport( value:Boolean ) : void
		{
			_teleport = value;
			draw();
		}
		public function get teleport() : Boolean
		{
			return _teleport;
		}
		
		
		
		// Protected Methods:
		
		/**
		 * Draws the tile.
		 */
		protected function draw():void
		{
			graphics.clear();
			graphics.beginFill(_color);
			graphics.lineStyle(0, 0xFFFFFF, .1);
			graphics.moveTo(-size, 0);
			graphics.lineTo(0, -size * .5);
			graphics.lineTo(size, 0);
			graphics.lineTo(0, size * .5);
			graphics.lineTo(-size, 0);
		}
		
		
	}
	
}