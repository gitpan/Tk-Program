#!/usr/local/bin/perl -w

use strict;
use lib '../.';
use Tk;
use Tk::Program;
use Tk::ROText;
my $status = {
	One => 'Status one',
	Full => 'Full sentence ....',
	Time => sprintf('%d seconds', time),
};

my $about = qq|
Tk::Program 
by Frank (xpix) Herrmann
� 2002 Netzwert AG 
Berlin, Germany
|;

my $mw = Tk::Program->new(
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

# New menu item
my $edit_menu = $mw->Menu();
$edit_menu->command(-label => '~Copy', -command => sub{ print "Choice Copy \n" });
$edit_menu->command(-label => '~Cut', -command => sub{ print "Choice Cut \n" });
$edit_menu->command(-label => '~Paste', -command => sub{ print "Choice Paste \n" });

my $menu = $mw->init_menu();
$menu->insert(1, 'cascade', -label => 'Edit', -menu => $edit_menu);


# Refresh Status field 
$mw->repeat(999, sub{
	$status->{Time} = sprintf('%d seconds', time);
});

# Add Status fields
foreach (sort keys %$status) {
	$mw->add_status($_, \$status->{$_}) ;
}

# Add Button to toolbar
$mw->add_toolbar('Button', -text  => 'Button', -tip   => 'tool tip', -command => sub { print "hi\n" });
$mw->add_toolbar('Label', -text  => 'Label');
$mw->add_toolbar('separator');
$mw->add_toolbar('Entry', -text => 'Entry');
$mw->add_toolbar('LabEntry', -label => 'Label', -text => 'Laber');

# MainFrame
my $t = $mw->Subwidget('main')->Scrolled('ROText')->pack(
		-expand => 1, 
		-fill => 'both'); 
$t->insert('end', `cat $0`);

# Splash for 2000 Milliseconds
$mw->splash( 2000 );

MainLoop;

