package 
{
	import blaze.service.p2p.P2PService;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	import org.osflash.signals.Signal;
	
	/**
	 * ...
	 * @author P.J.Shand
	 */
	public class Main extends Sprite 
	{
		private var sprite:Sprite;
		private var p2pService:P2PService;
		
		public function Main():void 
		{
			sprite = new Sprite();
			addChild(sprite);
			sprite.graphics.beginFill(0xFF0000);
			sprite.graphics.drawCircle(0, 0, 10);
			
			p2pService = new P2PService();
			p2pService.register(MouseEvent);
			p2pService.start();
			
			var signal:Signal = p2pService.addListener("Test");
			signal.add(OnNewMsg);
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, OnMouseMove);
		}
		
		private function OnNewMsg(data:Object):void 
		{
			sprite.x = data.x;
			sprite.y = data.y;
		}
		
		private function OnMouseMove(e:MouseEvent):void 
		{
			p2pService.addMessgae( { x:e.stageX, y:e.stageY } );
		}
	}
}