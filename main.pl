use strict;
use warnings;
use GD::Simple;
 
# create a new image (width, height)
my $img = GD::Simple->new(200, 100);
 

 
# convert into png data
open my $out, '>', 'maze.png' or die;
binmode $out;
print $out $img->png;