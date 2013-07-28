// ==================================================================
// Module:			TGADecoder
//
// Description:		Decoder for Targa file 
//
// Input/Output:	Bitmap data
//
// Author(s):		C.T. Yeung
//
// History:
// 27Apr10			start											cty
// 02May10			decodes 32 bpp no-compress, no interleave		cty
// 02May10			decodes 24 bpp no-compress, no interleave		cty
// 02May10			decodes 8 bpp no-compress, monochrome			cty
// 02May10			above tests performed on Adobe CS4 Photoshop and
//					GIMP 2.0										cty
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

	public class TGADecoder
	{
		public var hdr:TGAHeader;
		public var pal:TGAPalette;
		public var img:TGAImageData;
		
		public function TGADecoder()
		{
			hdr = new TGAHeader();
			pal = new TGAPalette(hdr);
			img = new TGAImageData(hdr, pal);
		}
		
/////////////////////////////////////////////////////////////////////
// Decode 
		public function decode(bytes:ByteArray):Boolean {
			if(hdr.decode(bytes))
				if(pal.decode(bytes))
					if(img.decode(bytes))
						return true;
			return false;
		}
		
		public function get bitDepth():int {
			if(!hdr) return -1;
			return hdr.bpp;
		}
		
		public function get bitmapData():BitmapData {
			if(!img) return null;
			return img.bitmapData;
		}
		
		
		
	}
}