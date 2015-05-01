package com.isometric {
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.getDefinitionByName;
	
	import com.core.Utils;
	import com.pathfinding.Grid;
	
	
	public class MapLoader extends EventDispatcher 
	{
		
		// Constants:
		
		// Public Properties:
		
		// Private Properties:
		private var _grid:Array;
		private var _loader:URLLoader;
		private var _tileTypes:Object;
		
		
		private var _Agrid:Grid;
		
		// Initialization:
		public function MapLoader() : void
		{ 
			_tileTypes = new Object();
		}
	
	
		// Public Methods:
		override public function toString() : String 
		{
            return "MapLoader";
        }
		
		
		/**
		 * Loads a text file from the specified url.
		 * @param url The location of the text file to load.
		 */
		public function loadMap( url:String ) : void
		{
			_loader = new URLLoader();
			_loader.addEventListener( Event.COMPLETE, onLoadMap );
			_loader.load( new URLRequest( url ) );
		}
		
		
		/**
		 * Links a symbol with a definition object.
		 * @param symbol The character to use for the definition.
		 * @param definition A generic object with definition properties
		 */
		public function setTileType( symbol:String, definition:Object ) : void
		{ 
			_tileTypes[symbol] = definition;
		}

		
		/**
		 * Creates an IsoWorld, iterates through loaded map, adding tiles to it based on map and definitions.
		 * @size The tile size to use when making the world.
		 * @return A fully populated IsoWorld instance.
		 */
		public function makeWorld( size:Number ) : IsoWorld
		{
			trace("MapLoader.makeWorld(" + size + ");");
			
			var world:IsoWorld = new IsoWorld();
			var debug:Utils = new Utils();
			
			for( var i:int = 0; i < _grid.length; i++ )
			{
				for( var j:int = 0; j < _grid[i].length; j++ )
				{
					var cellType:String = _grid[i][j];
					var cell:Object = _tileTypes[cellType];
					var tile:IsoObject;
					
					trace( "[" + i + "/" + j + "]" );
					debug.deepTrace( _tileTypes[cellType], 1 );
					
					switch( cell.type )
					{
						case "DrawnIsoTile":
							tile = new DrawnIsoTile( size, parseInt( "" + cell.color ), 0 );
						break;
						
						case "DrawnIsoTileTeleport":
							tile = new DrawnIsoTile( size, parseInt( "" + cell.color ), 0, cell.teleport );
							world.getGrid().setTeleportal( j, i, cell.teleport );
						break;
						
						case "DrawnIsoBox":
							tile = new DrawnIsoBox( size, parseInt( cell.color ), parseInt( cell.height ) );
						break;
						
						case "GraphicTile":
							var graphicClass:Class = getDefinitionByName( cell.graphicClass ) as Class;
							tile = new GraphicTile( size, graphicClass, parseInt( cell.xoffset ), parseInt( cell.yoffset ) );
						break;
						
						case "IsoObject":
							tile = new IsoObject( size );
						break;
						
						default:
							tile = new IsoObject( size );
						break;
					}

					tile.walkable = cell.walkable == "true";
					world.getGrid().setWalkable( j, i, tile.walkable );
					world.getGrid().setTileHeight( j, i, parseInt( cell.height ) );

					tile.x = j * size;
					tile.z = i * size;
					tile.j = j;
					tile.i = i;
					
					//trace( "tile [" + i + ", " + j +", " + tile.x + ", " + tile.z + ", " + tile.y + ", " + tile.walkable + "]");
					
					if( cell.type == "DrawnIsoTile" || cell.type == "DrawnIsoTileTeleport" || ( cell.type == "DrawnIsoBox" && tile.walkable == true )  ){
						world.addChildToFloor( tile );
						//world.addChildToWorld( tile );
					}else{
						world.addChildToWorld( tile );
						//world.addChildToFloor( tile );
					}
					
					
					//trace( "" );
				}
			}
			
			return world;
		}
		
		
		
		// Protected Methods:
		
		/**
		 * Parses text file into tile definitions and map.
		 */
		private function onLoadMap( event:Event ) : void
		{
			trace("MapLoader.onLoadMap();");
			
			_grid = new Array();
			var data:String = _loader.data;
			
			// first get each line of the file.
			var lines:Array = data.split("\n");
			
			for( var i:int = 0; i < lines.length; i++ )
			{
				var line:String = lines[i];
				
				line = removeSpecialCharacters( line );
				
				// if line is a tile type definition.
				if( isDefinition( line ) )
				{
					parseDefinition( line );
				}
				// otherwise, if line is not empty and not a comment, it's a list of tile types. add them to grid.
				else if( !lineIsEmpty( line ) && !isComment( line ) )
				{
					var cells:Array = line.split(" ");
					_grid.push( cells );
				}
			}
			
			dispatchEvent( new Event( Event.COMPLETE ) );
		}
		
		
		private function removeSpecialCharacters( line:String ) : String 
		{
			line = line.split("\n").join("");
			line = line.split("\r").join("");
			return line;
		}
		
		private function parseDefinition( line:String ) : void
		{
			// break apart the line into tokens
			var tokens:Array = line.split(" ");
			
			// get rid of #
			tokens.shift(); 
			
			// first token is the symbol
			var symbol:String = tokens.shift() as String;
			
			// loop through the rest of the tokens, which are key/value pairs separated by :
			var definition:Object = new Object();
			
			for( var i:int = 0; i < tokens.length; i++ )
			{
				var key:String = tokens[i].split(":")[0];
				var val:String = tokens[i].split(":")[1];
				definition[key] = val;
			}
			
			// register the type and definition
			setTileType( symbol, definition );
		}
		
		
		/**
		 * Returns true if line contains only spaces, false if any other characters.
		 * @param line The string to test.
		 */
		private function lineIsEmpty( line:String ) : Boolean
		{
			for( var i:int = 0; i < line.length; i++ )
			{
				if( line.charAt(i) != " " || line.charAt(i) != "\n" || line.charAt(i) != "\r" ) return false;
			}
			
			return true;
		}
		
		
		/**
		 * Returns true if line is a comment (starts with //).
		 * @param line The string to test.
		 */
		private function isComment( line:String ) : Boolean
		{
			return line.indexOf( "//" ) == 0;
		}
		
		
		/**
		 * Returns true if line is a definition (starts with #).
		 * @param line The string to test.
		 */
		private function isDefinition( line:String ) : Boolean
		{
			return line.indexOf( "#" ) == 0;
		}
	}
	
}