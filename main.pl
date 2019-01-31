# include
use strict;
use warnings;
use GD::Simple;
use FindBin;
use lib "$FindBin::Bin/lib";
use Point;
use Wall;

# resolution
my $EDGE_LONG = 20;

# prepare image
my $IMAGE_WIDTH = ($EDGE_LONG * 21) + 1;
my $IMAGE_HEIGHT = $IMAGE_WIDTH;
my $img = GD::Simple->new($IMAGE_WIDTH, $IMAGE_HEIGHT);
$img->fgcolor('black');

# generate grid
my @cells;		# cells with unique ids
my @edges;
my @vmatrix;	# vertical walls
my @hmatrix;	# horizontal walls
my $idc = 0;	# ID counter
for (my $i = 0; $i < $IMAGE_WIDTH /  $EDGE_LONG; ++$i)
{
	for (my $j = 0; $j < $IMAGE_HEIGHT /  $EDGE_LONG; ++$j)
	{
		$vmatrix[$i][$j] = Point->new(x => $i * $EDGE_LONG, y => $j * $EDGE_LONG);
		$hmatrix[$i][$j] = Point->new(x => $i * $EDGE_LONG, y => $j * $EDGE_LONG);
		$edges[$i][$j][0] = Wall->new(x => $i, y => $j, type => 0);
		$edges[$i][$j][1] = Wall->new(x => $i, y => $j, type => 1);
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
					#print("There is still more than one ID\n");
					last; # break
				}
			}
		}
		if ($isOneID) {
			last; # there is only one ID
		}

		while (1) {
			my $ret = 1; # ret code

			# rand x
			my $xl = scalar(@edges);
			my $i = int(rand($xl));

			if ($xl == 2) {
				$isOneID = 1;
				last;
			}

			# rand y
			my $yl = scalar(@{$edges[$i]});
			my $j = int(rand($yl));

			# debug
			#print("Scope(x) min=1 max=$xl\n");
			#print("Scope(y) min=1 max=$yl\n");
			#print("Rand \$x=$i \$y=$j\n");

			# rand type
			my $tl = 2;
			my $it = 0;
			if ($edges[$i][$j][0]->getType() == -1) {
				$it = 1;
				$tl = 1;
			}
			if ($edges[$i][$j][1]->getType() == -1) {
				$it = 0;
				$tl = 1;
			}
			
			if ($tl == 2) {
				$it = int(rand($tl));
			}

			#print("Choosing type from \$i=$i \$j=$j $tl\n");
			my $t = $edges[$i][$j][$it]->getType(); # 0 - vertical / 1 - horizontal wall
			#print("Type set to \$t=$t\n");

			
			my $bx = $edges[$i][$j][$it]->getX();
			my $by = $edges[$i][$j][$it]->getY();
			my $newID = $cells[$bx][$by];
			my $oldID = -1;
			if ($t == 0) {
				# $by stays the same, and <- $bx -> check cell(left, right)
				if ($bx == 0 || $bx == ($idxl-1) || ($cells[$bx-1][$by] == $cells[$bx][$by])) {
					$ret = 0; # we have the same id in these cells, repeat loop
				} else {
					$oldID = $cells[$bx-1][$by];
					#print("Removing wall(v) \$bx=$bx \$by=$by\n");
					$vmatrix[$bx][$by] = Point->new(x => -1, y => -1);
				}
			} else {
				# $bx stays the same, and <- $by -> check cell(top, bot)
				if ($by == 0 || $by == ($idyl-1) || ($cells[$bx][$by-1] == $cells[$bx][$by])) {
					$ret = 0; # we have the same id in these cells, repeat loop
				} else {
					$oldID = $cells[$bx][$by-1];
					#print("Removing wall(h) \$bx=$bx \$by=$by\n");
					$hmatrix[$bx][$by] = Point->new(x => -1, y => -1);
				}
			}

			if ($tl == 1) {
				if ($yl == 2) {
					#print("Deleting whole column \$i=$i\n");
					#sleep(1);
					splice(@edges, $i, 1); # delete whole column
				} else {
					#print("Deleting last wall \$i=$i \$j=$j\n");
					#sleep(1);
					splice(@{$edges[$i]}, $j, 1); # last wall
				}
			} else {
					#print("edges[$i][$j][$t] = $edges[$i][$j][$t]\n");
					#sleep(1);
					$edges[$i][$j][$t]->setType(-1); # first wall
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

		if ($isOneID) {
			last; # there is only one ID
		}
	}
}

# print walls into image
my $size = scalar(@vmatrix);
for (my $i = 0; $i < $size; ++$i)
{
	my $sv = scalar(@{$vmatrix[$i]});
	for (my $j = 0; $j < $sv; ++$j) {
		if ($vmatrix[$i][$j]->getX() != -1) {
			$img->moveTo($vmatrix[$i][$j]->getX(), $vmatrix[$i][$j]->getY());
			$img->lineTo($vmatrix[$i][$j]->getX(), $vmatrix[$i][$j]->getY() + $EDGE_LONG);
		}
	}

	my $sh = scalar(@{$hmatrix[$i]});
	for (my $j = 0; $j < $sh; ++$j) {
		if ($hmatrix[$i][$j]->getX() != -1) {
			$img->moveTo($hmatrix[$i][$j]->getX(), $hmatrix[$i][$j]->getY());
			$img->lineTo($hmatrix[$i][$j]->getX() + $EDGE_LONG, $hmatrix[$i][$j]->getY());
		}
	}
}

# draw start, end
$img->fgcolor('white');
$img->bgcolor('red');
$img->rectangle(2, 2, $EDGE_LONG - 2, $EDGE_LONG - 2);
my $corner = $IMAGE_WIDTH - $EDGE_LONG;
$img->bgcolor('green');
$img->rectangle($corner + 2, $corner + 2, $corner + $EDGE_LONG - 2, $corner + $EDGE_LONG - 2);
	

# convert into png data
open my $out, '>', 'maze.png' or die;
binmode $out;
print $out $img->png;
