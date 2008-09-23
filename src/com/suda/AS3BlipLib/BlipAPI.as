package com.suda.AS3BlipLib
{
	import com.adobe.net.*;
	import com.adobe.serialization.json.*;
	import com.adobe.webapis.URLLoaderBase;
	import com.arc90.rpc.*;
	import com.arc90.rpc.events.ResultEvent;
	import com.arc90.rpc.rest.*;
	import com.hurlant.util.Base64;
	import com.suda.*;
	import com.suda.AS3BlipLib.events.*;
	import com.suda.AS3BlipLib.objects.*;
	
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	
	[Event(name="onGetBliposphere", type="com.suda.AS3BlipLib.events.BlipResultEvent")]
	[Event(name="onGetDashboard", type="com.suda.AS3BlipLib.events.BlipResultEvent")]
	[Event(name="onGetUserDashboard", type="com.suda.AS3BlipLib.events.BlipResultEvent")]
	[Event(name="onGetUser", type="com.suda.AS3BlipLib.events.BlipResultEvent")]
	[Event(name="onGetStatuses", type="com.suda.AS3BlipLib.events.BlipResultEvent")]
	[Event(name="onGetUserStatuses", type="com.suda.AS3BlipLib.events.BlipResultEvent")]
	[Event(name="onGetStatus", type="com.suda.AS3BlipLib.events.BlipResultEvent")]
	[Event(name="onSetStatus", type="com.suda.AS3BlipLib.events.BlipResultEvent")]
	[Event(name="onDelStatus", type="com.suda.AS3BlipLib.events.BlipResultEvent")]
	[Event(name="onGetAvatar", type="com.suda.AS3BlipLib.events.BlipResultEvent")]
	[Event(name="onSetAvatar", type="com.suda.AS3BlipLib.events.BlipResultEvent")]
	[Event(name="onGetBackground", type="com.suda.AS3BlipLib.events.BlipResultEvent")]
	[Event(name="onSetBackground", type="com.suda.AS3BlipLib.events.BlipResultEvent")]
	[Event(name="onGetUpdates", type="com.suda.AS3BlipLib.events.BlipResultEvent")]
	[Event(name="onGetUserUpdates", type="com.suda.AS3BlipLib.events.BlipResultEvent")]
	[Event(name="onGetUpdate", type="com.suda.AS3BlipLib.events.BlipResultEvent")]
	[Event(name="onSendUpdate", type="com.suda.AS3BlipLib.events.BlipResultEvent")]
	[Event(name="onDelUpdate", type="com.suda.AS3BlipLib.events.BlipResultEvent")]
	[Event(name="onGetDms", type="com.suda.AS3BlipLib.events.BlipResultEvent")]
	[Event(name="onGetUserDms", type="com.suda.AS3BlipLib.events.BlipResultEvent")]
	[Event(name="onGetDm", type="com.suda.AS3BlipLib.events.BlipResultEvent")]
	[Event(name="onSendDm", type="com.suda.AS3BlipLib.events.BlipResultEvent")]
	[Event(name="onDelDm", type="com.suda.AS3BlipLib.events.BlipResultEvent")]
	[Event(name="onGetMovie", type="com.suda.AS3BlipLib.events.BlipResultEvent")]
	[Event(name="onGetRecording", type="com.suda.AS3BlipLib.events.BlipResultEvent")]
	[Event(name="onGetUpdatePictures", type="com.suda.AS3BlipLib.events.BlipResultEvent")]
	[Event(name="onGetPictures", type="com.suda.AS3BlipLib.events.BlipResultEvent")]
	[Event(name="onGetShortlinks", type="com.suda.AS3BlipLib.events.BlipResultEvent")]
	[Event(name="onGetSubs", type="com.suda.AS3BlipLib.events.BlipResultEvent")]
	[Event(name="onGetSubsFrom", type="com.suda.AS3BlipLib.events.BlipResultEvent")]
	[Event(name="onGetSubsTo", type="com.suda.AS3BlipLib.events.BlipResultEvent")]
	[Event(name="onGetUserSubs", type="com.suda.AS3BlipLib.events.BlipResultEvent")]
	[Event(name="onGetUserSubsFrom", type="com.suda.AS3BlipLib.events.BlipResultEvent")]
	[Event(name="onGetUserSubsTo", type="com.suda.AS3BlipLib.events.BlipResultEvent")]
	[Event(name="onSetSub", type="com.suda.AS3BlipLib.events.BlipResultEvent")]
	[Event(name="onDelSub", type="com.suda.AS3BlipLib.events.BlipResultEvent")]
	[Event(name="onGetTagUpdates", type="com.suda.AS3BlipLib.events.BlipResultEvent")]

	public class BlipAPI extends URLLoaderBase
	{
		private var AppName:String;		
		private var Service:RESTService;
		
		private var limit:int = 50;
		public var username:String = '';
		public var passwd:String = '';
		private var rootURL:String = 'http://api.blip.pl';
		
		public static const AS3_BLIP_LIB_VERSION:String = "0.2";
		
		public function BlipAPI(AppName:String="AS3BlipLib")
		{
			this.AppName = AppName;
  			/*  
			this.Service = new RESTService('http://api.blip.pl');
			 	
			this.Service.resultFormat = RESTService.RESULT_FORMAT_JSON;
			this.Service.contentType = RESTService.CONTENT_TYPE_JSON;
		 	this.Service.userAgent = this.AppName;
		 	this.Service.headers = {'X-Blip-API': '0.02'};
		  */
		}
		
		public function LogIn(username:String, passwd:String):void {
			this.username = username;
			this.passwd = passwd;
			//this.Service.setCredentials(this.username, this.passwd);
			
			// TODO: Weryfikacja zalogowania			
			//this.GetUser(this.username);
		}
 
 		/***************************************************
		 * Bliposphere
		 ***************************************************/
		public function GetBliposphere(includeResources:Array = null):void
		{	
			var urlRequest:URLRequest;
            var urlLoader:DynamicURLLoader = getURLLoader();
            var url:String = '/bliposphere';
            
            url += (null != includeResources) ? '?include=' + includeResources.join(',') : '';
			
            urlRequest = getURLRequest(url, URLRequestMethod.GET, null);
                        
            urlLoader.addEventListener(Event.COMPLETE, onGetBliposphere);
            urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
            urlLoader.addEventListener(Event.COMPLETE, onComplete);
            urlLoader.addEventListener(Event.OPEN, onOpen);
            urlLoader.load(urlRequest);
		}
		
		/************ Listener **************/
		public function onGetBliposphere(event:Event):void
		{

			var bliposphere:BlipLog = new BlipLog(JSON.decode(event.target.data));		
			var blipResultEvent:BlipResultEvent = new BlipResultEvent(BlipResultEvent.ON_GET_BLIPOSPHERE);
			blipResultEvent.data = bliposphere;
			dispatchEvent(blipResultEvent);
		}
		
		/***************************************************
		 * Dashboard
		 ***************************************************/
		public function GetDashboard(since:int = -1, includeResources:Array = null):void
		{
            GetUserDashboard(this.username, since, includeResources);					
		}
		
		public function GetUserDashboard(login:String, since:int = -1, includeResources:Array = null):void
		{
			var url:String;
			if (this.username == login) {
				url = '/dashboard';
			} else {
				url = '/users/'+login+'/dashboard';
			}
			
			if (-1 < since) {
				url += '/since/'+since;
			}
						
			url += (null != includeResources) ? '?include=' + includeResources.join(',') : '';	
			
			var urlRequest:URLRequest;
            var urlLoader:DynamicURLLoader = getURLLoader();
            urlRequest = getURLRequest(url, URLRequestMethod.GET, null);
                        
            urlLoader.addEventListener(Event.COMPLETE, onGetUserDashboard);
            urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			urlLoader.addEventListener(Event.COMPLETE, onComplete);
			urlLoader.addEventListener(Event.OPEN, onOpen);
            urlLoader.login = login;
            urlLoader.load(urlRequest);				
		}
		
		/************ Listener **************/
		public function onGetUserDashboard(event:Event):void
		{
			var userDashboard:BlipLog = new BlipLog(JSON.decode(event.target.data));		
			userDashboard.login = event.target.login;
						
			var blipResultEvent:BlipResultEvent;
			if (this.username == event.target.login) {
				blipResultEvent = new BlipResultEvent(BlipResultEvent.ON_GET_DASHBOARD);
			} else {
				blipResultEvent = new BlipResultEvent(BlipResultEvent.ON_GET_USER_DASHBOARD);
			}
			blipResultEvent.data = userDashboard;
			dispatchEvent(blipResultEvent);
		}
		
		/***************************************************
		 * Users
		 ***************************************************/
		public function GetUser(login:String):void
		{
			this.GetUserByPath('/users/'+login);
		}
		
		public function GetUserByPath(path: String):void
		{
			var urlRequest:URLRequest;
            var urlLoader:DynamicURLLoader = getURLLoader();
            urlRequest = getURLRequest(path, URLRequestMethod.GET, null);
                        
            urlLoader.addEventListener(Event.COMPLETE, onGetUser);
            urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			urlLoader.addEventListener(Event.COMPLETE, onComplete);
			urlLoader.addEventListener(Event.OPEN, onOpen);
            urlLoader.load(urlRequest);
		}
		
		/************ Listener **************/
		public function onGetUser(event:Event):void
		{
			var blipUser:BlipUser = new BlipUser(JSON.decode(event.target.data));
			var blipResultEvent:BlipResultEvent = new BlipResultEvent(BlipResultEvent.ON_GET_USER);
			blipResultEvent.data = blipUser;
			dispatchEvent(blipResultEvent);

		}
		
		/***************************************************
		 * Statuses
		 ***************************************************/
		public function GetStatuses(limit:int = -1, since:int = -1, all:Boolean = false):void
		{
			var limitStr:String = '';
			var sinceStr:String = '';
			
			if (-1 < limit) {
				limitStr = '?limit='+limit;
			}
			
			if (-1 < since) {
				sinceStr = '/'+since+'/';
				if (all) {
					sinceStr += 'all_since';
				} else {
					sinceStr += 'since';
				}
			}	
			
			var urlRequest:URLRequest;
            var urlLoader:DynamicURLLoader = getURLLoader();
            urlRequest = getURLRequest('/statuses'+sinceStr+limitStr, URLRequestMethod.GET, null);
                        
            urlLoader.addEventListener(Event.COMPLETE, onGetUserStatuses);
            urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			urlLoader.addEventListener(Event.COMPLETE, onComplete);
			urlLoader.addEventListener(Event.OPEN, onOpen);
            urlLoader.login = '';
            urlLoader.load(urlRequest);
		}
		
		public function GetUserStatuses(login:String, limit:int = -1, since:int = -1):void
		{
			var url:String;
			
			if (-1 != since) {
				url = '/users/'+login+'/statuses/'+since+'/since';
			} else if (-1 != limit) {
				url = '/users/'+login+'/statuses?limit='+limit;
			} else {
				url = '/users/'+login+'/statuses';
			}		
			
			var urlRequest:URLRequest;
            var urlLoader:DynamicURLLoader = getURLLoader();
            urlRequest = getURLRequest(url, URLRequestMethod.GET, null);
                        
            urlLoader.addEventListener(Event.COMPLETE, onGetUserStatuses);
            urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			urlLoader.addEventListener(Event.COMPLETE, onComplete);
			urlLoader.addEventListener(Event.OPEN, onOpen);
            urlLoader.login = login;
            urlLoader.load(urlRequest);			
		}
		
		/************ Listener **************/
		public function onGetUserStatuses(event:Event):void
		{
			var userStatuses:BlipLog = new BlipLog(JSON.decode(event.target.data));		
			userStatuses.login = event.target.login;			
						
			var blipResultEvent:BlipResultEvent;
			if ('' == event.target.login) {
				blipResultEvent = new BlipResultEvent(BlipResultEvent.ON_GET_STATUSES);
			} else {
				blipResultEvent = new BlipResultEvent(BlipResultEvent.ON_GET_USER_STATUSES);
			}
			blipResultEvent.data = userStatuses;
			dispatchEvent(blipResultEvent);

		}
		
		public function GetStatus(id:int):void
		{
			this.GetStatusByPath('/statuses/'+id);
		}
		
		public function GetStatusByPath(path: String):void
		{
			var urlRequest:URLRequest;
            var urlLoader:DynamicURLLoader = getURLLoader();
            urlRequest = getURLRequest(path, URLRequestMethod.GET, null);
                        
            urlLoader.addEventListener(Event.COMPLETE, onGetStatus);
            urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			urlLoader.addEventListener(Event.COMPLETE, onComplete);
			urlLoader.addEventListener(Event.OPEN, onOpen);
            urlLoader.load(urlRequest);
		}
		
		/************ Listener **************/
		public function onGetStatus(event:Event):void
		{
			var blipStatus:BlipStatus = new BlipStatus(JSON.decode(event.target.data));
			var blipResultEvent:BlipResultEvent = new BlipResultEvent(BlipResultEvent.ON_GET_STATUS);
			blipResultEvent.data = blipStatus;
			dispatchEvent(blipResultEvent);

		}
		
		public function SetStatus(text:String, file:FileReference = null):void
		{
			if (text.length > 160) {
				text = text.substr(0, 160);
			}
			
			var urlRequest:URLRequest;
            urlRequest = getURLRequest("/statuses", URLRequestMethod.POST, null);
            urlRequest.data = "status[body]="+escape(text);
            
            if (null == file) {
            	var urlLoader:DynamicURLLoader = getURLLoader();
	            urlLoader.addEventListener(Event.COMPLETE, onSetStatus);
	            urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
				urlLoader.addEventListener(Event.COMPLETE, onComplete);
				urlLoader.addEventListener(Event.OPEN, onOpen);
	            urlLoader.load(urlRequest);
            } else {
            	file.addEventListener(Event.COMPLETE, onSetStatus);
            	file.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
				file.addEventListener(Event.COMPLETE, onComplete);
				file.addEventListener(Event.OPEN, onOpen);
            	file.upload(urlRequest, "status[picture]");	
            }
		}
		
		/************ Listener **************/
		public function onSetStatus(event:Event):void
		{
			var blipResultEvent:BlipResultEvent = new BlipResultEvent(BlipResultEvent.ON_SET_STATUS);
			dispatchEvent(blipResultEvent);
		}		
		
		
		public function DelStatus(id:int):void
		{
			// TODO: Pieron wie dlaczego wyskakuje:
			// Error #2044: Unhandled ioError:. text=Error #2032: Stream Error. URL: http://api.blip.pl/statuses/x
			/* 
			var urlRequest:URLRequest;
            var urlLoader:DynamicURLLoader = getURLLoader();
            urlRequest = getURLRequest('/statuses/'+id, URLRequestMethod.DELETE, null);
            urlRequest.data = null;
            urlLoader.addEventListener(Event.COMPLETE, onDelStatus);
            urlLoader.load(urlRequest);
            */
            var service:RESTService = new RESTService(this.rootURL);
            service.method = RESTServiceMethod.DELETE;
			service.resource = '/statuses/'+id;
			service.resultFormat = RESTService.RESULT_FORMAT_JSON;
			service.contentType = RESTService.CONTENT_TYPE_JSON;
			service.headers = {'X-Blip-API': '0.02'};
			service.userAgent = this.AppName+' AS3BlipLib/'+AS3_BLIP_LIB_VERSION; 
			service.setCredentials(this.username, this.passwd);
			service.addEventListener(ResultEvent.RESULT, onDelStatus); 
			service.send();	
		}

		/************ Listener **************/
		public function onDelStatus(event:ResultEvent):void
		{
			var blipResultEvent:BlipResultEvent = new BlipResultEvent(BlipResultEvent.ON_DEL_STATUS);
			dispatchEvent(blipResultEvent);
		}

		
		/***************************************************
		 * Avatar
		 ***************************************************/
		public function GetAvatar(login:String):void
		{
			this.GetAvatarByPath('/users/'+login+'/avatar');
		}		
		
		public function GetAvatarByPath(path: String):void
		{
			var urlRequest:URLRequest;
            var urlLoader:DynamicURLLoader = getURLLoader();
            urlRequest = getURLRequest(path, URLRequestMethod.GET, null);
                        
            urlLoader.addEventListener(Event.COMPLETE, onGetAvatar);
            urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			urlLoader.addEventListener(Event.COMPLETE, onComplete);
			urlLoader.addEventListener(Event.OPEN, onOpen);
            urlLoader.path = path;
            urlLoader.load(urlRequest);
		}
		
		/************ Listener **************/
		public function onGetAvatar(event:Event):void
		{
			var blipAvatar:BlipAvatar = new BlipAvatar(JSON.decode(event.target.data));
			var blipResultEvent:BlipResultEvent = new BlipResultEvent(BlipResultEvent.ON_GET_AVATAR);
			blipResultEvent.data = blipAvatar;
			blipResultEvent.path = event.target.path;
			dispatchEvent(blipResultEvent);

		}
		
		public function SetAvatar(file:FileReference = null):void
		{
			// TODO: 400 Bad request
			var urlRequest:URLRequest;
            urlRequest = getURLRequest("/avatar", URLRequestMethod.POST, null);
            urlRequest.data = null;
            
            file.addEventListener(Event.COMPLETE, onSetAvatar);
            file.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			file.addEventListener(Event.COMPLETE, onComplete);
			file.addEventListener(Event.OPEN, onOpen);
            file.upload(urlRequest, "avatar[file]");	
		}
		
		/************ Listener **************/
		public function onSetAvatar(event:Event):void
		{
			var blipResultEvent:BlipResultEvent = new BlipResultEvent(BlipResultEvent.ON_SET_AVATAR);
			dispatchEvent(blipResultEvent);
		}
		
		/***************************************************
		 * Background
		 ***************************************************/
		public function GetBackground(login:String):void
		{
			this.GetBackgroundByPath('/users/'+login+'/background');
		}
		
		public function GetBackgroundByPath(path: String):void
		{
			var urlRequest:URLRequest;
            var urlLoader:DynamicURLLoader = getURLLoader();
            urlRequest = getURLRequest(path, URLRequestMethod.GET, null);
                        
            urlLoader.addEventListener(Event.COMPLETE, onGetBackground);
            urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			urlLoader.addEventListener(Event.COMPLETE, onComplete);
			urlLoader.addEventListener(Event.OPEN, onOpen);
            urlLoader.path = path;
            urlLoader.load(urlRequest);
		}
		
		/************ Listener **************/
		public function onGetBackground(event:Event):void
		{
			var blipBackground:BlipBackground= new BlipBackground(JSON.decode(event.target.data));
			var blipResultEvent:BlipResultEvent = new BlipResultEvent(BlipResultEvent.ON_GET_BACKGROUND);
			blipResultEvent.data = blipBackground;
			dispatchEvent(blipResultEvent);

		}
		
		public function SetBackground(file:FileReference = null):void
		{
			// TODO: 400 Bad request
			var urlRequest:URLRequest;
            urlRequest = getURLRequest("/background", URLRequestMethod.POST, null);
            urlRequest.data = null;
            
            file.addEventListener(Event.COMPLETE, onSetBackground);
            file.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			file.addEventListener(Event.COMPLETE, onComplete);
			file.addEventListener(Event.OPEN, onOpen);
            file.upload(urlRequest, "background[file]");	
		}
		
		/************ Listener **************/
		public function onSetBackground(event:Event):void
		{
			var blipResultEvent:BlipResultEvent = new BlipResultEvent(BlipResultEvent.ON_SET_BACKGROUND);
			dispatchEvent(blipResultEvent);
		}
		
		/***************************************************
		 * Updates
		 ***************************************************/
		public function GetUpdates(limit:int = -1, since:int = -1, all:Boolean = false):void
		{
			var limitStr:String = '';
			var sinceStr:String = '';
			
			if (-1 < limit) {
				limitStr = '?limit='+limit;
			}
			
			if (-1 < since) {
				sinceStr = '/'+since+'/';
				if (all) {
					sinceStr += 'all_since';
				} else {
					sinceStr += 'since';
				}
			}	
	
			var urlRequest:URLRequest;
            var urlLoader:DynamicURLLoader = getURLLoader();
            urlRequest = getURLRequest('/updates'+sinceStr+limitStr, URLRequestMethod.GET, null);
                        
            urlLoader.addEventListener(Event.COMPLETE, onGetUserUpdates);
            urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			urlLoader.addEventListener(Event.COMPLETE, onComplete);
			urlLoader.addEventListener(Event.OPEN, onOpen);
            urlLoader.login = '';
            urlLoader.load(urlRequest);
		}
		
		public function GetUserUpdates(login:String, limit:int = -1, since:int = -1):void
		{
			var url:String;
			
			if (-1 != since) {
				url = '/users/'+login+'/updates/'+since+'/since';
			} else if (-1 != limit) {
				url = '/users/'+login+'/updates?limit='+limit;
			} else {
				url = '/users/'+login+'/updates';
			}		
			
			var urlRequest:URLRequest;
            var urlLoader:DynamicURLLoader = getURLLoader();
            urlRequest = getURLRequest(url, URLRequestMethod.GET, null);
                        
            urlLoader.addEventListener(Event.COMPLETE, onGetUserUpdates);
            urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			urlLoader.addEventListener(Event.COMPLETE, onComplete);
			urlLoader.addEventListener(Event.OPEN, onOpen);
            urlLoader.login = login;
            urlLoader.load(urlRequest);					
		}
		
		/************ Listener **************/
		public function onGetUserUpdates(event:Event):void
		{
			var userUpdates:BlipLog = new BlipLog(JSON.decode(event.target.data));
			userUpdates.login = event.target.login;		
						
			var blipResultEvent:BlipResultEvent;
			if ('' == event.target.login) {
				blipResultEvent = new BlipResultEvent(BlipResultEvent.ON_GET_UPDATES);
			} else {
				blipResultEvent = new BlipResultEvent(BlipResultEvent.ON_GET_USER_UPDATES);
			}
			blipResultEvent.data = userUpdates;
			dispatchEvent(blipResultEvent);

		}
		
		public function GetUpdate(id:int):void
		{
			this.GetUpdateByPath('/updates/'+id);
		}
		
		public function GetUpdateByPath(path: String):void
		{
			var urlRequest:URLRequest;
            var urlLoader:DynamicURLLoader = getURLLoader();
            urlRequest = getURLRequest(path, URLRequestMethod.GET, null);
                        
            urlLoader.addEventListener(Event.COMPLETE, onGetUpdate);
            urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			urlLoader.addEventListener(Event.COMPLETE, onComplete);
			urlLoader.addEventListener(Event.OPEN, onOpen);
            urlLoader.path = path;
            urlLoader.load(urlRequest);
		}
		
		/************ Listener **************/
		public function onGetUpdate(event:Event):void
		{
			var data:Object = JSON.decode(event.target.data);
			var blipUpdate:*;
			if ('Status' == data.type) {
				blipUpdate = new BlipStatus(data);
			} else if ('DirectedMessage' == data.type) {
				blipUpdate = new BlipDirectedMessage(data);
			}
			var blipResultEvent:BlipResultEvent = new BlipResultEvent(BlipResultEvent.ON_GET_UPDATE);
			blipResultEvent.data = blipUpdate;
			dispatchEvent(blipResultEvent);

		}
		
		public function SendUpdate(text:String, file:FileReference = null):void
		{
			if (text.length > 160) {
				text = text.substr(0, 160);
			}
			
			var urlRequest:URLRequest;
            urlRequest = getURLRequest("/updates", URLRequestMethod.POST, null);
            urlRequest.data = "update[body]="+escapeMultiByte(text);
            
            
            if (null == file) {
            	var urlLoader:DynamicURLLoader = getURLLoader();
	            urlLoader.addEventListener(Event.COMPLETE, onSendUpdate);
	            urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
				urlLoader.addEventListener(Event.COMPLETE, onComplete);
				urlLoader.addEventListener(Event.OPEN, onOpen);
	            urlLoader.load(urlRequest);
            } else {
            	file.addEventListener(Event.COMPLETE, onSendUpdate);
            	file.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
				file.addEventListener(Event.COMPLETE, onComplete);
				file.addEventListener(Event.OPEN, onOpen);
            	file.upload(urlRequest, "update[picture]");	
            }
		}
		
		/************ Listener **************/
		public function onSendUpdate(event:Event):void
		{
			var blipResultEvent:BlipResultEvent = new BlipResultEvent(BlipResultEvent.ON_SEND_UPDATE);
			dispatchEvent(blipResultEvent);
		}
		
		public function DelUpdate(id:int):void
		{
			// TODO: Błąd jak przy DelStatus
            var service:RESTService = new RESTService(this.rootURL);
            service.method = RESTServiceMethod.DELETE;
			service.resource = '/updates/'+id;
			service.resultFormat = RESTService.RESULT_FORMAT_JSON;
			service.contentType = RESTService.CONTENT_TYPE_JSON;
			service.headers = {'X-Blip-API': '0.02'};
			service.userAgent = this.AppName+' AS3BlipLib/'+AS3_BLIP_LIB_VERSION; 
			service.setCredentials(this.username, this.passwd);
			service.addEventListener(ResultEvent.RESULT, onDelUpdate); 
			service.send();	
		}

		/************ Listener **************/
		public function onDelUpdate(event:ResultEvent):void
		{
			var blipResultEvent:BlipResultEvent = new BlipResultEvent(BlipResultEvent.ON_DEL_UPDATE);
			dispatchEvent(blipResultEvent);
		}
		
		/***************************************************
		 * Directed Messages
		 ***************************************************/
		public function GetDms(limit:int = -1, since:int = -1, all:Boolean = false):void
		{
			var limitStr:String = '';
			var sinceStr:String = '';
			
			if (-1 < limit) {
				limitStr = '?limit='+limit;
			}
			
			if (-1 < since) {
				sinceStr = '/'+since+'/';
				if (all) {
					sinceStr += 'all_since';
				} else {
					sinceStr += 'since';
				}
			}	
	
			var urlRequest:URLRequest;
            var urlLoader:DynamicURLLoader = getURLLoader();
            urlRequest = getURLRequest('/directed_messages'+sinceStr+limitStr, URLRequestMethod.GET, null);
                        
            urlLoader.addEventListener(Event.COMPLETE, onGetUserDms);
            urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			urlLoader.addEventListener(Event.COMPLETE, onComplete);
			urlLoader.addEventListener(Event.OPEN, onOpen);
            urlLoader.login = '';
            urlLoader.load(urlRequest);
		}
		
		public function GetUserDms(login:String, limit:int = -1, since:int = -1):void
		{			
			var url:String;
			
			if (-1 != since) {
				url = '/users/'+login+'/directed_messages/'+since+'/since';
			} else if (-1 != limit) {
				url = '/users/'+login+'/directed_messages?limit='+limit;
			} else {
				url = '/users/'+login+'/directed_messages';
			}		
			
			var urlRequest:URLRequest;
            var urlLoader:DynamicURLLoader = getURLLoader();
            urlRequest = getURLRequest(url, URLRequestMethod.GET, null);
                        
            urlLoader.addEventListener(Event.COMPLETE, onGetUserDms);
            urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			urlLoader.addEventListener(Event.COMPLETE, onComplete);
			urlLoader.addEventListener(Event.OPEN, onOpen);
            urlLoader.login = login;
            urlLoader.load(urlRequest);					
		}
		
		/************ Listener **************/
		public function onGetUserDms(event:Event):void
		{
			var userDms:BlipLog = new BlipLog(JSON.decode(event.target.data));
			userDms.login = event.target.login;		
						
			var blipResultEvent:BlipResultEvent;
			if ('' == event.target.login) {
				blipResultEvent = new BlipResultEvent(BlipResultEvent.ON_GET_DMS);
			} else {
				blipResultEvent = new BlipResultEvent(BlipResultEvent.ON_GET_USER_DMS);
			}
			blipResultEvent.data = userDms;
			dispatchEvent(blipResultEvent);
		}
		
		public function GetDm(id:int):void
		{
			this.GetDmByPath('/directed_messages/'+id);
		}
		
		public function GetDmByPath(path: String):void
		{
			var urlRequest:URLRequest;
            var urlLoader:DynamicURLLoader = getURLLoader();
            urlRequest = getURLRequest(path, URLRequestMethod.GET, null);
                        
            urlLoader.addEventListener(Event.COMPLETE, onGetDm);
            urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			urlLoader.addEventListener(Event.COMPLETE, onComplete);
			urlLoader.addEventListener(Event.OPEN, onOpen);
            urlLoader.path = path;
            urlLoader.load(urlRequest);
		}
		
		/************ Listener **************/
		public function onGetDm(event:Event):void
		{
			var blipDm:BlipDirectedMessage = new BlipDirectedMessage(JSON.decode(event.target.data));
			var blipResultEvent:BlipResultEvent = new BlipResultEvent(BlipResultEvent.ON_GET_DM);
			blipResultEvent.data = blipDm;
			dispatchEvent(blipResultEvent);

		}
		
		public function SendDm(recipient:String, text:String, file:FileReference = null):void
		{
			if (text.length > 160) {
				text = text.substr(0, 160);
			}
			
			var urlRequest:URLRequest;                                
            urlRequest = getURLRequest("/directed_messages", URLRequestMethod.POST, null);
            urlRequest.data = "directed_message[recipient]="+escape(recipient)+"&";            
            urlRequest.data += "directed_message[body]="+escape(text)+"\r\n";            
            
            if (null == file) {
            	var urlLoader:DynamicURLLoader = getURLLoader();
	            urlLoader.addEventListener(Event.COMPLETE, onSendDm);
	            urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
				urlLoader.addEventListener(Event.COMPLETE, onComplete);
				urlLoader.addEventListener(Event.OPEN, onOpen);
	            urlLoader.load(urlRequest);
            } else {
            	if ('' != file.name) {
            		file.addEventListener(Event.COMPLETE, onSendDm);
            		file.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
					file.addEventListener(Event.COMPLETE, onComplete);
					file.addEventListener(Event.OPEN, onOpen);
            		file.upload(urlRequest, "directed_message[picture]");
            	}	
            }
		}
		
		/************ Listener **************/
		public function onSendDm(event:Event):void
		{
			var blipResultEvent:BlipResultEvent = new BlipResultEvent(BlipResultEvent.ON_SEND_DM);
			dispatchEvent(blipResultEvent);
		}
		
		public function DelDm(id:int):void
		{
			// TODO: Błąd jak przy DelStatus
            var service:RESTService = new RESTService(this.rootURL);
            service.method = RESTServiceMethod.DELETE;
			service.resource = '/directed_messages/'+id;
			service.resultFormat = RESTService.RESULT_FORMAT_JSON;
			service.contentType = RESTService.CONTENT_TYPE_JSON;
			service.headers = {'X-Blip-API': '0.02'};
			service.userAgent = this.AppName+' AS3BlipLib/'+AS3_BLIP_LIB_VERSION; 
			service.setCredentials(this.username, this.passwd);
			service.addEventListener(ResultEvent.RESULT, onDelDm); 
			service.send();			
		}
		
		/************ Listener **************/
		public function onDelDm(event:ResultEvent):void
		{
			var blipResultEvent:BlipResultEvent = new BlipResultEvent(BlipResultEvent.ON_DEL_DM);
			dispatchEvent(blipResultEvent);
		}
		
		/***************************************************
		 * Movie
		 ***************************************************/
		public function GetMovie(id:int):void
		{
			this.GetMovieByPath('/updates/'+id+'/movie');
		}
		
		public function GetMovieByPath(path: String):void
		{
			var urlRequest:URLRequest;
            var urlLoader:DynamicURLLoader = getURLLoader();
            urlRequest = getURLRequest(path, URLRequestMethod.GET, null);
                        
            urlLoader.addEventListener(Event.COMPLETE, onGetMovie);
            urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			urlLoader.addEventListener(Event.COMPLETE, onComplete);
			urlLoader.addEventListener(Event.OPEN, onOpen);
            urlLoader.path = path;
            urlLoader.load(urlRequest);
		}
		
		/************ Listener **************/
		public function onGetMovie(event:Event):void
		{
			var blipMovie:BlipMovie = new BlipMovie(JSON.decode(event.target.data));
			var blipResultEvent:BlipResultEvent = new BlipResultEvent(BlipResultEvent.ON_GET_MOVIE);
			blipResultEvent.data = blipMovie;
			dispatchEvent(blipResultEvent);

		}
		
		/***************************************************
		 * Recording
		 ***************************************************/
		public function GetRecording(id:int):void
		{
			this.GetRecordingByPath('/updates/'+id+'/recording');
		}
		
		public function GetRecordingByPath(path: String):void
		{
			var urlRequest:URLRequest;
            var urlLoader:DynamicURLLoader = getURLLoader();
            urlRequest = getURLRequest(path, URLRequestMethod.GET, null);
                        
            urlLoader.addEventListener(Event.COMPLETE, onGetRecording);
            urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			urlLoader.addEventListener(Event.COMPLETE, onComplete);
			urlLoader.addEventListener(Event.OPEN, onOpen);
            urlLoader.path = path;
            urlLoader.load(urlRequest);
		}
		
		/************ Listener **************/
		public function onGetRecording(event:Event):void
		{
			var blipRecording:BlipRecording = new BlipRecording(JSON.decode(event.target.data));
			var blipResultEvent:BlipResultEvent = new BlipResultEvent(BlipResultEvent.ON_GET_RECORDING);
			blipResultEvent.data = blipRecording;
			dispatchEvent(blipResultEvent);

		}
		
		/***************************************************
		 * Pictures
		 ***************************************************/
		public function GetUpdatePictures(id:int):void
		{
			this.GetUpdatePicturesByPath('/updates/'+id+'/pictures');
		}

		public function GetUpdatePicturesByPath(path: String):void
		{
			var urlRequest:URLRequest;
            var urlLoader:DynamicURLLoader = getURLLoader();
            urlRequest = getURLRequest(path, URLRequestMethod.GET, null);
                        
            urlLoader.addEventListener(Event.COMPLETE, onGetUpdatePictures);
            urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			urlLoader.addEventListener(Event.COMPLETE, onComplete);
			urlLoader.addEventListener(Event.OPEN, onOpen);
            urlLoader.path = path;
            urlLoader.load(urlRequest);
		}				
		
		public function GetPictures(limit:int = 20, since:int = -1):void
		{
			var limitStr:String = '';
			var sinceStr:String = '';
			
			limitStr = '?limit='+limit;
			
			if (-1 < since) {
				sinceStr = since+'/all_since';
			} else {
				sinceStr = 'all';
			}	
			
			var urlRequest:URLRequest;
            var urlLoader:DynamicURLLoader = getURLLoader();
            urlRequest = getURLRequest('/pictures/'+sinceStr+limitStr, URLRequestMethod.GET, null);
                        
            urlLoader.addEventListener(Event.COMPLETE, onGetUpdatePictures);
            urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			urlLoader.addEventListener(Event.COMPLETE, onComplete);
			urlLoader.addEventListener(Event.OPEN, onOpen);
            urlLoader.path = '';
            urlLoader.load(urlRequest);				
		}
		
		/************ Listener **************/
		public function onGetUpdatePictures(event:Event):void
		{
			var data:Object = JSON.decode(event.target.data);
			var blipPictures:CustomArrayCollection = new CustomArrayCollection();
			
			for each (var item:Object in data) {
				var picture:BlipPicture = new BlipPicture(item);										
				blipPictures.addItem(picture);
			}
			
			var blipResultEvent:BlipResultEvent;
			if ('' == event.target.path) {
				blipResultEvent = new BlipResultEvent(BlipResultEvent.ON_GET_PICTURES);
			} else {
				blipResultEvent = new BlipResultEvent(BlipResultEvent.ON_GET_UPDATE_PICTURES);
			}
			blipResultEvent.data = blipPictures;
			dispatchEvent(blipResultEvent);
		}
		
		/***************************************************
		 * Shortlinks
		 ***************************************************/
		public function GetShortlinks(limit:int = 20, since:int = -1):void
		{
			var limitStr:String = '';
			var sinceStr:String = '';
			
			limitStr = '?limit='+limit;
			
			if (-1 < since) {
				sinceStr = since+'/all_since';
			} else {
				sinceStr = 'all';
			}	
			
			var urlRequest:URLRequest;
            var urlLoader:DynamicURLLoader = getURLLoader();
            urlRequest = getURLRequest('/shortlinks/'+sinceStr+limitStr, URLRequestMethod.GET, null);
                        
            urlLoader.addEventListener(Event.COMPLETE, onGetShortlinks);
            urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			urlLoader.addEventListener(Event.COMPLETE, onComplete);
			urlLoader.addEventListener(Event.OPEN, onOpen);
            urlLoader.load(urlRequest);				
		}
		
		/************ Listener **************/
		public function onGetShortlinks(event:Event):void
		{
			var data:Object = JSON.decode(event.target.data);
			var blipShortlinks:CustomArrayCollection = new CustomArrayCollection();
			
			for each (var item:Object in data) {
				var shortlink:BlipShortlink = new BlipShortlink(item);										
				blipShortlinks.addItem(shortlink);
			}
			
			var blipResultEvent:BlipResultEvent = new BlipResultEvent(BlipResultEvent.ON_GET_SHORTLINKS);
			blipResultEvent.data = blipShortlinks;
			dispatchEvent(blipResultEvent);
		}
		
		
		/***************************************************
		 * Subscriptions
		 ***************************************************/
		public function GetSubs(includeResources:Array = null):void
		{			
			var url:String = '/subscriptions';
			url += (null != includeResources) ? '?include=' + includeResources.join(',') : '';
			this.GetSubsByPath(url, 'subs');
		}
		
		public function GetSubsFrom(includeResources:Array = null):void
		{		
			var url:String = '/subscriptions/from';	
			url += (null != includeResources) ? '?include=' + includeResources.join(',') : '';
			this.GetSubsByPath(url, 'from');
		}
		
		public function GetSubsTo(includeResources:Array = null):void
		{			
			var url:String = '/subscriptions/to';
			url += (null != includeResources) ? '?include=' + includeResources.join(',') : '';
			this.GetSubsByPath(url, 'to');
		}
		
		public function GetUserSubs(login:String, includeResources:Array = null):void
		{			
			var url:String = '/users/'+login+'/subscriptions';
			url += (null != includeResources) ? '?include=' + includeResources.join(',') : '';
			this.GetSubsByPath(url, 'user');
		}
		
		public function GetUserSubsFrom(login:String, includeResources:Array = null):void
		{			
			var url:String = '/users/'+login+'/subscriptions/from';
			url += (null != includeResources) ? '?include=' + includeResources.join(',') : '';
			this.GetSubsByPath(url, 'userFrom');
		}
		
		public function GetUserSubsTo(login:String, includeResources:Array = null):void
		{			
			var url:String = '/users/'+login+'/subscriptions/to';
			url += (null != includeResources) ? '?include=' + includeResources.join(',') : '';
			this.GetSubsByPath(url, 'userTo');
		}
		
		public function GetSubsByPath(path:String, type:String):void
		{			
			var urlRequest:URLRequest;
            var urlLoader:DynamicURLLoader = getURLLoader();
            urlRequest = getURLRequest(path, URLRequestMethod.GET, null);
                        
            urlLoader.addEventListener(Event.COMPLETE, onGetSubs);
            urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			urlLoader.addEventListener(Event.COMPLETE, onComplete);
			urlLoader.addEventListener(Event.OPEN, onOpen);
            urlLoader.type = type;
            urlLoader.load(urlRequest);	
		}
		
		/************ Listener **************/
		public function onGetSubs(event:Event):void
		{
			var data:Object = JSON.decode(event.target.data);
			var blipSubscriptions:CustomArrayCollection = new CustomArrayCollection();
			var trackingUserPath:String;
			var trackedUserPath:String;
			
			for each (var item:Object in data) {
				trackingUserPath = (item.hasOwnProperty('tracking_user_path')) ? item.tracking_user_path : '/users/'+ item.tracking_user.login;
				trackedUserPath = (item.hasOwnProperty('tracked_user_path')) ? item.tracked_user_path : '/users/'+ item.tracked_user.login;
				
				var subscription:BlipSubscription = 
						blipSubscriptions.getByMany([{name:'trackingUserPath', value:trackingUserPath},
													 {name:'trackedUserPath', value:trackedUserPath}]);
				if (null == subscription) {										
					subscription = new BlipSubscription(item);
					blipSubscriptions.addItem(subscription);	
				} else {
					subscription.transports.push(new BlipTransport(item.transport));
				}
			}
			
			var blipResultEvent:BlipResultEvent;
			switch (event.target.type) {
				case 'subs':
					blipResultEvent = new BlipResultEvent(BlipResultEvent.ON_GET_SUBS);	
					break;
					
				case 'from':
					blipResultEvent = new BlipResultEvent(BlipResultEvent.ON_GET_SUBS_FROM);	
					break;
					
				case 'to':
					blipResultEvent = new BlipResultEvent(BlipResultEvent.ON_GET_SUBS_TO);	
					break;	
					
				case 'user':
					blipResultEvent = new BlipResultEvent(BlipResultEvent.ON_GET_USER_SUBS);	
					break;
					
				case 'userFrom':
					blipResultEvent = new BlipResultEvent(BlipResultEvent.ON_GET_USER_SUBS_FROM);	
					break;
					
				case 'userTo':
					blipResultEvent = new BlipResultEvent(BlipResultEvent.ON_GET_USER_SUBS_TO);	
					break;
			}
			
			blipResultEvent.data = blipSubscriptions;
			dispatchEvent(blipResultEvent);
		}
		
		public function SetSub(login:String, www:Boolean = true, im:Boolean = true):void
		{						
			// TODO: Błąd jak przy DelStatus
            var service:RESTService = new RESTService(this.rootURL);
            service.method = RESTServiceMethod.PUT;
			service.resource = '/subscriptions/'+login;
			service.request = {"subscription" : {"www" : (www) ? 1 : 0 , "im" : (im) ? 1 : 0}};
			service.resultFormat = RESTService.RESULT_FORMAT_JSON;
			service.contentType = RESTService.CONTENT_TYPE_JSON;
			service.headers = {'X-Blip-API': '0.02'};
			service.userAgent = this.AppName+' AS3BlipLib/'+AS3_BLIP_LIB_VERSION; 
			service.setCredentials(this.username, this.passwd);
			service.addEventListener(ResultEvent.RESULT, onSetSub); 
			service.send();
		}
		
		/************ Listener **************/
		public function onSetSub(event:ResultEvent):void
		{
			var blipResultEvent:BlipResultEvent = new BlipResultEvent(BlipResultEvent.ON_SET_SUB);
			dispatchEvent(blipResultEvent);
		}
		
		public function DelSub(login:String):void
		{
			// TODO: Błąd jak przy DelStatus
            var service:RESTService = new RESTService(this.rootURL);
            service.method = RESTServiceMethod.DELETE;
			service.resource = '/subscriptions/'+login;
			service.resultFormat = RESTService.RESULT_FORMAT_JSON;
			service.contentType = RESTService.CONTENT_TYPE_JSON;
			service.headers = {'X-Blip-API': '0.02'};
			service.userAgent = this.AppName+' AS3BlipLib/'+AS3_BLIP_LIB_VERSION; 
			service.setCredentials(this.username, this.passwd);
			service.addEventListener(ResultEvent.RESULT, onDelSub); 
			service.send();		
		}
		
		/************ Listener **************/
		public function onDelSub(event:ResultEvent):void
		{
			var blipResultEvent:BlipResultEvent = new BlipResultEvent(BlipResultEvent.ON_DEL_SUB);
			dispatchEvent(blipResultEvent);
		}
		
		/***************************************************
		 * Tags
		 ***************************************************/
		public function GetTagUpdates(tag:String, limit:int = -1, since:int = -1):void
		{
			var limitStr:String = '';
			var sinceStr:String = '';
			
			limitStr = (-1 < limit) ? '?limit='+limit : '';
			sinceStr = (-1 < since) ? '/since/'+since : '';
			
			var urlRequest:URLRequest;
            var urlLoader:DynamicURLLoader = getURLLoader();
            urlRequest = getURLRequest('/tags/'+tag+limitStr+sinceStr, URLRequestMethod.GET, null);
                        
            urlLoader.addEventListener(Event.COMPLETE, onGetTagUpdates);
            urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			urlLoader.addEventListener(Event.COMPLETE, onComplete);
			urlLoader.addEventListener(Event.OPEN, onOpen);
            urlLoader.tag = tag;
            urlLoader.load(urlRequest);				
		}
		
		/************ Listener **************/
		public function onGetTagUpdates(event:Event):void
		{
			var tagUpdates:BlipLog = new BlipLog(JSON.decode(event.target.data));
			tagUpdates.tag = event.target.tag;
			var blipResultEvent:BlipResultEvent = new BlipResultEvent(BlipResultEvent.ON_GET_TAG_UPDATES);
			blipResultEvent.data = tagUpdates;
			dispatchEvent(blipResultEvent);
		}
		
		/*
			FUNKCJE POMOCNICZE
		*/
		
		public function LoginFromPath(path: String):String
		{
			return path.split('/')[2];
		}

		private function getURLRequest(url:String, method:String, urlVariables:URLVariables = null):URLRequest {
	        // TODO: replace data with namevalue pair
	        var urlRequest:URLRequest = new URLRequest();
	        
	        urlRequest.cacheResponse = false;
	        urlRequest.useCache = false;
	        
	        if(urlVariables == null){
	        	urlVariables = new URLVariables();
	        }       
	        
	        urlRequest.requestHeaders = [ new URLRequestHeader("User-Agent", this.AppName+' AS3BlipLib/'+AS3_BLIP_LIB_VERSION),
	        							  new URLRequestHeader("X-Blip-api", '0.02'),
	        							  new URLRequestHeader("Accept", 'application/json')];
	        
	        switch(method){
                case "GET":
                    urlRequest.url = rootURL + url;
                    urlRequest.method = URLRequestMethod.GET;
                    break;
                case "POST":
                    urlRequest.url = rootURL + url;
                    urlRequest.method = URLRequestMethod.POST;
                    break;
                case "DELETE":
                    urlRequest.url = rootURL + url;
                    urlRequest.method = URLRequestMethod.DELETE;
                    //urlRequest.requestHeaders.push(new URLRequestHeader("X-HTTP-Method-Override", 'DELETE'));
                    break;
	        }
	        
	        urlRequest.data = urlVariables;
        
	        
			
	        if(this.username != ""){
                var authHeader:URLRequestHeader = new URLRequestHeader("Authorization", "Basic " + Base64.encode(this.username + ":" + this.passwd));

                urlRequest.requestHeaders.push(authHeader);
	        }

	        return urlRequest;
        }
        
        private function onIOError(event:IOErrorEvent):void {
			dispatchEvent(event);
        }
        
        private function onComplete(event:Event):void {
			dispatchEvent(event);
        }
        
        private function onOpen(event:Event):void {
			dispatchEvent(event);
        }
		
		private function GetResource(resource:String, eventName:String = ''):void
		{
			this.Service.method = RESTServiceMethod.GET;
			this.Service.resource = resource;
			this.Service.eventName = eventName;
			this.Service.send();	
		}
	}
}