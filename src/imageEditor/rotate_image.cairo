
#[wasm_bindgen]
pub struct Image {
    width: u32,
    height: u32,
    pixels: Vec<u8>,

    pixels_bk: Vec<u8>,
    width_bk: u32,
    height_bk: u32,

    last_operation: Operation,

    hsi: Vec<Vec<f64>>, //  elements: Hue, Saturation, Intensity
    lab: Vec<f64>, // L*a*b color space, used mostly in bilateral filter for calculating color difference. It'd get cleared when not used.
    // dct: (Vec<f64>, Vec<f64>),
}

fn rotate(&mut self, clockwise: bool) { // rotate 90
    let (w, h) = (self.width as usize, self.height as usize);

    let mut new_pixels = vec![0_u8; w * h * 4];
    let mut new_x;
    let mut new_y;
    let mut new_idx: usize;
    let mut current_idx: usize;

    for row in 0..h {
        for col in 0..w {
            new_x = if clockwise { h - 1 - row } else { row };
            new_y = if clockwise { col } else { w - 1 - col };
            new_idx = new_y * h + new_x; // new image's height is original image's width
            current_idx = row * w + col;

            new_pixels[new_idx * 4 + 0] = self.pixels[current_idx * 4 + 0];
            new_pixels[new_idx * 4 + 1] = self.pixels[current_idx * 4 + 1];
            new_pixels[new_idx * 4 + 2] = self.pixels[current_idx * 4 + 2];
            new_pixels[new_idx * 4 + 3] = self.pixels[current_idx * 4 + 3];
        }
    }
    self.pixels = new_pixels;
    self.width = h as u32;
    self.height = w as u32;
    self.last_operation = Operation::Transform
}