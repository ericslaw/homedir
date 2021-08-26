#!/usr/bin/perl
sub color {
    printf "\e]4;${_}[0];#${_}[1]\a",
}
$line1="COLOR_RES(\"%d\",";
$line2="\tscreen.Acolors[%d],";
$line3="\tDFT_COLOR(\"rgb:%2.2x/%2.2x/%2.2x\")),\n";

# colors 16-231 are a 6x6x6 color cube
for ($red = 0; $red < 6; $red++) {
    for ($green = 0; $green < 6; $green++) {
    for ($blue = 0; $blue < 6; $blue++) {
        $code = 16 + ($red * 36) + ($green * 6) + $blue;
        color($code,$red,$green,$blue)
        printf($line1, $code);
        printf($line2, $code);
        printf($line3,
           ($red ? ($red * 40 + 55) : 0),
           ($green ? ($green * 40 + 55) : 0),
           ($blue ? ($blue * 40 + 55) : 0));
    }
    }
}

# colors 232-255 are a grayscale ramp, intentionally leaving out
# black and white
$code=232;
for ($gray = 0; $gray < 24; $gray++) {
    $level = ($gray * 10) + 8;
    $code = 232 + $gray;
    printf($line1, $code);
    printf($line2, $code);
    printf($line3,
       $level, $level, $level);
}
