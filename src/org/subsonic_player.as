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
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundLoaderContext;
	import flash.net.SharedObject;
	import flash.net.URLRequest;
	
	import org.events.subsonicEvent;
	import org.helpers.Json;
	import org.helpers.XMLH;

	/*
		subsonic player class
	*/
	public class subsonic_player extends EventDispatcher
	{
		public var username:String;
		public var password:String;
		public var server:String;
		public var playing:String = null;
		public var so:SharedObject = SharedObject.getLocal("subsonic_data");
		
		private var client_id:String = "subsonic_player";
		private var s:Sound;
		private var context:SoundLoaderContext;
		private var sc:SoundChannel;
		private var lastPosition:int = 0;
		private var currPlaying:int = 0;
		
		private var current_playlist:playlist;
		
		/*
			Constructor
			Setting object variables
		*/
		public function subsonic_player(){
			this.password = so.data.pass;
			this.username = so.data.user;
			this.server = so.data.server;
			sc = new SoundChannel();
			context = new SoundLoaderContext(3000, true);
		}
		
		/*
		 * Ping callback 
		 * called after loading the ping response from server
		 *
		 * @param obj Object with the response
		 * @param callback Method to call after validating auth
		 *
		 * @see login
		 */
		private function ping_done(obj:Object, callback:Function):void {
			if(obj.data["subsonic-response"].status == "ok"){
				var user_url:String = "http://"+this.server+"/rest/getUser.view?v=1.5.0&c="+this.client_id+"&f=json&username="+this.username;
				current_playlist = new playlist(this);
				if(so.data.currPlaylist) {
					current_playlist.createFromId(so.data.currPlaylist,function(arr:Array):void {
						Json.load(user_url, callback);
					});
				} else {
					current_playlist.create("temp");
					Json.load(user_url, callback);
				}
			}
		}
		
		/*
		* Login method 
		* Makes a ping to the server to check credentials
		*
		* @param server String of the server in format server:port
		* @param username String of the username login
		* @param password String of the password
		* @param store Boolean if we want to remember credentials
		* @param callback Function to call after auth (this is called in ping_done)
		*
		* @see ping_done
		*/
		public function login(server:String, username:String, password:String, store:Boolean, callback:Function):Boolean
		{
			if(store){
				so.data.pass = password;
				so.data.user = username;
				so.data.server = server;
				so.flush();
			}
			var ping_url:String = "http://"+server+"/rest/ping.view?u="+username+"&p="+password+"&v=1.5.0&c="+this.client_id+"&f=json";
			Json.load(ping_url, function(obj:Object):void{
				ping_done(obj, callback);
			});
			this.username = username;
			this.server  = server;
			this.password = password;
			return true;
		}
		
		/*
		* getUsers method 
		* Retrieves an object of the nowPlaying users
		*
		* @param callback Function to call after retreiving data
		*
		*/
		public function getUsers(callback:Function):void {
			var users_url:String = "http://"+this.server+"/rest/getNowPlaying.view?u="+this.username+"&p="+this.password+"&v=1.5.0&c="+this.client_id+"&f=json";
			Json.load(users_url,function(obj:Object):void {
				var tmp:Array = new Array();
				if(obj.data["subsonic-response"].nowPlaying.entry.length == undefined){
					tmp[0] = new Object();
					tmp[0]["username"] = obj.data["subsonic-response"].nowPlaying.entry.username;
					tmp[0]["listening"] = obj.data["subsonic-response"].nowPlaying.entry.artist + " - " + obj.data["subsonic-response"].nowPlaying.entry.title;
				} else {
					for(var i:int = 0, max:int = obj.data["subsonic-response"].nowPlaying.entry.length; i < max; i++){
						tmp[i] = new Object();
						tmp[i]["username"] = obj.data["subsonic-response"].nowPlaying.entry[i].username;
						tmp[i]["listening"] = obj.data["subsonic-response"].nowPlaying.entry[i].artist + " - " + obj.data["subsonic-response"].nowPlaying.entry[i].title;
					}
				}
				callback(tmp);	
			});
		}
		
		/*
		* getArtists method 
		* Retrieves an object of the indexed artists
		*
		* @param callback Function to call after retreiving data
		*
		*/
		public function getArtists(callback:Function):void {
			var artists_url:String = "http://"+this.server+"/rest/getIndexes.view?u="+this.username+"&p="+this.password+"&v=1.5.0&c="+this.client_id;
			XMLH.load(artists_url, function(obj:Object):void {
				var xml:XML = obj.data;
				callback(xml);
			});
		}
		
		/*
		* getAlbums method 
		* Retrieves an object of the selected artist albums
		*
		* @param id String of the subsonic id of the artist
		* @param callback Function to call after retreiving data
		*
		*/
		public function getAlbums(id:String, callback:Function):void {
			var albums_url:String = "http://"+this.server+"/rest/getMusicDirectory.view?u="+this.username+"&p="+this.password+"&v=1.5.0&c="+this.client_id+"&id="+id+"&f=json";
			Json.load(albums_url,function(obj:Object):void {
				var tmp:Array = new Array();
				if(obj.data["subsonic-response"].directory.child.length == undefined){
					tmp[0] = new Object();
					tmp[0]["id"] = obj.data["subsonic-response"].directory.child.id;
					tmp[0]["album"] = obj.data["subsonic-response"].directory.child.title;
				} else {
					for(var i:int = 0, max:int = obj.data["subsonic-response"].directory.child.length; i < max; i++){
						tmp[i] = new Object();
						tmp[i]["id"] = obj.data["subsonic-response"].directory.child[i].id;
						tmp[i]["album"] = obj.data["subsonic-response"].directory.child[i].title;
					}
				}
				callback(tmp);	
			});
		}		
		
		/*
		* getSongs method 
		* Retrieves an object of the selected album songs
		*
		* @param id String of the subsonic id of the album
		* @param callback Function to call after retreiving data
		*
		*/
		public function getSongs(id:String, callback:Function):void {
			var songs_url:String = "http://"+this.server+"/rest/getMusicDirectory.view?u="+this.username+"&p="+this.password+"&v=1.5.0&c="+this.client_id+"&id="+id+"&f=json";
			Json.load(songs_url,function(obj:Object):void {
				var tmp:Array = new Array();
				if(obj.data["subsonic-response"].directory.child.length == undefined){
					tmp[0] = new Object();
					tmp[0]["id"] = obj.data["subsonic-response"].directory.child.id;
					tmp[0]["song"] = obj.data["subsonic-response"].directory.child.title;
				} else {
					for(var i:int = 0, max:int = obj.data["subsonic-response"].directory.child.length; i < max; i++){
						tmp[i] = new Object();
						tmp[i]["id"] = obj.data["subsonic-response"].directory.child[i].id;
						tmp[i]["song"] = obj.data["subsonic-response"].directory.child[i].title;
					}
				}
				callback(tmp);	
			});
		}

		
		/*
		* getPlaylists method 
		* Retrieves an array of the stored playlists
		*
		* @param callback Function to call after retreiving data
		*
		*/
		public function getPlaylists(callback:Function):void {
			var playlists_url:String = "http://"+this.server+"/rest/getPlaylists.view?u="+this.username+"&p="+this.password+"&v=1.5.0&c="+this.client_id+"&f=json";
			Json.load(playlists_url,function(obj:Object):void {
				var tmp:Array = new Array();
				if(obj.data["subsonic-response"].playlists.playlist.length == undefined){
					tmp[0] = {
						label: obj.data["subsonic-response"].playlists.playlist.name,
						data:obj.data["subsonic-response"].playlists.playlist.id
					};
				} else {
					for(var i:int = 0, max:int = obj.data["subsonic-response"].playlists.playlist.length; i < max; i++){
						tmp[i] = {
								label: obj.data["subsonic-response"].playlists.playlist[i].name,
								data:obj.data["subsonic-response"].playlists.playlist[i].id
								};
					}
				}
				callback(tmp);
			});
		}
		
		/*
		* getPlaylist method 
		* Retrieves an array of the list of songs in the selected playlist
		*
		* @param id String of the subsonic id of the playlist
		* @param callback Function to call after retreiving data
		*
		*/
		public function getPlaylist(id:String, callback:Function):void {
			var playlist_url:String = "http://"+this.server+"/rest/getPlaylist.view?u="+this.username+"&p="+this.password+"&v=1.5.0&c="+this.client_id+"&id="+id+"&f=json";
			trace(playlist_url);
			Json.load(playlist_url,function(obj:Object):void {
				var tmp:Array = new Array();
				try{
					if(obj.data["subsonic-response"].playlist.entry.length == undefined){
						tmp[0] = obj.data["subsonic-response"].playlist.entry;
					} else {
						tmp = obj.data["subsonic-response"].playlist.entry;
					}	
				} catch(err:Error) {
					
				}
				callback(tmp, obj.data["subsonic-response"].playlist.name);
			});
		}
		
		/*
		* addSong method 
		* Adds the selected song to playlist
		*
		* @param id String of the subsonic id of the song
		*
		*/
		public function addSong(songs:Array, playlist_id:String):void {
			var id:String = songs.join("&songId=");
			var update_url:String = "http://"+this.server+"/rest/createPlaylist.view?u="+this.username+"&p="+this.password+"&v=1.5.0&c="+this.client_id+"&songId="+id+"&playlistId="+playlist_id+"&f=json";
			Json.load(update_url, function(obj:Object):void {});
		}
		
		/*
		* playSong method 
		* Streams the selected song id
		*
		* @param id String of the subsonic id of the song
		*
		*/
		public function playSong(id:String):void {
			var song_url:String = "http://"+this.server+"/rest/stream.view?u="+this.username+"&p="+this.password+"&v=1.5.0&c="+this.client_id+"&id="+id;
			if(s && s.bytesLoaded != s.bytesTotal) {
				s.close();
			}
			if(sc.position){
				sc.stop();
			}
			s = new Sound();
			s.addEventListener(Event.OPEN, sound_loaded);
			s.addEventListener(Event.COMPLETE, sound_complete);
			s.load(new URLRequest(song_url), context);
			this.playing = id;
			dispatchEvent(new subsonicEvent(subsonicEvent.CHANGED, {id:id}));
		}

		/*
		* playFrom method 
		* Streams the selected song id from the playlist
		*
		* @param id String of the subsonic id of the song
		*
		*/
		public function playFrom(id:String):void {
			for(var i:int, max:int = currPlaylist.songs.length; i < max; i++){
				if(currPlaylist.songs[i].id == id) currPlaying = i;
			}
			playSong(id);
		}
		
		/*
		* song_ended callback 
		* Song has finished playing, play next from the playlist
		*
		* @param e Event Object
		*
		*/
		public function song_ended(e:Event):void {
			currPlaying++;
			if(currPlaying < currPlaylist.songs.length){
				playSong(currPlaylist.songs[currPlaying].id);
			}
		}
		
		/*
		* sound_loaded callback 
		* After the sound has connected successfully we play the stream
		*
		* @param Event Sound event
		*
		*/
		private function sound_loaded(e:Event):void {
			sc = s.play();
			sc.addEventListener(Event.SOUND_COMPLETE, song_ended);
			s.removeEventListener(Event.OPEN, sound_loaded);
		}
		
		/*
		* sound_complete callback 
		* When the stream has finished downloading
		*
		* @param Event Sound event
		*
		*/
		private function sound_complete(e:Event):void {
			//something here
			s.removeEventListener(Event.COMPLETE, sound_complete);
		}
		
		/*
		* status getter 
		* Returns the current status of the playback
		*
		* @retunrs {bytesLoaded:, bytesTotal:, time:, duration:}
		*
		*/
		public function get status():Object {
			var tmp:Object = new Object;
			if(s){
				tmp.bytesLoaded = s.bytesLoaded;
				tmp.bytesTotal = s.bytesTotal;
				tmp.time = sc.position;
				tmp.duration = (s.bytesTotal / (s.bytesLoaded / s.length));
			}
			return tmp;
		}
		
		/*
		* currPlaylist getter 
		* Returns the current playlist object
		*
		* @retunrs playlist object
		*
		*/
		public function get currPlaylist():playlist {
			return current_playlist; 
		}
		
		/*
		* status setter 
		* set the current_playlist object and stores the current id in the shared object
		*
		* @param obj playlist
		*
		*/
		public function set currPlaylist(obj:playlist):void {
			so.data.currPlaylist = obj.id;
			current_playlist = obj;
		}
		
		/*
		* Play method
		* Plays a paused audio
		*/
		public function play():void{
			sc = s.play(lastPosition);
		}
		
		/*
		* Pause method
		* Pause current audio stream
		*/
		public function pause():void {
			lastPosition = sc.position;
			sc.stop();
		}
	}
}