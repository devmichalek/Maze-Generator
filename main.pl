#Includes.
use strict;
use warnings;
use GD::Simple;
use FindBin;
use lib "$FindBin::Bin/lib";
use Point;
use Wall;

#Resolution and settings
my $EDGE_LONG = 20;
my $EDGE_MULTIPLIER = 21;
my $IMAGE_WIDTH = ($EDGE_LONG * $EDGE_MULTIPLIER) + 1;
my $IMAGE_HEIGHT = $IMAGE_WIDTH;

#Generate grid.
my @cells;		#Cells with unique ids.
my @edges;		#Not used walls.
my @vmatrix;	#Vertical walls.
my @hmatrix;	#Horizontal walls.
my $idc = 0;	#Counter of id.
for (my $i = 0; $i < $IMAGE_WIDTH /  $EDGE_LONG; ++$i) {
	for (my $j = 0; $j < $IMAGE_HEIGHT /  $EDGE_LONG; ++$j) {
		$vmatrix[$i][$j] = Point->new(x => $i * $EDGE_LONG, y => $j * $EDGE_LONG);
		$hmatrix[$i][$j] = Point->new(x => $i * $EDGE_LONG, y => $j * $EDGE_LONG);
		$edges[$i][$j][0] = Wall->new(x => $i, y => $j, type => 0); #0 represents the vertical wall.
		$edges[$i][$j][1] = Wall->new(x => $i, y => $j, type => 1); #1 represents the hotizontal wall.
		$cells[$i][$j] = $idc++; #Ascribe id to the cell.
	}
}

#Remove walls.
while (1) {
	#Check how many ids are there.
	#If more than one, continue.
	my $idxl = scalar(@cells);
	my $idyl = scalar(@{$cells[0]});
	my $closeLoop = 1;
	for (my $i = 0; $i < $idxl; ++$i) {
		for (my $j = 0; $j < $idyl; ++$j) {
			if ($cells[$i][$j] != $cells[0][0]) {
				$closeLoop = 0;
				last;
			}
		}
	}

	while (!$closeLoop) {
		my $closeInnerLoop = 1;

		#Rand x.
		my $xl = scalar(@edges);
		my $i = int(rand($xl));
		#If there are only 2 rows (top and bot).
		if ($xl == 2) {
			$closeLoop = 1;
			last;
		}

		#Rand y.
		my $yl = scalar(@{$edges[$i]});
		my $j = int(rand($yl));

		#Rand type.
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
			$it = int(rand($tl)); #Rand which one.
		}
		my $t = $edges[$i][$j][$it]->getType(); # 0 - vertical / 1 - horizontal wall

		#Set proper x and y, new id and old id.
		my $bx = $edges[$i][$j][$it]->getX();
		my $by = $edges[$i][$j][$it]->getY();
		my $newID = $cells[$bx][$by];
		my $oldID = -1;

		if ($t == 0) {
			# $by stays the same, and <- $bx -> check cell(left, right)
			if ($bx == 0 || $bx == ($idxl-1) || ($cells[$bx-1][$by] == $cells[$bx][$by])) {
				$closeInnerLoop = 0; #We have the same id in these cells, repeat loop.
			} else {
				$oldID = $cells[$bx-1][$by];
				#print("Removing wall(v) \$bx=$bx \$by=$by\n");
				$vmatrix[$bx][$by] = Point->new(x => -1, y => -1);
			}
		} else {
			# $bx stays the same, and <- $by -> check cell(top, bot)
			if ($by == 0 || $by == ($idyl-1) || ($cells[$bx][$by-1] == $cells[$bx][$by])) {
				$closeInnerLoop = 0; #We have the same id in these cells, repeat loop.
			} else {
				$oldID = $cells[$bx][$by-1];
				$hmatrix[$bx][$by] = Point->new(x => -1, y => -1);
			}
		}

		#There is only one type of wall (v/h).
		if ($tl == 1) {
			#Delete whole column.
			if ($yl == 2) {
				splice(@edges, $i, 1);
			}
			#Delete last wall.
			else {
				splice(@{$edges[$i]}, $j, 1);
			}
		}

		#There are two walls (v and h).
		else {
			$edges[$i][$j][$t]->setType(-1); 
		}

		if ($closeInnerLoop) {
			# Set new id to old ids.
			for (my $k = 0; $k < $idxl; ++$k) {
				for (my $l = 0; $l < $idyl; ++$l) {
					if ($cells[$k][$l] == $oldID) {
						$cells[$k][$l] = $newID;
					}
				}
			}
			last; #Break inner loop.
		}
	}

	if ($closeLoop) {
		last;
	}
}


# Draw walls in image.
my $img = GD::Simple->new($IMAGE_WIDTH, $IMAGE_HEIGHT);
$img->fgcolor('black');
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

# Draw start and end.
$img->fgcolor('white');
$img->bgcolor('red');
$img->rectangle(2, 2, $EDGE_LONG - 2, $EDGE_LONG - 2);
my $corner = $IMAGE_WIDTH - $EDGE_LONG;
$img->bgcolor('green');
$img->rectangle($corner + 2, $corner + 2, $corner + $EDGE_LONG - 2, $corner + $EDGE_LONG - 2);
	
# Convert into png data.
open my $out, '>', 'maze.png' or die;
binmode $out;
print $out $img->png;
