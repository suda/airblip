import com.suda.plugins.PluginEvent;

import flash.events.Event;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLVariables;

/**********************************************************/
/*********** OBSŁUGA API                        ***********/
/**********************************************************/
public function onGetBliposphere(event:BlipResultEvent):void {
	var pluginEvent:PluginEvent = new PluginEvent(ON_PLUGIN_RENDER_STATUS);
	pluginEvent.data = event.data;
	pluginHost.dispatchEvent(pluginEvent);

	cacheAvatars(event.data);
	
	addPicturesLinks(event.data);
	
	Bliposphere.AddUpdates(event.data);
}

public function onGetUserDashboard(event:BlipResultEvent):void {
	var userDashboard:* = BlipLogs.getBy('login', event.data.login);
	
	var pluginEvent:PluginEvent = new PluginEvent(ON_PLUGIN_RENDER_STATUS);
	pluginEvent.data = event.data;
	pluginHost.dispatchEvent(pluginEvent);
	
	cacheAvatars(event.data);
	
	addPicturesLinks(event.data);
	
	userDashboard.AddUpdates(event.data);
}

public function onGetDashboard(event:BlipResultEvent):void {
	var dashboard:* = Dashboard;
	
	if (!hasFocus && !userNotificated) {
		for each(var update:* in event.data) {
			if ((BlipUpdate.UPDATE_TYPE_DM == update.type) && (update.user.login != config.data.loginUsername)) {
				unreadDms++;	
			}
		}
		//trace('unreadDms: '+unreadDms);		
		if (0 < unreadDms) {
			if (!mnuMute.toggled) {
				notifySound.play();	
			}
			// TODO: Rysowanie ilości nieprzeczytanych DM 
			if (NativeApplication.supportsDockIcon) {
				(NativeApplication.nativeApplication.icon as DockIcon).bounce();	
			}
			
			
			var notifyStr:String;
			if (1 == unreadDms) {
				notifyStr = unreadDms.toString() + ' nowa skierowana wiadomość';
			} else if ((1 < unreadDms) && (5 > unreadDms)) {
				notifyStr = unreadDms.toString() + ' nowe skierowane wiadomości';
			} else if (5 <= unreadDms) {
				notifyStr = unreadDms.toString() + ' nowych skierowanych wiadomości';
			}
			//this.nativeWindow.notifyUser(notifyStr);
			userNotificated = true;
		}
	}
	
	if ((0 == dashboard.lastId) && hasFocus) {	
		unreadDms = 0;		
	}
	
	var updates:* = event.data;
	
	cacheAvatars(updates);
	
	var pluginEvent:PluginEvent = new PluginEvent(ON_PLUGIN_RENDER_STATUS);
	pluginEvent.data = updates;
	pluginHost.dispatchEvent(pluginEvent);
	
	addPicturesLinks(updates);
	
	dashboard.AddUpdates(updates);
}

public function addPicturesLinks(updates):void {
	for each (var update in updates) {
		if (null != update.pictures) {
			for each (var picture in update.pictures) {
				update.htmlBody += ' <a href="'+picture.url+'" class="plugin">[Obrazek]</a>';	
			}
		}		
	}
}

public function onGetSubs(event:BlipResultEvent):void {
	var subscriptions:* = event.data;

	cacheSubscriptionsAvatars(subscriptions);
	
	Subscriptions = subscriptions;
	
	lstSubscriptions.dataProvider = Subscriptions;
}

public function onSendUpdate(event:BlipResultEvent):void {
	taStatus.enabled = true;
	taStatus.text = '';
	lblCharsLeft.text = '160';
	btnSend.enabled = true;
	cnvAttachement.enabled = true;
	onDelAttachement(null);	
	
	if ('dashboard' == currentState) {
		api.GetDashboard(Dashboard.lastId, new Array('user','user[avatar]','pictures','movie'));
	} else if ('bliposphere' == currentState) {
		api.GetBliposphere();
	}	
}

/**********************************************************/
/*********** OBSŁUGA WWW BLIPA                  ***********/
/**********************************************************/
public var authenticityToken:String = '';
public var blipPlLoader:URLLoader = new URLLoader();
public var blipPlRequest:URLRequest
public function getBlipPl():void {
	blipPlRequest = new URLRequest('http://www.blip.pl/');
	
	blipPlRequest.manageCookies = true;
	
	blipPlLoader.addEventListener(Event.COMPLETE, onGetBlipPl);
	blipPlLoader.load(blipPlRequest);	
}

public function onGetBlipPl(event:Event):void {
	var matches:Array = event.target.data.toString().match(/value\=\"([0-9|a-f]*)\"/); 
	if (0 < matches.length) {
		authenticityToken = matches[1];
		blipPlLoader.removeEventListener(Event.COMPLETE, onGetBlipPl);
		loginToBlipPl();	
	}	
}

public function loginToBlipPl():void {
	blipPlRequest.url = 'http://www.blip.pl/sessions';
	var variables:URLVariables = new URLVariables();
	
	blipPlRequest.method = URLRequestMethod.POST;
	// Odszyfrowanie hasła
	cypherData = Hex.toArray(config.data.loginPasswd);
	cypher.decrypt(cypherData);
	
	//variables.logging_in_user = { login: config.data.loginUsername, password: Hex.toString(Hex.fromArray(cypherData))};
	//variables.logging_in_user = { login: 'kicztv', password: 'proste21', remember: 1};
	variables.authenticity_token = authenticityToken;
	Debug.log(authenticityToken);
	blipPlRequest.data = variables;
	
	blipPlLoader.addEventListener(Event.COMPLETE, onLoginToBlipPl);
	blipPlLoader.load(blipPlRequest);
}

public function onLoginToBlipPl(event:Event):void {
	Debug.log(event.target.data);
}
