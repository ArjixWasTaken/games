package tictactoe

import rl "vendor:raylib"

BeginDrawing :: proc() {
    rl.BeginTextureMode(RENDER_TARGET)
    rl.ClearBackground(rl.RAYWHITE)
}

EndDrawing :: proc() {
    rl.EndTextureMode()

    rl.BeginDrawing()
    rl.ClearBackground(rl.GRAY)

    scale := min(
        f32(rl.GetScreenWidth()) / GAME_W,
        f32(rl.GetScreenHeight()) / GAME_H,
    )

    dst_w := f32(GAME_W) * scale
    dst_h := f32(GAME_H) * scale

    rl.DrawTexturePro(
        RENDER_TARGET.texture,
        rl.Rectangle{
            0, 0,
            f32(GAME_W),
            -f32(GAME_H), // render textures are upside-down
        },
        rl.Rectangle{
            (f32(rl.GetScreenWidth()) - dst_w) / 2,
            (f32(rl.GetScreenHeight()) - dst_h) / 2,
            dst_w,
            dst_h,
        },
        rl.Vector2{},
        0,
        rl.WHITE,
    )

    rl.EndDrawing()
}

GetMousePosition :: proc() -> rl.Vector2 {
    mouse := rl.GetMousePosition()

    scale := min(
        f32(rl.GetScreenWidth()) / GAME_W,
        f32(rl.GetScreenHeight()) / GAME_H,
    )

    dst_w := f32(GAME_W) * scale
    dst_h := f32(GAME_H) * scale

    offset_x := (f32(rl.GetScreenWidth()) - dst_w) / 2.0
    offset_y := (f32(rl.GetScreenHeight()) - dst_h) / 2.0

    // convert screen → game space
    return rl.Vector2{
        (mouse.x - offset_x) / scale,
        (mouse.y - offset_y) / scale,
    }
}
