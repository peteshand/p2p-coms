package blaze.service.p2p 
{
	import blaze.utils.delay.Delay;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.net.GroupSpecifier;
	import flash.net.NetConnection;
	import flash.net.NetGroup;
	import flash.net.NetGroupReplicationStrategy;
	import flash.utils.Dictionary;
	import org.osflash.signals.Signal;

	/**
	 * ...
	 * @author P.J.Shand
	 */
	public class P2PObject 
	{
		public var groupID:String;
		private var serviceURL:String;
		private var autoStart:Boolean;
		
		private var nc:NetConnection;
		private var groupspec:GroupSpecifier;
		public var group:NetGroup;
		
		private var _numberOfConnectedPairs:int = 0;
		private var _connected:Boolean = false;
		
		public var connectionRefused:Signal = new Signal();
		public var connectionSuccess:Signal = new Signal();
		public var neighborConnect:Signal = new Signal();
		public var neighborDisconnect:Signal = new Signal();
		public var onMsg:Signal = new Signal(Object);
		public var onMsgs:Dictionary = new Dictionary(true);
		
		private var totalFrameBuffers:int = 0;
		private var frameBufferCount:int = 0;
		private var activeFrames:int = 0;
		private var frames:Vector.<Vector.<Object>>;
		//private var msgObjects:Vector.<Object> = new Vector.<Object>();
		private var s:Sprite = new Sprite();
		
		public function P2PObject(groupID:String, serviceURL:String, autoStart:Boolean, frameBuffer:int) 
		{
			this.groupID = groupID;
			this.serviceURL = serviceURL;
			this.autoStart = autoStart;
			this.totalFrameBuffers = frameBuffer;
			
			frames = new Vector.<Vector.<Object>>(totalFrameBuffers+1, true);
			for (var i:int = 0; i < frames.length; i++) 
			{
				frames[i] = new Vector.<Object>();
			}
			
			if (nc == null){
				nc = new NetConnection();
				nc.addEventListener(NetStatusEvent.NET_STATUS, netStatus);
			}
			nc.connect(serviceURL);
			start();
		}
		
		public function addMessgae(msgObject:Object):void 
		{
			frames[frameBufferCount].push(msgObject);
		}
		
		public function clearMsgs():void
		{
			for (var j:int = 0; j < frames[frameBufferCount].length; j++) 
			{
				frames[frameBufferCount].splice(0, 1);
			}
		}
		
		public function clearAllMsgs():void
		{
			for (var i:int = 0; i < frames.length; i++) 
			{
				for (var j:int = 0; j < frames[i].length; j++) 
				{
					frames[i].splice(0, 1);
				}
			}
		}
		
		public function start():void 
		{
			if (!connected) {
				connectionSuccess.addOnce(OnConnectionStartUpdate);
				return;
			}
			s.addEventListener(Event.ENTER_FRAME, Update);
		}
		
		private function OnConnectionStartUpdate():void 
		{
			start()
		}
		
		public function stop():void 
		{
			connectionSuccess.remove(OnConnectionStartUpdate);
			s.removeEventListener(Event.ENTER_FRAME, Update);
		}
		
		private function Update(e:Event):void 
		{
			if (frames[frameBufferCount].length > 0) activeFrames++;
			else clearMsgs();
			
			frameBufferCount++;
			
			if (frameBufferCount >= totalFrameBuffers) {
				if (activeFrames != 0) SendMessage();
				frameBufferCount = 0;
				activeFrames = 0;
			}
		}
		
		private function SendMessage():void 
		{
			MsgReceived(frames);
			if (group) {
				//group.sendToAllNeighbors(frames);
				group.post(frames);
				clearAllMsgs();
			}
		}
		
		public function dispose():void
		{
			nc.close();
			if (group) group.close();
			nc = null;
			group = null;
		}
		
		public function msgSignal(objectID:String):Signal 
		{
			if (objectID == 'all') {
				return onMsg;
			}
			else {
				if (!onMsgs[objectID]) onMsgs[objectID] = new Signal(Object);
				return onMsgs[objectID];
			}
		}
		
		private function netStatus(event:NetStatusEvent):void
		{
			trace("event.info.code = " + event.info.code);
			switch(event.info.code){
				case "NetConnection.Connect.Success":
					setupGroup();
					break;
				case "NetGroup.Connect.Success":
					OnNetGroupConnectSuccess();
					break;
				case "NetGroup.Connect.Rejected":
					OnNetGroupConnectRejected();
					break;
				case "NetGroup.Neighbor.Connect":
					OnNeighborConnect();
					break;
				case "NetGroup.Neighbor.Disconnect":
					OnNeighborDisconnect();
					break;
				case "NetGroup.Posting.Notify":
					MsgReceived(Vector.<Vector.<Object>>(event.info.message));
					break;
				case "NetGroup.SendTo.Notify":
					MsgReceived(Vector.<Vector.<Object>>(event.info.message));
					break;
				
				case "NetGroup.Replication.Request":
					ReplicationRequest(event);
					break;
				case "NetGroup.Replication.Fetch.Result":
					ReplicationResult(event);
					break;
			}
		}
		
		private function ReplicationRequest(event:NetStatusEvent):void 
		{
			//group.writeRequestedObject(event.info.requestID,obj[event.info.index])
		}
		
		private function ReplicationResult(event:NetStatusEvent):void 
		{
			//group.addHaveObjects(event.info.index,event.info.index);
		}
		
		private function setupGroup():void
		{
			if (CONFIG::air) {
				groupspec = new GroupSpecifier(groupID);
				groupspec.multicastEnabled = true;
				groupspec.postingEnabled = true;
				groupspec.ipMulticastMemberUpdatesEnabled = true;
				groupspec.routingEnabled = true;
				groupspec.objectReplicationEnabled = true;
				groupspec.serverChannelEnabled = true;
				groupspec.addIPMulticastAddress("225.225.0.1:30303");
				
				group = new NetGroup(nc,groupspec.groupspecWithAuthorizations());
				group.addEventListener(NetStatusEvent.NET_STATUS, netStatus);	
				group.replicationStrategy = NetGroupReplicationStrategy.LOWEST_FIRST;
			}
		}
		
		
		
		private function MsgReceived(frames:Vector.<Vector.<Object>>):void 
		{
			for (var j:int = 0; j < frames.length; j++) 
			{
				if (j == 0) FrameMsgReceived(Vector.<*>(frames[j]));
				else Delay.by(j, FrameMsgReceived, [frames[j]]);
			}
		}
		
		private function FrameMsgReceived(messageObjects:Vector.<*>):void 
		{
			for (var i:int = 0; i < messageObjects.length; i++) 
			{
				onMsg.dispatch(messageObjects[i]);
				
				for (var property:* in messageObjects[i]) {
					if (onMsgs[property]) Signal(onMsgs[property]).dispatch(messageObjects[i][property]);
				}
			}
		}
		
		private function OnNetGroupConnectSuccess():void 
		{
			connected = true;
			if (autoStart) this.start();
		}
		
		private function OnNetGroupConnectRejected():void 
		{
			connected = false;
		}
		
		private function OnNeighborConnect():void 
		{
			numberOfConnectedPairs++;
			neighborConnect.dispatch();
		}
		
		private function OnNeighborDisconnect():void 
		{
			numberOfConnectedPairs--;
			neighborDisconnect.dispatch();
		}
		
		public function get connected():Boolean 
		{
			return _connected;
		}
		
		public function set connected(value:Boolean):void 
		{
			_connected = value;
			if (connected) connectionSuccess.dispatch();
			else connectionRefused.dispatch();
		}
		
		public function get numberOfConnectedPairs():int 
		{
			return _numberOfConnectedPairs;
		}
		
		public function set numberOfConnectedPairs(value:int):void 
		{
			_numberOfConnectedPairs = value;
		}
	}
}