package blaze.service.p2p 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.registerClassAlias;
	import flash.utils.getDefinitionByName;
	import org.osflash.signals.Signal;
	
	import flash.utils.describeType;
	/**
	 * ...
	 * @author Pete Shand
	 */
	public class P2PService
	{
		public static const DEFAULT_GROUP:String = 'default_group';
		
		private var serviceURL:String = "rtmfp:";
		private static var communicationObjects:Vector.<P2PObject>;
		
		private var running:Boolean = false;
		public var frameBuffer:int = 0;
		
		public function P2PService() 
		{
			if (!P2PService.communicationObjects) P2PService.communicationObjects = new Vector.<P2PObject>();
		}
		
		public function start():void
		{
			running = true;
			for (var i:int = 0; i < P2PService.communicationObjects.length; i++) {
				P2PService.communicationObjects[i].start();
			}
		}
		
		public function stop():void
		{
			running = false;
			for (var i:int = 0; i < P2PService.communicationObjects.length; i++) {
				P2PService.communicationObjects[i].stop();
			}
		}
		
		public function addMessgae(msgObject:Object, groupID:String=null):void 
		{
			if (groupID) group(groupID).addMessgae(msgObject);
			else {
				for (var i:int = 0; i < P2PService.communicationObjects.length; i++) P2PService.communicationObjects[i].addMessgae(msgObject);
			}
		}
		
		public function groupSignal(groupID:String, objectID:String=null):Signal 
		{
			if (!objectID) objectID = 'all';
			return group(groupID).msgSignal(objectID);
		}
		
		private function group(groupID:String):P2PObject
		{
			for (var i:int = 0; i < P2PService.communicationObjects.length; ++i) {
				if (P2PService.communicationObjects[i].groupID == groupID) {
					return P2PService.communicationObjects[i];
				}
			}
			var p2pObject:P2PObject = new P2PObject(groupID, serviceURL, running, frameBuffer);
			P2PService.communicationObjects.push(p2pObject);
			return p2pObject;
		}
		
		public function createGroup(groupID:String):void 
		{
			group(groupID);
		}
		
		private static var registeredClasses:Vector.<Class> = new Vector.<Class>();
		
		public function register(_class:Class):void
		{
			if (alreadyAdded(_class)) return;
			P2PService.registeredClasses.push(_class);
			
			var classXML:XML = XML(describeType(_class));
			
			var split:Array = classXML.@name.split("::");
			var path:String = split[0] + "." + split[1];
			registerClassAlias(path, _class);
			
			var numVars:int = classXML.factory.variable.length();
			for (var i:int = 0; i < numVars; i++) 
			{
				var type:String = classXML.factory.variable[i].@type;
				var VarClass:Class = Class(getDefinitionByName(type));
				if (alreadyAdded(VarClass)) continue;
				register(VarClass);
			}
		}
		
		private function alreadyAdded(_class:Class):Boolean
		{
			for (var j:int = 0; j < P2PService.registeredClasses.length; j++) 
			{
				if (P2PService.registeredClasses[j] == _class) return true;
			}
			return false;
		}
	}
}