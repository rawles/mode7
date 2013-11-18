package mode7::config;
our $VERSION = '1.00';
use base 'Exporter';
our @EXPORT = qw(config_get);
use warnings;
use strict;

# This is really just a home for all the configuration
# lying around the code.

my %config = (
	# Viewdata platforms and BBC microcomputers handle double height
	# a little differently.
	# set "emulation" to "viewdata" to elide line 2 of a double
	#                 height pair and use the first line only.
	#                 to "micro" to use the character-generation 
	#                 approach of displaying each part independently.
	emulation => 'viewdata',

	# Do we allow black foreground text? Allowing this would be 
	# heresy. 1=allow, 0=deny.
	allow_80 => 0,

	# Do we allow black backgrounds with the code 0x90? You should
	# really use 0x9c to revert to a black background. 1=allow,
	# 0=deny.
	allow_90 => 1,

	# The number of rows in a frame. The BBC micro uses 25, whereas
	# teletext and viewdata use 24.
	rows => 24,
	);

sub config_get { 
	my $name = shift; # name of the config item
	if ( ! ( defined $config{$name} ) ) { 
		die "Non-existent configuration item \"$name\"."; 
		}
	return $config{$name};
	}

1;
