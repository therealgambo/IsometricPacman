package com.pathfinding {
	
	public class Node {
		
		// Constants:
		
		// Public Properties:
		public var x:int;
		public var y:int;
		public var f:Number;
		public var g:Number;
		public var h:Number;
		public var walkable:Boolean = false;
		public var parent:Node;
		public var costMultiplier:Number = 1.0;
		public var teleport:Boolean = false;
		public var tileHeight:int = 0;
		
		// Private Properties:
	
		// Initialization:
		public function Node( x:int, y:int ) : void
		{
			this.x = x;
			this.y = y;
		}
	
		// Public Methods:
		public function toString() : String {
            return "Node";
        }
		
		
		// Protected Methods:
		
		
	}
	
}