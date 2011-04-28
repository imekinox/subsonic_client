package org.helpers
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class XMLH
	{
		public static function load(url:String, callback:Function, id:int = 0):void {
			var myLoader:URLLoader = new URLLoader();
			var request:URLRequest  = new URLRequest(url);
			myLoader.load(request);
			myLoader.addEventListener(Event.COMPLETE, function(event:Event):void {
				var obj:Object = new Object;
				obj.id = id;
				obj.data = new XML(event.target.data);
				callback(obj);
			});
		}
	}
}