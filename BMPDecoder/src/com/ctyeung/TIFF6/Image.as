// ==================================================================
// Module:			Image.as
//
// Description:		Image content for Adobe TIFF file v6.0
//
// Reference:		http://www.fileformat.info/format/tiff/corion-lzw.htm
//
// Author(s):		C.T. Yeung
//
// History:
// 06Jul09			functional 1, 8, 24 bpp RGB and grayscale		cty

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
package com.ctyeung.TIFF6
{
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	
	public class Image
	{
		public var bitmapData:BitmapData;
		protected var hdr:Header;
		protected var info:ImageInfo;
		protected var bytes:ByteArray;
		protected var cmp:Compression;
		
/////////////////////////////////////////////////////////////////////
// initialization

		public function Image(hdr:Header=null,
							  info:ImageInfo=null) {
			this.hdr  = hdr;
			this.info = info;
		}
		
		public function dispose():void {
			hdr = null;
			info = null;
			bytes = null;
			if (cmp) {
				cmp.dispose();
				cmp = null;
			}
			if(bitmapData) {
				bitmapData.dispose();
				bitmapData = null;
			}
		}

		public function empty():void {
			if(bitmapData)
				bitmapData.dispose();
			bitmapData = null;
		}
		
		public function isEmpty():Boolean {
			if(bitmapData)
				return false;
			return true;
		}
		
		public function setRef(hdr:Header=null,
							  info:ImageInfo=null)
							  :void {
			this.hdr = hdr;
			this.info = info;
		}

/////////////////////////////////////////////////////////////////////
// public

		public function decode(bytes:ByteArray):Boolean {
			empty();
			
			this.bytes = bytes;
			bitmapData = new BitmapData(info.imageWidth, info.imageLength, false, 0x00);
			
			cmp = new Compression(hdr, info);
			if(!cmp.decode(bytes)) return false;
			
			switch(info.bitsPerPixel)
			{
				case Fields.BPP_1:
				return decode1bpp();
				
				case Fields.BPP_8:
				return decode8bpp();
				
				case Fields.BPP_24:
				if(info.planarConfiguration == Fields.CHUNCKY)	return decode24bpp();
				else return decode24bppPlanes();
				
				case Fields.BPP_32:
				return decode32bpp();
			}
			cmp.dispose();
			cmp = null;
			return false;
		}

/////////////////////////////////////////////////////////////////////
// protected decoding
				
		protected function defaultGrayMap(bitDepth:int):Array {
			var palette:Array = new Array();
			var nofc:int = Math.pow(2, bitDepth);
			var clr:uint;
			
			for(var c:int=0; c<3; c++) {				// cycle through channels, R, G, B
				for(var i:int=0; i<nofc; i++)
				{
					switch(bitDepth) {
						case Fields.BPP_1:
						if(info.photometricInterpretation == Fields.BLACK_ZERO) clr = (i*255);
						if(info.photometricInterpretation == Fields.WHITE_ZERO) clr = 255-(i*255);
						clr += clr << 8;
						break;
						
						case Fields.BPP_8:
						clr = i;
						clr += clr << 8;
						break;
					}
					palette.push(clr);
				}
			}
			return palette;
		}
		
		protected function decode1bpp():Boolean {
			var so:Array = info.stripOffset;		// strip offset
			var rps:Array = info.rowsPerStrip;		// row per strip
			var pal:Array = (info.colorMap)?info.colorMap:defaultGrayMap(1);
			var mask:uint;
			var clr:uint;
			
			var len:int = info.imageLength;
			var wid:int = info.imageWidth;
			var stripIndex:int = 0;
			var i:uint = 0;
			var stripOfPixels:ByteArray = cmp.getStrip(stripIndex);
			if(!stripOfPixels)
				return false;
			
			for( var y:int = 0; y<len; y++) {  
				mask = 0x80;
				for( var x:int = 0; x<wid; x++) {
					var pixel:uint = stripOfPixels[i];
					var palIndex:int = (pixel&mask)?1:0;
					clr  = pal[palIndex+4]&0xFF;
					clr += pal[palIndex+2]&0xFF00;
					clr += (pal[palIndex]&0xFF00)<<8;
					bitmapData.setPixel(x,y, clr);
					
					i += (mask>1)?0:1;						// shift to next byte
					mask = (mask>1)? mask>>1:0x80;			// shift mask for next pixel
				}
				if((i>=stripOfPixels.length)&&(y<(len-1))) {
					stripOfPixels = cmp.getStrip(stripIndex++);
					i = 0;
					if(!stripOfPixels)
						return false;
				}
			}
			return true;
		}

		protected function decode8bpp():Boolean
		{
			// works only for 8bpp grayscale
			var pal:Array = (info.colorMap)?info.colorMap:defaultGrayMap(8);
			var clr:uint;
			var len:int = info.imageLength;
			var wid:int = info.imageWidth;
			var i:uint = 0;
			var stripIndex:uint = 0;
			var stripOfPixels:ByteArray = cmp.getStrip(stripIndex);
			if(!stripOfPixels)
				return false;
			
			for( var y:int = 0; y<len; y++) { 
				for( var x:int = 0; x<wid; x++) { 
					var index:uint = uint(stripOfPixels[i++]);
					// palette entries order in R 0-255, G 0-255, B 0-255
					clr  = pal[index+512]&0xFF;
					clr += pal[index+256]&0xFF00;
					clr += (pal[index]&0xFF00)<<8;
					bitmapData.setPixel(x,y, clr);
				}
				if((i>=stripOfPixels.length)&&(y<(len-1))) {
					stripOfPixels = cmp.getStrip(stripIndex++);
					i = 0;
					if(!stripOfPixels)
						return false;
				}
			}
			return true;
		}
		
		protected function decode24bpp():Boolean {
			var clr:uint;
			var len:int = info.imageLength;
			var wid:int = info.imageWidth*3;
			var stripIndex:int = 0;
			var i:int = 0;
			var stripOfPixels:ByteArray = cmp.getStrip(stripIndex);
			if(!stripOfPixels)
				return false;
			
			for( var y:int = 0; y<len; y++) { 
				for( var x:int = 0; x<wid; x+=3) {
					clr  = uint(stripOfPixels[i++])<<(8*2);
					clr += uint(stripOfPixels[i++])<<8;
					clr += uint(stripOfPixels[i++]);
					bitmapData.setPixel(x/3,y, clr);
				}
				if((i>=stripOfPixels.length)&&(y<(len-1))) {
					stripOfPixels = cmp.getStrip(stripIndex++);
					i = 0;
					if(!stripOfPixels)
						return false;
				}
			}
			return true;
		}
		
		protected function decode24bppPlanes():Boolean
		{
			var Y:int=0;
			var shift:uint=8*2;
			var clr:uint;
			var len:int = info.imageLength;
			var wid:int = info.imageWidth;
			var stripIndex:int = 0;
			var i:int = 0;
			var stripOfPixels:ByteArray = cmp.getStrip(stripIndex);
			if(!stripOfPixels)
				return false;
			
			for( var y:int = 0; y<len*3; y++) {  
				for( var x:int = 0; x<wid; x++) {
					clr = bitmapData.getPixel(x,Y);
					clr  += uint(stripOfPixels[i++])<<shift;
					bitmapData.setPixel(x,Y, clr);
				}
				if(Y >= len) {
					Y = 0;
					shift -= 8;
					//if(shift<0) return true;
				}
				Y++;
				if((i>=stripOfPixels.length)&&(y<(len-1))) {
					stripOfPixels = cmp.getStrip(stripIndex++);
					i = 0;
					if(!stripOfPixels)
						return false;
				}
			}
			return true;
		}
		
		//***Need to perform CMYK to RGB conversion
		protected function decode32bpp():Boolean
		{
			// non - functional
			var so:Array = info.stripOffset;
			var rps:Array = info.rowsPerStrip;
			var offsetList:Array = new Array();
			var lineWidth:int = info.imageWidth * 4;
			var y:int=0;
			for( var i:int = 0; i<so.length; i++) {
				for(var j:int = 0; j<rps[i]; j++) {
					var pos:int = so[i] + lineWidth * j; 
					y ++;
					for( var x:int = 0; x<lineWidth; x+=4) {
						var clr:uint = uint(bytes[pos+x]);
						clr += uint(bytes[pos+x+1])<<8;
						clr += uint(bytes[pos+x+2])<<(8*2);
					//	clr += uint(bytes[pos+x+3])<<(8*3);
						bitmapData.setPixel(x,y, clr);
					}
				}
			}
			return true;
		}
	}
}