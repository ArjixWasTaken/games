package breakout

import rl "vendor:raylib"

GAME_TITLE :: "Breakout"
GAME_W :: 800
GAME_H :: 600

RENDER_TARGET: rl.RenderTexture2D

PADDLE_W     :: f32(120)
PADDLE_H     :: f32(15)
PADDLE_SPEED :: f32(600)
PADDLE_Y     :: f32(GAME_H - 50)

BALL_RADIUS  :: f32(10)
BALL_SPEED   :: f32(420)

BRICK_ROWS   :: 5
BRICK_COLS   :: 8
BRICK_W      :: f32(80)
BRICK_H      :: f32(25)
BRICK_GAP    :: f32(8)
BRICK_OFF_X  :: f32(52)
BRICK_OFF_Y  :: f32(60)

Brick :: struct {
    rect:  rl.Rectangle,
    alive: bool,
    color: rl.Color,
}

GameState :: enum { Start, Paused, Playing, Win, Lose }

init_bricks :: proc(bricks: ^[BRICK_ROWS * BRICK_COLS]Brick) {
    colors := [BRICK_ROWS]rl.Color{rl.RED, rl.ORANGE, rl.YELLOW, rl.GREEN, rl.SKYBLUE}
    for r in 0..<BRICK_ROWS {
        for c in 0..<BRICK_COLS {
            bricks[r * BRICK_COLS + c] = {
                rect = {
                    BRICK_OFF_X + f32(c) * (BRICK_W + BRICK_GAP),
                    BRICK_OFF_Y + f32(r) * (BRICK_H + BRICK_GAP),
                    BRICK_W,
                    BRICK_H,
                },
                alive = true,
                color = colors[r],
            }
        }
    }
}


center_text_x :: proc(text: cstring, font_size: i32) -> i32 {
    return (GAME_W - rl.MeasureText(text, font_size)) / 2
}

main :: proc() {
    rl.SetConfigFlags({.WINDOW_RESIZABLE})
    rl.InitWindow(GAME_W, GAME_H, GAME_TITLE)

    RENDER_TARGET = rl.LoadRenderTexture(GAME_W, GAME_H)
    defer rl.UnloadRenderTexture(RENDER_TARGET)
    rl.SetTargetFPS(60)
    rl.SetExitKey(nil)

    bricks: [BRICK_ROWS * BRICK_COLS]Brick
    init_bricks(&bricks)

    paddle_x := f32(GAME_W) / 2 - PADDLE_W / 2
    ball_pos  := rl.Vector2{f32(GAME_W) / 2, f32(GAME_H) / 2}
    ball_vel  := rl.Vector2{BALL_SPEED * 0.6, -BALL_SPEED * 0.8}
    score     := i32(0)
    lives     := i32(3)
    state     := GameState.Start

    for !rl.WindowShouldClose() {
        dt := rl.GetFrameTime()

        if state == .Playing {
            if rl.IsKeyDown(.LEFT)  do paddle_x -= PADDLE_SPEED * dt
            if rl.IsKeyDown(.RIGHT) do paddle_x += PADDLE_SPEED * dt
            paddle_x = clamp(paddle_x, 0, f32(GAME_W) - PADDLE_W)

            ball_pos.x += ball_vel.x * dt
            ball_pos.y += ball_vel.y * dt

            // Wall bounces
            if ball_pos.x - BALL_RADIUS < 0 {
                ball_pos.x = BALL_RADIUS
                ball_vel.x = abs(ball_vel.x)
            }
            if ball_pos.x + BALL_RADIUS > f32(GAME_W) {
                ball_pos.x = f32(GAME_W) - BALL_RADIUS
                ball_vel.x = -abs(ball_vel.x)
            }
            if ball_pos.y - BALL_RADIUS < 0 {
                ball_pos.y = BALL_RADIUS
                ball_vel.y = abs(ball_vel.y)
            }

            // Paddle bounce
            paddle_rect := rl.Rectangle{paddle_x, PADDLE_Y, PADDLE_W, PADDLE_H}
            if ball_vel.y > 0 && rl.CheckCollisionCircleRec(ball_pos, BALL_RADIUS, paddle_rect) {
                ball_pos.y = PADDLE_Y - BALL_RADIUS
                hit := (ball_pos.x - paddle_x) / PADDLE_W // 0..1
                ball_vel.x = BALL_SPEED * (hit - 0.5) * 2.2
                ball_vel.y = -abs(ball_vel.y)
            }

            // Ball lost
            if ball_pos.y > f32(GAME_H) + BALL_RADIUS {
                lives -= 1
                if lives <= 0 {
                    state = .Lose
                } else {
                    ball_pos = {f32(GAME_W) / 2, f32(GAME_H) / 2}
                    ball_vel = {BALL_SPEED * 0.6, -BALL_SPEED * 0.8}
                }
            }

            // Brick collisions
            for &brick in bricks {
                if !brick.alive do continue
                if rl.CheckCollisionCircleRec(ball_pos, BALL_RADIUS, brick.rect) {
                    brick.alive = false
                    score += 10
                    // Bounce off the nearest face
                    ndx := abs(ball_pos.x - (brick.rect.x + brick.rect.width  / 2)) / (brick.rect.width  / 2)
                    ndy := abs(ball_pos.y - (brick.rect.y + brick.rect.height / 2)) / (brick.rect.height / 2)
                    if ndx > ndy {
                        ball_vel.x = -ball_vel.x
                    } else {
                        ball_vel.y = -ball_vel.y
                    }
                    break
                }
            }
            alive_count := 0
            for brick in bricks { if brick.alive do alive_count += 1 }
            if alive_count == 0 do state = .Win
        }

        BeginDrawing()
        rl.ClearBackground(rl.BLACK)

        switch state {
        case .Playing, .Paused:
            for brick in bricks {
                if !brick.alive do continue
                rl.DrawRectangleRec(brick.rect, brick.color)
                rl.DrawRectangleLinesEx(brick.rect, 1, rl.Fade(rl.BLACK, 0.45))
            }
            rl.DrawRectangleRec({paddle_x, PADDLE_Y, PADDLE_W, PADDLE_H}, rl.WHITE)
            rl.DrawCircleV(ball_pos, BALL_RADIUS, rl.WHITE)
            rl.DrawText(rl.TextFormat("Score: %d", score), 10, 10, 20, rl.WHITE)
            rl.DrawText(rl.TextFormat("Lives: %d", lives), GAME_W - 110, 10, 20, rl.WHITE)

            if state == .Paused {
                rl.DrawText("Paused", center_text_x("Paused", 55), GAME_H/2 - 50, 55, rl.WHITE)
            }

            if rl.IsKeyPressed(.ESCAPE) {
                #partial switch state {
                    case .Paused:
                        state = .Playing
                    case .Playing:
                        state = .Paused
                }
            }

        case .Start:
            rl.DrawText("Breakout!", center_text_x("Breakout!", 80), GAME_H/2 - 50, 80, rl.YELLOW)
            rl.DrawText("Press space to play", center_text_x("Press space to play", 20), GAME_H/2 + 60, 20, rl.GRAY)
        case .Win:
            rl.DrawText("YOU WIN!", center_text_x("YOU WIN!", 55), GAME_H/2 - 50, 55, rl.GREEN)
            rl.DrawText(rl.TextFormat("Score: %d", score), center_text_x(rl.TextFormat("Score: %d", score), 25), GAME_H/2 + 20, 25, rl.WHITE)
            rl.DrawText("Press R to play again", center_text_x("Press R to play again", 20), GAME_H/2 + 60, 20, rl.GRAY)

        case .Lose:
            rl.DrawText("GAME OVER", center_text_x("GAME OVER", 55), GAME_H/2 - 50, 55, rl.RED)
            rl.DrawText(rl.TextFormat("Score: %d", score), center_text_x(rl.TextFormat("Score: %d", score), 25), GAME_H/2 + 20, 25, rl.WHITE)
            rl.DrawText("Press R to play again", center_text_x("Press R to play again", 20), GAME_H/2 + 60, 20, rl.GRAY)
        }

        EndDrawing()

        if
            state == .Start && rl.IsKeyPressed(.SPACE) ||
            state == .Win && rl.IsKeyPressed(.R) ||
            state == .Lose && rl.IsKeyPressed(.R)
        {
            init_bricks(&bricks)
            paddle_x = f32(GAME_W) / 2 - PADDLE_W / 2
            ball_pos = {f32(GAME_W) / 2, f32(GAME_H) / 2}
            ball_vel = {BALL_SPEED * 0.6, -BALL_SPEED * 0.8}
            score    = 0
            lives    = 3
            state    = .Playing
        }
    }

    rl.CloseWindow()
}