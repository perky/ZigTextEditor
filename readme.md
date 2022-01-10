# Zig Text Editor
A multi-line text editor written in zig that is rendering/input agnostic.
Provides an example using raylib as the renderer.

## Usage
`const TextEditor = @import("text_editor.zig");`

or if you have a build.zig

```
# build.zig
exe.addPackagePath("text_editor", "../path/to/text_editor.zig");

# your_code.zig
const TextEditor = @import("text_editor");
```

then call the following functions

```
# inits an editor that can hold up to 1 million bytes.
var editor = try TextEditor.init(allocator, 1_000_000);
defer editor.deinit();

# in your input handler
editor.insertByte(next_char);
editor.deleteBackward();
editor.deleteForward();
editor.moveCursorLeft(&editor.cursor);
editor.moveCursorRight(&editor.cursor);
editor.moveCursorUp(&editor.cursor);
editor.moveCursorDown(&editor.cursor);
editor.moveCursorToLineStart(&editor.cursor);
editor.moveCursorToLineEnd(&editor.cursor);

# in your drawing handler
# note that you will need to implement your own
# renderer with three functions:
# drawGlyph, cursorRect, drawCursorRect
# see examples for a renderer that uses raylib.
const editor_renderer = YourRenderer.interface(
    &immutable_data, &mutable_state
);
editor.drawBuffer(editor_renderer);
editor.drawCursor(editor_renderer);

# The rendering functions will receive the immutable and mutable state
# as anyopaque pointers (void*)
# you can cast these back to your own types with
var data: *const T = TextEditor.castUserdata(T, immutable_data);
var state: *T = TextEditor.castMutableUserdata(T, mutable_state);

```