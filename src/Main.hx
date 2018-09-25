package;

import file.save.FileSave;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.Assets;

using StringTools;

#if sys
/**
	Convert .SWF to .SWFTY
	Draw all shapes and bitmaps into one Spritesheet and save all symbol's 
    definitions into an easy to read .JSON, the two files are then combined
    into a .ZIP file with the .SWFTY extension.
**/
class CLI extends mcli.CommandLine {

    /**
		Path of the SWFTY to save
        @alias o 
	**/
	public var output:String = null;

	/**
		Show this message.
	**/
	public function help() {
		trace(this.showUsage());
		Sys.exit(0);
	}

	public function runDefault(?path:String) {
		if(path == null) {
            trace('Please specify a .SWF to convert!');
            Sys.exit(0);
        } else {
            trace('Converting: $path...');
            Main.processSWF(path, exporter -> {
                var zip = exporter.getSwfty();
                var output = this.output == null ? path.replace('.swf', '.swfty') : this.output;
                trace('Saving: $output...');
                FileSave.writeBytes(zip, output);
                trace('Done!');
                Sys.exit(0);
            });
        }
	}
}
#end

class Main extends Sprite {

	public function new() {	
		super();

        #if sys
        new mcli.Dispatch(Sys.args()).dispatch(new CLI());
        #else
		// Process SWF
		processSWF('res/Test2.swf', exporter -> {
            var zip = exporter.getSwfty();

            // Showing Tilemap for fun
            var tilemap = exporter.getTilemap();
            var bmp = new Bitmap(tilemap.bitmapData);
            bmp.y = 0;
            addChild(bmp);

            // Save file for test
            FileSave.saveClickBytes(zip, 'Test2.swfty');
        });
        #end
	}

	public static function processSWF(path:String, onComplete:SWFTileExporter->Void) {
		Assets
		.loadBytes(path)
		.onError(function(error) {
			trace('Error!!!', error);
		})
		.onComplete(function(bytes) {
			trace('Loaded ${bytes.length}');

			var timer = haxe.Timer.stamp();
			SWFTileExporter.create(bytes, function(exporter) {
                trace('Parsed SWF: ${haxe.Timer.stamp() - timer}');
                onComplete(exporter);
            });
		});
	}
}