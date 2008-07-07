package com.suda.AS3BlipLib.objects
{
	public class BlipTransport
	{
		public var id:int;
		[Bindable]
		public var name:String;
		
		public function BlipTransport(data:Object = null)
		{
			if (null != data) {
				this.id = data.id;
				this.name = data.name;
			}
		}

	}
}