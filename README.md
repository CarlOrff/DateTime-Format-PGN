# NAME

DateTime::Format::PGN - a Perl module for parsing and formatting date fields in chess game databases in PGN format

# VERSION

version 0.05

# SYNOPSIS

       use DateTime::Format::PGN;
    
       my $f = DateTime::Format::PGN->new();
       my $dt = $f->parse_datetime( '2004.04.23' );
    
       # 2004.04.23
       print $f->format_datetime( $dt );
       
       # return a DateTime::Incomplete object:
       my $fi = DateTime::Format::PGN->new( { use_incomplete => 1} );
       my $dti = $fi->parse_datetime( '2004.??.??' );
       
       # 2004.??.??
       print $fi->format_datetime( $dti );

# METHODS

## new(%options)

Options are Boolean `use_incomplete` (default 0) and Boolean `fix_errors` (default 0).

    my $f = DateTime::Format::PGN->new( { fix_errors => 1, use_incomplete => 1 } );

PGN allows for incomplete dates while `DateTime` does not. All missing date values in `DateTime` default to 1. So PGN `????.??.??` becomes 
`0001.01.01` with `DateTime`. If `use_incomplete => 1`, a `DateTime::Incomplete` object is used instead where missing values are `undef`.

I observed a lot of mistaken date formats in PGN databases downloaded from the internet. If `fix_errors => 1`, an attempt is made to parse the 
date anyway.

## parse\_datetime($string)

Returns a `DateTime` object or a `DateTime::Incomplete` object if option `use_incomplete => 1`. Since the first recorded chess game 
was played 1485, years with a leading 0 are handled as errors.

## format\_datetime($datetime)

Given a `DateTime` object, this methods returns a PGN date string. If the date is incomplete, use 
a `DateTime::Incomplete` object (the `use_incomplete` option does not affect the formatting here).

# Source

[PGN spec](https://www.chessclub.com/user/help/PGN-spec) by Steven J. Edwards.

# See also

- [Chess::PGN::Parse](https://metacpan.org/pod/Chess::PGN::Parse)
- [DateTime::Incomplete](https://metacpan.org/pod/DateTime::Incomplete)
- [http://datetime.perl.org/](http://datetime.perl.org/)

# AUTHOR

Ingram Braun <ibraun@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2016 by Ingram Braun.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
