// ==================================================================
// Module:		TGAImageData.as
//
// Description:	Targa Image Data class
// 				- image pixel data
//
// Author(s):	C.T. Yeung 	(cty)
//
// History:
// 29Apr10		start working on this 							cty
//
// Copyright (c) 2010 C.T.Yeung

// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:

// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
// ==================================================================
package com.ctyeung.Targa
{
	import flash.display.BitmapData;
	import flash.utils.ByteArray;

	public class TGAImageData
	{
		public var bytes:ByteArray;
		protected var hdr:TGAHeader;
		protected var pal:TGAPalette;
		protected var offset:uint;
		protected var bmd:BitmapData;
		
		public function TGAImageData(hdr:TGAHeader,
									 pal:TGAPalette) {
			this.hdr = hdr;
			this.pal = pal;
		}
		
		public function dispose():void {
			hdr = null;
			pal = null;
			empty();
		}
		
		public function empty():void {
			if(bmd) {
				bmd.dispose();
				bmd = null;
			}
		}
		
		public function get bitmapData():BitmapData {
			return bmd;
		}
		
		public function set bitmapData(bmd:BitmapData):void {
			this.bmd = bmd;
		}

/////////////////////////////////////////////////////////////////////
// Encode 
		// default encoder, 24 or 32 bpp no-compression only
		public function encode( bmd:BitmapData,
							    hasAlpha:Boolean=false)
								:Boolean {
			
			bytes = new ByteArray();
			var pxlWid:int = (hasAlpha)?4:3;
			
			for(var y:int=bmd.height-1; y>=0; y--) {
				for(var x:int=0; x<bmd.width*pxlWid; x+=pxlWid) {
					var clr:uint = bmd.getPixel(x/pxlWid,y);
					bytes.writeByte((clr & 0xFF));
					bytes.writeByte((clr & 0xFF00)>>(8));
					bytes.writeByte((clr & 0xFF0000)>>(8*2));
					if(hasAlpha)
						bytes.writeByte((clr & 0xFF000000)>>(8*3));
				}
			}
			return true;
		}
		
/////////////////////////////////////////////////////////////////////
// Decode 		
		public function decode(bytes:ByteArray):Boolean {
			empty();
			offset = hdr.length + pal.length;
			switch(hdr.bpp) {
				case TGATypeEnum.BPP_1:
					return decodeMono(bytes);
				
				case TGATypeEnum.BPP_8:
					return decode8(bytes);
					
				case TGATypeEnum.BPP_24:
					return decode24(bytes);
					
				case TGATypeEnum.BPP_32:
					return decode32(bytes);
			}
			empty();
			return false;
		}
		
		// 1 bpp
		protected function decodeMono(bytes:ByteArray):Boolean {
			bmd = new BitmapData(hdr.imgWid, hdr.imgWid);
			var mask:uint=0x80;
			var index:uint = offset;
			for(var y:uint=0; y<hdr.imgLen; y++) {
				for(var x:uint=0; x<hdr.imgWid; x++) {
					var clr:uint = (mask&bytes[index])?0xFFFFFF:0x0;
					bmd.setPixel(x,y,clr);
					mask = (mask>0x1)?mask>>1:0x80;
					index ++;
				}
			}
			return true;
		}

/////////////////////////////////////////////////////////////////////
// 8 bpp image
		protected function decode8(bytes:ByteArray):Boolean {
			bmd = new BitmapData(hdr.imgWid, hdr.imgWid);
			switch(hdr.imgType) {
				case TGATypeEnum.IMG_TYPE_MONO_NO_CMP:
					return decode8Mono(bytes);
					
				case TGATypeEnum.IMG_TYPE_CLR_MAP_NO_CMP:
					return decode8ClrMap(bytes);
					
				case TGATypeEnum.IMG_TYPE_CLR_RMAP_RLE:
				case TGATypeEnum.IMG_TYPE_CLR_MAP_HUFF:
				case TGATypeEnum.IMG_TYPE_CLR_MAP_HUFFQUAD:
					break;
			}
			return false;
		}
		
		protected function decode8Mono(bytes:ByteArray):Boolean {
			for(var y:uint=0; y<hdr.imgLen; y++) {
				var index:uint = y*hdr.imgWid+offset;
				for(var x:uint=0; x<hdr.imgWid; x++) {
					var clr:uint = bytes[index++];
					clr = (clr<<16) +
						  (clr<<8) + 
						  clr;
					
					bmd.setPixel(x,y,clr);
				}
			}
			return true;
		}
		
		// 8 bpp, only 16 entries of color in palette
		protected function decode8ClrMap(bytes:ByteArray):Boolean {
			for(var y:uint=0; y<hdr.imgLen; y++) {
				var index:uint = y*hdr.imgWid+offset;
				for(var x:uint=0; x<hdr.imgWid; x++) {
					var i:int 	 = bytes[index++];
					var clr:uint = pal.color(i);
					bmd.setPixel(x,y,clr);
				}
			}
			return true;
		}

/////////////////////////////////////////////////////////////////////
// decode 24 bpp image
		
		protected function decode24(bytes:ByteArray):Boolean {
			bmd = new BitmapData(hdr.imgWid, hdr.imgWid, true, 0xFFFFFFFF);
			switch(hdr.imgType) {
				case TGATypeEnum.IMG_TYPE_RGB_RLE:
					break;
					
				case TGATypeEnum.IMG_TYPE_RGB_NO_CMP:		// type 2
					return decode24BGR(bytes);
			}
			return false;
		}
		
		protected function decode24BGR(bytes:ByteArray):Boolean {
			for(var y:uint=0; y<hdr.imgLen; y++) {
				var index:uint = y*hdr.imgWid*3+offset;
				for(var x:uint=0; x<hdr.imgWid; x++) {
					var clr:uint = 	(bytes[index++])+
									(bytes[index++]<<8)+
									(bytes[index++]<<16);
					
					bmd.setPixel(x,y,clr);
				}
			}
			return true;
		}
		
/////////////////////////////////////////////////////////////////////
// decode 32 bpp image	
		protected function decode32(bytes:ByteArray):Boolean {
			bmd = new BitmapData(hdr.imgWid, hdr.imgWid, true, 0xFFFFFFFF);
			switch(hdr.imgType) {
				case TGATypeEnum.IMG_TYPE_RGB_RLE:
					break;
				
				case TGATypeEnum.IMG_TYPE_RGB_NO_CMP:		// type 2
					return decode32BGRA(bytes);
			}
			return false;
		}
		
		protected function decode32BGRA(bytes:ByteArray):Boolean {
			for(var y:uint=0; y<hdr.imgLen; y++) {
				var index:uint = y*hdr.imgWid*4+offset;
				for(var x:uint=0; x<hdr.imgWid; x++) {
					var clr:uint = 	(bytes[index++])+
									(bytes[index++]<<8)+
									(bytes[index++]<<16) +
									(bytes[index++]<<24);
					
					bmd.setPixel32(x,y,clr);
				}
			}
			return true;
		}
							   
	}
}