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
		
		public function createFromId(_id:String, callback:Function):void {
			player.getPlaylist(_id, function(arr:Array, _name:String):void {
				id = _id;
				name = _name;
				type = "remote";
				songs = arr;
				callback(arr);
			});
		}
		
		public function addSong(id:String, name:String):void {
			songs.push({id:id, name:name});
			switch(this.type){
				case "local":
					player.currPlaylist = this;
					break;
				case "remote":
					player.addSong(id, this.id);
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
		
		public function save():void {

		}
	}
}