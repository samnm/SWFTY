package swfty;

import haxe.ds.IntMap;

// TODO: These should be absract over Int or simple Enum maybe? Using string seems like a waste

@:enum abstract BlendMode(String) from String to String {
    var Normal      = 'normal';
    var LayerBlend  = 'layer';
    var Multiply    = 'multiply';
    var Screen      = 'screen';
    var Lighten     = 'lighten';
    var Darken      = 'darken';
    var Difference  = 'difference';
    var Add         = 'add';
    var Subtract    = 'subtract';
    var Invert      = 'invert';
    var Alpha       = 'alpha';
    var Erase       = 'erase';
    var Overlay     = 'overlay';
    var Hardlight   = 'hardlight';
}

@:enum abstract Align(String) to String {
    var Left        = 'Left';
    var Right       = 'Right';
    var Center      = 'Center';
    var Justify     = 'Justify';
}

/* JSON Type */

typedef Transform = {
    a: Float,
	b: Float,
	c: Float,
	d: Float,
	tx: Float,
	ty: Float,
}

typedef Rect = {
    x: Int,
	y: Int,
	width: Int,
	height: Int
}

typedef BitmapDefinition = {
	> Rect,
    originalWidth: Float,
    originalHeight: Float,
    id: Int
}

typedef Character = {
    id: Int,
    bitmap: Int,
    tx: Float,
    ty: Float,
    advance: Float,
    height: Float
}

typedef FontDefinition = {
    id: Int,
    name: String,
    cleanName: String,
    color: Int,
    size: Float,
    bold: Bool,
    italic: Bool,
    bitmap: Int,
    ascent: Float,
    descent: Float,
    leading: Float,
    characters: Array<Character>
}

typedef ShapeDefinition = {
    > Transform,
    id: Int,
    bitmap: Int,
}

typedef TextDefinition = {
    font: Int,
    align: Align,
    size: Float,
    color: UInt,
    multiline: Bool,
    text: String,
    html: String,
    leftMargin: Float,
    rightMargin: Float,
    leading: Float,
    indent: Float,
    x: Float,
    y: Float,
    width: Float,
    height: Float
}

typedef ColorTransform = {
    r: Float,
    g: Float,
    b: Float,
    rAdd: Float,
    gAdd: Float,
    bAdd: Float
}

typedef SpriteDefinition = {
	> Transform,
    id: Int,
    shapes: Array<ShapeDefinition>,
    ?mask: Int,
    ?text: TextDefinition,
    ?blendMode: BlendMode,
    ?color: ColorTransform,
    alpha: Float,
	name: String,
    visible: Bool
}

typedef MovieClipDefinition = {
	id: Int,
    name: String,
	children: Array<SpriteDefinition>
}

typedef SWFTYJson = {
    tilemap: {
        width: Int,
        height: Int,
        scale: Float,
        reserved: Int
    },
    name: String,
	definitions: Array<MovieClipDefinition>,
    tiles: Array<BitmapDefinition>,
    fonts: Array<FontDefinition>
}

typedef Rectangle = {
    width: Int,
    height: Int
}

typedef InnerQuality = {
    name: String,
    ?appendName: Bool,
    ?scale: Float,
    ?maxDimension: Rectangle,
    ?outputFolder: String,
}

typedef CustomConfig = {
    name: String,
    ?pngquant: Bool,
    ?jpegtran: Bool,
    ?useJPEG: Bool,
    ?jpegQuality: Int,
    ?quality: Array<InnerQuality>,
    ?maxDimension: Rectangle,
    ?reservedSpace: Rectangle,
    ?fontEnabled: Bool,
    ?maxFontDimension: Rectangle
}

typedef Config = {
    ?watch: Bool,
    ?watchFolder: String,
    ?outputFolder: String,
    ?abstractFolder: String,
    ?templateFolder: String,
    ?tempFolder: String,
    ?fontFolder: String,
    ?quality: Array<InnerQuality>,
    ?pngquant: Bool,
    ?jpegtran: Bool,
    ?useJPEG: Bool,
    ?jpegQuality: Int,
    ?fontEnabled: Bool,
    ?bakeColor: Bool,
    ?sharedFonts:Bool,
    ?maxDimension: Rectangle,
    ?reservedSpace: Rectangle,
    ?files: Array<CustomConfig>,
}

/* Binary Type */

@:structInit
class MovieClipType #if !macro implements hxbit.Serializable #end {
    @:s public var id:Int;
    @:s public var name:String;
    @:s public var children:Array<SpriteType>;

    public static inline function fromJson(json:MovieClipDefinition, movieClips:IntMap<MovieClipType>, bitmaps:IntMap<BitmapType>, fonts:IntMap<FontType>):MovieClipType {
        return {
            id: json.id,
            name: json.name,
            children: [ for (child in json.children) SpriteType.fromJson(child, movieClips, bitmaps, fonts) ],
        };
    }

    public function new(?id:Int, ?name:String, ?children:Array<SpriteType>) {
        this.id = id;
        this.name = name;
        this.children = children;
    }
}

@:structInit
class SpriteType #if !macro implements hxbit.Serializable #end {
    @:s public var mc:Null<MovieClipType>;
    @:s public var id:Int;
    @:s public var a:Float;
	@:s public var b:Float;
	@:s public var c:Float;
	@:s public var d:Float;
	@:s public var tx:Float;
	@:s public var ty:Float;
    @:s public var shapes:Array<ShapeType>;
    @:s public var mask:Int;
    @:s public var text:Null<TextType>;
    @:s public var blendMode:BlendMode;
    @:s public var color:Null<ColorTransformType>;
    @:s public var alpha:Float;
	@:s public var name:String;
    @:s public var visible:Bool;

    public static inline function fromJson(json:SpriteDefinition, movieClips:IntMap<MovieClipType>, bitmaps:IntMap<BitmapType>, fonts:IntMap<FontType>):SpriteType {
        return {
            id: json.id,
            mc: movieClips.get(json.id),
            a: json.a,
            b: json.b,
            c: json.c,
            d: json.d,
            tx: json.tx,
            ty: json.ty,
            shapes: [ for (shape in json.shapes) ShapeType.fromJson(shape, bitmaps) ],
            mask: json.mask,
            text: json.text != null ? TextType.fromJson(json.text, fonts) : null,
            blendMode: json.blendMode,
            color: json.color != null ? ColorTransformType.fromJson(json.color) : null,
            alpha: json.alpha,
            name: json.name,
            visible: json.visible,
        };
    }

    public function new(?id:Int, ?mc:MovieClipType, ?a:Float, ?b:Float, ?c:Float, ?d:Float, ?tx:Float, ?ty:Float, ?shapes:Array<ShapeType>, ?mask:Int, ?text:TextType, ?blendMode:BlendMode, ?color:ColorTransformType, ?alpha:Float, ?name:String, ?visible:Bool) {
        this.id = id;
        this.mc = mc;
        this.a = a;
        this.b = b;
        this.c = c;
        this.d = d;
        this.tx = tx;
        this.ty = ty;
        this.shapes = shapes;
        this.mask = mask;
        this.text = text;
        this.blendMode = blendMode;
        this.color = color;
        this.alpha = alpha;
        this.name = name;
        this.visible = visible;
    }
}

@:structInit
class ShapeType #if !macro implements hxbit.Serializable #end {
    @:s public var id:Int;
    @:s public var a:Float;
	@:s public var b:Float;
	@:s public var c:Float;
	@:s public var d:Float;
	@:s public var tx:Float;
	@:s public var ty:Float;
    @:s public var bitmap:BitmapType;

    public static inline function fromJson(json:ShapeDefinition, bitmaps:IntMap<BitmapType>):ShapeType {
        return {
            id: json.id,
            a: json.a,
            b: json.b,
            c: json.c,
            d: json.d,
            tx: json.tx,
            ty: json.ty,
            bitmap: bitmaps.get(json.bitmap),
        };
    }

    public function new(?id:Int, ?a:Float, ?b:Float, ?c:Float, ?d:Float, ?tx:Float, ?ty:Float, ?bitmap:BitmapType) {
        this.id = id;
        this.a = a;
        this.b = b;
        this.c = c;
        this.d = d;
        this.tx = tx;
        this.ty = ty;
        this.bitmap = bitmap;
    }
}

@:structInit
class ColorTransformType #if !macro implements hxbit.Serializable #end {
    @:s public var r:Float;
    @:s public var g:Float;
    @:s public var b:Float;
    @:s public var rAdd:Float;
    @:s public var gAdd:Float;
    @:s public var bAdd:Float;

    public static inline function fromJson(json:ColorTransform):ColorTransformType {
        return {
            r: json.r,
            g: json.g,
            b: json.b,
            rAdd: json.rAdd,
            gAdd: json.gAdd,
            bAdd: json.bAdd,
        };
    }

    public function new(?r:Float, ?g:Float, ?b:Float, ?rAdd:Float, ?gAdd:Float, ?bAdd:Float) {
        this.r = r;
        this.g = g;
        this.b = b;
        this.rAdd = rAdd;
        this.gAdd = gAdd;
        this.bAdd = bAdd;
    }
}

@:structInit
class TextType #if !macro implements hxbit.Serializable #end {
    @:s public var font:FontType;
    @:s public var align:Align;
    @:s public var size:Float;
    @:s public var color:UInt;
    @:s public var text:String;
    @:s public var html:String;
    @:s public var leftMargin:Float;
    @:s public var rightMargin:Float;
    @:s public var leading:Float;
    @:s public var indent:Float;
    @:s public var multiline:Bool;
    @:s public var x:Float;
    @:s public var y:Float;
    @:s public var width:Float;
    @:s public var height:Float;

    public static inline function fromJson(json:TextDefinition, fonts:IntMap<FontType>):TextType {
        return {
            font: fonts.get(json.font),
            align: json.align,
            size: json.size,
            color: json.color,
            text: json.text,
            multiline: json.multiline,
            html: json.html,
            leftMargin: json.leftMargin,
            rightMargin: json.rightMargin,
            leading: json.leading,
            indent: json.indent,
            x: json.x,
            y: json.y,
            width: json.width,
            height: json.height,
        };
    }

    public function new(?font:FontType, ?align:Align, ?size:Float, ?color:UInt, ?text:String, ?html:String, ?leftMargin:Float, ?rightMargin:Float, ?leading:Float, ?indent:Float, ?x:Float, ?y:Float, ?multiline:Bool, ?width:Float, ?height:Float) {
        this.font = font;
        this.align = align;
        this.size = size;
        this.color = color;
        this.text = text;
        this.html = html;
        this.multiline = multiline;
        this.leftMargin = leftMargin;
        this.rightMargin = rightMargin;
        this.leading = leading;
        this.indent = indent;
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
    }
}

@:structInit
class FontType #if !macro implements hxbit.Serializable #end {
    @:s public var id:Int;
    @:s public var name:String;
    @:s public var cleanName:String;
    @:s public var color:Int;
    @:s public var size:Float;
    @:s public var bold:Bool;
    @:s public var italic:Bool;
    @:s public var bitmap:Int;
    @:s public var ascent:Float;
    @:s public var descent:Float;
    @:s public var leading:Float;
    @:s public var characters:IntMap<CharacterType>;

    public static inline function fromJson(json:FontDefinition, bitmaps:IntMap<BitmapType>):FontType {
        return {
            id: json.id,
            name: json.name,
            cleanName: json.cleanName,
            color: json.color,
            size: json.size,
            bold: json.bold,
            italic: json.italic,
            bitmap: json.bitmap,
            ascent: json.ascent,
            descent: json.descent,
            leading: json.leading,
            characters: [ for (char in json.characters) char.id => CharacterType.fromJson(char, bitmaps) ],
        };
    }

    public function new(?id:Int, ?name:String, ?cleanName:String, ?color:Int, ?size:Float, ?bold:Bool, ?italic:Bool, ?bitmap:Int, ?ascent:Float, ?descent:Float, ?leading:Float, ?characters:IntMap<CharacterType>) {
        this.id = id;
        this.name = name;
        this.cleanName = cleanName;
        this.color = color;
        this.size = size;
        this.bold = bold;
        this.italic = italic;
        this.bitmap = bitmap;
        this.ascent = ascent;
        this.descent = descent;
        this.leading = leading;
        this.characters = characters;
    }

    public inline function get(code:Int) {
        return characters.get(code);
    }

    public inline function has(code:Int) {
        return characters.exists(code);
    }
}

@:structInit
class CharacterType #if !macro implements hxbit.Serializable #end {
    @:s public var id:Int;
    @:s public var bitmap:BitmapType;
    @:s public var tx:Float;
    @:s public var ty:Float;
    @:s public var advance:Float;
    @:s public var height:Float;

    public static inline function fromJson(json:Character, bitmaps:IntMap<BitmapType>):CharacterType {
        return {
            id: json.id,
            bitmap: bitmaps.get(json.bitmap),
            tx: json.tx,
            ty: json.ty,
            advance: json.advance,
            height: json.height
        };
    }

    public function new(?id:Int, ?bitmap:BitmapType, ?tx:Float, ?ty:Float, ?advance:Float, ?height:Float) {
        this.id = id;
        this.bitmap = bitmap;
        this.tx = tx;
        this.ty = ty;
        this.advance = advance;
        this.height = height;
    }
}

@:structInit
class BitmapType #if !macro implements hxbit.Serializable #end {
    @:s public var id:Int;
    @:s public var x:Int;
	@:s public var y:Int;
	@:s public var width:Int;
	@:s public var height:Int;
	@:s public var originalWidth:Float;
	@:s public var originalHeight:Float;
    
    public static inline function fromJson(json:BitmapDefinition):BitmapType {
        return {
            id: json.id,
            x: json.x,
            y: json.y,
            width: json.width,
            height: json.height,
            originalWidth: json.originalWidth,
            originalHeight: json.originalHeight
        };
    }

    public function new(?id:Int, ?x:Int, ?y:Int, ?width:Int, ?height:Int, ?originalWidth:Float, ?originalHeight:Float) {
        this.id = id;
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
        this.originalWidth = originalWidth;
        this.originalHeight = originalHeight;
    }
}

@:structInit
class SWFTYType #if !macro implements hxbit.Serializable #end {
    @:s public var name:String;
    @:s public var reserved_space:Int;
    @:s public var tilemap_width:Int;
    @:s public var tilemap_height:Int;
    @:s public var tilemap_scale:Float;
	@:s public var definitions:IntMap<MovieClipType>;
    @:s public var tiles:IntMap<BitmapType>;
    @:s public var fonts:IntMap<FontType>;
    
    public static inline function fromJson(json:SWFTYJson):SWFTYType {
        var bitmaps = [ for (def in json.tiles) def.id => BitmapType.fromJson(def) ];
        var fonts = [ for (def in json.fonts) def.id => FontType.fromJson(def, bitmaps) ];
        var movieClips = new IntMap();

        for (def in json.definitions) movieClips.set(def.id, MovieClipType.fromJson(def, movieClips, bitmaps, fonts));

        return {
            tilemap_width: json.tilemap.width,
            tilemap_height: json.tilemap.height,
            tilemap_scale: json.tilemap.scale,
            reserved_space: json.tilemap.reserved,
            name: json.name,
            definitions: movieClips,
            tiles: bitmaps,
            fonts: fonts,
        };
    }

    public function new(?tilemap_width:Int, ?tilemap_height:Int, ?tilemap_scale:Float, ?reserved_space:Int, ?name:String, ?definitions:IntMap<MovieClipType>, ?tiles:IntMap<BitmapType>, ?fonts:IntMap<FontType>) {
        this.tilemap_width = tilemap_width;
        this.tilemap_height = tilemap_height;
        this.tilemap_scale = tilemap_scale;
        this.reserved_space = reserved_space;
        this.name = name;
        this.definitions = definitions;
        this.tiles = tiles;
        this.fonts = fonts;
    }

    inline function getRandomId<T>(map:IntMap<T>) {
        var r = 481516234;//2
        var n = 1000;
        while (map.exists(r) && (--n > 0)) r = Std.int(Math.random() * 0xFFFFFFFF);
        return r;
    }

    // Add a special "All" Sprite that is the whole Tilemap
    public function addAll(width:Int, height:Int) {
        var bmp:BitmapType = {
            id: getRandomId(tiles),
            x: 0,
            y: 0,
            width: width,
            height: height,
            originalWidth: width,
            originalHeight: height
        };

        tilemap_width = width;
        tilemap_height = height;
        
        var id = getRandomId(definitions);
        definitions.set(id, { 
            id: id,
            name: 'All',
            children: [{
                mc: null,
                id: 0,
                a: 1,
                b: 0,
                c: 0,
                d: 1,
                tx: 0,
                ty: 0,
                shapes: [ {
                    id: bmp.id,
                    a: 1,
                    b: 0,
                    c: 0,
                    d: 1,
                    tx: 0,
                    ty: 0,
                    bitmap: bmp
                } ],
                mask: 0,
                text: null,
                blendMode: null,
                color: null,
                alpha: 1.0,
                name: null,
                visible: true
            }]
        });

        tiles.set(bmp.id, bmp);

        addEmpty();
    }

    // Add a special "Empty" Sprite that is the whole Tilemap
    public function addEmpty() {
        var bmp:BitmapType = {
            id: getRandomId(tiles),
            x: 0,
            y: 0,
            width: 1,
            height: 1  
        };

        var id = getRandomId(definitions);
        definitions.set(id, { 
            id: id,
            name: 'Empty',
            children: [{
                mc: null,
                id: 0,
                a: 1,
                b: 0,
                c: 0,
                d: 1,
                tx: 0,
                ty: 0,
                shapes: [ {
                    id: bmp.id,
                    a: 1,
                    b: 0,
                    c: 0,
                    d: 1,
                    tx: 0,
                    ty: 0,
                    bitmap: bmp
                } ],
                mask: 0,
                text: null,
                blendMode: null,
                color: null,
                alpha: 0.0,
                name: null,
                visible: true
            }]
        });

        tiles.set(bmp.id, bmp);
    }
}