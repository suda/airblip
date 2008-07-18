package com.suda.AS3BlipLib.objects
{
	public class BlipPicture
	{
		public var id:int;
		public var url:String;
		public var updatePath:String;
		
		public function BlipPicture(data:Object = null)
		{
			if (null != data) {
				this.id = data.id;
				this.url = data.url;
				this.updatePath = data.update_path;
			}
		}

	}
}