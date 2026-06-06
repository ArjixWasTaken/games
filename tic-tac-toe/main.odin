package tictactoe

import "core:fmt"
import "core:c"
import rl "vendor:raylib"

GAME_TITLE :: "Tic Tac Toe"
GAME_W :: 800
GAME_H :: 600

RENDER_TARGET: rl.RenderTexture2D
CELLS: [9]Cell

make_layout :: proc() -> BoardLayout {
    cell_size: f32 = 150.0
    gap: f32 = 10.0

    board_w := (cell_size + gap) * 3
    board_h := (cell_size + gap) * 3

    offset_x := (f32(GAME_W) - board_w) / 2.0
    offset_y := (f32(GAME_H) - board_h) / 2.0 + 50.0

    return BoardLayout{
        cell_size,
        gap,
        offset_x,
        offset_y,
    }
}

init_cells :: proc(layout: BoardLayout) {
    for i: i32 = 0; i < len(CELLS); i += 1 {
        row := i / 3
        col := i % 3

        x := layout.offset_x + f32(col) * (layout.cell_size + layout.gap)
        y := layout.offset_y + f32(row) * (layout.cell_size + layout.gap)

        CELLS[i] = Cell{
            player = .None,
            index = i,
            rect = rl.Rectangle{
                x,
                y,
                layout.cell_size,
                layout.cell_size,
            },
        }
    }
}

draw_cells :: proc() {
    mouse_pos := GetMousePosition()

    has_set_cursor: bool = false

    for cell, i in CELLS {
        color := rl.Color{240, 240, 240, 255}

        is_hovered := rl.CheckCollisionCircleRec(mouse_pos, f32(1), cell.rect)
        if is_hovered {
            has_set_cursor = true
            #partial switch cell.player {
                case .None: rl.SetMouseCursor(.POINTING_HAND)
                case: rl.SetMouseCursor(.NOT_ALLOWED)
            }

            if cell.player == .None && is_hovered {
                color = rl.Color{220, 235, 255, 255}
            }
        }

        rl.DrawRectangleRec(cell.rect, color)
        rl.DrawRectangleLinesEx(cell.rect, 2, rl.BLACK)

        text := rl.TextFormat("%d", i)
        rl.DrawText(
            text,
            i32(cell.rect.x + 5),
            i32(cell.rect.y + 5),
            20,
            rl.GRAY,
        )
    }

    if !has_set_cursor {
        rl.SetMouseCursor(.DEFAULT)
    }
}

main :: proc() {
    rl.SetConfigFlags({.WINDOW_RESIZABLE})
    rl.InitWindow(GAME_W, GAME_H, GAME_TITLE)

    RENDER_TARGET = rl.LoadRenderTexture(GAME_W, GAME_H)
    defer rl.UnloadRenderTexture(RENDER_TARGET)

    layout := make_layout()
    init_cells(layout)

    for !rl.WindowShouldClose() {
        BeginDrawing()

            font_size: i32 = 40
            title := cstring(GAME_TITLE)
            title_size := rl.MeasureText(title, font_size)

            rl.DrawText(
                title,
                i32((f32(GAME_W) - f32(title_size)) / 2.0),
                i32(layout.offset_y - 60),
                font_size,
                rl.BLACK,
            )

            draw_cells()

            if rl.IsMouseButtonPressed(.LEFT) {
                mouse_pos := GetMousePosition()
                for &cell in CELLS {
                    if rl.CheckCollisionCircleRec(mouse_pos, f32(1), cell.rect) {
                        cell.player = .X
                        fmt.printfln("Clicked cell %d", cell.index)
                    }
                }
            }

        EndDrawing()
    }

    rl.CloseWindow()
}
