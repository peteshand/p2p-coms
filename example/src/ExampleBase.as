package  
{
	import blaze.service.p2p.P2PService;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author P.J.Shand
	 */
	public class ExampleBase extends Sprite 
	{
		protected var sprite:Sprite;
		protected var p2pService:P2PService;
		
		public function ExampleBase() 
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, OnAdd);
		}
		
		private function OnAdd(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, OnAdd);
			
			sprite = new Sprite();
			addChild(sprite);
			sprite.graphics.beginFill(0xFF0000);
			sprite.graphics.drawCircle(0, 0, 10);
			
			init();
		}
		
		public function init():void
		{
			// Class Reg Example
			p2pService = new P2PService();
			p2pService.start();
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, OnMouseMove);
		}
		
		protected function OnMouseMove(e:MouseEvent):void 
		{
			
		}
	}

}