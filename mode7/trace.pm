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

	my @flcodes = ("St", "Fl");
	my @cocodes = ("   ", "Con");

	my %control = ();
	$control{128} = "Kt";
	$control{129} = "Rt";
	$control{130} = "Gt";
	$control{131} = "Yt";
	$control{132} = "Bt";
	$control{133} = "Mt";
	$control{134} = "Ct";
	$control{135} = "Wt";
	$control{136} = "Fla";
	$control{137} = "Ste";
	$control{138} = "SBx";
	$control{139} = "EBx";
	$control{140} = "Nor";
	$control{141} = "Dbl";
	$control{142} = "SO";
	$control{143} = "SI";
	$control{144} = "Kg";
	$control{145} = "Rg";
	$control{146} = "Gg";
	$control{147} = "Yg";
	$control{148} = "Bg";
	$control{149} = "Mg";
	$control{150} = "Cg";
	$control{151} = "Wg";
	$control{152} = "Con";
	$control{153} = "Sol";
	$control{154} = "Sep";
	$control{156} = "BBg";
	$control{157} = "NBg";
	$control{158} = "Hol";
	$control{159} = "Rel";

	for ( my $y = 0; $y < 216; $y++ ) { 
		for ( my $x = 0; $x < 240; $x++ ) { 
			# We use the version in which the flash characters are on
			my $c = $colcodes[$screen->{gfx}[1][$x][$y]];
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
				my $ocharcode = $charcode;
				my $echarcode = $charcode; # effective char code
				$charcode = sprintf("%X", $charcode);
				my $char = "";
				if ( $echarcode > 128 ) { $echarcode -= 128; } 
				if ( $echarcode >= 32 && $echarcode < 127 ) { 
					$char = chr($echarcode);
					}
				if ( defined $control{$ocharcode} ) { 
					$char = $control{$ocharcode};
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
			$trace .= "\n";
			for ( my $tx = 0; $tx < 40; $tx++ ) { 
				my $flacon = "";
				$flacon .= $flcodes[$screen->{fltrib}[$tx][$ty]];
				$flacon .= " ";
				$flacon .= $cocodes[$screen->{cotrib}[$tx][$ty]];
				$trace .= $flacon;
				if ( $tx < 39 ) { $trace .= " "; } 
				}
			$trace .= "\n\n";
			} 
		}


	return $trace;
	}

1;
