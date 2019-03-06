package swfty.renderer;

import swfty.renderer.Sprite.FinalSprite;

// TODO: Switch to class instead of Typedef?
typedef Line = {
    textWidth: Float,
    tiles: Array<{
        code: Int,
        tile: DisplayBitmap
    }>
}

class BaseText extends FinalSprite {

    public static inline var SPACE    = 0x20;
    public static inline var DOT      = 0x2E;
    public static inline var NEW_LINE = 0x0A;
    public static inline var RETURN   = 0x0D;

    public var text(default, set):String = null;

    public var textWidth(default, null):Float = 0.0;
    public var textHeight(default, null):Float = 0.0;

    public var originalText:String = '';

    // Add "..." at the end of the text if cannot fit within the boundaries
    public var short = false;

    // Scale the text down until it fits withing the boundaries
    // TODO: Use an Enum instead of bools
    public var fit = false;
    public var fitVertically = true;
    public var singleLine = false;

    var textDefinition:Null<TextType>;

    public function new(layer:BaseLayer, ?definition:TextType) {
        super(layer);

        loadText(definition);
    }

    public function loadText(definition:TextType) {
        textDefinition = definition;
        if (text == null && definition != null) {
            text = definition.text;
            originalText = text;
        } else if (this.text != null) {
            // Force refresh
            var text = this.text == originalText ? originalText = definition.text : this.text;
            set_text('');
            set_text(text);
        }

        return this;
    }

    public override function reload() {
        super.reload();
        
        if (textDefinition != null && textDefinition.font != null && layer.hasFont(textDefinition.font.id)) {
            textDefinition.font = layer.getFont(textDefinition.font.id);
            loadText(textDefinition);
        }
    } 

    function set_text(text:String) {
        if (this.text == text) return text;

        this.text = text;

        // Clear tiles
        removeAll();

        if (text.empty()) {
            textWidth = 0;
            textHeight = 0;
            return text;
        }

        if (textDefinition == null || textDefinition.font == null) return text;

        // Show characters
        var x = textDefinition.x;
        var y = textDefinition.y;

        var c = textDefinition.color;
        var r = (c & 0xFF0000) >> 16;
        var g = (c & 0xFF00) >> 8;
        var b = c & 0xFF;

        var size = textDefinition.size;
        var scale = size / textDefinition.font.size;

        y += (1 - (textDefinition.font.ascent / (textDefinition.font.ascent + textDefinition.font.descent))) * size; 
        
        var lineHeight = (textDefinition.font.ascent + textDefinition.font.descent + textDefinition.font.leading) / 20 / 1024 * size;

        var hasSpace = false;
        var lastSpaceX = 0.0;
        var currentLine:Line = {
            textWidth: 0.0,
            tiles: []
        };
        var lines:Array<Line> = [currentLine];

        // Get the '.' char
        var dot = textDefinition.font.get(DOT);

        for (i in 0...text.length) {
            var code = text.charCodeAt(i);

            if (code == SPACE) {
                lastSpaceX = x;
                hasSpace = true;
            }

            if (textDefinition.font.has(code)) {
                var char = textDefinition.font.get(code);
                var w = char.advance * scale;

                var tile = layer.createBitmap(char.bitmap.id, true);
                tile.color(r, g, b);
                tile.x = x + char.tx * scale;
                tile.y = y + char.ty * scale;

                tile.scaleX = tile.scaleY = scale;

                addBitmap(tile);

                currentLine.tiles.push({
                    code: code,
                    tile: tile
                });

                if (fit) {
                    // TODO: For multiline check the "height" as well?
                    // TODO: Could probably be done simply at the end of each line?
                    if (code != SPACE && (x - textDefinition.x) + w > textDefinition.width) {
                        var scaleDown =  textDefinition.width / ((x - textDefinition.x) + w);

                        // Take all tiles and scale them down
                        for (line in lines) {
                            for (tile in line.tiles) {
                                tile.tile.scaleX *= scaleDown;
                                tile.tile.scaleY *= scaleDown;
                                tile.tile.x *= scaleDown;
                                tile.tile.y *= scaleDown;
                            }
                        }

                        x *= scaleDown;
                        y *= scaleDown;

                        size *= scaleDown;
                        scale = size / textDefinition.font.size;

                        if (!fitVertically) {
                            lineHeight = (textDefinition.font.ascent + textDefinition.font.descent + textDefinition.font.leading) / 20 / 1024 * size;
                        }
                        
                        w = char.advance * scale;
                    }

                } else if (short) {
                    // TODO: For multiline "short" text we should check the "height" and do it on the last line only!
                    if ((x - textDefinition.x) + w > (textDefinition.width - scale * dot.advance * 3) && (i <= text.length - 3)) {
                        // Set the remaining charaters as "..." and call it a day
                        for (j in 0...3) {
                            code = DOT;
                            char = textDefinition.font.get(code);
                            tile = layer.createBitmap(char.bitmap.id, true);
                            tile.color(r, g, b);
                            tile.x = x + char.tx;
                            tile.y = y + char.ty;

                            tile.scaleX = tile.scaleY = scale;

                            addBitmap(tile);

                            currentLine.tiles.push({
                                code: code,
                                tile: tile
                            });

                            w = char.advance * scale;
                            x += w;
                        }
                        break;
                    }
                } else if ((x - textDefinition.x) + w > textDefinition.width && hasSpace) {
                    y += lineHeight;
                    hasSpace = false;

                    // Take all characters until a space and move them to next line (ignoring the space)
                    var tiles = [];
                    var tile = currentLine.tiles.pop();
                    while(tile != null && tile.code == SPACE) {
                        tile = currentLine.tiles.pop();
                    }

                    var offsetX = 0.0;
                    var maxWidth = (tile != null && tile.tile != null) ? tile.tile.x : 0.0;
                    while(tile != null && tile.code != SPACE) {
                        if (tile.tile != null) {
                            tile.tile.y += lineHeight;
                            offsetX = tile.tile.x;
                        }
                        tiles.push(tile);

                        tile = currentLine.tiles.pop();
                        if (tile != null && tile.tile != null) maxWidth = tile.tile.x;
                    }

                    for (tile in tiles) tile.tile.x -= offsetX - textDefinition.x;

                    currentLine.textWidth = maxWidth - textDefinition.x;
                    if (currentLine.textWidth > textWidth) textWidth = currentLine.textWidth;

                    currentLine = {
                        textWidth: 0.0,
                        tiles: tiles
                    };
                    lines.push(currentLine);

                    x -= offsetX - textDefinition.x;

                    if (singleLine) break;
                }

                x += w;
            } else {
                // Special cases
                switch(code) {
                    case NEW_LINE | RETURN : 
                        y += lineHeight;
                        x = textDefinition.x;
                        if (singleLine) break;
                    case _ : 
                }
            }
        }

        currentLine.textWidth = x - textDefinition.x;

        // Center vertically
        if (fit && fitVertically) {
            for (line in lines)
                for (tile in line.tiles) 
                    tile.tile.y += (1 - size / textDefinition.size) * lineHeight / 2.0;
        }

        if (currentLine.textWidth > textWidth) textWidth = currentLine.textWidth;
        textHeight = y + lineHeight;

        switch(textDefinition.align) {
            case Left    : 
            case Right   : 
                for (line in lines)
                    for (tile in line.tiles) 
                        if (tile.tile != null) tile.tile.x += textDefinition.width - line.textWidth;
            case Center  : 
                for (line in lines)
                    for (tile in line.tiles) 
                        if (tile.tile != null) tile.tile.x += textDefinition.width / 2 - line.textWidth / 2;
            case Justify : trace('Justify not supported!!!');
        }

        return text;
    }
}