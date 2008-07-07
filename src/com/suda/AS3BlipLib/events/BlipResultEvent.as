package com.suda.AS3BlipLib.events
{
	import com.adobe.webapis.events.ServiceEvent;
	
	import flash.events.Event;

	public class BlipResultEvent extends ServiceEvent
	{
		public static const ON_GET_BLIPOSPHERE:String = "onGetBliposphere";
		
		public static const ON_GET_DASHBOARD:String = "onGetDashboard";
		public static const ON_GET_USER_DASHBOARD:String = "onGetUserDashboard";
		
		public static const ON_GET_USER:String = "onGetUser";
		
		public static const ON_GET_STATUSES:String = "onGetStatuses";
		public static const ON_GET_USER_STATUSES:String = "onGetUserStatuses";		
		public static const ON_GET_STATUS:String = "onGetStatus";
		public static const ON_SET_STATUS:String = "onSetStatus";
		public static const ON_DEL_STATUS:String = "onDelStatus";
		
		public static const ON_GET_AVATAR:String = "onGetAvatar";
		public static const ON_SET_AVATAR:String = "onSetAvatar";
		public static const ON_GET_BACKGROUND:String = "onGetBackground";
		public static const ON_SET_BACKGROUND:String = "onSetBackground";
		
		public static const ON_GET_UPDATES:String = "onGetUpdates";
		public static const ON_GET_USER_UPDATES:String = "onGetUserUpdates";
		public static const ON_GET_UPDATE:String = "onGetUpdate";
		public static const ON_SEND_UPDATE:String = "onSendUpdate";
		public static const ON_DEL_UPDATE:String = "onDelUpdate";
		
		public static const ON_GET_DMS:String = "onGetDms";
		public static const ON_GET_USER_DMS:String = "onGetUserDms";
		public static const ON_GET_DM:String = "onGetDm";
		public static const ON_SEND_DM:String = "onSendDm";
		public static const ON_DEL_DM:String = "onDelDm";
		
		public static const ON_GET_MOVIE:String = "onGetMovie";
		public static const ON_GET_RECORDING:String = "onGetRecording";
		
		public static const ON_GET_UPDATE_PICTURES:String = "onGetUpdatePictures";
		public static const ON_GET_PICTURES:String = "onGetPictures";
		
		public static const ON_GET_SHORTLINKS:String = "onGetShortlinks";
		
		public static const ON_GET_SUBS:String = "onGetSubs";
		public static const ON_GET_SUBS_FROM:String = "onGetSubsFrom";
		public static const ON_GET_SUBS_TO:String = "onGetSubsTo";
		public static const ON_GET_USER_SUBS:String = "onGetUserSubs";
		public static const ON_GET_USER_SUBS_FROM:String = "onGetUserSubsFrom";
		public static const ON_GET_USER_SUBS_TO:String = "onGetUserSubsTo";
		public static const ON_SET_SUB:String = "onSetSub";
		public static const ON_DEL_SUB:String = "onDelSub";
		
		public static const ON_GET_TAG_UPDATES:String = "onGetTagUpdates";
		
		public var path:String = '';
		
		public function BlipResultEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
        {
        	super(type, bubbles, cancelable);
        }
        
        public override function clone():Event{
            return new BlipResultEvent(type);
        }

		
	}
}