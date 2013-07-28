package  
{
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	/**
	 * ActionScript入門Wiki - 24bit BMPを自前で読み込んで表示する
	 * http://www40.atwiki.jp/spellbound/pages/1265.html
	 * ...
	 * @author umhr
	 */
	public class Kihon 
	{
		
		public function Kihon() 
		{
			
		}
		static public function Decode(byteArray:ByteArray):BitmapData {
			byteArray.endian = Endian.LITTLE_ENDIAN;
			if (byteArray.readUTFBytes(2) != "BM") return null;
			byteArray.position += 8;
			var offset:int = byteArray.readUnsignedInt();
		 
			const BITMAP_CORE_HEADER:int = 12;
			if (byteArray.readUnsignedInt() == BITMAP_CORE_HEADER) return null;
			var width:int = byteArray.readUnsignedInt();
			var height:int = byteArray.readUnsignedInt();
			byteArray.position += 2;
			if (byteArray.readUnsignedShort() != 24) return null;
			byteArray.position = offset;
		 
			var padding:int = width * 3 % 4;
			var bitmapData:BitmapData = new BitmapData(width, height, false);
			for (var y:int = height - 1; y >= 0; y--)
			{
				for (var x:int = 0; x < width; x++)
				{
					var pixel:int = byteArray.readUnsignedByte() | byteArray.readUnsignedByte() << 8 | byteArray.readUnsignedByte() << 16;
					bitmapData.setPixel(x, y, pixel);
				}
				byteArray.position += padding;
			}
		 
			return bitmapData;
		}
		
	}

}