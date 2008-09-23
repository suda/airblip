import com.carlcalderon.arthropod.Debug;
import com.codeazur.utils.*;
import com.hurlant.crypto.*;
import com.hurlant.crypto.symmetric.*;
import com.hurlant.util.*;
import com.suda.*;
import com.suda.AS3BlipLib.*;
import com.suda.AS3BlipLib.events.BlipResultEvent;
import com.suda.AS3BlipLib.objects.*;
import com.suda.net.*;

import flash.events.*;
import flash.filesystem.File;
import flash.media.Sound;
import flash.net.FileReference;
import flash.net.URLRequest;

import mx.collections.ArrayCollection;
import mx.controls.Menu;
import mx.events.*;

public var api:BlipAPI = new BlipAPI('AirBlip');
public var users:CustomArrayCollection = new CustomArrayCollection();
public var usersQueue:ArrayCollection = new ArrayCollection();
public var avatars:CustomArrayCollection = new CustomArrayCollection();

public var Dashboard:BlipLog = new BlipLog();
public var Bliposphere:BlipLog = new BlipLog();
public var Subscriptions:CustomArrayCollection = new CustomArrayCollection();
public var BlipLogs:CustomArrayCollection = new CustomArrayCollection();

public var FileAttachement:FileReference = new FileReference();
public var AttachementTypes:Array = [new FileFilter("Grafika (*.jpg, *.jpeg, *.gif, *.png)", "*.jpg;*.jpeg;*.gif;*.png")];

public var config:SharedObject;
public var cypherKey:String = '58fb270c7d563ff8a47ea93f3048ead1';
public var cypherPad:IPad = new PKCS5;
public var cypherData:ByteArray;
public var cypher:ICipher = Crypto.getCipher('simple-aes', Hex.toArray(cypherKey), cypherPad);

public var notifySound:Sound;
public var refreshTimer:Timer;
public var unreadDms:int;
public var hasFocus:Boolean;
public var userNotificated:Boolean;
public var muteCommand:NativeMenuItem;
public var hideToTray:Boolean = false;

public var mnuOptions:Menu;
            
public function init():void {	
	api.addEventListener(Event.OPEN, onCommOpen);
	api.addEventListener(Event.COMPLETE, onCommComplete);
	
	api.addEventListener(BlipResultEvent.ON_GET_DASHBOARD, onGetDashboard);
	api.addEventListener(BlipResultEvent.ON_GET_USER_DASHBOARD, onGetUserDashboard);
	api.addEventListener(BlipResultEvent.ON_GET_BLIPOSPHERE, onGetBliposphere);
	api.addEventListener(BlipResultEvent.ON_GET_SUBS_FROM, onGetSubs);
	api.addEventListener(BlipResultEvent.ON_SEND_UPDATE, onSendUpdate);
	
	api.addEventListener(IOErrorEvent.IO_ERROR, onCommError);
	
	config = SharedObject.getLocal("airblip");	
	cypherPad.setBlockSize(cypher.getBlockSize());
	
	try {
		if (0 < config.data.windowWidth) {
			this.nativeWindow.x = config.data.windowX;	
			this.nativeWindow.y = config.data.windowY;
			this.width = config.data.windowWidth;
			this.height = config.data.windowHeight;
		}
	} catch(err:Error) {
		Debug.log(err.message);
	}
	
	var appXml:XML = NativeApplication.nativeApplication.applicationDescriptor;
	var ns:Namespace = appXml.namespace();
	lblTitle.text = appXml.ns::version[0];
	
	var request:URLRequest = new URLRequest("http://www.airblip.pl/download/AirBlip.air");
	var updater:AIRRemoteUpdater = new AIRRemoteUpdater();
	updater.addEventListener(AIRRemoteUpdaterEvent.VERSION_CHECK, updaterVersionCheckHandler);
	updater.addEventListener(AIRRemoteUpdaterEvent.UPDATE, updaterUpdateHandler);
	updater.update(request);
	
	FileAttachement.addEventListener(Event.SELECT, onSelectAttachement);	
	
	pluginHost.api = api;
	pluginHost.queryPlugins();
	// Hack: Module preloading in Windows
	pluginHost.loadAllPlugins();
	/* 
	if (NativeApplication.supportsSystemTrayIcon) {
		pluginHost.loadAllPlugins();
	}
	 */
	//loginToBlipPl();
	//getBlipPl();			
}

public function updaterVersionCheckHandler(event:AIRRemoteUpdaterEvent):void {
   var updater:AIRRemoteUpdater = event.target as AIRRemoteUpdater;
   Debug.log("Local version: " + updater.localVersion);
   Debug.log("Remote version: " + updater.remoteVersion);
   
   var localVersion:Number = parseInt(updater.localVersion.replace(/[\D|\.]/g, ''));
   var remoteVersion:Number = parseInt(updater.remoteVersion.replace(/[\D|\.]/g, ''));
   
   if (remoteVersion > localVersion) {
   	    updater.versionMatch = 1;		
   } else if (remoteVersion == localVersion) {
   		updater.versionMatch = 0;
   } else {
   		updater.versionMatch = -1;
   		event.preventDefault();	
   }

}
 
public function updaterUpdateHandler(event:AIRRemoteUpdaterEvent):void {
   Debug.log("Installer: " + event.file.nativePath);
}

public function initLoginPanel():void {
	try {
		cbLoginRemember.selected = config.data.loginRemember;
		if (config.data.isEncrypted) {			
			if (cbLoginRemember.selected) {
				taLoginUsername.text = config.data.loginUsername;
				
				cypherData = Hex.toArray(config.data.loginPasswd);
				cypher.decrypt(cypherData);
				taLoginPasswd.text = Hex.toString(Hex.fromArray(cypherData));
			}		
		} else {
			if (cbLoginRemember.selected) {
				taLoginUsername.text = config.data.loginUsername;
				taLoginPasswd.text = config.data.loginPasswd;
			}
		}
	} catch(err:Error) {
		Debug.log(err.message);
	}
	
	taLoginUsername.setFocus();
	
	// Ładowanie i ustawianie ikony w Tray-u
	var icon:Loader = new Loader();
	icon.contentLoaderInfo.addEventListener(Event.COMPLETE, onIconLoaded);
	if (NativeApplication.supportsSystemTrayIcon) {
		icon.load(new URLRequest("app:/img/air_blip16.png"));
	} else {
		icon.load(new URLRequest("app:/img/air_blip128.png"));
	}	
	
}

public function logIn():void {
	if (('' != taLoginUsername.text) && ('' != taLoginPasswd.text)) {
		api.LogIn(taLoginUsername.text, taLoginPasswd.text);
		config.data.loginRemember = cbLoginRemember.selected; 
		if (cbLoginRemember.selected) {
			config.data.loginUsername = taLoginUsername.text;
			
			cypherData = Hex.toArray(Hex.fromString(taLoginPasswd.text))
			cypher.encrypt(cypherData);
			config.data.loginPasswd = Hex.fromArray(cypherData).toString();
		} else {
			config.data.loginUsername = '';
			config.data.loginPasswd = '';
		}
		config.data.isEncrypted = true;
		config.flush();
		currentState = 'dashboard';
		
		refreshTimer = new Timer(3000);
		refreshTimer.addEventListener(TimerEvent.TIMER, onTimer);
		refreshTimer.start();
	}
		
	// Ustawianie menu
	mnuOptions = Menu.createMenu(cnvMain, dtaTmpMenu, false);
	mnuOptions.addEventListener(MenuEvent.ITEM_CLICK, onMenuClick);
	mnuOptions.variableRowHeight = true;
	 	
	
	// Ładowanie wtyczek
	pluginHost.loadAllPlugins();
}

public function onTimer(event:TimerEvent):void {
	api.GetDashboard(Dashboard.lastId, new Array('user','user[avatar]','pictures','movie'));
	//trace('Dashboard.lastId: '+Dashboard.lastId);
}

public function loadOptions():void {
	try {
		mnuMute.toggled = config.data.mute;
		
		if ('' == config.data.notifySound) {
			notifySound = new Sound(new URLRequest("app:/sfx/pingblib5.mp3"));		  
		} else {
			var file:File = new File("app:/sfx/"+config.data.notifySound);
			if (file.exists) {
				notifySound = new Sound(new URLRequest("app:/sfx/"+config.data.notifySound));
			} else {
				notifySound = new Sound(new URLRequest("app:/sfx/pingblib5.mp3"));
			}
		}
	} catch(err:Error) {
		Debug.log(err.message);
	}
}

public function onCommOpen(event:Event):void {
	fxFade.play();
}

public function onCommComplete(event:Event):void {
	fxFade.stop();
}

public function onCommError(event:IOErrorEvent):void {
	Debug.log(event.text, 0xFF0000);
}


/**********************************************************/
/*********** OBSŁUGA MENU                       ***********/
/**********************************************************/
public function onMenuClick(event:MenuEvent):void {
	if ('Wyłącz dźwięki' ==  event.item.label) {
		config.data.mute = event.item.toggled;
		config.flush();	
		if (null != muteCommand) {
			muteCommand.checked = event.item.toggled;
		}
	}
}

/**********************************************************/
/*********** CACHE AVATARÓW                     ***********/
/**********************************************************/
public function onStreamComplete(event:Event):void {
	var bytes:ByteArray = new ByteArray;
	var cacheFile:File;
	var fileStream:FileStream = new FileStream();
	
	event.target.readBytes(bytes);
	
	fileStream.open(new File(event.target.filename), FileMode.WRITE);
	fileStream.writeBytes(bytes);
	fileStream.close();
	
	avatars.setAllBy('id', event.target.avatarId, 'url30', event.target.filename);
}

public function cacheAvatar(url:String, avatarId:int):String {
	var fileStream:FileStream = new FileStream();
	var cacheFile:File;
	var filename:String = url.split('/').pop();
	var cachePath:String;
	var stream:DynamicURLStream = new DynamicURLStream();
	
	stream.addEventListener(Event.COMPLETE, onStreamComplete);
	stream.addEventListener(IOErrorEvent.IO_ERROR, onCommError);
	cachePath = 'app-storage:/cache/'+filename;
	cacheFile = new File(cachePath);
	if (!cacheFile.exists) {
		stream.filename = cachePath;
		stream.avatarId = avatarId;
		stream.load(new URLRequest(url));
		return '';
	}
	return cachePath;
}

public function cacheAvatars(updates):void {
	for each (var update in updates) {
		var avatarUrl:String = '';
		
		if (null == update.user.avatar) {
			update.user.avatar = new BlipAvatar();
			update.user.avatar.url30 = 'app:/img/not_logged30.png';
		} else {
			avatarUrl = cacheAvatar(update.user.avatar.url30, update.user.avatar.id);
			
			if ('' == avatarUrl) {
				// Tymaczasowy avatar
				update.user.avatar.url30 = 'app:/img/not_logged30.png';
				avatars.addItem(update.user.avatar);	
			} else {
				update.user.avatar.url30 = avatarUrl;	
			}	
		}
	}
}

public function cacheSubscriptionsAvatars(subscriptions):void {
	for each (var subscription in subscriptions) {
		var avatarUrl:String = '';
		// Tracking user
		if (null == subscription.trackingUser.avatar) {
			subscription.trackingUser.avatar = new BlipAvatar();
			subscription.trackingUser.avatar.url30 = 'app:/img/not_logged30.png';
		} else {
			avatarUrl = cacheAvatar(subscription.trackingUser.avatar.url30, subscription.trackingUser.avatar.id);
			
			if ('' == avatarUrl) {
				// Tymaczasowy avatar
				subscription.trackingUser.avatar.url30 = 'app:/img/not_logged30.png';
				avatars.addItem(subscription.trackingUser.avatar);	
			} else {
				subscription.trackingUser.avatar.url30 = avatarUrl;	
			}	
		}
		
		// Tracked user
		if (null == subscription.trackedUser.avatar) {
			subscription.trackedUser.avatar = new BlipAvatar();
			subscription.trackedUser.avatar.url30 = 'app:/img/not_logged30.png';
		} else {
			avatarUrl = cacheAvatar(subscription.trackedUser.avatar.url30, subscription.trackedUser.avatar.id);
			
			if ('' == avatarUrl) {
				// Tymaczasowy avatar
				subscription.trackedUser.avatar.url30 = 'app:/img/not_logged30.png';
				avatars.addItem(subscription.trackedUser.avatar);	
			} else {
				subscription.trackedUser.avatar.url30 = avatarUrl;	
			}	
		}
	}	
}

/**********************************************************/
/*********** USTAWIENIA FILTRÓW DLA SUBSKRYPCJI ***********/
/**********************************************************/
public function onItemRollOut(object:*):void {
	var filterIndex:int = object.filters.indexOf(fxGlowWhite);
	if (-1 < filterIndex) {
		var filters:Array = object.filters;
		filters.splice(filterIndex);
		object.filters = filters;
	}
}

public function onItemRollOver(object:*):void {
	var filterIndex:int = object.filters.indexOf(fxGlowWhite);
	if (-1 == filterIndex) {
		var filters:Array = object.filters;
		filters.push(fxGlowWhite);
		object.filters = filters;
	}
}

/**********************************************************/
/*********** NOWY POST                          ***********/
/**********************************************************/
public function onStatusChange(event:Event):void {
	taStatus.text = taStatus.text.substr(0, 160);
	lblCharsLeft.text = (160-taStatus.text.length).toString();
}

public function onStatusKeyUp(event:KeyboardEvent):void {
	if (13 == event.keyCode) {
		event.preventDefault();
		onStatusSet(null);
	}	
}

public function onStatusSet(event:Event):void {
	
	if ('' != taStatus.text) {
		taStatus.enabled = false;
		btnSend.enabled = false;
		cnvAttachement.enabled = false;
		try {
			if ('' != FileAttachement.name) {
				api.SendUpdate(taStatus.text, FileAttachement);
			}
		} catch (err:Error) {
			api.SendUpdate(taStatus.text);
		}
	}	
}



/**********************************************************/
/*********** ZAŁĄCZNIK DO POSTU                 ***********/
/**********************************************************/
public function onDragIn(event:NativeDragEvent):void {
	NativeDragManager.acceptDragDrop(this);    
}

public function onDrag(event:NativeDragEvent):void {
  NativeDragManager.dropAction = NativeDragActions.COPY;
  var dropfiles:Array = event.clipboard.getData( ClipboardFormats.FILE_LIST_FORMAT) as Array;
  var file:File = dropfiles.pop();

  if (('png' == file.extension.toLowerCase()) ||
  	  ('jpg' == file.extension.toLowerCase()) ||
  	  ('jpeg' == file.extension.toLowerCase()) ||
  	  ('gif' == file.extension.toLowerCase())) 
  {
  	FileAttachement = file;  	
	onSelectAttachement(null);	  
  } else {
  	NativeDragManager.dropAction = NativeDragActions.NONE;
  }
}

public function onSelectAttachement(event:Event):void {
	imgDel.visible = true;
	imgAttachement.filters = [fxGlowWhite];
	cnvAttachement.toolTip = FileAttachement.name;
}

public function onDelAttachement(event:Event):void {
	imgDel.visible = false;
	FileAttachement = new FileReference();
	FileAttachement.addEventListener(Event.SELECT, onSelectAttachement);
	imgAttachement.filters = [fxDesaturate];
	cnvAttachement.toolTip = '';
	if (null != event) {
		event.preventDefault();
		event.stopPropagation();
	}
}

/**********************************************************/
/*********** OBSŁUGA SUBSKRYPCJI                ***********/
/**********************************************************/
public function onChangeSub(event:ListEvent):void {
	//trace();
	var login:String = event.target.selectedItem.trackedUserPath.split('/').pop();
	var userDashboard:BlipLog = BlipLogs.getBy('login', login);
	
	if (null == userDashboard) {
		userDashboard = new BlipLog();
		userDashboard.login = login;		
		BlipLogs.addItem(userDashboard);
	}
	
	api.GetUserDashboard(login, -1, new Array('user','user[avatar]','pictures','movie'));
	
	lstBlipLog.dataProvider = userDashboard;
}

public function onAppExit(event:Event):void {
	if (this.visible) { 
		config.data.windowX = this.nativeWindow.x;
		config.data.windowY = this.nativeWindow.y;
		config.data.windowWidth = this.nativeWindow.width;
		config.data.windowHeight = this.nativeWindow.height;
		config.flush();
	}
	pluginHost.closeAllWindows();	
}

