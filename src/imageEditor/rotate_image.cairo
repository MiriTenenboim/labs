
%lang starknet
%builtins pedersen range_check

from starkware.starknet.common.storage import Storage
from starkware.cairo.common.cairo_builtins import HashBuiltin


fun rotateImage(imageData: ArrayTrait::<u128>, width: u32, degrees: u32) -> ArrayTrait::<u128> {
    // let width = imageData.len();
    let height = width;

    let mut rotateImage = ArrayTrait::new();

    let mut dictRotateImage: Felt252Dict<u64> = Default::default();

    if degrees == 90:
        let mut i: u128 = 0;
        loop {
            if i >= width { // Break condition
                break ();
            }
            // Repeating code
            let mut j: u128 = 0;
            loop {
                if j >= height { // Break condition
                    break ();
                }
                // Repeating code
                let newIndex = (j * width) + (width - i - 1);
                rotateImage[newIndex] = imageData[i * height + j];
                j = j + 1;
            };
            i = i + 1;
        };
    return rotateImage;
    else:
        if degrees == 270:
            let mut i: u128 = 0;
            loop {
                if i >= width { // Break condition
                    break ();
                }
                // Repeating code
                let mut j: u128 = 0;
                loop {
                    if j >= height { // Break condition
                        break ();
                    }
                    // Repeating code
                    let newIndex = ((height - j - 1) * width) + i;
                    rotateImage[newIndex] = imageData[i * height + j];
                    j = j + 1;
                };
                i = i + 1;
            };
        return rotateImage;
        else:
            return(0);
    end
}



// 
// surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, 200, 200)
// ctx = cairo.Context(surface)

// # Draw a rectangle
// ctx.rectangle(50, 50, 100, 50)
// ctx.set_source_rgb(1, 0, 0)
// ctx.fill()

// # Define a transformation matrix for rotation
// angle = 45 * (math.pi / 180)  # Convert angle to radians
// matrix = cairo.Matrix()
// matrix.rotate(angle)

// # Apply the transformation to the context
// ctx.transform(matrix)

// # Draw the same rectangle after rotation
// ctx.rectangle(50, 50, 100, 50)
// ctx.set_source_rgb(0, 0, 1)
// ctx.fill()

// surface.write_to_png("transformed_rectangle.png")
/// 