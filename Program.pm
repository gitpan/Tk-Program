package Tk::Program;
#------------------------------------------------
# automagically updated versioning variables -- CVS modifies these!
#------------------------------------------------
our $Revision           = '$Revision: 1.1 $';
our $CheckinDate        = '$Date: 2003/06/04 17:14:35 $';
our $CheckinUser        = '$Author: xpix $';
# we need to clean these up right here
$Revision               =~ s/^\$\S+:\s*(.*?)\s*\$$/$1/sx;
$CheckinDate            =~ s/^\$\S+:\s*(.*?)\s*\$$/$1/sx;
$CheckinUser            =~ s/^\$\S+:\s*(.*?)\s*\$$/$1/sx;
#-------------------------------------------------
#-- package Tk::DBI::Tree -----------------------
#-------------------------------------------------

use vars qw($VERSION);
$VERSION = '0.01';

use base qw(Tk::MainWindow);
use strict;

use IO::File;
use Tk::Balloon;
use Tk::Getopt;
use Tk::Splashscreen; 
use Tk::Pod;

Construct Tk::Widget 'Program';

# ------------------------------------------
sub Populate {
# ------------------------------------------
	my ($obj, $args) = @_;

	$obj->{app} 		= delete $args->{'-app'} 	|| 'Program';
	$obj->{icon} 		= delete $args->{'-icon'} 	|| undef;
	$obj->{cfg} 		= delete $args->{'-cfg'} 	|| sprintf( '%s/.%s.cfg', ($ENV{HOME} ? $ENV{HOME} : $ENV{HOMEDRIVE}.$ENV{HOMEPATH}), $obj->{app} );
	$obj->{add_prefs} 	= delete $args->{'-add_prefs'};
	$obj->{logo} 		= delete $args->{'-logo'};
	$obj->{about} 		= delete $args->{'-about'};
	$obj->{help} 		= delete $args->{'-help'}	|| $0;

	$obj->SUPER::Populate($args);
	
	$obj->ConfigSpecs(
		-init_menu	=> ["METHOD", 	"init_menu", 	"Init_Menu", 	undef],
		-init_prefs	=> ["METHOD", 	"init_prefs", 	"Init_Prefs", 	undef],
		-init_main	=> ["METHOD", 	"init_main", 	"Init_Main", 	undef],
		-init_status	=> ["METHOD", 	"init_status", 	"Init_Status", 	undef],
		-add_status	=> ["METHOD", 	"add_status", 	"Add_Status", 	undef],

		-skin		=> ["METHOD", 	"skin", 	"Skin", 	undef],
		-prefs		=> ["METHOD", 	"prefs", 	"Prefs", 	undef],
		-splash		=> ["METHOD", 	"splash", 	"Splash", 	undef],
           	);
	
	$obj->bind( "<Configure>", sub{ $obj->{opt}->{'geometry'} = $obj->geometry } );
	$obj->bind( "<Destroy>", sub{ $obj->{optobj}->save_options() } );
	$obj->bind( "<Double-Escape>", sub { exit } );

	$obj->Icon('-image' => $obj->Photo( -file => $obj->{icon} ) ) if($obj->{icon});
	$obj->optionAdd("*tearOff", "false");
	$obj->configure(-title 	=> $obj->{app});

	$obj->init_menu();
	$obj->init_prefs();
	$obj->init_main();
	$obj->init_status();

	$obj->packall();

	$obj->Advertise('menu' => $obj->{menu});
	$obj->Advertise('main' => $obj->{main});
	$obj->Advertise('status' => $obj->{status});

	$obj->{balloon} = $obj->Balloon();
	$obj->update;
}

# ------------------------------------------
sub help {
# ------------------------------------------
	my $obj = shift || return error('No Object');
	
	$obj->Pod(-file => $obj->{help}, -tree => 0);	
}

# ------------------------------------------
sub about {
# ------------------------------------------
	my $obj = shift || return error('No Object');
	my $text = shift || $obj->{about};
	
	$obj->splash(4000, $text);
}

# ------------------------------------------
sub splash {
# ------------------------------------------
	my $obj = shift || return error('No Object');
	my $mseconds = shift || 0;
	my $text = shift;	
        
	if($obj->{splash} and ! $mseconds) {
		$obj->{splash}->Destroy();
	} elsif(defined $obj->{logo} or defined $text) {
		$obj->{splash} = $obj->Splashscreen;

		$obj->{splash}->Label(
			-image => $obj->Photo( -file => $obj->{logo} ) 
			)->pack()	if($obj->{logo}); 

		$obj->{splash}->Label(
			-textvariable => $text,  
			)->pack()	if($text); 

		$obj->{splash}->Splash();
		$obj->{splash}->Destroy( $mseconds );
		return $obj->{splash};
	} else {
		return error('Can\'t find a logo. Please define first -logo!');
	}

}

# ------------------------------------------
sub prefs {
# ------------------------------------------
	my $obj = shift || return error('No Object');
	return error('Please call Tk::Program::init_prefs before call prefs')
		unless defined $obj->{optobj};
	my $w = $obj->{optobj}->option_editor(
		$obj,
		-buttons => [qw/ok save cancel defaults/],
		-delaypagecreate => 0,
		-wait	=> 1,
		-transient => $obj,
	);
}

# ------------------------------------------
sub packall {
# ------------------------------------------
	my $obj = shift || return error('No Object');

	$obj->{status}	->pack( -side => 'bottom', -fill => 'x');
	$obj->{main}	->pack( -side => 'top', -expand => 1, -fill => 'both');
}

# ------------------------------------------
sub init_main {
# ------------------------------------------
	my $obj = shift || return error('No Object');
	$obj->{main} = shift || $obj->Frame();

	return $obj->{main};
}

# ------------------------------------------
sub init_status {
# ------------------------------------------
	my $obj = shift || return error('No Object');
        return $obj->{status} if(defined $obj->{status});

	# Statusframe
	$obj->{status} = $obj->Frame();

	return $obj->{status};
}

# ------------------------------------------
sub add_status {
# ------------------------------------------
	my $obj = shift || return error('No Object');
	my $name = shift || return error('No Name');
	my $value = shift || return error('No Value');

        return $obj->{status}->{$name} if(defined $obj->{status}->{$name});
	
	$obj->{status} = $obj->init_status()
		unless(defined $obj->{status});

	my $w = $obj->{status}->Label(
		-textvariable => $value,
		-relief => 'sunken',
		-borderwidth => 2,
		-padx => 5,
		-anchor => 'w')->pack(
			-side => 'left', 
			-fill => 'x', 
			-expand => 1,
			);
	$obj->Advertise('status_'.$name => $w); 
}

# ------------------------------------------
sub init_prefs {
# ------------------------------------------
	my $obj = shift || return error('No Object');
	return $obj->{optobj} if defined $obj->{optobj}; 

	my $optionen = shift || $obj->get_prefs($obj->{add_prefs});
	
	$obj->{optobj} = Tk::Getopt->new(
			-opttable => $optionen,
			-options => $obj->{opt},
			-filename => $obj->{cfg}
		);
	$obj->{optobj}->set_defaults;
	$obj->{optobj}->load_options;
	if (! $obj->{optobj}->get_options) {
	    die $obj->{optobj}->usage;
	}
	$obj->{optobj}->process_options;
	return $obj->{optobj};
}

# ------------------------------------------
sub get_prefs {
# ------------------------------------------
	my $obj = shift || return error('No Object');
	my $to_add = shift || [];
	my $default = 
	[
		'Display',
		['Geometry', '=s', undef,
		    'help' => 'Set geometry from Programm',
		    'subtype' => 'geometry',
			'callback' => sub {    	
				if (my $geo = $obj->{opt}->{'Geometry'}) {
					$obj->geometry($geo);
					$obj->update;
				}
			},
   		], 
		['Color', '=s', 'gray85',
		    'help' => 'Set color palette to Program',
		    'subtype' => 'color',
			'callback' => sub {    	
				if (my $col = $obj->{opt}->{'Color'}) {
					$obj->setPalette($col);
					$obj->update;
				}
			},
   		], 
   		['Font', '=s', 'Helvetica 10 normal',
			'callback' => sub {    	
				if (my $font = $obj->{opt}->{'Font'}) {
					$obj->optionAdd("*font", $font);
					$obj->optionAdd("*Font", $font);
					if($obj->{menu}) {
						$obj->{menu}->configure(-font => $font);
						$obj->{menu}->update;
					}
					$obj->update;
				}
			},
			'subtype' => 'font',
			'help' => 'Default font',
		],
		@$to_add
	];
	return $default;
}

# ------------------------------------------
sub init_menu {
# ------------------------------------------
	my $obj = shift || return error('No Object');
	return $obj->{menu} if defined $obj->{menu}; 
	my $menuitems = shift || [
		[Cascade => "File", -menuitems =>
			[
				[Button => "Prefs", 	-command => sub{ $obj->prefs() } ],
				[Button => "Quit", 	-command => sub{ exit }],
			]	
		],	
		
		
		[Cascade => "Help", -menuitems =>
			[
				[Button => "Help", -command => sub{ $obj->help() } ],
				[Button => "About", -command => sub{ $obj->about() } ],
			]	
		],
	];

	# Menu
	if ($Tk::VERSION >= 800) {
		$obj->{menu} = $obj->Menu(
			-menuitems => $menuitems,
			-tearoff => 0,
			);
		$obj->configure(-menu => $obj->{menu});
	} else {
		$obj->{menu} = $obj->Menubutton(-text => "Pseudo menubar",
				 	 -menuitems => $menuitems)->pack;
	}
	return $obj->{menu};
}


#-------------------------------------------------
sub error {
#-------------------------------------------------
	my ($package, $filename, $line, $subroutine, $hasargs,
    		$wantarray, $evaltext, $is_require, $hints, $bitmask) = caller(1);
	my $msg = shift || return undef;
	warn sprintf("ERROR in %s:%s #%d: %s",
		$package, $subroutine, $line, sprintf($msg, @_));
	return undef;
}

1;

=head1 NAME

Tk::Program - MainWindow Widget with special features.

=head1 SYNOPSIS

  use Tk;
  use Tk::Program;

  my $top = Tk::Program->new(
	-app => 'xpix',
	-cfg => './testconfig.cfg',
	-icon	=> './icon.gif',
	-logo => './logo.gif',
	-about => \$about,
	-help => '../Tk/Program.pm',
  	-add_prefs => [
		'Tools',
			['acrobat', '=s', '/usr/local/bin/acroread',
			{	'subtype' => 'file',
				'help' => 'Path to acrobat reader.'
			} ],
  	],
  );

  MainLoop;

=head1 DESCRIPTION

This  is  a  megawidget to  display  a  program window.  I  was  tyred in  every
application  to   create a   menu,  prefs  dialog,  about  .... I  search  for a
standard way and  write this module.  This remember the  font, size and  postion
from the Mainwindow and use also the function from Tk::Mainwindow.

=head1 WIDGET-SPECIFIC OPTIONS

=head2 -app => $Applikation_Name

Set a Application name, default is I<Program>

=head2 -icon => $Path_to_icon_image

Set a Application Icon, please give this in 32x32 pixel and in gif format.

=head2 -cfg => $path_to_config_file;

Set the path to the config file, default:

  	$HOME/.$Application_Name.cfg

=head2 -add_prefs => $arrey_ref_more_prefs;

This allow mor Preferences as the default:

  	-add_prefs => [
		'Tools',
			['acrobat', '=s', '/usr/local/bin/acroread',
			{	'subtype' => 'file',
				'help' => 'Path to acrobat reader.'
			} ],
  	],


=head2 -logo => $image_file;

One logo for one program ;-) This picture will use from Splash and About Method. 
Carefully, if this not defined in Splash then returnd this with an error.

=head2 -help => $pod_file;

This include a Help function as a topwindow with Poddisplay. Look for more 
Information on Tk::Pod. Default is the program source ($0).


=head1 METHODS

These are the methods you can use with this Widget.

=head2 $top->init_prefs( I<$prefs> );

This will initialize the user or default preferences. This returnd a 
Prefsobject. More information about the prefsobject look on B<Tk::Getopt> from 
slaven. The Program with use  this Module have a  configuration dialog in tk 
and on the commandline with the following standard options:

=over 4

=item I<Geometry>: Save the geometry (size and position) from mainwindow.

=item I<Font>: Save the font from mainwindow.

=item I<Color>: Save the color from mainwindow.

=back

In the Standard menu you find the preferences dialog under I<File - Prefs>.

I.E.:

	my $opt = $top->init_prefs();
	$opt->save_options;
	....	

=head2 $top->prefs();

Display the Configuration dialog.

=head2 $top->init_menu( I<$menuitems> );

Initialize the user or default Menu and returnd the Menuobject. You can set your 
own menu with the first parameter. the other (clever) way, you add your own menu 
to the standart menu. 
I.E:

	# New menu item
	my $edit_menu = $mw->Menu();
	$edit_menu->command(-label => '~Copy', -command => sub{ print "Choice Copy \n" });
	$edit_menu->command(-label => '~Cut', -command => sub{ print "Choice Cut \n" });
	# ....	

	my $menu = $mw->init_menu();
	$menu->insert(1, 'cascade', -label => 'Edit', -menu => $edit_menu);


=head2 $top->splash( I<$milliseconds> );

Display the  Splashscreen for  (optional) x  milliseconds. The  -logo option  is 
required to initialize with a Picture. Also you can this use as Switch,  without 
Parameter:

  	$top->splash();	# Splash on
  	....
  	working
  	...
  	$top->splash(); # Splash off
  	


=head1 ADVERTISED WIDGETS

You can use the advertice widget with the following command I<$top-
>Subwidget('name_from_adv_widget')>.

=head2 B<menu>: Menubar

=head2 B<main>: Mainframe

=head2 B<status>: Statusframe

=head2 B<status_I<name>>: StatusEntry from $top->add_status

=head1 CHANGES

  $Log: Program.pm,v $
  Revision 1.1  2003/06/04 17:14:35  xpix
  * New Modul for standart way to build a Programwindow.

=head1 AUTHOR

Copyright (C) 2003 , Frank (xpix) Herrmann. All rights reserved.

http://xpix.dieserver.de

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 KEYWORDS

Tk, Tk::MainWindow

__END__
