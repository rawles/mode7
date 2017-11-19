package mode7::output;
our $VERSION = '1.00';
use base 'Exporter';
our @EXPORT = qw(output_large_png output_small_png output_large_gif output_small_gif output_text);
use warnings;
use strict;

# Bug: causes errors on 121 and 146 when last row is top of a double height pair.

use mode7::screen;
use mode7::config;

sub output_large_png {
	my $screen = shift;
	my $phase = shift;
	my $finalName = shift;
	my $fileName = "$finalName.tmp";
	my $rows = config_get('rows');

	open(F, ">$fileName");
	binmode F, ":utf8";
	print F "P3\n# frame\n480 ".($rows*20)."\n1\n";
	for ( my $y = 0; $y < $rows*10; $y += 0.5 ) { 
		for ( my $x = 0; $x < 240; $x += 0.5 ) { 

			my $gx = int($x);
			my $gy = int($y);

			my $pc = $screen->{gfx}[$phase][$gx][$gy];
			my $rc = $pc & 1;
			my $gc = $pc & 2;
			my $bc = $pc & 4;
			if ( $rc > 0 ) { $rc = 1; } 
			if ( $gc > 0 ) { $gc = 1; }
			if ( $bc > 0 ) { $bc = 1; }

			# sub-block in the large output
			my $sbx = (2*$x) % 2;
			my $sby = (2*$y) % 2;

			if ( ! ( defined $sbx ) ) { print "!!! not defined.\n"; } 

			# character position in the grid
			my $cx = int($x/6);
			my $cy = int($y/10);

			# sub-block for double height
			# relative to the part of the double-height pair we're in.
			my $sbhy = 0;
			if ( $screen->{dbtrib}[$cx][$cy] == 1 ) { 
				$sbhy = ( ( $y % 10 ) * 2 ) % 4;
				}

			# pixel in char
			my $px = ( int($x) % 6 );
			my $py = ( int($y) % 10 );

			# character code here
			my $cc = ord($screen->{frame}[$cx][$cy]);

			my $cc1 = $cc; if ( $cc1 > 128 ) { $cc1 -= 128; } 
			$cc1 = chr($cc1);

			# check upper left pixels for overwriting
			if (	$sbx == 0 

			&&	( ( $sby == 0 && $screen->{dbtrib}[$cx][$cy] != 1 )
				|| ( ( $sbhy==0 || $sbhy==1 ) && $screen->{dbtrib}[$cx][$cy] == 1 ) )

				# If this is line 2 of a double we should allow it to look into 
				# its other half, ie we smooth across the join between two double
				# height cells.
			&&	$px > 0 && ( ( $screen->{dblpart}[$cy] == 2 && $y > 1 ) || $py > 0 )

			&&	(  ( $screen->{gftrib}[$cx][$cy] == 0 ) 
				|| ( $screen->{gftrib}[$cx][$cy] == 2 )
				|| ( output_tigm($cc) == 1 ) ) 
			&& 	$screen->{gfx}[$phase][$gx][$gy] == $screen->{bgtrib}[$cx][$cy]
			&& 	$screen->{gfx}[$phase][$gx-1][$gy] == $screen->{fgtrib}[$cx][$cy]
			&& 	$screen->{gfx}[$phase][$gx][$gy-1] == $screen->{fgtrib}[$cx][$cy]
			&& 	$screen->{gfx}[$phase][$gx-1][$gy-1] == $screen->{bgtrib}[$cx][$cy]
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

			&&	$px < 5 && ( ( $screen->{dblpart}[$cy] == 2 && $y > 1 ) || $py > 0 )

			&&	(  ( $screen->{gftrib}[$cx][$cy] == 0 )
				|| ( $screen->{gftrib}[$cx][$cy] == 2 )
				|| ( output_tigm($cc) == 1 ) ) 
			&& 	$screen->{gfx}[$phase][$gx][$gy] == $screen->{bgtrib}[$cx][$cy]
			&& 	$screen->{gfx}[$phase][$gx+1][$gy] == $screen->{fgtrib}[$cx][$cy]
			&& 	$screen->{gfx}[$phase][$gx][$gy-1] == $screen->{fgtrib}[$cx][$cy]
			&& 	$screen->{gfx}[$phase][$gx+1][$gy-1] == $screen->{bgtrib}[$cx][$cy]
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

			&&	$px > 0 && ( ( $screen->{dblpart}[$cy] == 1 && $y < ($rows*10)-1 ) || $py < 9 )

			&&	(  ( $screen->{gftrib}[$cx][$cy] == 0 )
				|| ( $screen->{gftrib}[$cx][$cy] == 2 )
				|| ( output_tigm($cc) == 1 ) )
			&& 	$screen->{gfx}[$phase][$gx][$gy] == $screen->{bgtrib}[$cx][$cy]
			&& 	$screen->{gfx}[$phase][$gx-1][$gy] == $screen->{fgtrib}[$cx][$cy]
			&& 	$screen->{gfx}[$phase][$gx][$gy+1] == $screen->{fgtrib}[$cx][$cy]
			&& 	$screen->{gfx}[$phase][$gx-1][$gy+1] == $screen->{bgtrib}[$cx][$cy]
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

			&&	$px < 5 && ( ( $screen->{dblpart}[$cy] == 1 && $y < ($rows*10)-1 ) || $py < 9 )

			&&	(  ( $screen->{gftrib}[$cx][$cy] == 0 )
				|| ( $screen->{gftrib}[$cx][$cy] == 2 )
				|| ( output_tigm($cc) == 1 ) )
			&& 	$screen->{gfx}[$phase][$gx][$gy] == $screen->{bgtrib}[$cx][$cy]
			&& 	$screen->{gfx}[$phase][$gx+1][$gy] == $screen->{fgtrib}[$cx][$cy]
			&& 	$screen->{gfx}[$phase][$gx][$gy+1] == $screen->{fgtrib}[$cx][$cy]
			&& 	$screen->{gfx}[$phase][$gx+1][$gy+1] == $screen->{bgtrib}[$cx][$cy]
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

sub output_small_png {
	# No smoothing is needed, so we can make this a lot simpler.

	my $screen = shift;
	my $phase = shift;
	my $finalName = shift;
	my $fileName = "$finalName.tmp";
	my $rows = config_get('rows');

	open(F, ">$fileName");
	binmode F, ":utf8";
	print F "P3\n# frame\n240 ".($rows*10)."\n1\n";
	for ( my $y = 0; $y < $rows*10; $y++ ) { 
		for ( my $x = 0; $x < 240; $x++ ) { 
			my $rc = $screen->{gfx}[$phase][$x][$y] & 1; if ( $rc > 0 ) { $rc = 1; } 
			my $gc = $screen->{gfx}[$phase][$x][$y] & 2; if ( $gc > 0 ) { $gc = 1; }
			my $bc = $screen->{gfx}[$phase][$x][$y] & 4; if ( $bc > 0 ) { $bc = 1; }
			print F "$rc $gc $bc\n";
			}
		print F "\n";
		}
	close(F);

	system("convert -define png:color-type=2 $fileName $finalName");
	unlink($fileName);
	unlink($fileName);
	}

# This is a helper subroutine which will create a GIF. The advantage 
# of this is that (if necessary) it will be an animated GIF, otherwise
# a static GIF.
# I know that GIFs are bad. I'll try to figure out how to make ImageMagick
# do an animated PNG.
sub output_large_gif { # Will flash if needed
	my $screen = shift;
	my $finalName = shift;

	if ( screen_flash_invariant($screen) == 1 ) { 

		output_large_png($screen, 1, "/tmp/on.png");
		system("convert /tmp/on.png $finalName");
		unlink("/tmp/on.png");

		} else { # graphically different, so need to flash

		output_large_png($screen, 1, "/tmp/on.png");
		output_large_png($screen, 0, "/tmp/off.png");
		system("convert -delay 100 /tmp/on.png -delay 33 /tmp/off.png -loop 0 $finalName");
		unlink("/tmp/on.png");
		unlink("/tmp/off.png");
		}
	}

# And the same helper function for small graphics.
sub output_small_gif { # Will flash if needed
	my $screen = shift;
	my $finalName = shift;

	if ( screen_flash_invariant($screen) == 1 ) { 

		output_small_png($screen, 1, "/tmp/on.png");
		system("convert /tmp/on.png $finalName");
		unlink("/tmp/on.png");

		} else { # graphically different, so need to flash

		output_small_png($screen, 1, "/tmp/on.png");
		output_small_png($screen, 0, "/tmp/off.png");
		system("convert -delay 100 /tmp/on.png -delay 33 /tmp/off.png -loop 0 $finalName");
		unlink("/tmp/on.png");
		unlink("/tmp/off.png");
		}
	}

sub output_tigm { # text in graphics mode
	my $cc = shift;
	if ( $cc >= 64 && $cc < 96 ) { return 1; } 
	if ( $cc >= 192 && $cc < 224 ) { return 1; } 
	return 0;
	}

# Outputs the frame as text in a single line.
sub output_text {
	my $screen = shift;
	my $text = "";
	my $rows = config_get('rows');

	for ( my $cy = 1; $cy < $rows; $cy++ ) { 
		for ( my $cx = 0; $cx < 40; $cx++ ) { 
			if ( ( $screen->{gftrib}[$cx][$cy] % 2 ) == 1 ) { $text .= " "; next; } 
			my $ch = $screen->{frame}[$cx][$cy];
			if ( ord($ch) > 127 ) { $ch = chr(ord($ch)-128); } 
			if ( ord($ch) < 32 || ord($ch) > 126 ) { $ch = " "; } 
			$text .= $ch;
			}
		$text .= " ";
		}

	$text =~ s/`+/ /g;
	$text =~ s/~+/ /g;
	$text =~ s/\s+/ /g;
	$text =~ s/^\s+//;
	$text =~ s/\s+$//;
	return $text;
	}

1;
