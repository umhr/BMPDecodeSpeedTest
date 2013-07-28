// ==================================================================
// Module:			Compression.as
//
// Description:		Handle decompression
//
// Author(s):		C.T. Yeung
//
// History:
// 27Jul09			work in progress - no compression works		cty
//					working on LZW								cty

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
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;
	
	public class Compression
	{
		protected var hdr:Header;
		protected var info:ImageInfo;
		protected var bytes:ByteArray;
		protected var rowPos:Array;
		protected var _lineByteWid:int;
		protected var stripOfPixels:ByteArray;
		protected var decoder:CmpBase;
		protected var numOfChannels:int;
		
		public function Compression(hdr:Header=null,
							        info:ImageInfo=null) {
			this.hdr  = hdr;
			this.info = info;
			setLineByteWid();
		}
		public function dispose():void {
			hdr 		  = null;
			info 		  = null;
			bytes 		  = null;
			rowPos 		  = null;
			stripOfPixels = null;
			if(decoder) {
				decoder.dispose();
				decoder = null;
			}
		}
		
		public function empty():void {
			bytes = null;
		}
		
		public function isEmpty():Boolean {
			if(!bytes) return true;
			return false;
		}
		
		public function setRef(hdr:Header=null,
							  info:ImageInfo=null)
							  :void {
			this.hdr = hdr;
			this.info = info;
		}
		
		public function setLineByteWid():void {
			var lineWidth:int = info.imageWidth;
			
			switch(info.bitsPerPixel)
			{
				case Fields.BPP_1:
				numOfChannels = 1;
				_lineByteWid = (lineWidth%8)?lineWidth/8+1:lineWidth/8;
				break;
				
				case Fields.BPP_8:
				numOfChannels = 1;
				_lineByteWid = lineWidth;
				break;
				
				case Fields.BPP_24:
				numOfChannels = 3;
				_lineByteWid = (info.planarConfiguration == Fields.CHUNCKY)?lineWidth * 3:lineWidth;
				break;
				
				case Fields.BPP_32:
				numOfChannels = 4;
				_lineByteWid = lineWidth * 4;
				break;
			}
		}
		
		public function decode(bytes:ByteArray):Boolean {
			this.bytes = bytes;
			
			switch(info.compression) {
				case Fields.NO_COMPRESSION:
				decoder = null;
				stripOfPixels = new ByteArray();
				return buildRowIndex();				
				
				case Fields.LZW_CMPRSSN:
				decoder = new CmpLZW(info, bytes, _lineByteWid, numOfChannels);
				break;
								
				//case Fields.ZIP_CMPRSSN:
				//decoder = new CmpZIP(info, bytes, _lineByteWid);
				//break;
					
				default:
				Alert.show("Compression not supported");
				return false;
			}
			return true;
		}
		
		protected function buildRowIndex():Boolean {
			var so:Array 	  = info.stripOffset;
			var rps:Array 	  = info.rowsPerStrip;
			
			rowPos = new Array();
			for( var i:int = 0; i<so.length; i++) {
				var index:uint = (i>rps.length-1)?rps.length-1:i; 
				for(var j:int = 0; j<rps[index]; j++) {
					var pos:int = so[i] + _lineByteWid * j; 
					rowPos.push(pos);
				}
			}
			return true;
		}
		
		public function getStrip(index:int):ByteArray {
			if(decoder)
				return decoder.getStrip(index);
			else {
				stripOfPixels.position = 0;
				stripOfPixels.writeBytes(bytes, rowPos[index], _lineByteWid);
				return stripOfPixels;
			}
		}

	}
}