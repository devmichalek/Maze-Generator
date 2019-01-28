use strict;
use warnings;
use GD::Simple;

# Prepare image
my $EDGE_LONG = 50;
my $EDGE_SPACE = 48;
my $IMAGE_WIDTH = ($EDGE_SPACE * 21) + 1;
my $IMAGE_HEIGHT = $IMAGE_WIDTH;
my $img = GD::Simple->new($IMAGE_WIDTH, $IMAGE_HEIGHT);
$img->bgcolor('blue');

# Generate grid
my @matrix_x;
my @matrix_y;
my @matrix_used;
my @matrix_id;
my $counter_id = 0;
for (my $i = 0; $i < $IMAGE_WIDTH /  $EDGE_SPACE; $i = $i + 1) {
	for (my $j = 0; $j < $IMAGE_HEIGHT /  $EDGE_SPACE; $j = $j + 1) {
		$matrix_x[$i][$j] = $i * $EDGE_SPACE;
		$matrix_y[$i][$j] = $j * $EDGE_SPACE;
		$matrix_used[$i][$j] = 1;
		$matrix_id[$i][$j] = $counter_id;
		++$counter_id;
	}
}

# Remove walls
while (1) {
	
}


# Print walls
my $size = scalar(@matrix_x);
for (my $i = 0; $i < $size; $i = $i + 1) {
	for (my $j = 0; $j < $size; $j = $j + 1) {
		$img->moveTo($matrix_x[$i][$j], $matrix_y[$i][$j]);
		$img->lineTo($matrix_x[$i][$j], $matrix_y[$i][$j] + $EDGE_LONG);
		$img->moveTo($matrix_x[$i][$j], $matrix_y[$i][$j]);
		$img->lineTo($matrix_x[$i][$j] + $EDGE_LONG, $matrix_y[$i][$j]);
	}
}

# Convert into png data
open my $out, '>', 'maze.png' or die;
binmode $out;
print $out $img->png;