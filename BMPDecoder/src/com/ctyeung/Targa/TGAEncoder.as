// ==================================================================
// Module:			TGAEncoder.as
//
// Description:		Encoder for Truevision TARGA
//
// Input/Output:	Bitmap data
//
// Author(s):		C.T. Yeung
//
// History:
// 02May10			default RGB 24, 32 bpp no-compress encoding passed testing
//					on Adobe CS4 Photoshop 							cty
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

	public class TGAEncoder
	{
		public var bytes:ByteArray;
		protected var hdr:TGAHeader;
		protected var pal:TGAPalette;
		protected var img:TGAImageData;
		protected var bmd:BitmapData;
		
		public function TGAEncoder()
		{
			hdr = new TGAHeader();
			//pal = new TGAPalette(hdr);
			img = new TGAImageData(hdr, pal);
		}
		
		public function encode( bmd:BitmapData, 		// [in] image
							    hasAlpha:Boolean=false)	// [in] 24, or 32 bpp
								:Boolean {				// [out] success or not
			hdr.bpp = (hasAlpha)?
						TGATypeEnum.BPP_32:
						TGATypeEnum.BPP_24;
			
			if(hdr.encode(bmd))
				//if(pal.encode(bmd))
				if(img.encode(bmd, hasAlpha)){
					bytes = new ByteArray();
					bytes.writeBytes(hdr.bytes, 0, hdr.bytes.length);
					bytes.writeBytes(img.bytes, 0, img.bytes.length);
					bytes.writeUnsignedInt(0);
					bytes.writeUnsignedInt(0);
					bytes.writeMultiByte("TRUEVISION-XFILE.", "us-ascii");
					return true;
				}
		
			return false;
		}
	}
}