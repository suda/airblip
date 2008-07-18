package plugins.LinkToImage
{
	import com.suda.AS3BlipLib.events.BlipResultEvent;
	import com.suda.AS3BlipLib.objects.*;
	import com.suda.CustomArrayCollection;
	import com.suda.plugins.PluginEvent;
	import com.suda.plugins.PluginHost;
	
	import mx.modules.ModuleBase;

	public class LinkToImage extends ModuleBase
	{ 
		private var pluginHost:PluginHost;
		private var linkColor:String = '#777777';
		private var updates:CustomArrayCollection = new CustomArrayCollection();
		
		public function LinkToImage()
		{
			super();
		}
		
		public function init(pluginHost:PluginHost):Boolean {
			this.pluginHost = pluginHost;
			
			this.pluginHost.addEventListener('onPluginRenderStatus', renderStatus, false, 1);
			return true;
		}
		
		public function renderStatus(event:PluginEvent):void {
			if (event.data is BlipLog) {
				for each (var item in event.data) {
					if ('' != item.picturesPath) {
						updates.addItem(item);
						pluginHost.api.addEventListener(BlipResultEvent.ON_GET_UPDATE_PICTURES, onGetUpdatePictures);
						pluginHost.api.GetUpdatePicturesByPath(item.picturesPath);
						
					}
				}
			}	
		}
		
		private function onGetUpdatePictures(event:BlipResultEvent):void {
			var update = updates.getBy('id', event.data[0].updatePath.split('/')[2]);
			//update.htmlBody += ' <a href="'+event.data[0].url+'"><font color="'+linkColor+'"><b>[Obrazek]</b></font></a>';  
		}
	}
}