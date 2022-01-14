/*******************************
 * Had to do this in C for wasm as I couldn't get the zig version of raylib
 * to work properly in wasm32.
 * 
 * */

#include <stdio.h>
#include <math.h>
#include "raylib/raylib.h"

struct Editor;

struct Editor *editorInit(void);
void editorFree(struct Editor *editor);
void editorInsertChar(struct Editor *editor, char c);
void editorDeleteBackward(struct Editor *editor);
void editorDeleteForward(struct Editor *editor);
void editorMoveCursorLeft(struct Editor *editor);
void editorMoveCursorRight(struct Editor *editor);
void editorMoveCursorUp(struct Editor *editor);
void editorMoveCursorDown(struct Editor *editor);
void editorMoveCursorToLineStart(struct Editor *editor);
void editorMoveCursorToLineEnd(struct Editor *editor);
void editorUpdate(struct Editor *editor, void*, void*, void*, void*, const void*);
void handleTextEditorInput(struct Editor *editor);

struct DrawParams {
    int x;
    int y;
    int horizontal_spacing;
    int vertical_spacing;
    int font_size;
    Font font;
    Color color;
};

struct CursorState {
    float blink_counter;
    float blink_duration;
};

struct RectangleInt {
    int x, y;
    int width, height;
};

struct RectangleInt cursorRect(int col, int row, void *userdata)
{
    const struct DrawParams *draw_params = userdata;
    Vector2 size = MeasureTextEx(
        draw_params->font, 
        "A", 
        draw_params->font_size, 
        draw_params->horizontal_spacing
    );
    int width = size.x; 
    int height = draw_params->font_size;
    return (struct RectangleInt){
        .x = draw_params->x + (col * (width + draw_params->horizontal_spacing)),
        .y = draw_params->y + (row * (height + draw_params->vertical_spacing)),
        .width = width,
        .height = height
    };
}

void drawCursorRect(
    struct RectangleInt rect, 
    void *mutable_userdata, 
    void const *userdata)
{
    struct CursorState *cursor_state = mutable_userdata;
    cursor_state->blink_counter += GetFrameTime();
    if (GetKeyPressed() != 0) cursor_state->blink_counter = 0;
    if (fmodf(cursor_state->blink_counter, cursor_state->blink_duration*2) < cursor_state->blink_duration)
    {
        struct DrawParams const *draw_params = userdata;
        DrawRectangle(
            rect.x, rect.y,
            rect.width, rect.height,
            draw_params->color
        );
    }
}

void drawGlyph(char glyph, int x, int y, void const *userdata)
{
    struct DrawParams const *params = userdata;
    Vector2 pos = { .x = x, .y = y };
    DrawTextCodepoint(
        params->font, 
        glyph, 
        pos,
        params->font_size,
        params->color
    );
}

void createWindowAndLoop()
{
    // Window.
    InitWindow(600, 400, "Text Editor - Raylib");
    SetTargetFPS(30);

    // Create font.
    const int font_size = 20;
    Font font = LoadFontEx("monofonto.otf", font_size, 0, 0);

    // Create text editor.
    struct Editor *editor = editorInit();

    // Setup parameters for text editor renderer.
    struct DrawParams draw_params = {
        .x = 20,
        .y = 20,
        .horizontal_spacing = 1,
        .vertical_spacing = 2,
        .font_size = 20,
        .font = font,
        .color = WHITE
    };
    struct CursorState cursor_state = {0};
    cursor_state.blink_duration = 0.5f;

    // Event loop.
    while (!WindowShouldClose())
    {
        handleTextEditorInput(editor);

        BeginDrawing();
        ClearBackground(BLACK);
        editorUpdate(editor, &drawGlyph, &cursorRect, &drawCursorRect, &cursor_state, &draw_params);
        EndDrawing();
    }

    editorFree(editor);
    UnloadFont(font);
    CloseWindow();
}

void handleTextEditorInput(struct Editor *editor)
{
    // TODO: key repeat.
    char in_char = GetCharPressed();
    if (in_char != 0)
    {
        editorInsertChar(editor, in_char);
        return;
    }

    if (IsKeyPressed(KEY_ENTER))
    {
        editorInsertChar(editor, '\n');
    }
    else if (IsKeyPressed(KEY_TAB))
    {
        editorInsertChar(editor, ' ');
        editorInsertChar(editor, ' ');
    }
    else if (IsKeyPressed(KEY_BACKSPACE))
    {
        editorDeleteBackward(editor);
    }
    else if (IsKeyPressed(KEY_DELETE))
    {
        editorDeleteForward(editor);
    }
    else if (IsKeyPressed(KEY_LEFT))
    {
        editorMoveCursorLeft(editor);
    }
    else if (IsKeyPressed(KEY_RIGHT))
    {
        editorMoveCursorRight(editor);
    }
    else if (IsKeyPressed(KEY_UP))
    {
        editorMoveCursorUp(editor);
    }
    else if (IsKeyPressed(KEY_DOWN))
    {
        editorMoveCursorDown(editor);
    }
    else if (IsKeyPressed(KEY_HOME))
    {
        editorMoveCursorToLineStart(editor);
    }
    else if (IsKeyPressed(KEY_END))
    {
        editorMoveCursorToLineEnd(editor);
    }
}

int main()
{
    createWindowAndLoop();
    return 0;
}