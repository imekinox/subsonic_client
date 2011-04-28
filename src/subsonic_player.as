package
{
	import flash.data.EncryptedLocalStore;
	import flash.display.Sprite;
	import flash.utils.ByteArray;
	
	import org.helpers.Json;
	
	public class subsonic_player extends Sprite
	{
		public var username:String;
		public var password:String;
		public var server:String;
		private var storageArray:ByteArray;
		
		public function subsonic_player(){
			storageArray = new ByteArray();
			if((storageArray = EncryptedLocalStore.getItem("pass")))
				this.password = storageArray.readUTFBytes(storageArray.length);
			if((storageArray = EncryptedLocalStore.getItem("user")))
				this.username = storageArray.readUTFBytes(storageArray.length);
			if((storageArray = EncryptedLocalStore.getItem("server")))
				this.server = storageArray.readUTFBytes(storageArray.length);
		}
		
		private function ping_done(obj:Object, callback:Function):void {
			if(obj.data["subsonic-response"].status == "ok"){
				var user_url:String = "http://"+this.server+"/rest/getUser.view?v=1.5.0&c=asd&f=json&username="+this.username;
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
			var ping_url:String = "http://"+server+"/rest/ping.view?u="+username+"&p="+password+"&v=1.5.0&c=subsonic_player&f=json";
			Json.load(ping_url, function(obj:Object):void{
				ping_done(obj, callback);
			});
			this.username = username;
			this.server  = server;
			this.password = password;
			return true;
		}
	}
}