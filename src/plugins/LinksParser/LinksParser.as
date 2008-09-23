package plugins.LinksParser
{
	import com.suda.AS3BlipLib.objects.*;
	import com.suda.plugins.PluginEvent;
	import com.suda.plugins.PluginHost;
	
	import mx.modules.ModuleBase;

	public class LinksParser extends ModuleBase
	{
		private var pluginHost:PluginHost;
		private var linkColor:String = '#777777';
		
		public function LinksParser()
		{
			super();
		}
		
		public function init(pluginHost:PluginHost):Boolean {
			this.pluginHost = pluginHost;
			
			this.pluginHost.addEventListener('onPluginRenderStatus', renderStatus, false, 2);
			return true;
		}
		
		public function renderStatus(event:PluginEvent):void {
			if (event.data is BlipLog) {
				for each (var item in event.data) {
					var out:String = item.htmlBody;
					
					var loginStr:String = '';
					if (BlipUpdate.UPDATE_TYPE_STATUS == item.type) {	
											
						loginStr = '<a href="http://www.blip.pl/users/'+loginFromPath(item.userPath)+
								   '/dashboard" class="login" target="_blank">'+
								   loginFromPath(item.userPath) + '</a>: ';
					} else {
						loginStr = '<a href="http://www.blip.pl/users/'+loginFromPath(item.userPath)+
								   '/dashboard" class="login" target="_blank">'+
								   loginFromPath(item.userPath) + '</a> &gt; ' +
								   '<a href="http://www.blip.pl/users/'+loginFromPath(item.recipientPath)+
								   '/dashboard" class="login" target="_blank">'+
								   loginFromPath(item.recipientPath)+ '</a>: ';
					}
					out = htmlspecialchars(out);
					out = parseLinks(out);
					out = parseTags(out);
					out = parseUsers(out);
					item.htmlBody = loginStr + out;
				}
			}	
		}
		
		public function htmlspecialchars(str:String):String {
			str = str.replace(/\</g, "&lt;");
			str = str.replace(/\>/g, "&gt;");
			return str;
		}
			
		private function noPl(text:String):String {
			var out:String = text;
			
			out = out.replace(/ę/g, 'e');
			out = out.replace(/ó/g, 'o');
			out = out.replace(/ą/g, 'a');
			out = out.replace(/ś/g, 's');
			out = out.replace(/ł/g, 'l');
			out = out.replace(/[ż|ź]/g, 'z');
			out = out.replace(/ć/g, 'c');
			out = out.replace(/ń/g, 'n');
			
			out = out.replace(/Ę/g, 'E');
			out = out.replace(/Ó/g, 'O');
			out = out.replace(/Ą/g, 'A');
			out = out.replace(/Ś/g, 'S');
			out = out.replace(/Ł/g, 'L');
			out = out.replace(/[Ż|Ź]/g, 'Z');
			out = out.replace(/Ć/g, 'C');
			out = out.replace(/Ń/g, 'N');
			
			return out;
		}
		
		private function parseTags(text:String):String {
			var pattern:String = '(?<!\")(?<=\#)([a-z]|[0-9]|[ęóąśłżźćń]|[ĘÓĄŚŁŻŹĆŃ]|[\-\_])+';
			var results:Array = text.match(new RegExp(pattern, 'gi'));
			var out:String = text;
			
			for each (var result:String in results) {
				var formatedOut:String = noPl(result);
				formatedOut = formatedOut.replace(/[\-\_]/g, '');
				formatedOut = formatedOut.toLowerCase();
				
				out = out.replace(new RegExp('(?<!\")\#'+result, 'g'), 
					  '<a href="http://www.blip.pl/tags/'+formatedOut+'" target="_blank">#'+result+'</a>');	
			}
			
			return out;	
		}
		
		private function parseUsers(text:String):String {
			return text.replace(/\^(\w+)/g, '<a href="http://www.blip.pl/users/$1/dashboard" target="_blank">^$1</a>');
		}
		
		private function parseLinks(text:String):String {
			//return text.replace(/(?<!\!)((http[s]?|ftp|ssh)\:\/\/([\S|^\]]+))/gi, '<a href="$2://$3" target="_blank">$1</a>');
			return text.replace(/(([a-zA-Z]+\:\/\/)([a-zA-Z0-9?&%\.;:\/=\+_-]*))/gi, '<a href="$1" target="_blank">$1</a>');
		}
		
		private function loginFromPath(text:String):String {
			return text.split('/').pop();
		}
		
	}
}