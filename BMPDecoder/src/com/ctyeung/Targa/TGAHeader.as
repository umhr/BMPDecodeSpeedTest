// ==================================================================
// Module:		TGAHeader.as
//
// Description:	Targa Header class
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
	import flash.display.BitmapData;
	import flash.utils.ByteArray;

	public class TGAHeader
	{
		public var bytes:ByteArray;
		public var length:int = TGATypeEnum.HEADER_LEN;
		public var lenID:int;			// length of image ID, 1 byte: 0 - 255 bytes (0=no id)
		public var clrMapType:Boolean;	// Color map type, 1 byte: 	0 (no color map) 
										//							1 (color map included)
		public var imgType:int;			// Image type, 1 byte:		0 no image data in file
										//							1 color map image, uncompressed
										//							2 RGB image (24bpp) uncompressed
										//							3 Monochrome image uncompressed
										//							9 Color map image, RLE-encoding
										// 						   10 RGB image (24bpp) RLE-encoding
										//						   11 Monochrome image, RLE-encoding
										// 						   32 Color map image, Huffman, delta and RLE-encoding
										//						   33 Color map image, Huffman, delta, RLE, 4 pass quad tree
		public var clrMapOrgn:int;		// Color map origin, 2 bytes
		public var clrMapLen:int;		// Color map length, 2 bytes
		public var clrMapEntrySze:int;	// Color map entry size (16, 24, 32), 1 byte
		public var xOrgn:int;			// X-coordinate origin, 2 bytes
		public var yOrgn:int;			// Y-coordinate origin, 2 bytes
		public var imgWid:int;			// image width in pixels, 2 bytes
		public var imgLen:int;			// image height in pixels, 2 bytes
		public var bpp:int;				// bits per pixel, 1 byte
		public var imgIDField:Array;	// image identification field
		public var scrnOrgn:int;		// screen origin
		public var dataInterleave:int	// data storage interleave
		public var attrBpp:int;			// Attribute bits per pixel (alpha)
										// Targa 16: 0 or 1
										// Targa 24: 0
										// Targa 32: 8
		
		public function TGAHeader()
		{
		}
		
		public function isEmpty():Boolean {
			if(imgWid&&imgLen)
				return true;
			return false;
		}
		
		public function dispose():void {
			
		}

/////////////////////////////////////////////////////////////////////
// decoding
		
		public function decode(bytes:ByteArray):Boolean {
			lenID	  		=  bytes[0];
			clrMapType 		= (bytes[1])?true:false;
			imgType			=  bytes[2];
			clrMapOrgn		=  uint(bytes[3]) +
							   (uint(bytes[4])<<8);
			clrMapLen		=  uint(bytes[5]) +
							   (uint(bytes[6])<<8);
			clrMapEntrySze	= bytes[7];
			xOrgn			= uint(bytes[8]) +
							  (uint(bytes[9])<<8);
			yOrgn			= uint(bytes[10]) +
							  (uint(bytes[11])<<8);
			imgWid			= uint(bytes[12]) +
							  (uint(bytes[13])<<8);
			imgLen			= uint(bytes[14]) +
							  (uint(bytes[15])<<8);
			bpp				= bytes[16];
			imageDescriptor	= bytes[17];
			
			if(lenID) 
				this.length + lenID;
			return true;
		}
		
		// image descriptor byte, 1 byte
		protected function set imageDescriptor(value:int):void {
			dataInterleave 	= (value&0xC0)>>6;
			scrnOrgn		= (value&0x30)>>3;
			attrBpp			= value&0x0F;
		}
		
/////////////////////////////////////////////////////////////////////
// Encoding
		
		// default 32 bpp encoding, no compression
		public function encode(bmd:BitmapData):Boolean {
			bytes = new ByteArray();
			bytes.writeByte(0);									// lenID = 0
			bytes.writeByte(0);									// clrMapType = false
			bytes.writeByte(TGATypeEnum.IMG_TYPE_RGB_NO_CMP);	// type 2
			bytes.writeByte(0);									// no map origin
			bytes.writeByte(0);									
			bytes.writeByte(0);									// no map length
			bytes.writeByte(0);
			bytes.writeByte(0);									// no color map entries
			bytes.writeByte(0);									// x coor origin
			bytes.writeByte(0);
			bytes.writeByte(0);									// y coor origin
			bytes.writeByte(0);
			bytes.writeByte((bmd.width & 0xFF));				// image width
			bytes.writeByte((bmd.width & 0xFF00)>>(8));
			bytes.writeByte((bmd.height & 0xFF));				// image height
			bytes.writeByte((bmd.height & 0xFF00)>>(8));
			bytes.writeByte(bpp);								// 24 or 32 bpp
			bytes.writeByte(imageDescriptor);					// 0 if BGR or 8 if BGRA
			return true;
		}
		
		protected function get imageDescriptor():int {
			// not including Screen origin for default
			// not including data storage interleave for default
			
			// include only 24, 32 bits
			switch(bpp) {
				case TGATypeEnum.BPP_24:
					return TGATypeEnum.ATTR_NONE_24bpp;
					
				case TGATypeEnum.BPP_32:
					return TGATypeEnum.ATTR_DEPTH_32bpp;
			}
			return 0;
		}
	}
}