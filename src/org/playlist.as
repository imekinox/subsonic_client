package org
{
	public class playlist
	{
		private var player:subsonic_player;
		
		public var songs:Array;
		public var type:String;
		public var id:String;
		public var name:String;
		
		public function playlist(ref:subsonic_player) {
			player = ref;
		}
		
		public function create(_name:String):void {
			name = _name;
			type = "local";
			songs = new Array();
		}
		
		public function createFromId(id:String, callback:Function = null):void {
			this.id = id;
			var _this:playlist = this;
			player.getPlaylist(id, function(arr:Array, name:String):void {
				_this.name = name;
				_this.type = "remote";
				_this.songs = arr;
				player.currPlaylist = _this; //Update stored reference
				if(callback != null) callback(arr);
			});
		}
		
		public function addSong(song:Object):void {
			songs.push({id:song.id, name:song.song});
			switch(this.type){
				case "local":
					player.currPlaylist = this;
					break;
				case "remote":
					player.addSong(song.id, this.id);
					break;
			}
		}
		
		public function removeSong(id:String):void {
			var index:int = -1;
			for(var i:int, max:int = songs.length; i < max; i++){
				if(songs[i].id == id) index = i;	
			}
			if(index != -1) songs.splice(index, 1);
		}
	}
}