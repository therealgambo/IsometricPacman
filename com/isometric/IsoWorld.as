package com.isometric {
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import flash.geom.Point;
	
	import com.pathfinding.Grid;
	
	public class IsoWorld extends Sprite 
	{
		
		// Constants:
		
		// Public Properties:
		
		// Private Properties:
		private var _floor:Sprite;
		private var _floorObj:Array;
		private var _objects:Array;
		private var _world:Sprite;
		private var _grid:Grid;
		
		
		// Initialization:
		public function IsoWorld() : void
		{
			trace("IsoWorld.IsoWorld();");
			
			_floor = new Sprite();
			_floorObj = new Array();
			addChild( _floor );
			
			_world = new Sprite();
			addChild( _world );
			
			_objects = new Array();
			
			_grid = new Grid( 25, 25 );
		}
	
	
		// Public Methods:
		override public function toString() : String {
            return "IsoWorld";
        }
		
		
		public function getGrid() : Grid
		{
			return _grid;
		}
		
		
		public function setStartNode( x:int, y:int ) : void
		{
			var pos:Point = getTileAt( x, y );
			trace( "Start  [x -> " + pos.x + ", z -> " + pos.y + "]" );
			
			_grid.setStartNode( pos.x, pos.y );
		}
		
		
		public function setEndNode( x:int, y:int ) : void
		{
			var pos:Point = getTileAt( x, y );
			_grid.setEndNode( pos.x, pos.y );
			
			trace( "End    [x -> " + pos.x + ", z -> " + pos.y + "]" );
		}
		
		
		public function addChildToWorld( child:IsoObject ) : void
		{
			_world.addChild( child );
			_objects.push( child );
			
			sort();
		}
		
		
		public function removeChildFromWorld( child:IsoObject ) : void
		{
			_world.removeChild( child );
			_objects.splice( _objects.indexOf( child ), 1 );
			
			
			// MIGHT NEED WORK!!
			
			sort();
		}
		
		
		public function addChildToFloor( child:IsoObject ) : void
		{
			_floor.addChild( child );
			_floorObj.push( child );
			
			sort();
		}
		
		
		public function removeChildFromFloor( child:IsoObject ) : void
		{
			_floor.removeChild( child );
			_floorObj.splice( _floorObj.indexOf( child ), 1 );
			// NEEDS WORK!!
			
			sort();
		}
		
		
		public function sort():void
		{
			_objects.sortOn( "depth", Array.NUMERIC );
			
			for( var i:int = 0; i < _objects.length; i++ )
			{
				_world.setChildIndex( _objects[i], i );
			}
		}
		
		
		public function isTileTeleportal ( x:int, y:int ) : Boolean
		{
			var pos:Point = getTileAt( x, y );
			return _grid.isNodeTeleportal( pos.x, pos.y );
		}
		
		public function isTileWalkable ( x:int, y:int ) : Boolean 
		{
			var pos:Point = getTileAt( x, y );
			return _grid.isNodeWalkable( pos.x, pos.y );
		}
		
		public function getTileHeight ( x:int, y:int ) : int
		{
			var pos:Point = getTileAt( x, y );
			return _grid.getTileHeight( pos.x, pos.y );
		}
		
		
		public function canMove( obj:IsoObject ) : Boolean
		{
			var rect:Rectangle = obj.rect;
			rect.offset( obj.vx, obj.vz );
			
			for( var i:int = 0; i < _objects.length; i++ )
			{
				var objB:IsoObject = _objects[i] as IsoObject;
				
				if( obj != objB && !objB.walkable && rect.intersects( objB.rect ) )
				{
					return false;
				}
			}
			
			return true;
		}
		
		
		
		// Protected Methods:
		public function getTileAt( x:int, z:int ){
			for( var i:int = 0; i < _floorObj.length; i++ )
			{
				var obj:IsoObject = _floorObj[i] as IsoObject;
				
				if( obj.x == x && obj.z == z )
				{
					return new Point( obj.j , obj.i );
				}
			}
			
			/*for( var ii:int = 0; ii < _objects.length; ii++ )
			{
				var objW:IsoObject = _objects[ii] as IsoObject;
				
				if( objW.x === x && objW.z === z )
				{
					return new Point( objW.j , objW.i );
				}
			}*/

			return new Point(0,0);
		}
		
		
	}
	
}