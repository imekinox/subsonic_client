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
package org
{
	/*
	palylist class
	*/
	public class playlist
	{
		private var player:subsonic_player;
		
		public var songs:Array;
		public var type:String;
		public var id:String;
		public var name:String;
		
		/*
		Constructor
		Setting reference to the subsonic_player object
		*/
		public function playlist(ref:subsonic_player) {
			player = ref;
		}
		
		/*
		* create method 
		* Used to create a new playlist
		*
		* @param _name String name of the playlist
		*/
		public function create(_name:String):void {
			name = _name;
			type = "local";
			songs = new Array();
		}
		
		/*
		* createFromId method 
		* Used to load a playlist from server
		*
		* @param id String id of the desired playlist
		* @param callback Function to call after loading playlist
		*/
		public function createFromId(id:String, callback:Function = null):void {
			this.id = id;
			var _this:playlist = this;
			//We assign class properties when loaded before firing callback
			player.getPlaylist(id, function(arr:Array, name:String):void {
				_this.name = name;
				_this.type = "remote";
				_this.songs = arr;
				//Needed to update stored reference (id of the currPlaylist in shared object)
				player.currPlaylist = _this;
				if(callback != null) callback(arr);
			});
		}
		
		/*
		* addSong method 
		* Adds a song to the remote or local playlist
		*
		* @param song Object 
		*/
		public function addSong(song:Object):void {
			//this object comes from the data grid
			songs.push({id:song.id, name:song.song});
			if(this.type == "remote") updatePlaylist();
		}
		
		/*
		* addAlbum method 
		* Adds an album to the remote or local playlist
		*
		* @param album_id String 
		*/
		public function addAlbum(album_id:String):void {
			trace(album_id);
			player.getSongs(album_id, function(arr:Array):void {
				trace(arr.length);
				for(var i:int = 0, max:int = arr.length; i < max; i++){
					songs.push({id:arr[i].id, name:arr[i].title});	
				}
				if(type == "remote") updatePlaylist();
			});
		}
		
		/*
		* updatePlaylist method 
		* Updates remote playlist with new array;
		*/
		private function updatePlaylist():void {
			//update server's playlist
			var tmp:Array = new Array();
			for(var i:int = 0, max:int = songs.length; i < max; i++){
				tmp.push(songs[i].id);
			}
			player.addSong(tmp, this.id);
		}
		
		/*
		* removeSong method 
		* Removes a song from the songs array
		*
		* @param id String Subsonic id of the song to be removed 
		*/
		public function removeSong(id:String):void {
			var index:int = -1;
			for(var i:int, max:int = songs.length; i < max; i++){
				if(songs[i].id == id) index = i;	
			}
			if(index != -1) songs.splice(index, 1);
		}
	}
}