# TEST IMAGE PROCESSORS

# jpeg-recompress --version     => 2.2.0
# jpegoptim --version           => v1.5.1
# jpegtran -V                   => 9e (16-Jan-2022)
# jhead -V                      => Jhead version: 3.04
#
# advpng --version              => v2.5
# oxipng --version              => oxipng 8.0.0
# optipng --version             => OptiPNG version 0.7.7
# pngquant --version            => 2.18.0 (January 2023)
# pngcrush --version            => pngcrush 1.8.13
# pngout                        => Jan 15 2020
#
# gifsicle --version            => LCDF Gifsicle 1.92

mkdir /img_test
cd /img_test

# size: 196684
wget -O test-start-kit.jpg https://raw.githubusercontent.com/the-teacher/rails7-startkit/master/Rails7StartKit/assets/logos/Rails7.StartKit.jpg

# size: 124033
wget -O test-thinking-sphinx.png https://raw.githubusercontent.com/the-teacher/rails7-startkit/master/Rails7StartKit/assets/images/thinking-sphinx.png

# size: 4888813
wget -O test-cat.gif https://media.tenor.com/yLjbMCoTu3UAAAAd/cat-pounce.gif

# 1. jpeg-recompress
cp test-start-kit.jpg start-kit.jpg
jpeg-recompress --strip start-kit.jpg start-kit.jpg

# 2. jpegoptim
cp test-start-kit.jpg start-kit.jpg
jpegoptim --strip-all start-kit.jpg

# 3. jpegtran
cp test-start-kit.jpg start-kit.jpg
jpegtran -verbose -optimize -outfile start-kit.jpg start-kit.jpg

# 4. jhead
cp test-start-kit.jpg start-kit.jpg
jhead -purejpg start-kit.jpg

# 5. advpng
cp test-thinking-sphinx.png thinking-sphinx.png
advpng --recompress --shrink-normal thinking-sphinx.png
advpng --list --shrink-normal thinking-sphinx.png

# 5. oxipng
cp test-thinking-sphinx.png thinking-sphinx.png
oxipng -o 3 --strip all thinking-sphinx.png

# 7. optipng
cp test-thinking-sphinx.png thinking-sphinx.png
optipng thinking-sphinx.png

# 8. pngquant
cp test-thinking-sphinx.png thinking-sphinx.png
pngquant --speed 4 --verbose --force --output thinking-sphinx.png thinking-sphinx.png

# 9. pngcrush
cp test-thinking-sphinx.png thinking-sphinx.png
pngcrush thinking-sphinx.png thinking-sphinx.png -ow

# 10. pngout
cp test-thinking-sphinx.png thinking-sphinx.png
pngout thinking-sphinx.png  thinking-sphinx.png -s2 -y

# 11. gifsicle
cp test-cat.gif cat.gif
gifsicle -I cat.gif

# cleanup
rm -rf ./*

cd /
