package org.helpers
{
	import com.adobe.serialization.json.JSON;
	
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class Json
	{
		public static function load(url:String, callback:Function, id:int = 0):void {
			var loader:URLLoader = new URLLoader();
			var request:URLRequest  = new URLRequest(url);
			loader.addEventListener(Event.COMPLETE, function(event:Event):void {
				var obj:Object = new Object;
				obj.id = id;
		        try {
					obj.data = JSON.decode(event.target.data);
					callback(obj);
		        } catch(e:Error){
		        	trace("Json ERROR!:"+e.message);
					trace(event.target.data);
		        }
			});
			loader.load(request);
		}
   
	}
}

