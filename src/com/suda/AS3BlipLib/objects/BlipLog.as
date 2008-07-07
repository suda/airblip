package com.suda.AS3BlipLib.objects
{
	import com.suda.*;

	public class BlipLog extends CustomArrayCollection
	{
		public var login:String;
		public var tag:String;
		public var lastId:int;
		
		public function BlipLog(source:Object = null)
		{
			super(null);
			for each (var item:Object in source) {
				var update:*;				
				if ('Status' == item.type) {
					update = new BlipStatus(item);
				} else if ('DirectedMessage' == item.type) {
					update = new BlipDirectedMessage(item);
				}
				
				if (item.hasOwnProperty('user')) {
					update.user = new BlipUser(item.user);
					update.userPath = update.user.userPath;
					
					if (item.user.hasOwnProperty('avatar')) {
						update.user.avatar = new BlipAvatar(item.user.avatar);
					}				
				}
				
				if (item.hasOwnProperty('pictures')) {
					for each (var picture in item.pictures) {
						update.pictures.push(new BlipPicture(picture));
					}
				}
				
				if (this.lastId < item.id) {
					this.lastId = item.id;	
				}				
				this.addItem(update);
			}
		}
		
		public function AddUpdates(data:*):void {		
			if (0 < data.length) {	
				
				for (var i:int = data.length; i > 0; i--) {
					if (data[i-1].id > this.lastId) {
						this.addItemAt(data[i-1], 0);
					}
				}
				
				this.lastId = data.lastId;
			}
		}
		
	}
}