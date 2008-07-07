package com.suda.AS3BlipLib.objects
{
	public class BlipSubscription
	{
		public var trackingUserPath:String;
		[Bindable]
		public var trackingUser:BlipUser;
		
		public var trackedUserPath:String;
		[Bindable]
		public var trackedUser:BlipUser;
		
		public var transports:Array;
		
		public function BlipSubscription(data:Object = null)
		{
			if (null != data) {
				this.trackingUserPath = data.tracking_user_path;
				this.trackedUserPath = data.tracked_user_path;				
				this.transports = new Array();
				this.transports.push( new BlipTransport(data.transport));
			}
		}

	}
}