package com.suda.plugins
{
	import mx.core.Window;
	
	public class Plugin
	{
		public var name:String;
		public var enabled:Boolean;
		public var url:String;
		public var window:Window;
		public var child;				
		
		// Informations from info.xml file
		public var friendlyName:String;
		public var version:String;
		public var author:String;
		public var description:String;
		public var pageUrl:String;
		public var width:int;
		public var height:int;		
		public var hasWindow:Boolean;	
		
		public function Plugin(name:String, info:XML = null)
		{
			this.name = name;
			this.url = "app:/plugins/"+name+"/"+name+".swf";
			
			if (null != info) {
				this.friendlyName = info.name;
				this.version = info.version;
				this.author = info.author;
				this.description = info.description;
				this.pageUrl = info.url;
				
				this.width = parseInt(info.width);
				this.height = parseInt(info.height);
				
				this.hasWindow = ('true' == info.hasWindow) ? true : false;				
			}	
		}

	}
}