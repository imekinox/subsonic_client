package
{
	import flash.display.Sprite;
	import flash.utils.ByteArray;
	import flash.data.EncryptedLocalStore;
	
	public class subsonic_player extends Sprite
	{
		public var username:String;
		public var password:String;
		private var storageArray:ByteArray;
		
		public function subsonic_player(){
			storageArray = new ByteArray();
			if((storageArray = EncryptedLocalStore.getItem("pass"))){
				this.password = storageArray.readUTFBytes(storageArray.length);
				storageArray = EncryptedLocalStore.getItem("user")
				this.username = storageArray.readUTFBytes(storageArray.length);
			}
		}
		
		public function login(username:String, password:String, store:Boolean):void
		{
			if(store){
				storageArray = new ByteArray();
				storageArray.writeUTFBytes(password);
				trace(EncryptedLocalStore.isSupported);
				EncryptedLocalStore.setItem("pass", storageArray);
				storageArray.clear();
				storageArray.writeUTFBytes(username);
				EncryptedLocalStore.setItem("user", storageArray);
				storageArray.clear();
			}
			this.username = username;
			this.password = password;
		}
	}
}