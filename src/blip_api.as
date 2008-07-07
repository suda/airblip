/**********************************************************/
import com.suda.plugins.PluginEvent;

/*********** OBSŁUGA API                        ***********/
/**********************************************************/
public function onGetBliposphere(event:BlipResultEvent):void {
	//var userDashboard:BlipLog = BlipLogs.getBy('login', event.data.login);
	var pluginEvent:PluginEvent = new PluginEvent(ON_PLUGIN_RENDER_STATUS);
	pluginEvent.data = event.data;
	pluginHost.dispatchEvent(pluginEvent);
	
	Bliposphere.AddUpdates(event.data);
	fetchUsers(event.data);	
}

public function onGetUserDashboard(event:BlipResultEvent):void {
	var userDashboard:* = BlipLogs.getBy('login', event.data.login);
	
	var pluginEvent:PluginEvent = new PluginEvent(ON_PLUGIN_RENDER_STATUS);
	pluginEvent.data = event.data;
	pluginHost.dispatchEvent(pluginEvent);
	
	userDashboard.AddUpdates(event.data);
	fetchUsers(userDashboard);	
}

public function onGetDashboard(event:BlipResultEvent):void {
	var dashboard:* = Dashboard;
	
	if (!hasFocus && !userNotificated) {
		for each(var update:* in event.data) {
			if (BlipUpdate.UPDATE_TYPE_DM == update.type) {
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
	
	var pluginEvent:PluginEvent = new PluginEvent(ON_PLUGIN_RENDER_STATUS);
	pluginEvent.data = updates;
	pluginHost.dispatchEvent(pluginEvent);
	
	dashboard.AddUpdates(updates);
	fetchUsers(updates);
}

public function onGetSubs(event:BlipResultEvent):void {
	var subscriptions:* = event.data;
	
	if (0 < subscriptions.length) {
		for each (var subscription:BlipSubscription in subscriptions) {						
			if (!usersQueue.contains(subscription.trackingUserPath)) {
				api.GetUserByPath(subscription.trackingUserPath);
				usersQueue.addItem(subscription.trackingUserPath);										
			} else {					
				subscriptions.setAllBy('trackingUserPath', subscription.trackingUserPath, 'trackingUser', users.getBy('userPath', subscription.trackingUserPath));	
			}
			
			if (!usersQueue.contains(subscription.trackedUserPath)) {
				api.GetUserByPath(subscription.trackedUserPath);
				usersQueue.addItem(subscription.trackedUserPath);										
			} else {					
				subscriptions.setAllBy('trackedUserPath', subscription.trackedUserPath, 'trackedUser', users.getBy('userPath', subscription.trackedUserPath));	
			}	
		}	
	}
	Subscriptions = subscriptions;
	
	lstSubscriptions.dataProvider = Subscriptions;
}

public function onGetUser(event:BlipResultEvent):void {
	var dashboard:* = lstBlipLog.dataProvider;
	var subscriptions:CustomArrayCollection = Subscriptions;
	var user:* = event.data;
	users.addItem(user);
	dashboard.setAllBy('userPath', user.userPath, 'user', user);
	dashboard.setAllBy('recipientPath', user.userPath, 'recipient', user);
	subscriptions.setAllBy('trackingUserPath', user.userPath, 'trackingUser', user);
	subscriptions.setAllBy('trackedUserPath', user.userPath, 'trackedUser', user); 
	fetchAvatar(user);
}

public function onGetAvatar(event:BlipResultEvent):void {
	var avatar:* = event.data;
	
	//avatar.url30 = cacheAvatar(avatar.url30);
	//var avatarUrl90:String = cacheAvatar(avatar.url90, 0);
	var avatarUrl:String = cacheAvatar(avatar.url30, avatar.id);
	if ('' == avatarUrl) {
		avatar.url30 = 'app:/img/not_logged30.png';
	} else {
		avatar.url30 = avatarUrl;	
	}
	
	avatars.addItem(avatar);
	users.setAllBy('avatarPath', event.path, 'avatar', avatar);	
}

public function onSendUpdate(event:BlipResultEvent):void {
	taStatus.enabled = true;
	taStatus.text = '';
	lblCharsLeft.text = '160';
	btnSend.enabled = true;
	cnvAttachement.enabled = true;
	onDelAttachement(null);	
	
	if ('dashboard' == currentState) {
		api.GetDashboard(Dashboard.lastId);
	} else if ('bliposphere' == currentState) {
		api.GetBliposphere();
	}	
}
