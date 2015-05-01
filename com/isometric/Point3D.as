package com.isometric {
	
	public class Point3D {
		
		// Constants:
		
		// Public Properties:
		public var x:Number;
		public var y:Number;
		public var z:Number;
		
		// Private Properties:
	
		// Initialization:
		public function Point3D( x:Number = 0, y:Number = 0, z:Number = 0 ) : void
		{
			this.x = x;
			this.y = y;
			this.z = z;
		}
	
		// Public Methods:
		public function toString() : String {
            return "Point3D";
        }
		
		
		// Protected Methods:
		
		
	}
	
}