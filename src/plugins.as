import com.suda.plugins.*;

import flash.events.TextEvent;

var pluginHost:PluginHost = new PluginHost();

public static const ON_PLUGIN_RENDER_STATUS:String = "onPluginRenderStatus";
 
public function trim(str:String, char:String = ' '):String {
    return trimBack(trimFront(str, char), char);
}

public function trimFront(str:String, char:String):String {
    char = stringToCharacter(char);
    if (str.charAt(0) == char) {
        str = trimFront(str.substring(1), char);
    }
    return str;
}

public function trimBack(str:String, char:String):String {
    char = stringToCharacter(char);
    if (str.charAt(str.length - 1) == char) {
        str = trimBack(str.substring(0, str.length - 1), char);
    }
    return str;
}

public function stringToCharacter(str:String):String {
    if (str.length == 1) {
        return str;
    }
    return str.slice(0, 1);
}
 
public function onBlipLogPlugin(event:TextEvent):void {
	//trace(event.text);
	var temp:Array = event.text.split('.');
	var pluginName:String = temp.reverse().pop();
		
	var tempStr:String = (temp.pop() as String).replace(/((\w+)\s*\((.*)\))/i, '$2\n$3');
	temp = tempStr.split('\n');
	var func:String = temp.reverse().pop();
	 
	var paramsStr:String = temp.pop();	
	var paramsArr:Array = paramsStr.split(',');
	var params:Array = new Array();
	
	for each (var param:String in paramsArr) {
		param = trim(param);	
		
		if ((("'" == param.charAt(0)) && ("'" == param.charAt(param.length -1))) ||
			(('"' == param.charAt(0)) && ('"' == param.charAt(param.length -1)))) {
			params.push(new String(param.substring(1, param.length - 1)));
		} else if (('true' == param) || ('false' == param)) {
			params.push('true' == param ? true : false);
		} else {
			params.push(parseInt(param));
		}
	}
	 
	var showWindow:Boolean = false;
	if (0 < params.length) {
		params.reverse();
		showWindow = params.pop();
		params.reverse();
	}
	pluginHost.execPluginFunc(pluginName, func, params, showWindow);
}
