
use debug::PrintTrait;
use array::ArrayTrait;
use dict::Felt252DictTrait;
use core::panic_with_felt252;


fn rotateImage(imageData: @Array<u256>, width: u32, degrees: u32) -> Array<u256> {
    // let width = imageData.len();
    let height = width;

    let mut rotateImage:Array<u256> = ArrayTrait::new();

    let mut dictRotateImage = felt252_dict_new::<u32>();

    if degrees == 90 {
        let mut i: u32 = 0;
        loop {
            if i >= width { // Break condition
                break ();
            }
            // Repeating code
            let mut j: u32 = 0;
            loop {
                if j >= height { // Break condition
                    break ();
                }
                // Repeating code
                let newIndex: felt252 = ((j * width) + (width - i - 1)).into();
                let value = (*imageData.at(i * height + j)).try_into().unwrap();
                dictRotateImage.insert(newIndex, value);
                j = j + 1;
            };
            i = i + 1;
        };
        return rotateImage;
    }
    else {
        if degrees == 270 {
            let mut i: u32 = 0;
            loop {
                if i >= width { // Break condition
                    break ();
                }
                // Repeating code
                let mut j: u32 = 0;
                loop {
                    if j >= height { // Break condition
                        break ();
                    }
                    // Repeating code
                    let newIndex: felt252 = (((height - j - 1) * width) + i).into();
                    let value = (*imageData.at(i * height + j)).try_into().unwrap();
                    dictRotateImage.insert(newIndex, value);
                    j = j + 1;
                };
                i = i + 1;
            };
            return rotateImage;
        }
    }
    return rotateImage;
}

fn main() {
    let width: u32 = 10;
    let height: u32 = 10;
    int[][] image = {
                    {255, 255, 255, 255, 255, 255, 255, 255, 255, 255},
                    {255, 200, 200, 200, 200, 200, 200, 200, 200, 255},
                    {255, 200, 150, 150, 150, 150, 150, 150, 200, 255},
                    {255, 200, 150, 100, 100, 100, 100, 150, 200, 255},
                    {255, 200, 150, 100,  50,  50, 100, 150, 200, 255},
                    {255, 200, 150, 100,  50,  50, 100, 150, 200, 255},
                    {255, 200, 150, 100, 100, 100, 100, 150, 200, 255},
                    {255, 200, 150, 150, 150, 150, 150, 150, 200, 255},
                    {255, 200, 200, 200, 200, 200, 200, 200, 200, 255},
                    {255, 255, 255, 255, 255, 255, 255, 255, 255, 255}
                };
    byte[] imageData = new byte[width * height];
    int index = 0;
    for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
            imageData[index++] = (byte) image[i][j];
        }
    }

    let degrees: u32 = 90;

    let mut rotateImage:Array<u256> = rotateImage(:imageData, :width, :degrees);
}