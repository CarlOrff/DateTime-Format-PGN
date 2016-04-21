use strict;
use warnings;

package DateTime::Format::PGN;
# ABSTRACT: parse and format date fields from chess game databases in PGN format

use DateTime::Incomplete 0.08;
use Params::Validate 1.23 qw( validate BOOLEAN );

=head1 SYNOPSIS

    use DateTime::Format::PGN;
 
    my $f = DateTime::Format::PGN->new();
    my $dt = $f->parse_datetime( '2004.04.23' );
 
    # 2004.04.23
    print $f->format_datetime($dt);
    
    # return a DateTime::Incomplete object:
    my $fi = DateTime::Format::PGN->new( { use_incomplete => 1} );
    my $dti = $fi->parse_datetime( '2004.??.??' );
    
    # 2004.??.??
    print $fi->format_datetime($dti);

=head1 METHODS

=method new(%options)

Options are Boolean C<use_incomplete> (default 0) and Boolean C<fix_errors> (default 0).

    my $f = DateTime::Format::PGN->new({fix_errors => 1, use_incomplete => 1});
    
PGN allows for incomplete dates while C<DateTime> does not. All missing values in DateTime default to 1. So PGN C<????.??.??> becomes 
C<0001.01.01> with C<DateTime>. If C<use_incomplete => 1>, a C<DateTime::Incomplete> object is used instead in order to preserve the question marks.

I observed a lot of mistaken date formats in PGN databases downloaded from the internet. If C<fix_errors => 1>, an attempt is made to parse the 
date anyway.

=cut

sub new {
    my( $class ) = shift;

    my %args = validate( @_,
        {
            fix_errors => {
                type        => BOOLEAN,
                default     => 0,
                callbacks   => {
                    'is 0, 1, or undef' =>
                        sub { ! defined( $_[0] ) || $_[0] == 0 || $_[0] == 1 },
                },
            },
            use_incomplete => {
                type        => BOOLEAN,
                default     => 0,
                callbacks   => {
                    'is 0, 1, or undef' =>
                        sub { ! defined( $_[0] ) || $_[0] == 0 || $_[0] == 1 },
                },
            },
        }
    );

    $class = ref( $class ) || $class;

    my $self = bless( \%args, $class );

    return( $self );
}


=method parse_datetime($string)

Returns a C<DateTime> object or a C<DateTime::Incomplete> object if option C<use_incomplete => 1>. Since the first recorded chess game 
is from 1485, years with a leading 0 are handled as errors.

=cut

sub parse_datetime {
    my ( $self, $date ) = @_;
    my @matches = ( '????', '??', '??' );
    
    if ($date =~ m/^(\?{4}|[1-2]\d{3})\.(\?{2}|0[1-9]|1[0-2])\.(\?{2}|0[1-9]|[1-2]\d|3[0-1])$/) {
    
        @matches = ( $1,$2,$3 );
    }
    else {
    
        # We can try to fix frequently occuring faults.
        if ($self->{ fix_errors }) {
             
            # if we find a year, we can try to parse the wrong date.
            if ($date =~ /(\A|\D)([1-2]\d{3})(\D|\Z)/ && $2 > 0) {
        
                $matches[0] = $2;
                
                # Try to find month and day.
                if ($date =~ /(\A|\D)(\d{1,2})\D+(\d{1,2})(\D|\Z)/) {
                    if (($2 < 13 && $3 > 12 && $3 < 32 && $2 > 0 && $3 > 0) || ($2 == $3 && $2 < 13 && $2 > 0)) {
                        $matches[1] = $2;
                        $matches[2] = $3;
                    }
                    elsif ($3 < 13 && $2 > 12 && $2 < 32 && $2 > 0 && $3 > 0) {
                        $matches[1] = $3;
                        $matches[2] = $2;
                    }
                }
                elsif ($date =~ /(January|February|March|April|May|June|July|August|September|October|November|December)/) {
                
                    if (index($1,'January') > -1) {$matches[1] = 1}
                    elsif (index($1,'February') > -1) {$matches[1] = 2}
                    elsif (index($1,'March') > -1) {$matches[1] = 3}
                    elsif (index($1,'April') > -1) {$matches[1] = 4}
                    elsif (index($1,'May') > -1) {$matches[1] = 5}
                    elsif (index($1,'June') > -1) {$matches[1] = 6}
                    elsif (index($1,'July') > -1) {$matches[1] = 7}
                    elsif (index($1,'August') > -1) {$matches[1] = 8}
                    elsif (index($1,'September') > -1) {$matches[1] = 9}
                    elsif (index($1,'October') > -1) {$matches[1] = 10}
                    elsif (index($1,'November') > -1) {$matches[1] = 11}
                    else {$matches[1] = 12}

                    $matches[2] = $2 if $date =~ /(\A|\D)(\d{1,2})(\D|\Z)/ && $2 < 32 && $2 > 0;
                }
                
                # check month length
                if (index($matches[1],'?') == -1 && index($matches[2],'?') == -1) {
                    if ($matches[2] == 31 && ($matches[1] == 4 || $matches[1] == 6 || $matches[1] == 9 || $matches[1] == 9 || $matches[1] == 11)) {
                        $matches[1] = '??';
                        $matches[2] = '??';
                    }
                    elsif ($matches[1] == 2) {
                        if (($matches[2] == 29 && $matches[0] % 4 == 0 && $matches[0] % 100 > 0) || $matches[2] < 29) {}
                        else {
                            $matches[1] = '??';
                            $matches[2] = '??';
                        }
                    }
                }
            }
        }
    }    
    
    # If incomplete data should be preserved, we must create a DateTime::Incomplete object instead.
    if ( $self->{ use_incomplete } ) {
    
        grep { $_  = undef if index($_,'?') > -1 } @matches;
        
        return DateTime::Incomplete->new(
            year       => $matches[0],
            month      => $matches[1],
            day        => $matches[2],
            formatter  => $self,
        );
    }
    # The usual DateTime object.
    else {
    
        grep { $_  = 1 if index($_,'?') > -1 } @matches;
        
        return DateTime->new(
            year       => $matches[0],
            month      => $matches[1],
            day        => $matches[2],
            formatter  => $self,
        );
    }
}

=method format_datetime($datetime)

Given a C<DateTime> object, this methods returns an PGN date string. If the date is incomplete, use 
a C<DateTime::Incomplete> object (the C<use_incomplete> option does not affect the formatting here).

=cut

sub format_datetime {
    my ( $self, $dt ) = @_;
    
    my $year = (defined $dt->year()) ? $dt->year() : '????';
    my $month = (defined $dt->month()) ? $dt->month() : '??';
    my $day = (defined $dt->day()) ? $dt->day() : '??';
    
    return sprintf '%04s.%02s.%02s', $year, $month, $day;
}

1;

=head1 Source

L<PGN spec|https://www.chessclub.com/user/help/PGN-spec> by Steven J. Edwards.

=head1 See also

=for :list
* L<Chess::PGN::Parse>
* L<DateTime::Incomplete>
* L<http://datetime.perl.org/>
