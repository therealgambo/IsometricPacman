package com.core {

	import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.display.Stage;
	import flash.display.StageAlign;
    import flash.display.StageQuality;
    import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;

	import flash.geom.Point;

	import com.isometric.DrawnIsoBox;
	import com.isometric.DrawnIsoTile;
	import com.isometric.GraphicTile;
	import com.isometric.IsoWorld;
	import com.isometric.MapLoader;

	import com.isometric.Point3D;
	import com.isometric.IsoUtils;

	import com.pathfinding.AStar;
	import flash.text.engine.TextBlock;
	import flash.text.TextField;

	[SWF(width="1024", height="700", frameRate="28", backgroundColor="#333333")]
	public class IsometricPacman extends Sprite 
	{
		
		// Constants:
		
		// Public Properties:
		
		// Private Properties:
		private static var _instance : IsometricPacman;
		private static var _parent : DisplayObject;
        private static var stage : Stage;
		
		private var _world:IsoWorld;
		private var _floor:IsoWorld;
		private var mapLoader:MapLoader;
		
		private var _player:DrawnIsoBox;
		private var speed:Number = 1;
		private var highlightedTile:DrawnIsoTile;
		
		private var _cellSize = 20;
		private var _index:int;
		private var _path:Array;
		private var _showPath:Array;
		
		private var traceBox:TextField = new TextField();
	
		// Initialization:
		static public function getInstance() : IsometricPacman
		{ 
			if( _instance == null ){
				_instance = new IsometricPacman();
			}
			
			return _instance;
		}
		
		public function IsometricPacman() : void 
		{
			if( _instance ){
				throw new Error ( "Gamecore can only be accessed through GameCore.getInstance()" );
			}else{
				_instance = this;
			}
			
			waitingForStage();
		}


		// Public Methods:
		override public function toString() : String 
		{
            return "IsometricPacman";
        }
		
		
		public function waitingForStage() : void
		{
            addEventListener( Event.ADDED_TO_STAGE, initiateGame );
        }
		
		
		public function initiateGame( event:Event ) : void
		{ 
			trace("IsometricPacman.initiateGame();");
			
            stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.showDefaultContextMenu = false;
            stage.stageFocusRect = false;
			stage.quality = StageQuality.BEST;
			
            
            _parent = this.root;
			_showPath = new Array();
			loadTraceBox();
			
			mapLoader = new MapLoader();
			mapLoader.addEventListener( Event.COMPLETE, onMapComplete );
			mapLoader.loadMap( "map.txt" );
		}
		
		private function loadTraceBox() : void {
			
			traceBox.width = 450;
			traceBox.height = 150;
			traceBox.x = 5;
			traceBox.y = stage.stageHeight - 158;
			traceBox.background = true;
			traceBox.selectable = false;
			traceBox.multiline = true;
			
			//this.addChild( traceBox );
			
		}
		
		// Protected Methods:
		private function onMapComplete( event:Event ) : void
		{
			trace("IsometricPacman.onMapComplete();");
			
			try
			{
				_world = mapLoader.makeWorld( 20 );
				_world.x = stage.stageWidth / 2;
				_world.y = 100;
				
				addChild( _world );
				makePlayer();
				
				stage.addEventListener( MouseEvent.CLICK, onGridClick );
				//stage.addEventListener( MouseEvent.MOUSE_MOVE, highlightTile );
				//stage.addEventListener( KeyboardEvent.KEY_DOWN, playerUp );
				
				
				//stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDownn);
				//stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUpp);
			}
			catch( error:Error )
			{
				trace( "Map Error: " + error.toString() );
			}
		}
		
		
		private function makePlayer() : void 
		{
			_player = new DrawnIsoBox( 20, 0xFF0000, 20 );
			_player.x = 20;
			_player.y = 00;
			_player.z = 20;
			
			_world.addChildToWorld( _player );
		}

		private function playerUp( event:KeyboardEvent ) : void 
		{
			if( event.keyCode == Keyboard.UP ){
				_player.y += -20;
			}else if( event.keyCode == Keyboard.DOWN ){
				_player.y += +20;
			}
			trace( "player up");
			_world.sort();
		}

		private function highlightTile( event:MouseEvent ) : void
		{
			var pos:Point3D = IsoUtils.screenToIso( new Point( _world.mouseX, _world.mouseY ) );
			//trace( _world.mouseX + "/" + pos.x + " --- " + _world.mouseY + "/" + pos.z );
			
			if( _world.isTileWalkable( pos.x, pos.y ) )
			{
				highlightedTile = new DrawnIsoTile( 20, 0xffffff, 0);
				highlightedTile.x = pos.x;
				highlightedTile.z = pos.y;	
			}
		}
		
		
		private function onGridClick( event:MouseEvent ) : void
		{
			clearPath();
			
			trace( "\n------------------" );
			trace( "Player [x -> " + _player.x + ", z -> " + _player.z + "]" );

			_world.setStartNode( _player.x, _player.z );
			
			var pos:Point3D = IsoUtils.screenToIso( new Point( _world.mouseX, _world.mouseY ) );
			pos.x = Math.round( pos.x / 20 ) * 20;
			pos.z = Math.round( pos.z / 20 ) * 20;

			_world.setEndNode( pos.x, pos.z );

			/*
			// make a green destination box and add to movie.
			var box:DrawnIsoBox = new DrawnIsoBox(20, 0x49E20E, 18);
			box.position = pos;
			_world.addChildToWorld(box);
			*/
			
			var teleport:Boolean = _world.isTileTeleportal( pos.x, pos.z );
			trace( "Teleport: " + teleport );
			
			findPath();
			
			trace( "------------------" );
		}
		
		private function findPath() : void
		{
			var astar:AStar = new AStar();
			
			if( astar.findPath( _world.getGrid() ) )
			{
				_path = astar.path;
				_index = 0;
				
				// Display isometric path to destination.
				//showPath( astar );

				addEventListener( Event.ENTER_FRAME, onEnterFrame );
			}
			
			astar = null;
			
		}
		

		// Finds the next node on the path and eases to it.
		private function onEnterFrame( event:Event ) : void
		{
			
			var targetX:Number = _path[_index].x * _cellSize + _cellSize / 20;
			var targetY:Number = _path[_index].y * _cellSize + _cellSize / 20;
			
			var dx:Number = targetX - _player.x - 1;
			var dy:Number = targetY - _player.z - 1;
			var dist:Number = Math.sqrt( dx * dx + dy * dy );
			
			
			if( dist < 1 )
			{
				_index++;
				if( _index >= _path.length )
				{
					removeEventListener( Event.ENTER_FRAME, onEnterFrame );
					
					
					if( _world.isTileTeleportal( _player.x, _player.z ) )
					{
						movePlayer( _player.x, _player.z);
					}
				}
			}
			else
			{
				_player.x += dx;
				_player.z += dy;
				_player.y = -_world.getTileHeight( _player.x, _player.z );
				
				// _world.getGrid().getNode( x, y ).tileHeight;
				
			}
			
			_world.sort();
		}
		
		private function movePlayer( x:int, y:int ) : void
		{
			if( x == 0 && y == 200){
				_player.x = 340;
				_player.z = 200;
			}else{
				_player.x = 20;
				_player.z = 200;
			}
			_world.sort();
		}
		
		private function showPath( astar:AStar ) : void
		{
			var path:Array = astar.path;
			_showPath = null;
			
			if( path.length > 0 ){
				_showPath = new Array();
				for( var i:int = 0; i < path.length; i++ )
				{
					/*graphics.lineStyle( 0 );
					graphics.beginFill( 0 );
					graphics.lineStyle( 2 );
					graphics.drawRect( path[i].x * _cellSize, path[i].y * _cellSize, 5, 5 );
					graphics.endFill();*/
					
					// highlight the designated path to destination.
					var point:Point3D = new Point3D( path[i].x, 0 , path[i].y );
					var hTile:DrawnIsoTile = new DrawnIsoTile( 20, 0xffff00, 0);
					
					point.x = Math.round( point.x / 20 ) * 20;
					point.z = Math.round( point.z / 20 ) * 20;
					
					hTile.x = path[i].x * 20;
					hTile.z = path[i].y * 20;
					hTile.y = -_world.getTileHeight( hTile.x, hTile.z );
					hTile.alpha = 0.3;
					_world.addChildToFloor( hTile );
					_showPath.push( hTile );
				}
			}
		}
		
		private function clearPath() : void 
		{
			if( _showPath.length > 0 ){
				for( var i:int = 0; i < _showPath.length; i++ ){
					_world.removeChildFromFloor( _showPath[i] );
				}
				
			}
		}
		
		
		
		
		
		
		
		
		
		/*
		private function onKeyDownn(event:KeyboardEvent):void
		{
			switch(event.keyCode)
			{
				case Keyboard.UP :
				_player.vx = -speed;
				break;
				
				case Keyboard.DOWN :
				_player.vx = speed;
				break;
				
				case Keyboard.LEFT :
				_player.vz = speed;
				break;
				
				case Keyboard.RIGHT :
				_player.vz = -speed;
				break;
				
				default :
				break;
				
			}
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function onKeyUpp(event:KeyboardEvent):void
		{
			_player.vx = 0;
			_player.vz = 0;
			
			trace( _world.getTileAt( _player.x, _player.z ) );
			
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function onEnterFrame(event:Event):void
		{
			if(_world.canMove(_player))
			{
				_player.x += _player.vx;
				_player.y += _player.vy;
				_player.z += _player.vz;
			}
			
			_world.sort();
		}*/
	}
}