# include
use strict;
use warnings;
use GD::Simple;
use FindBin;
use lib "$FindBin::Bin/lib";
use Point;
use Wall;

# resolution
my $EDGE_LONG = 50;
my $EDGE_SPACE = 48;

# prepare image
my $IMAGE_WIDTH = ($EDGE_SPACE * 21) + 1;
my $IMAGE_HEIGHT = $IMAGE_WIDTH;
my $img = GD::Simple->new($IMAGE_WIDTH, $IMAGE_HEIGHT);
$img->fgcolor('black');

# generate grid
my @cells;		# cells with unique ids
my @edges;
my @vmatrix;	# vertical walls
my @hmatrix;	# horizontal walls
my $idc = 0;	# ID counter
for (my $i = 0; $i < $IMAGE_WIDTH /  $EDGE_SPACE; ++$i)
{
	for (my $j = 0; $j < $IMAGE_HEIGHT /  $EDGE_SPACE; ++$j)
	{
		$vmatrix[$i][$j] = Point->new(x => $i * $EDGE_SPACE, y => $j * $EDGE_SPACE);
		$hmatrix[$i][$j] = Point->new(x => $i * $EDGE_SPACE, y => $j * $EDGE_SPACE);
		$edges[$i][$j][0] = Wall->new(type => 0);
		$edges[$i][$j][1] = Wall->new(type => 1);
		$cells[$i][$j] = $idc++;
	}
}



# remove walls
{
	while (1)
	{
		# check how many ids are there
		my $idxl = scalar(@cells);
		my $idyl = scalar(@{$cells[0]});
		my $isOneID = 1;
		for (my $i = 0; $i < $idxl; ++$i) {
			for (my $j = 0; $j < $idyl; ++$j) {
				if ($cells[$i][$j] != $cells[0][0]) {
					$isOneID = 0;
					last; # break
				}
			}
		}
		if ($isOneID) {
			last; # there is only one ID
		}

		while (1) {
			my $ret = 1;
			# rand x
			my $xl = (scalar(@edges) - 1);
			my $i = (int(rand($xl)) + 1); # 1 ... (size-1)
			# rand y
			my $yl = (scalar(@{$edges[$i]}) - 1);
			my $j = (int(rand($yl)) + 1); # 1 ... (size-1)
			# rand type
			my $tl = (scalar(@{$edges[$i][$j]}));
			my $it = (int(rand($tl))); # 0 ... 1

			my $t = $edges[$i][$j][$it]->getType(); # 0 - vertical / 1 - horizontal wall

			my $newID = $cells[$i][$j];
			my $oldID = -1;
			if ($t == 0) {
				# $j stays the same, and <- $i -> check cell(left, right)
				if ($cells[$i-1][$j] == $cells[$i][$j]) {
					$ret = 0; # we have the same id in these cells, repeat loop
				} else {
					$oldID = $cells[$i-1][$j];
					if ($yl == 2) {
						splice(@vmatrix, $i, 1);	# remove the last wall
					} else {
						splice(@{$vmatrix[$i]}, $j, 1); # remove wall
					}
				}
			} else {
				# $i stays the same, and <- $j -> check cell(top, bot)
				if ($cells[$i][$j-1] == $cells[$i][$j]) {
					$ret = 0; # we have the same id in these cells, repeat loop
				} else {
					$oldID = $cells[$i][$j-1];
					if ($yl == 2) {
						splice(@hmatrix, $i, 1);	# remove the last wall
					} else {
						my tmp = \@hmatrix[$i];
						splice(@tmp, $j, 1);# remove wall
					}
				}
			}

			if ($tl == 1) {
				if ($yl == 2) {
					splice(@edges, $i, 1);
				} else {
					splice(@{$edges[$i]}, $j, 1);
				}
			} else {
				splice(@{$edges[$i][$j]}, $t, 1);
			}

			if ($ret == 1) {
				# set new ID to old IDs
				for (my $k = 0; $k < $idxl; ++$k) {
					for (my $l = 0; $l < $idyl; ++$l) {
						if ($cells[$k][$l] == $oldID) {
							$cells[$k][$l] = $newID;
						}
					}
				}

				last; # break
			}
		}
	}
}

# print walls into image
my $size = scalar(@vmatrix);
for (my $i = 0; $i < $size; ++$i)
{
	my $sv = scalar(@{$vmatrix[$i]});
	for (my $j = 0; $j < $sv; ++$j) {
		$img->moveTo($vmatrix[$i][$j]->getX(), $vmatrix[$i][$j]->getY());
		$img->lineTo($vmatrix[$i][$j]->getX(), $vmatrix[$i][$j]->getY() + $EDGE_LONG);
	}

	my $sh = scalar(@{$hmatrix[$i]});
	for (my $j = 0; $j < $sh; ++$j) {
		$img->moveTo($hmatrix[$i][$j]->getX(), $hmatrix[$i][$j]->getY());
		$img->lineTo($hmatrix[$i][$j]->getX() + $EDGE_LONG, $hmatrix[$i][$j]->getY());
	}
}

	

# convert into png data
open my $out, '>', 'maze.png' or die;
binmode $out;
print $out $img->png;
