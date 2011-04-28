/**
 * subsonic desktop client
 *
 * Copyright (c) 2011 Juan Carlos del Valle (imekinox.com) <jc.ekinox@gmail.com>
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * @license http://www.gnu.org/licenses/gpl.html
 * @project subsonic.player
 */

package org.helpers
{
	import caurina.transitions.Tweener;
	
	import com.imagefeed.objects.Image;
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;

	public class ImageLoader extends MovieClip{
		private var loader:Loader;
		private var w:Number;
		private var h:Number;
		private var temporalLoaderB:MovieClip;
		
		private var _maxWidth		: int;
		private var _maxHeight		: int;
		private var _resizedWidth	: int;
		private var _resizedHeight	: int;
	
		public function ImageLoader(){
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,progressFunc);
			loader.contentLoaderInfo.addEventListener(Event.INIT,imageLoaded);
			var temporalLoader:MovieClip = new MovieClip();
			temporalLoaderB = new MovieClip();
			
			temporalLoader.graphics.beginFill(0x000033);
			temporalLoader.graphics.drawRect(0,0,100,20);
			temporalLoader.graphics.endFill();
			
			temporalLoaderB.graphics.beginFill(0x0000CC);
			temporalLoaderB.graphics.drawRect(0,0,10,20);
			temporalLoaderB.graphics.endFill();
			temporalLoaderB.width = .1;
			
			temporalLoader.addChild(temporalLoaderB);
			addChild(temporalLoader);
			addChild(loader);
			
		}
		
		private function imageLoaded(e:Event):void{
			if(!_resizedWidth)resizeImage();
			this.width = _resizedWidth;
			this.height = _resizedHeight;
		}
		
		private function progressFunc(e:ProgressEvent):void{
			Tweener.addTween(temporalLoaderB,{width:100* (e.bytesLoaded/e.bytesTotal)});
		}
		
		
		private function resizeImage():void{
			if(w == 0){
				w= this.width;
				h= this.height
			}
			if(w > h){
				if(w>_maxWidth){
					_resizedWidth = _maxWidth;
					_resizedHeight = h * _maxWidth/w;
				}
			}else{
				if(h>_maxHeight){
					_resizedHeight = _maxHeight;
					_resizedWidth = w * _maxHeight/h;
				}			
			}
			this.y += (_maxHeight - _resizedHeight)/2;
			this.x += (_maxWidth - _resizedWidth)/2;
		}		
		public function loadImage(image:Image):void{
			w = image.width;
			h = image.height;
			if(w>0)resizeImage();
			loader.load(new URLRequest(image.original));
			trace("loading image" + image.original);
		}
		public function get resizedWidth():int{
			return _resizedWidth;
		}
		public function get resizedHeight():int{
			return _resizedHeight;
		}
		public function set maxWidth(i:int):void{
			_maxWidth = i;
		}
		public function set maxHeight(i:int):void{
			_maxHeight = i;
		}
		
	}
	
}