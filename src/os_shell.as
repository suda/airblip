// ActionScript file
/**********************************************************/
/*********** OBSŁUGA TRAY I DOCK                ***********/
/**********************************************************/

public function onIconLoaded(event:Event):void {

	NativeApplication.nativeApplication.icon.bitmaps = [event.target.content.bitmapData];
	this.nativeApplication.icon.bitmaps = [event.target.content.bitmapData];
	
	
	if (NativeApplication.supportsSystemTrayIcon) {
		var iconMenu:NativeMenu = new NativeMenu();
		
		muteCommand = iconMenu.addItem(new NativeMenuItem("Wyłącz dźwięki"));
		muteCommand.checked = mnuMute.toggled;
        muteCommand.addEventListener(Event.SELECT, function(event:Event):void {
            mnuMute.toggled = !mnuMute.toggled;
            mnuOptions.dispatchEvent(new MenuEvent(MenuEvent.ITEM_CLICK, false, true, null, mnuOptions, mnuMute));
            mnuOptions.invalidateList();            
        });
        
        var separatorCommand:NativeMenuItem = iconMenu.addItem(new NativeMenuItem('', true));
		
		var exitCommand:NativeMenuItem = iconMenu.addItem(new NativeMenuItem("Zamknij"));
        exitCommand.addEventListener(Event.SELECT, function(event:Event):void {
            NativeApplication.nativeApplication.icon.bitmaps = [];
            NativeApplication.nativeApplication.exit();
        });

		var systray:SystemTrayIcon = 
	        NativeApplication.nativeApplication.icon as SystemTrayIcon;
	        
	        
	    systray.tooltip = "AirBlip";
	    systray.menu = iconMenu;
		systray.addEventListener(MouseEvent.CLICK, onTrayIconClick);
		this.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, preventMinimize); 
	}
	
	if (NativeApplication.supportsDockIcon) {
		
	}
}

public function onTrayIconClick(event:Event):void {
	if (this.visible && !hasFocus) {
		this.stage.nativeWindow.alwaysInFront = true;
		this.stage.nativeWindow.alwaysInFront = false;		
	} else {
		this.visible = !this.visible;	
		if (this.visible) {
			this.nativeWindow.restore();
		}
	}
}

private function preventMinimize(event:NativeWindowDisplayStateEvent):void{
    if(event.afterDisplayState == NativeWindowDisplayState.MINIMIZED){
        event.preventDefault();
        event.target.visible = false;        
    }
}