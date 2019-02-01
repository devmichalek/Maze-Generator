![maze](https://user-images.githubusercontent.com/19840443/52094116-27028000-25be-11e9-9168-0194ab81a40e.gif)
![maze](https://user-images.githubusercontent.com/19840443/52094375-23232d80-25bf-11e9-8e51-2c23a26025d3.gif)
![1](https://user-images.githubusercontent.com/19840443/52095124-2835ac00-25c2-11e9-8541-df0e6c3560db.gif)
![2](https://user-images.githubusercontent.com/19840443/52095126-2835ac00-25c2-11e9-93c6-73663599d1d6.gif)
![3](https://user-images.githubusercontent.com/19840443/52113701-58a13880-260a-11e9-891e-7be1788f26a9.gif)
![4](https://user-images.githubusercontent.com/19840443/52113458-9fdaf980-2609-11e9-9460-be969e6e5f5b.gif)

## Maze Generator Algorithm
Kruskal's algorithm creates a minimum spanning tree from a weighted graph. Implementing algorithm is straightforward, but for best results you need to find a very efficient way to join sets. Since we are dealing with scripting language creating a minimum spanning tree by building the segments of the tree and then combining them is pretty hard to make. Here is the **pseudo algorithm** that takes three steps to accomplish:
1. Label each cell with a unique id.
2. Select an edge from the grid that hasn’t already been selected.<br>
  2.1 If the cells on either side of the edge have different ids, then remove the edge, and merge the cells. They now have the same id.<br>
  2.2 Else pick a new edge.
3. Repeat step 2. until all edges have been selected or there is only one id.

To make it as simple as possible in Perl you don't need to have a tree structure but still be very efficient and keep good memory usage rate. First you need a way to represent a **point** and the **wall**.
```perl
package Point;
use strict;
sub new {
    my ($class, %args) = @_;
    my $self = bless {}, $class;

    $self->setX($args{x});
    $self->setY($args{y});
    return $self;
}
```
```perl
package Wall;
use strict;
sub new {
    my ($class, %args) = @_;
    my $self = bless {}, $class;

    $self->setX($args{x});
    $self->setY($args{y});
    $self->setType($args{type});
    return $self;
}
```
These two packages contain functions like *getX()*, *getY()*, *setX()*, *setY()* and the wall (which is just a point with type) is different, by type we recognize if it is a vertical or horizontal wall which later would be differentiate by *getType()* and *setType()*. Right now we have two 2D arrays one contains points for vertical walls and the second for horizontal walls these two 2D arrays are represent by a point. We need an efficient way to know which walls were not used. For this purpose we have 3D array represent by a wall. Further we will simply remove items from this array. Lastly we need to have a cells a 2D array of unique ids. So far so good, now we can generate the "grid".
```perl
#Generate grid.
my @cells; #Cells with unique ids.
my @edges; #Not used walls.
my @vmatrix; #Vertical walls.
my @hmatrix; #Horizontal walls.
my $idc = 0; #Counter of id.
for (my $i = 0; $i < $IMAGE_WIDTH /  $EDGE_LONG; ++$i) {
	for (my $j = 0; $j < $IMAGE_HEIGHT /  $EDGE_LONG; ++$j) {
		$vmatrix[$i][$j] = Point->new(x => $i * $EDGE_LONG, y => $j * $EDGE_LONG);
		$hmatrix[$i][$j] = Point->new(x => $i * $EDGE_LONG, y => $j * $EDGE_LONG);
		$edges[$i][$j][0] = Wall->new(x => $i, y => $j, type => 0); #0 represents the vertical wall.
		$edges[$i][$j][1] = Wall->new(x => $i, y => $j, type => 1); #1 represents the hotizontal wall.
		$cells[$i][$j] = $idc++; #Ascribe id to the cell.
	}
}
```
With this prepared data we start removing walls and do what algorithm says. At the beggining of the most outside loop we check if there is more than one id if not we break he loop.
```perl
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
```
Now we rand i, j and t, which later gives as x, y and type (remember that i, j and t are only indexes in 3D array)
```perl
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
```
Finally we have x, y and type. If type ($t) was 0 (vertical wall) we check if x is 0 if yes it's the left border which we don't want to remove because we want to keep a frame of our maze, then we check ids of the cell on the left, if they are the same we remove this vertical wall from our "not used walls" array, if the ids are not the same we remove the wall from $vmatrix and also from "not used walls" array, we repeat this process until there are no more "not used walls". At the end if the cells had different ids we need to ascribe old ids to new ids, that's it! We do the same with horizontal wall ($hmatrix) but now we check if y is 0 (to keep the top border which makes frame), check ids of top cell ...
```perl

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
```

## Conclusion
Without a doubt this is a really simple algorithm to make without trees idea included. What we did was pretty expensive (looking from trees perspective), we had to iterate on every cell in case of new id and iterate through "not used walls" array every time to get a new wall. Using trees to represent the sets is much faster, allowing you to merge sets efficiently simply by adding one tree as a subtree of the other. Testing whether two cells share a set is done by comparing the roots of their corresponding trees. I wouldn't recommend to use array's idea but rather to try it and feel it.
