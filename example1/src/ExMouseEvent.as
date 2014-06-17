package  
{
	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author P.J.Shand
	 */
	public class ExMouseEvent extends MouseEvent 
	{
		private var e:MouseEvent;
		public function ExMouseEvent() 
		{
			super("", true, false, NaN, NaN, null, false, false, false, false, 0, false, false, 0);
		}
		
		public function init(e:MouseEvent):void
		{
			this.e = e;
			//this.type = e.type;
			//this.bubbles = e.bubbles;
			//this.cancelable = e.cancelable;
			this.localX = e.localX;
			this.localY = e.localY;
			this.relatedObject = e.relatedObject;
			this.ctrlKey = e.ctrlKey;
			this.altKey = e.altKey;
			this.shiftKey = e.shiftKey;
			this.buttonDown = e.buttonDown;
			this.delta = e.delta;
			this.commandKey = e.commandKey;
			this.controlKey = e.controlKey;
			//this.clickCount = e.clickCount;
			
			//super(type, bubbles, cancelable, localX, localY, relatedObject, ctrlKey, altKey, shiftKey, buttonDown, delta, commandKey, controlKey, clickCount);
			
		}
		
	}

}