package tictactoe

import rl "vendor:raylib"

Player :: enum {
    None,
    X,
    O,
}

Cell :: struct {
    player: Player,
    index: i32,
    rect: rl.Rectangle,
}

BoardLayout :: struct {
    cell_size: f32,
    gap: f32,

    offset_x: f32,
    offset_y: f32,
}
