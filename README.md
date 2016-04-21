# NAME

DateTime::Format::PGN - parse and format date fields from chess game databases in PGN format

# VERSION

version 0.001

# SYNOPSIS

       use DateTime::Format::PGN;
    
       my $f = DateTime::Format::PGN->new();
       my $dt = $f->parse_datetime( '2004.04.23' );
    
       # 2004.04.23
       print $f->format_datetime($dt);
       
       my $fi = DateTime::Format::PGN->new( { use_incomplete => 1} );
       my $dti = $fi->parse_datetime( '2004.??.??' );
       
       # 2004.??.??
       print $fi->format_datetime($dti);

# METHODS

## new()

## parse\_datetime($string)

## format\_datetime($datetime)

# See also

- [Chess::PGN::Parse](https://metacpan.org/pod/Chess::PGN::Parse)

# AUTHOR

Ingram Braun <ibraun@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2016 by Ingram Braun.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
