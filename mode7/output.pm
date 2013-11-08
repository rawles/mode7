package mode7::output;
our $VERSION = '1.00';
use base 'Exporter';
our @EXPORT = qw(output_large output_small);
use warnings;
use strict;

sub output_large {
	my $screen = shift;
	my $finalName = shift;
	my $fileName = "$finalName.tmp";

	open(F, ">$fileName");
	binmode F, ":utf8";
	print F "P3\n# frame\n480 432\n1\n";
	for ( my $y = 0; $y < 216; $y += 0.5 ) { 
		for ( my $x = 0; $x < 240; $x += 0.5 ) { 
			my $pc = $screen->{gfx}[int($x)][int($y)];
			my $rc = $pc & 1;
			my $gc = $pc & 2;
			my $bc = $pc & 4;
			if ( $rc > 0 ) { $rc = 1; } 
			if ( $gc > 0 ) { $gc = 1; }
			if ( $bc > 0 ) { $bc = 1; }

			# sub-block
			my $sbx = (2*$x) % 2;
			my $sby = (2*$y) % 2;

			# sub-block for double height
			my $sbhy = (2*$y) % 4;

			# character position in the grid
			my $cx = int($x/6);
			my $cy = int($y/9);

			# pixel in char
			my $px = ( int($x) % 6 );
			my $py = ( int($y) % 9 );

			# character code here
			my $cc = ord($screen->{frame}[$cx][$cy]);

			my $cc1 = $cc; if ( $cc1 > 128 ) { $cc1 -= 128; } 
			$cc1 = chr($cc1);

			# check upper left pixels for overwriting
			if (	$sbx == 0 

			&&	( ( $sby == 0 && $screen->{dbtrib}[$cx][$cy] != 1 )
				|| ( ( $sbhy==0 || $sbhy==1 ) && $screen->{dbtrib}[$cx][$cy] == 1 ) )

			&&	$px > 0 
			&&	$py > 0 

			&&	( $screen->{gftrib}[$cx][$cy] == 0
				|| $screen->{gftrib}[$cx][$cy] == 2
				|| output_tigm($cc) == 1 ) 
			&& 	$screen->{gfx}[$x][$y] == $screen->{bgtrib}[$cx][$cy]
			&& 	$screen->{gfx}[$x-1][$y] == $screen->{fgtrib}[$cx][$cy]
			&& 	$screen->{gfx}[$x][$y-1] == $screen->{fgtrib}[$cx][$cy]
			&& 	$screen->{gfx}[$x-1][$y-1] == $screen->{bgtrib}[$cx][$cy]
				) {

				$rc = $screen->{fgtrib}[$cx][$cy] & 1; 
				$gc = $screen->{fgtrib}[$cx][$cy] & 2; 
				$bc = $screen->{fgtrib}[$cx][$cy] & 4; 
				if ( $rc > 0 ) { $rc = 1; } 
				if ( $gc > 0 ) { $gc = 1; }
				if ( $bc > 0 ) { $bc = 1; }
				}

			# upper right
			if (	$sbx == 1 

			&&	( ( $sby == 0 && $screen->{dbtrib}[$cx][$cy] != 1 )
				|| ( ( $sbhy==0 || $sbhy==1 ) && $screen->{dbtrib}[$cx][$cy] == 1 ) )

			&&	$px < 5 
			&&	$py > 0 
			&&	(  $screen->{gftrib}[$cx][$cy] == 0
				|| $screen->{gftrib}[$cx][$cy] == 2
				|| output_tigm($cc) == 1 ) 
			&& 	$screen->{gfx}[$x][$y] == $screen->{bgtrib}[$cx][$cy]
			&& 	$screen->{gfx}[$x+1][$y] == $screen->{fgtrib}[$cx][$cy]
			&& 	$screen->{gfx}[$x][$y-1] == $screen->{fgtrib}[$cx][$cy]
			&& 	$screen->{gfx}[$x+1][$y-1] == $screen->{bgtrib}[$cx][$cy]
				) {
				$rc = $screen->{fgtrib}[$cx][$cy] & 1; 
				$gc = $screen->{fgtrib}[$cx][$cy] & 2; 
				$bc = $screen->{fgtrib}[$cx][$cy] & 4; 
				if ( $rc > 0 ) { $rc = 1; } 
				if ( $gc > 0 ) { $gc = 1; }
				if ( $bc > 0 ) { $bc = 1; }
				}

			# lower left
			if (	$sbx == 0 

			&&	( ( $sby == 1 && $screen->{dbtrib}[$cx][$cy] != 1 )
				|| ( ( $sbhy==2 || $sbhy==3 ) && $screen->{dbtrib}[$cx][$cy] == 1 ) )

			&&	$px > 0 
			&&	$py < 8 
			&&	( $screen->{gftrib}[$cx][$cy] == 0
				|| $screen->{gftrib}[$cx][$cy] == 2
				|| output_tigm($cc) == 1 ) 
			&& 	$screen->{gfx}[$x][$y] == $screen->{bgtrib}[$cx][$cy]
			&& 	$screen->{gfx}[$x-1][$y] == $screen->{fgtrib}[$cx][$cy]
			&& 	$screen->{gfx}[$x][$y+1] == $screen->{fgtrib}[$cx][$cy]
			&& 	$screen->{gfx}[$x-1][$y+1] == $screen->{bgtrib}[$cx][$cy]
				) {
				$rc = $screen->{fgtrib}[$cx][$cy] & 1; 
				$gc = $screen->{fgtrib}[$cx][$cy] & 2; 
				$bc = $screen->{fgtrib}[$cx][$cy] & 4; 
				if ( $rc > 0 ) { $rc = 1; } 
				if ( $gc > 0 ) { $gc = 1; }
				if ( $bc > 0 ) { $bc = 1; }
				}

			# lower right
			if (	$sbx == 1 

			&&	( ( $sby == 1 && $screen->{dbtrib}[$cx][$cy] != 1 )
				|| ( ( $sbhy==2 || $sbhy==3 ) && $screen->{dbtrib}[$cx][$cy] == 1 ) )

			&&	$px < 5 
			&&	$py < 8 
			&&	( $screen->{gftrib}[$cx][$cy] == 0
				|| $screen->{gftrib}[$cx][$cy] == 2
				|| output_tigm($cc) == 1 ) 
			&& 	$screen->{gfx}[$x][$y] == $screen->{bgtrib}[$cx][$cy]
			&& 	$screen->{gfx}[$x+1][$y] == $screen->{fgtrib}[$cx][$cy]
			&& 	$screen->{gfx}[$x][$y+1] == $screen->{fgtrib}[$cx][$cy]
			&& 	$screen->{gfx}[$x+1][$y+1] == $screen->{bgtrib}[$cx][$cy]
				) {
				$rc = $screen->{fgtrib}[$cx][$cy] & 1; 
				$gc = $screen->{fgtrib}[$cx][$cy] & 2; 
				$bc = $screen->{fgtrib}[$cx][$cy] & 4; 
				if ( $rc > 0 ) { $rc = 1; } 
				if ( $gc > 0 ) { $gc = 1; }
				if ( $bc > 0 ) { $bc = 1; }

				}

			print F "$rc $gc $bc\n";
			}
		print F "\n";
		}
	close(F);

	system("convert -define png:color-type=2 $fileName $finalName");
	unlink($fileName);
	}

sub output_small {
	# No smoothing is needed, so we can make this a lot simpler.

	my $screen = shift;
	my $finalName = shift;
	my $fileName = "$finalName.tmp";

	open(F, ">$fileName");
	binmode F, ":utf8";
	print F "P3\n# frame\n240 216\n1\n";
	for ( my $y = 0; $y < 216; $y++ ) { 
		for ( my $x = 0; $x < 240; $x++ ) { 
			my $rc = $screen->{gfx}[$x][$y] & 1; if ( $rc > 0 ) { $rc = 1; } 
			my $gc = $screen->{gfx}[$x][$y] & 2; if ( $gc > 0 ) { $gc = 1; }
			my $bc = $screen->{gfx}[$x][$y] & 4; if ( $bc > 0 ) { $bc = 1; }
			print F "$rc $gc $bc\n";
			}
		print F "\n";
		}
	close(F);

	system("convert -define png:color-type=2 $fileName $finalName");
	unlink($fileName);
	unlink($fileName);
	}

sub output_tigm { # text in graphics mode
	my $cc = shift;
	if ( $cc >= 64 && $cc < 96 ) { return 1; } 
	if ( $cc >= 192 && $cc < 224 ) { return 1; } 
	return 0;
	}

1;
