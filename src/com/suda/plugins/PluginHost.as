package com.suda.plugins
{
	import com.suda.*;
	import com.suda.AS3BlipLib.BlipAPI;
	
	import flash.desktop.*;
	import flash.display.*;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.filesystem.*;
	
	import mx.core.Window;
	import mx.events.ModuleEvent;
	import mx.modules.*;

	public class PluginHost extends EventDispatcher
	{
		public var plugins:CustomArrayCollection = new CustomArrayCollection();
		public var api:BlipAPI;
		
		public function PluginHost(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function queryPlugins():void {
			var pluginsDirectory:File = new File('app:/plugins/');
			var list:Array = pluginsDirectory.getDirectoryListing();
			
			for (var i:uint = 0; i < list.length; i++) {	    
			    if (list[i].isDirectory) {
			    	var pluginInfoFile:File = new File("app:/plugins/"+list[i].name+"/info.xml");
			    	if (pluginInfoFile.exists) {
			    		var pluginInfoStream:FileStream = new FileStream();
			    		pluginInfoStream.open(pluginInfoFile, FileMode.READ);	    		
			    		var plugin:Plugin = new Plugin(list[i].name, 
			    							new XML(pluginInfoStream.readUTFBytes(pluginInfoFile.size)));
		
			    		this.plugins.addItem(plugin);				    					    		
			    	}
			    }
			}	
		}
		
		public function loadAllPlugins():void {
			for each (var plugin:Plugin in this.plugins) {												
				this.loadPlugin(plugin.name);
			}
		}
		
		public function loadPlugin(name:String):void {
			var module:IModuleInfo = ModuleManager.getModule("app:/plugins/"+name+"/"+name+".swf");
			module.addEventListener(ModuleEvent.READY, onLoadPlugin);    
		    module.load();

		}
		
		public function onLoadPlugin(event:ModuleEvent):void {
			var plugin:Plugin = plugins.getBy('url', event.module.url);
			if (plugin.hasWindow) {
				plugin.window = new Window();
				plugin.window.systemChrome = NativeWindowSystemChrome.STANDARD;
				plugin.window.transparent = false;
				plugin.window.title = plugin.friendlyName;
				plugin.window.width = plugin.width;
				plugin.window.height = plugin.height;
				plugin.window.showStatusBar = false;
				
				plugin.child = plugin.window.addChild(event.module.factory.create() as DisplayObject);				
				plugin.window.addEventListener(Event.CLOSING, onWindowClosing);
				
				// Setup basic window event listeners from plugin
				if (plugin.child.hasOwnProperty('onClose')) {
					plugin.window.addEventListener(Event.CLOSE, plugin.child.onClose);
				}
				
				if (plugin.child.hasOwnProperty('onClosing')) {
					plugin.window.addEventListener(Event.CLOSING, plugin.child.onClosing);
				}
			
			} else {
				plugin.child = event.module.factory.create();
			}
			plugin.child.init(this);					
		}
		
		private function onWindowClosing(event:Event):void {
			event.preventDefault();
			
			event.currentTarget.visible = false;
		}
		
		public function openPluginWindow(name:String):void {
			var plugin:Plugin = plugins.getBy('name', name);
			if (plugin.hasWindow && (null != plugin.window)) {
				if (null == plugin.window.nativeWindow) {				
					plugin.window.open();
				} else {
					plugin.window.visible = true;
				}
			}
		}
		
		
		public function closeAllWindows():void {
			for each (var plugin:Plugin in this.plugins) {
				if (plugin.hasWindow && (null != plugin.window)) {
					plugin.window.removeEventListener(Event.CLOSING, onWindowClosing);
					plugin.window.close();
				}
			}
		}
		
		public function execPluginFunc(name:String, func:String, params:Array, showWindow:Boolean):void {
			var plugin:Plugin = plugins.getBy('name', name);
			if (null !=  plugin) {
				plugin.child.exec(func, params);
				if (showWindow) {
					openPluginWindow(name);
				}
			}				
		}
		
	}
}