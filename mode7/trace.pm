package mode7::trace;
our $VERSION = '1.00';
use base 'Exporter';
our @EXPORT = qw(trace_screen);
use warnings;
use strict;

sub trace_screen { 

	my $screen = shift;
	my $trace = ""; 

	my @colcodes = ("K", "R", "G", "Y", "B", "M", "C", "W");
	my @gfxcodes = ("Txt", "Sol", "TxS", "Sep");

	my @dblcodes = ("N", "D", "R"); # normal, double, reset
	my @partcodes = ("N", "T", "B"); # none, top half, bottom half
	my @hgsepcode = ("c", "s"); # continous, separated

	for ( my $y = 0; $y < 216; $y++ ) { 
		for ( my $x = 0; $x < 240; $x++ ) { 
			my $c = $colcodes[$screen->{gfx}[$x][$y]];
			if ( $c eq "K" ) { $c = "."; } 
			$trace .= $c;
			if ( $x % 6 == 5 && $x < 239 ) { $trace .= " "; } 
			}
		$trace .= "\n";
		if ( $y % 9 == 8 ) {
			my $ty = int($y/9);
			for ( my $tx = 0; $tx < 40; $tx++ ) { 
				$trace .= substr("      $tx,$ty", -6);
				if ( $tx < 39 ) { $trace .= " "; } 
				}
			$trace .= "\n";
			for ( my $tx = 0; $tx < 40; $tx++ ) { 
				my $charcode = ord($screen->{frame}[$tx][$ty]);
				my $echarcode = $charcode; # effective char code
				$charcode = sprintf("0x%X", $charcode);
				my $char = "";
				if ( $echarcode > 128 ) { $echarcode -= 128; } 
				if ( $echarcode >= 32 && $echarcode < 127 ) { 
					$char = chr($echarcode);
					}
				$trace .= substr("      $char $charcode", -6);
				if ( $tx < 39 ) { $trace .= " "; } 
				}
			$trace .= "\n";
			for ( my $tx = 0; $tx < 40; $tx++ ) { 
				my $colgfx = "";
				$colgfx .= uc($colcodes[$screen->{fgtrib}[$tx][$ty]]);
				$colgfx .= lc($colcodes[$screen->{bgtrib}[$tx][$ty]]);
				$colgfx .= " ";
				$colgfx .= $gfxcodes[$screen->{gftrib}[$tx][$ty]];
				$trace .= $colgfx;
				if ( $tx < 39 ) { $trace .= " "; } 
				}
			$trace .= "\n";
			for ( my $tx = 0; $tx < 40; $tx++ ) { 
				my $other = "";
				$other .= $dblcodes[$screen->{dbtrib}[$tx][$ty]];
				$other .= $partcodes[$screen->{dblpart}[$ty]];
				$other .= " ";
				my $heldcode = "???";
				if ( $screen->{hgtrib}[$tx][$ty] == 0 ) { 
					$heldcode = "nhg"; 
					}
				if ( $screen->{hgtrib}[$tx][$ty] == 1 ) { 
					$heldcode = sprintf("%X", $screen->{hgchar}[$tx][$ty]);
					$heldcode .= $hgsepcode[$screen->{hgcharsep}[$tx][$ty]];
					}
				$other .= $heldcode;
				$trace .= $other;
				if ( $tx < 39 ) { $trace .= " "; } 
				}
			$trace .= "\n\n";
			} 
		}


	return $trace;
	}

1;
