use strict; use warnings;
use Test::More;
use Config;
# Stop f77-linking causing spurious undefined symbols (alpha)
$ENV{'PERL_DL_NONLAZY'}=0 if $Config{'osname'} eq "dec_osf";
require PGPLOT;

my $dev = $ENV{PGPLOT_DEV} || '/NULL';

$ENV{PGPLOT_XW_WIDTH}=0.3;

note "Testing Object-Oriented stuff";

PGPLOT::pgbegin(9,$dev,1,1); PGPLOT::pgwnad(-100,100,-100,100);
PGPLOT::pgpage(); PGPLOT::pgbox('BC',0,0,'BC',0,0);

# Define some object classes

##############################################################

package Square;

# Create a new Square - colour is first argument

sub new {
   my $type = shift; # Ignore as we know we are a Square;
   my $self = {};    # $self is ref to anonymous hash
   my $colour = shift;
   $colour = 2 unless defined($colour);            # Default is red
   $self->{'Colour'}=$colour;
   $self->{'Xvertices'} = [-10, 10, 10,-10, -10];  # Initialise as square
   $self->{'Yvertices'} = [-10,-10, 10, 10, -10];
   bless $self;
}

# Method to plot a Square object at $x,$y

sub plot {
   my $self = shift;
   my($x,$y) = @_;
   my(@xpts) = @{$self->{'Xvertices'}};
   my(@ypts) = @{$self->{'Yvertices'}};

   for (@xpts) { $_ = $_ + $x }
   for (@ypts) { $_ = $_ + $y }

   PGPLOT::pgsci($self->{'Colour'});  PGPLOT::pgpoly(scalar(@xpts), \@xpts, \@ypts);
   PGPLOT::pgsci(1);                  PGPLOT::pgline(scalar(@xpts), \@xpts, \@ypts);
}

# Method to expand a Square object

sub expand {
   my $self = shift;
   my $fac  = shift;
   my $xpts  = $self->{'Xvertices'};
   my $ypts  = $self->{'Yvertices'};

   for (@$xpts) { $_ = $_ * $fac }
   for (@$ypts) { $_ = $_ * $fac }
}

# Method to rotate a Square object

sub rotate {
   my $self  = shift;
   my $angle = (shift)*(3.141592564/180);
   my $x = $self->{'Xvertices'};
   my $y = $self->{'Yvertices'};
   my ($x2,$y2);

   for(my $i=0; $i<=$#{$x}; $i++) {
     $x2 =  $$x[$i]*cos($angle) + $$y[$i]*sin($angle);
     $y2 = -$$x[$i]*sin($angle) + $$y[$i]*cos($angle);
     $$x[$i] = $x2; $$y[$i] = $y2;
   }
}


##############################################################

package Triangle;

# Only difference is "new" method. Otherwise inherit
# all other properties from "Square";

our @ISA = qw( Square );

# Create a new Triangle

sub new {
   my $type = shift; # Ignore as we know we are a Square;
   my $self = {};    # $self is ref to anonymous hash
   my $colour = shift;
   $colour = 3 unless defined($colour);       # Default is green
   $self->{'Colour'}=$colour;
   $self->{'Xvertices'} = [-10, 10, 0, -10];  # Initialise as square
   $self->{'Yvertices'} = [-10,-10, 5, -10];
   bless $self;
}

##############################################################

# Now let's use these objects

package main;

note "Testing Square Objects...";

my $shape1 = new Square;

# Plot first shape at 50,50;

note "Square plot method...";

$shape1->plot(50,50);

note "Square expand and rotate methods...";

$shape1->expand(2.3); # Make the shape bigger
$shape1->rotate(20);  # Rotate the shape bigger

$shape1->plot(-20,-50);

note "Inheriting Square methods in Triangles...";

my $shape2 = new Triangle;

$shape2->plot(-20,50);

my $shape3 = new Triangle(4);  # Blue triangle
$shape3->rotate(-15); $shape3->expand(1.5);

$shape3->plot(50,-50);

PGPLOT::pgend();

pass;
done_testing;
