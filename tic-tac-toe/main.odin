package tictactoe

import "core:c"
import rl "vendor:raylib"

GAME_TITLE :: "Tic Tac Toe"
GAME_W :: 800
GAME_H :: 600

RENDER_TARGET: rl.RenderTexture2D

main :: proc() {
    rl.SetConfigFlags({.WINDOW_RESIZABLE})
    rl.InitWindow(GAME_W, GAME_H, GAME_TITLE)

    RENDER_TARGET = rl.LoadRenderTexture(GAME_W, GAME_H)
    defer rl.UnloadRenderTexture(RENDER_TARGET)

    for !rl.WindowShouldClose() {
        BeginDrawing()

        CELL :: 20

        // vertical lines
        for x: i32 = 0; x <= GAME_W; x += CELL {
            col := rl.Color{200, 200, 200, 255}
            if x == GAME_W / 2 {
                col = rl.RED
            }
            rl.DrawLine(x, 0, x, GAME_H, col)
        }

        // horizontal lines
        for y: i32 = 0; y <= GAME_H; y += CELL {
            col := rl.Color{200, 200, 200, 255}
            if y == GAME_H / 2 {
                col = rl.BLUE
            }
            rl.DrawLine(0, y, GAME_W, y, col)
        }

        EndDrawing()
    }

    rl.CloseWindow()
}
