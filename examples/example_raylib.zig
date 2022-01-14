const std = @import("std");
const ray = @import("raylib");
const TextEditor = @import("text_editor");
const TextEditorRenderer = @import("text_editor_raylib_renderer.zig");

pub fn main() !void 
{
    // Allocator.
    var allocator = std.heap.c_allocator;

    // Window.
    const screenSize = .{ .x = 600, .y = 800 };
    ray.InitWindow(@intCast(i32, screenSize.x), @intCast(i32, screenSize.y), "Text Editor - Raylib");
    ray.SetTargetFPS(60);
    defer ray.CloseWindow();

    // Create font.
    const font_size = 20;
    var font: ray.Font = ray.LoadFontEx("monofonto.otf", font_size, null, 0);
    defer ray.UnloadFont(font);

    // Create text editor.
    var code_editor = try TextEditor.init(allocator, 1_000_000);
    defer code_editor.deinit();

    // Setup parameters for text editor renderer.
    const code_editor_draw_params = TextEditorRenderer.DrawParams{
        .x = 25,
        .y = 25,
        .horizontal_spacing = 1,
        .vertical_spacing = 1,
        .font_size = font_size,
        .font = font,
        .color = ray.WHITE
    };
    var cursor_state = TextEditorRenderer.CursorState{};
    const code_editor_renderer = TextEditorRenderer.interface(
        &code_editor_draw_params, &cursor_state
    );

    // Event loop.
    while (!ray.WindowShouldClose())
    {
        handleTextEditorInput(&code_editor);

        ray.BeginDrawing();
        defer ray.EndDrawing();
        ray.ClearBackground(ray.BLACK);

        code_editor.drawBuffer(code_editor_renderer);
        code_editor.drawCursor(code_editor_renderer);
    }
}

fn handleTextEditorInput(editor: *TextEditor) void
{
    // TODO: key repeat.
    var in_char = ray.GetCharPressed();
    if (in_char != 0)
    {
        editor.insertByte(@intCast(u8, in_char));
        return;
    }

    if (ray.IsKeyPressed(ray.KEY_ENTER))
    {
        editor.insertByte('\n');
    }
    else if (ray.IsKeyPressed(ray.KEY_TAB))
    {
        editor.insertByte(' ');
        editor.insertByte(' ');
    }
    else if (ray.IsKeyPressed(ray.KEY_BACKSPACE))
    {
        editor.deleteBackward();
    }
    else if (ray.IsKeyPressed(ray.KEY_DELETE))
    {
        editor.deleteForward();
    }
    else if (ray.IsKeyPressed(ray.KEY_LEFT))
    {
        editor.moveCursorLeft(&editor.cursor);
    }
    else if (ray.IsKeyPressed(ray.KEY_RIGHT))
    {
        editor.moveCursorRight(&editor.cursor);
    }
    else if (ray.IsKeyPressed(ray.KEY_UP))
    {
        editor.moveCursorUp(&editor.cursor);
    }
    else if (ray.IsKeyPressed(ray.KEY_DOWN))
    {
        editor.moveCursorDown(&editor.cursor);
    }
    else if (ray.IsKeyPressed(ray.KEY_HOME))
    {
        editor.moveCursorToLineStart(&editor.cursor);
    }
    else if (ray.IsKeyPressed(ray.KEY_END))
    {
        editor.moveCursorToLineEnd(&editor.cursor);
    }
}