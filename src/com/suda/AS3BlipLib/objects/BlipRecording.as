package com.suda.AS3BlipLib.objects
{
	public class BlipRecording
	{
		public var id:int;
		public var url:String;
		
		public function BlipRecording(data:Object = null)
		{
			if (null != data) {
				this.id = data.id;
				this.url = data.url;
			}
		}

	}
}