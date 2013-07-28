package com.ctyeung.TIFF6
{
	import flash.utils.ByteArray;
	
	public class CmpBase
	{
		protected var info:ImageInfo;
		protected var bytes:ByteArray;
		protected var lineByteWid:int;
		
		protected var blockIndex:int;	// index within a decompressed strip
		public var numChannels:int = 1;
		
		public function CmpBase(info:ImageInfo,
								bytes:ByteArray,
							    lineByteWid:int,
								numChannels:int) {
			this.info 		 = info;
			this.bytes 	 	 = bytes;
			this.lineByteWid = lineByteWid;
			this.numChannels = numChannels;
			bytes = new ByteArray();
		}
		
		public function dispose():void {
			info 	 = null;
			bytes 	 = null;
		}
		
		public function empty():void {
			if(bytes.length) 	
				bytes.clear();
		}
		
		public function isEmpty():Boolean {
			if(!bytes)			return true;
			if(!bytes.length)	return true;
			return false;
		}
		
		protected function decode(	offset:uint,			// [in] start position
									length:uint)			// [in] length of block
									:ByteArray {		// [out] uncompressed data
			return null;
		}
		
		// get a row of pixels
		public function getStrip(index:int)				// [in] row index
								:ByteArray {			// [out] 1 row decompressed pixels
			var pxls:ByteArray;

			if(index < (info.stripOffset.length)) {
				
				pxls = decode(	info.stripOffset[index] as uint, 
								info.stripByteCount[index] as uint);
				return pxls;
			}
			return null;
		}

	}
}