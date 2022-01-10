///! This handles all the logic for rendering the glyphs and cursor
///! for the text editor. That way TextEditor is not coupled to raylib.
const ray = @import("raylib");
const TextEditor = @import("text_editor");

pub const DrawParams = struct {
    x: i32,
    y: i32,
    horizontal_spacing: i32,
    vertical_spacing: i32,
    font_size: i32,
    font: ray.Font,
    color: ray.Color
};

pub const CursorState = struct {
    blink_counter: f64 = 0,
    blink_duration: f64 = 0.5
};

/// Returns the rendering interface to pass to TextEditor draw functions.
pub fn interface(draw_params: *const DrawParams, cursor_state: *CursorState) TextEditor.RendererInterface
{
    return .{
        .draw_glyph_fn = drawGlyph,
        .cursor_rect_fn = cursorRect,
        .draw_cursor_rect_fn = drawCursorRect,
        .mutable_userdata =cursor_state,
        .userdata = draw_params
    };
}

fn cursorRect(cursor: TextEditor.Cursor, userdata: *const anyopaque) TextEditor.RectangleInt
{
    const params = TextEditor.castUserdata(DrawParams, userdata);
    const size = ray.MeasureTextEx(
        params.font, 
        "A", 
        @intToFloat(f32, params.font_size), 
        @intToFloat(f32, params.horizontal_spacing)
    );
    const width = @floatToInt(i32, size.x); 
    const height = params.font_size;
    return TextEditor.RectangleInt{
        .x = params.x + (@intCast(i32, cursor.col) * (width + params.horizontal_spacing)),
        .y = params.y + (@intCast(i32, cursor.row) * (height + params.vertical_spacing)),
        .width = width,
        .height = height
    };
}

fn drawCursorRect(
    rect: TextEditor.RectangleInt, 
    mutable_userdata: *anyopaque, 
    userdata: *const anyopaque) void
{
    const cursor_params = TextEditor.castMutableUserdata(CursorState, mutable_userdata);
    cursor_params.blink_counter += ray.GetFrameTime();
    if (ray.GetKeyPressed() != 0) cursor_params.blink_counter = 0;
    if (@mod(cursor_params.blink_counter, cursor_params.blink_duration*2) < cursor_params.blink_duration)
    {
        const params = TextEditor.castUserdata(DrawParams, userdata);
        ray.DrawRectangle(
            rect.x, rect.y,
            rect.width, rect.height,
            params.color
        );
    }
}

fn drawGlyph(char: u8, rect: TextEditor.RectangleInt, userdata: *const anyopaque) void
{
    const params = TextEditor.castUserdata(DrawParams, userdata);
    const pos = .{
        .x = @intToFloat(f32, rect.x),
        .y = @intToFloat(f32, rect.y),
    };
    ray.DrawTextCodepoint(
        params.font, 
        char, 
        pos, 
        @intToFloat(f32, params.font_size), 
        params.color
    );
}