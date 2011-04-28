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