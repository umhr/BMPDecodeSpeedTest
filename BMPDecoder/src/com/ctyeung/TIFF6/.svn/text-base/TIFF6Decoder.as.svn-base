// ==================================================================
// Module:			TIFFDecoder.as
//
// Description:		Decoder for Adobe TIFF file v6.0
//
// Input:			TIFF file
// Output:			Bitmap data
//
// Author(s):		C.T. Yeung
//
// History:
// 23Feb09			start coding								cty
// 06Jul09			handle 1, 8, 24 bpp - basline
//					handle Big & Little endian
//					handle interlace and planar pixels			cty
// ==================================================================
package com.ctyeung.TIFF6
{
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	
	public class TIFF6Decoder
	{
		protected var hdr:Header;		// file header
		protected var info:ImageInfo;	// info, palette, etc
		protected var img:Image;		// image object
		
/////////////////////////////////////////////////////////////////////
// initialization

		public function TIFF6Decoder()
		{
			hdr  = new Header();
			info = new ImageInfo(hdr);
			img  = new Image(hdr, info);
		}
		
		public function dispose():void {
			hdr = null;
			if(info) {
				info.dispose();
				info = null;
			}
			if(img) {
				img.dispose();
				img = null;
			}
		}
		
		public function empty():void
		{
			hdr.empty();
			info.empty();
			img.empty();
		}
		
		public function isEmpty():Boolean
		{
			if(img)
				return img.isEmpty();
			return false;
		}
		
/////////////////////////////////////////////////////////////////////
// public

		public function get bitmapData():BitmapData
		{
			if(!img) return null;
			return img.bitmapData;
		}
		
		public function decode(bytes:ByteArray):Boolean
		{
			if(hdr.decode(bytes))
				if(info.decode(bytes))
					if(img.decode(bytes))
						return true; 
			return false;
		}
	}
}