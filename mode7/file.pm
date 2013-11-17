package mode7::file;
our $VERSION = '1.00';
use base 'Exporter';
our @EXPORT = qw(read_frame read_fromdata);
use warnings;
use strict;
use mode7::screen;

sub read_frame { 
	my $screen = shift;
	my $fileName = shift;
	for ( my $y = 0; $y < 25; $y++ ) { 
		for ( my $x = 0; $x < 40; $x++ ) { 
			$screen->{frame}[$x][$y] = " ";
			}
		}
	open(F, $fileName);
	my $lineno = 0;
	while(<F>) { 
		chomp; my $x = $_;
		my $ll = 40; 
		if ( length($x) < $ll ) { $ll = length($x); } 
		for ( my $i = 0; $i < $ll; $i++ ) { 
			$screen->{frame}[$i][$lineno] = substr($x, $i, 1);
			}
		$lineno++;
		}
	close(F);
	}

# Returns the offset up to which we read, or -1 if at the end of the stream.
sub read_fromdata {
	my $screen = shift;
	my $data = shift;

	my $vdu31 = 0; my $vdu31x = 0; my $vdu31y = 0;

	# Go through character-by-character
	for ( my $i = 0; $i < length($data); $i++ ) { 
		my $c = substr($data, $i, 1);
		my $cc = ord($c);
		my $cx = $screen->{cursor}[0];
		my $cy = $screen->{cursor}[1];
		# TODO: delegate into screen.pm
		if ( $vdu31 == 2 ) {
			$vdu31y = $cc;
			if ( $vdu31x > 39 ) { $vdu31x = 39; } 
			if ( $vdu31y > 24 ) { $vdu31x = 24; } 
			screen_set_cursor($screen, $vdu31x, $vdu31y);
			$vdu31 = 0;
			next;
			}
		if ( $vdu31 == 1 ) {
			$vdu31x = $cc; $vdu31 = 2; next;
			next; 
			}

		# VDU31 is now 0 (we arent in any state)

		if ( $cc == 0 ) { # our special frame delimiter
			if ( $i >= length($data) - 1 ) { return -1; } 
			return $i + 1;
			}
		if ( $cc == 8 ) { # move the cursor back one character
			$cx--; if ( $cx < 0 ) { $cx = 39; $cy--; }
			if ( $cy < 0 ) { $cy = 0; } 
			$screen->{cursor}[0] = $cx;
			$screen->{cursor}[1] = $cy;
			next;
			}
		if ( $cc == 9 ) { # move the cursor forward one character
			$cx++; if ( $cx > 39 ) { $cy++; $cx = 0; }
			if ( $cy > 24 ) { $cy = 24; } 
			$screen->{cursor}[0] = $cx;
			$screen->{cursor}[1] = $cy;
			next;
			}
		if ( $cc == 10 ) { # move the cursor down one line
			$cy++; if ( $cy > 24 ) { $cy = 24; }
			$screen->{cursor}[1] = $cy;
			next;
			}
		if ( $cc == 11 ) { # move the cursor up one line
			$cy--; if ( $cy < 0 ) { $cy = 0; }
			$screen->{cursor}[1] = $cy;
			next;
			}
		if ( $cc == 12 ) { # clear screen
			screen_clear($screen);
			next;
			}
		if ( $cc == 13 ) { # move the cursor to the start of the current line 
			$screen->{cursor}[0] = 0;
			next;
			}
		if ( $cc == 31 ) {
			$vdu31 = 1; next; } 

		screen_writechar($screen, $c);
		}
	return -1;

	}


1;
