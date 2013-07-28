// ==================================================================
// Module:		TGAPalette.as
//
// Description:	Targa Palette class
// 				- bitmapheader 
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
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	public class TGAPalette
	{
		public var length:int = 0;
		public var hdr:TGAHeader;
		protected var palette:Array;
		protected var dictionary:Dictionary;
		protected var keys:Array;
		
		public function TGAPalette(hdr:TGAHeader) {
			this.hdr 	= hdr;
		}
		
		public function dispose():void {
			hdr 		= null;
			keys 		= null;
			dictionary 	= null;
			palette 	= null;
		}
		
		public function decode(bytes:ByteArray):Boolean {
			if(!hdr.clrMapType)
				return true;
			
			palette = new Array();
			switch(hdr.clrMapEntrySze) {
				case TGATypeEnum.CLR_MAP_SIZE_16:
					return decode16(bytes);
				
				case TGATypeEnum.CLR_MAP_SIZE_24:
					return decode24(bytes);
				
				case TGATypeEnum.CLR_MAP_SIZE_32:
					return decode32(bytes);
			}
			this.length = hdr.clrMapLen * numOfBytes;
			return false;
		}
		
		public function color(index:int):uint {
			if(index>this.palette.length)
				return 0xFFFFFFFF;
			
			if(index<0)
				return 0;
			
			return palette[index];
		}
		
		protected function get numOfBytes():int {
			switch(hdr.clrMapEntrySze) {
				case TGATypeEnum.CLR_MAP_SIZE_16:
					return 2;
					
				case TGATypeEnum.CLR_MAP_SIZE_24:
					return 3;
					
				case TGATypeEnum.CLR_MAP_SIZE_32:
					return 4;
			}
			return 0;
		}
		
		protected function decode16(bytes:ByteArray):Boolean {
			for(var i:int = hdr.clrMapOrgn; i<hdr.clrMapLen; i+=2) {
				var a:uint = (bytes[i]&0x80)?0xFF:0x0;		// alpha
				var r:uint = (bytes[i]&0x7C)>>2;			// red
				var g:uint = ((bytes[i]&0x03)<<3)
				            +((bytes[i+1]&0xE0)>>5);		// green
				var b:uint = (bytes[i+1]&0x1F);				// blue
				var clr:uint =  (a<<24) +
								(r<<19) +
								(g<<11) +
								(b<<3);
				palette.push(clr);
			}
			return true;
		}
		
		protected function decode24(bytes:ByteArray):Boolean {
			for(var i:int = hdr.clrMapOrgn; i<hdr.clrMapLen; i+=3) {
				var clr:uint = 	(bytes[i]<<16) +
								(bytes[i+1]<<8) +
								bytes[i+2];
				palette.push(clr);
			}
			return true;
		}
		
		protected function decode32(bytes:ByteArray):Boolean {
			for(var i:int = hdr.clrMapOrgn; i<hdr.clrMapLen; i+=4) {
				var clr:uint = 	(bytes[i]<<24) +
								(bytes[i+1]<<16) +
								(bytes[i+2]<<8) +
								bytes[i+3];
				palette.push(clr);
			}
			return true;
		}
	}
}