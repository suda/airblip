package com.suda.AS3BlipLib.objects
{
	public class BlipDirectedMessage extends BlipUpdate
	{
		[Bindable]
		public var recipientPath:String;

		[Bindable]
		public var recipient:BlipUser;
		
		public function BlipDirectedMessage(data:Object = null)
		{
			super(data);
			
			if (null != data) {
				this.recipientPath = data.recipient_path;
			}
		}

	}
}