# NAME

Scientist - carefully refactor critical paths

# SYNOPSIS

    use Scientist;

    my $experiment = Scientist::Default->new('thing-study');

    $experiment->use( sub { do_old_thing() } );
    $experiment->try( sub { do_new_thing() } );
    $experiment->run;

# DESCRIPTION

## How do I science?

...

# LICENSE

Copyright (C) Joshua Keroes.

See LICENSE file.

# AUTHOR

Joshua Keroes <joshua.keroes@dreamhost.com>
