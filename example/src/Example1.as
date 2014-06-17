package  
{
	import blaze.service.p2p.P2PService;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import org.osflash.signals.Signal;
	
	/**
	 * ...
	 * @author P.J.Shand
	 */
	public class Example1 extends ExampleBase 
	{
		public function Example1() 
		{
			super();
			
		}
		
		override public function init():void
		{
			super.init();
			
			// Class Reg Example
			p2pService.register(DataVO);
			
			var signal:Signal = p2pService.groupSignal("Test", "data");
			var signal2:Signal = p2pService.groupSignal("Test", "xyz");
			
			signal.add(OnNewMsg);
			signal2.add(OnNewMsg2);
		}
		
		
		private function OnNewMsg(data:DataVO):void 
		{
			sprite.x = data.x;
			sprite.y = data.y;
		}
		
		private function OnNewMsg2(testValue:int):void 
		{
			trace("testValue = " + testValue);
		}
		
		override protected function OnMouseMove(e:MouseEvent):void 
		{
			var dataVO:DataVO = new DataVO();
			dataVO.x = e.stageX;
			dataVO.y = e.stageY;
			dataVO.index = 0;
			dataVO.type = "TEST";
			
			p2pService.addMessgae( { data:dataVO, xyz:0 } );
		}
	}

}