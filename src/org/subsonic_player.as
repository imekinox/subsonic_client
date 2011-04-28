package org
{
	import flash.data.EncryptedLocalStore;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundLoaderContext;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import org.helpers.Json;
	import org.helpers.XMLH;
	
	public class subsonic_player extends Sprite
	{
		public var username:String;
		public var password:String;
		public var server:String;
		private var storageArray:ByteArray;
		private var client_id:String = "subsonic_player";
		private var s:Sound;
		private var context:SoundLoaderContext;
		private var sc:SoundChannel;
		private var lastPosition:int = 0;
		
		public function subsonic_player(){
			storageArray = new ByteArray();
			if((storageArray = EncryptedLocalStore.getItem("pass")))
				this.password = storageArray.readUTFBytes(storageArray.length);
			if((storageArray = EncryptedLocalStore.getItem("user")))
				this.username = storageArray.readUTFBytes(storageArray.length);
			if((storageArray = EncryptedLocalStore.getItem("server")))
				this.server = storageArray.readUTFBytes(storageArray.length);
			
			sc = new SoundChannel();
			context = new SoundLoaderContext(3000, true);
		}
		
		private function ping_done(obj:Object, callback:Function):void {
			if(obj.data["subsonic-response"].status == "ok"){
				var user_url:String = "http://"+this.server+"/rest/getUser.view?v=1.5.0&c="+this.client_id+"&f=json&username="+this.username;
				Json.load(user_url, callback);
			}
		}
		
		public function login(server:String, username:String, password:String, store:Boolean, callback:Function):Boolean
		{
			if(store && EncryptedLocalStore.isSupported){
				storageArray = new ByteArray();
				storageArray.writeUTFBytes(password);
				EncryptedLocalStore.setItem("pass", storageArray);
				storageArray.clear();
				storageArray.writeUTFBytes(username);
				EncryptedLocalStore.setItem("user", storageArray);
				storageArray.clear();
				storageArray.writeUTFBytes(server);
				EncryptedLocalStore.setItem("server", storageArray);
				storageArray.clear();
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
		
		public function getArtists(callback:Function):void {
			var artists_url:String = "http://"+this.server+"/rest/getIndexes.view?u="+this.username+"&p="+this.password+"&v=1.5.0&c="+this.client_id;
			XMLH.load(artists_url, function(obj:Object):void {
				var xml:XML = obj.data;
				callback(xml);
			});
		}
		
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

		private function sound_loaded(e:Event):void {
			sc = s.play();	
			s.removeEventListener(Event.OPEN, sound_loaded);
		}
		
		private function sound_complete(e:Event):void {
			//trace("finished");
			s.removeEventListener(Event.COMPLETE, sound_complete);
		}
		
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
		
		public function play():void{
			sc = s.play(lastPosition);
		}
		
		public function pause():void {
			lastPosition = sc.position;
			sc.stop();
		}
	}
}