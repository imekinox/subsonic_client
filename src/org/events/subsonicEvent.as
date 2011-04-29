package org.events
{
	import flash.events.Event;
	public class subsonicEvent extends Event {
		public static const CHANGED:String = 'CHANGED'; 
		
		public var data:*; 	
		public function subsonicEvent(type:String, data:*) {
			this.data= data;
			super(type);
		}
	}
}