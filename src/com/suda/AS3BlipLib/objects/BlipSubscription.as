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
				if (data.hasOwnProperty('tracking_user')) {
					this.trackingUser = new BlipUser(data.tracking_user);
					this.trackingUserPath = '/users/'+this.trackingUser.login;
				} else {				
					this.trackingUserPath = data.tracking_user_path;
				}
				
				if (data.hasOwnProperty('tracked_user')) {
					this.trackedUser = new BlipUser(data.tracked_user);
					this.trackedUserPath = '/users/'+this.trackedUser.login;
				} else {				
					this.trackedUserPath = data.tracked_user_path;
				}
								
				this.transports = new Array();
				this.transports.push( new BlipTransport(data.transport));
			}
		}

	}
}