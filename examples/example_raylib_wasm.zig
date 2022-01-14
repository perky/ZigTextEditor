const std = @import("std");
const TextEditor = @import("text_editor");
const ray = @import("raylib/raylib.zig");

export fn editorUpdate(editor: *anyopaque,
                       draw_glyph_ptr: *anyopaque, 
                       cursor_rect_ptr: *anyopaque, 
                       draw_cursor_ptr: *anyopaque, 
                       mutable_userdata: *anyopaque,
                       userdata: *const anyopaque) void
{
    var draw_glyph_fn = @ptrCast(TextEditor.DrawGlyphSignature, draw_glyph_ptr);
    var cursor_rect_fn = @ptrCast(TextEditor.CursorRectSignature, cursor_rect_ptr);
    var draw_cursor_fn = @ptrCast(TextEditor.DrawCursorRectSignature, draw_cursor_ptr);
    var interface = TextEditor.RendererInterface{
        .draw_glyph_fn = draw_glyph_fn,
        .cursor_rect_fn = cursor_rect_fn,
        .draw_cursor_rect_fn = draw_cursor_fn,
        .mutable_userdata = mutable_userdata,
        .userdata = userdata
    };
    var editorZ = TextEditor.castMutableUserdata(TextEditor, editor);
    editorZ.drawBuffer(interface);
    editorZ.drawCursor(interface);
}

export fn editorInit() *anyopaque
{
    var editor = TextEditor.initC(std.heap.c_allocator, 1_000_000) catch unreachable;
    return editor;
}

export fn editorFree(editor: *anyopaque) void
{
    var editorZ = TextEditor.castMutableUserdata(TextEditor, editor);
    editorZ.deinit();
}

export fn editorInsertChar(editor: *anyopaque, c: u8) void
{
    var editorZ = TextEditor.castMutableUserdata(TextEditor, editor);
    editorZ.insertByte(c);
}

export fn editorDeleteBackward(editor: *anyopaque) void
{
    var editorZ = TextEditor.castMutableUserdata(TextEditor, editor);
    editorZ.deleteBackward();
}

export fn editorDeleteForward(editor: *anyopaque) void
{
    var editorZ = TextEditor.castMutableUserdata(TextEditor, editor);
    editorZ.deleteForward();
}

export fn editorMoveCursorLeft(editor: *anyopaque) void
{
    var editorZ = TextEditor.castMutableUserdata(TextEditor, editor);
    editorZ.moveCursorLeft(&editorZ.cursor);
}

export fn editorMoveCursorRight(editor: *anyopaque) void
{
    var editorZ = TextEditor.castMutableUserdata(TextEditor, editor);
    editorZ.moveCursorRight(&editorZ.cursor);
}

export fn editorMoveCursorUp(editor: *anyopaque) void
{
    var editorZ = TextEditor.castMutableUserdata(TextEditor, editor);
    editorZ.moveCursorUp(&editorZ.cursor);
}

export fn editorMoveCursorDown(editor: *anyopaque) void
{
    var editorZ = TextEditor.castMutableUserdata(TextEditor, editor);
    editorZ.moveCursorDown(&editorZ.cursor);
}

export fn editorMoveCursorToLineEnd(editor: *anyopaque) void
{
    var editorZ = TextEditor.castMutableUserdata(TextEditor, editor);
    editorZ.moveCursorToLineEnd(&editorZ.cursor);
}

export fn editorMoveCursorToLineStart(editor: *anyopaque) void
{
    var editorZ = TextEditor.castMutableUserdata(TextEditor, editor);
    editorZ.moveCursorToLineStart(&editorZ.cursor);
}