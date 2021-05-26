""" README

Author: Huang Po-Hsuan (P78081528)

Description:
create img.dat and golden.dat from image.jpg
where img.dat is a 128x128 image with salt and pepper noise
and golden.dat is a 128x128 image processed by median filter

Environment setup:
$ vrtualenv -p python3.6 venv
$ source venv/bin/activate
$ pip install scikit-image==0.17.2

Usage:
$ python3 main.py
"""

import argparse
import skimage
from skimage.io import imread, imsave
from skimage.color import rgb2gray
from skimage.transform import resize
from skimage import img_as_ubyte
from skimage.util import random_noise
import numpy as np

def median_filtering(img):
    y, x = img.shape
    pad_img = np.pad(img, 1, mode='constant')
    out_img = np.empty(shape=img.shape, dtype=np.uint8)
    for i in range(1, y+1):
        for j in range(1, x+1):
            out_img[i-1][j-1] = np.median([
                    pad_img[i-1][j-1],
                    pad_img[i-1][j  ],
                    pad_img[i-1][j+1],
                    pad_img[i  ][j-1],
                    pad_img[i  ][j  ],
                    pad_img[i  ][j+1],
                    pad_img[i+1][j-1],
                    pad_img[i+1][j  ],
                    pad_img[i+1][j+1],
                    ])
    return out_img

def save_dat(filename, data):
    with open(filename, "w") as fout:
        for i in range(data.shape[0]):
            for j in range(data.shape[1]):
                fout.write(f"{data[i][j]:02x}\n")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("-i", "--image", help = "Path to the image", default="./image.jpg")
    args = vars(ap.parse_args())

    img = imread(args['image'])
    img = rgb2gray(img)
    img = resize(img, (128,128))
    img = img_as_ubyte(random_noise(img, mode='s&p', amount=0.02))
    golden = median_filtering(img)

    # imsave("img.jpg", img)
    # imsave("golden.jpg", golden)

    save_dat("img.dat", img)
    save_dat("golden.dat", golden)

if __name__ == '__main__':
    main()
