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
	import flash.net.SharedObject;
	import flash.net.URLRequest;
	
	import flash.display.Sprite;
	
	import flash.events.Event;
	
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundLoaderContext;
	
	import org.helpers.Json;
	import org.helpers.XMLH;
	/*
		subsonic player class
	*/
	public class subsonic_player extends Sprite
	{
		public var username:String;
		public var password:String;
		public var server:String;
		private var client_id:String = "subsonic_player";
		private var s:Sound;
		private var context:SoundLoaderContext;
		private var sc:SoundChannel;
		private var lastPosition:int = 0;
		private var so:SharedObject = SharedObject.getLocal("subsonic_data");
		
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
				Json.load(user_url, callback);
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
				for(var i:int = 0, max:int = obj.data["subsonic-response"].nowPlaying.entry.length; i < max; i++){
					tmp[i] = new Object();
					tmp[i]["username"] = obj.data["subsonic-response"].nowPlaying.entry[i].username;
					tmp[i]["listening"] = obj.data["subsonic-response"].nowPlaying.entry[i].artist + " - " + obj.data["subsonic-response"].nowPlaying.entry[i].title;
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
		* playSong method 
		* Streams de selected song id
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