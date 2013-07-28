package  
{
	
	import com.bit101.components.PushButton;
	import com.ctyeung.WindowsBitmap.WinBmpDecoder;
	import com.senocular.images.BMPEncoder;
	import com.terrynoya.image.BMP.BMPDecoder;
	import com.voidelement.images.BMPDecoder;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import jp.mztm.umhr.logging.Log;
	/**
	 * ...
	 * @author umhr
	 */
	public class Canvas extends Sprite 
	{
		[Embed(source="gomacha.bmp", mimeType="application/octet-stream")] 
		private var EmbedClass:Class;
		private var _fileReference:FileReference = new FileReference();
		private var _bitmapData:BitmapData;
		private var _imgStage:Sprite = new Sprite();
		public function Canvas() 
		{
			init();
		}
		private function init():void 
		{
			if (stage) onInit();
			else addEventListener(Event.ADDED_TO_STAGE, onInit);
		}

		private function onInit(event:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, onInit);
			// entry point
			
			var byteArray:ByteArray = new EmbedClass();
			
			addChild(_imgStage);
			addChild(new Log(8, 30, 465, 465, 0xFFFFFF));
			
			new PushButton(this, 8, 8, "Load", onLoad);
			
			new PushButton(this, 116, 8, "Save", onSave);
			
			Log.trace("Embedしてある 320 x 240 の BMP 画像のデコード時間を計測します（msec）");
			terrynoyaBMPDecoder(byteArray);
			voidelementBMPDecoder(byteArray);
			windowsBitmapDecoder(byteArray);
			kihonDecoder(byteArray);
		}
		
		private function onSave(event:Event):void 
		{
			var bitmapData:BitmapData = new BitmapData(stage.stageWidth, stage.stageHeight, true, 0x0);
			bitmapData.draw(stage);
			_fileReference.save(com.senocular.images.BMPEncoder.encode(bitmapData), "senocular.bmp");
		}
		
		
		private function onLoad(event:Event):void 
		{
			var imagesFilter:FileFilter = new FileFilter("Images", "*.bmp");
			_fileReference.addEventListener(Event.SELECT, fileReference_select);
			_fileReference.browse([imagesFilter]);
		}
		
		private function fileReference_select(event:Event):void 
		{
			_fileReference.removeEventListener(Event.SELECT, fileReference_select);
			_fileReference.addEventListener(Event.COMPLETE, fileReference_complete);
			_fileReference.load();
		}
		
		private function fileReference_complete(event:Event):void 
		{
			_fileReference.removeEventListener(Event.COMPLETE, fileReference_complete);
			
			var byteArray:ByteArray = _fileReference.data;
			
			// byteArrayの先頭の二文字がBMである場合、bmpとする。
			// http://ja.wikipedia.org/wiki/Windows_bitmap
			if (byteArray.toString().substr(0, 2) == "BM") {
				Log.clear();
				Log.trace("読み込んだ BMP 画像のデコード時間を計測します。（msec）");
				terrynoyaBMPDecoder(byteArray);
				voidelementBMPDecoder(byteArray);
				windowsBitmapDecoder(byteArray);
				kihonDecoder(byteArray);
			}else {
				Log.clear();
				Log.trace("BMP 画像と認識できませんでした。");
			}
		}
		
		/**
		 * terrynoya/ASImageLib · GitHub
		 * https://github.com/terrynoya/ASImageLib
		 * @param	byteArray
		 */
		private function terrynoyaBMPDecoder(byteArray:ByteArray):void 
		{
			byteArray.position = 0;
			Log.timeStart();
			
			// デコード処理
			_bitmapData = new com.terrynoya.image.BMP.BMPDecoder().decode(byteArray);
			
			Log.traceTime("com.terrynoya.image.BMP.BMPDecoder");
			
			if (_bitmapData == null) {
				Log.trace("デコードできませんでした。");
				return;
			};
			var bitmap:Bitmap = new Bitmap(_bitmapData);
			bitmap.x = bitmap.y = 30;
			_imgStage.addChild(bitmap);
		}
		
		/**
		 * munegon/BMPDecoder - Spark project
		 * http://www.libspark.org/wiki/munegon/BMPDecoder
		 * @param	byteArray
		 */
		private function voidelementBMPDecoder(byteArray:ByteArray):void 
		{
			byteArray.position = 0;
			Log.timeStart();
			
			// デコード処理
			_bitmapData = new com.voidelement.images.BMPDecoder().decode(byteArray);
			
			Log.traceTime("com.voidelement.images.BMPDecoder");
			
			if (_bitmapData == null) {
				Log.trace("デコードできませんでした。");
				return;
			};
			var bitmap:Bitmap = new Bitmap(_bitmapData);
			bitmap.x = bitmap.y = 60;
			_imgStage.addChild(bitmap);
		}
		
		/**
		 * windowsbitmapdencoder - Windows bmp Encoder/Decoder, Adobe TIFF 6 Baseline decoder, Truevision TARGA (.tga)encoder (decoder-work-in-progress) - Google Project Hosting
		 * https://code.google.com/p/windowsbitmapdencoder/
		 * @param	byteArray
		 */
		private function windowsBitmapDecoder(byteArray:ByteArray):void 
		{
			byteArray.position = 0;
			Log.timeStart();
			
			// デコード処理
			var winBmpDecoder:WinBmpDecoder = new com.ctyeung.WindowsBitmap.WinBmpDecoder();
			winBmpDecoder.decode(byteArray);
			_bitmapData = winBmpDecoder.bitmapData;
			
			Log.traceTime("com.ctyeung.WindowsBitmap.WinBmpDecoder");
			
			if (_bitmapData == null) {
				Log.trace("デコードできませんでした。");
				return;
			};
			var bitmap:Bitmap = new Bitmap(_bitmapData);
			bitmap.x = bitmap.y = 90;
			_imgStage.addChild(bitmap);
		}
		
		/**
		 * ActionScript入門Wiki - 24bit BMPを自前で読み込んで表示する
		 * http://www40.atwiki.jp/spellbound/pages/1265.html
		 * @param	byteArray
		 */
		private function kihonDecoder(byteArray:ByteArray):void 
		{
			byteArray.position = 0;
			Log.timeStart();
			
			// デコード処理
			_bitmapData = Kihon.Decode(byteArray);

			Log.traceTime("kihon (ActionScript入門Wiki)");
			
			if (_bitmapData == null) {
				Log.trace("デコードできませんでした。");
				return;
			};
			var bitmap:Bitmap = new Bitmap(_bitmapData);
			bitmap.x = bitmap.y = 120;
			_imgStage.addChild(bitmap);
		}
	}
	
}