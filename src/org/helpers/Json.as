/**
 * subsonic desktop client
 *
 * Copyright (c) 2011 Juan Carlos del Valle (imekinox.com) <jc.ekinox@gmail.com>
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * @license http://www.gnu.org/licenses/gpl.html
 * @project subsonic.player
 */

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
					obj.data = JSON.decode(event.target.data.replace("&#146;","\'"));
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

