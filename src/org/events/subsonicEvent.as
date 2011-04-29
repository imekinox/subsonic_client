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
package org.events
{
	import flash.events.Event;
	/*
	Extending Flash Event so we can pass custom data throug the dispatched event
	*/
	public class subsonicEvent extends Event {
		public static const CHANGED:String = 'CHANGED'; 
		
		public var data:*; 	
		public function subsonicEvent(type:String, data:*) {
			this.data= data;
			super(type);
		}
	}
}