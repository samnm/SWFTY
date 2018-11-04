package swfty.renderer;

// Currently no engine-specific implementation
// But this is because we're using Bitmap Fonts
// Eventually think about a solution to render text to reserved space in the texture

class FinalText extends BaseText {

    public static inline function create(layer:EngineLayer, ?definition:TextType):FinalText {
        return new FinalText(layer, definition);
    }

    public function new(layer:EngineLayer, ?definition:TextType) {
        super(layer, definition);
    }
}

@:forward(x, y, scaleX, scaleY, rotation, text)
abstract Text(FinalText) from FinalText to FinalText {
    
}