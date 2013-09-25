package Parallel::Async::Task;
use 5.008005;
use strict;
use warnings;

use Try::Tiny;
use Storable ();
use File::Spec;
use POSIX ":sys_wait_h";

(my $TMPDIR_BASENAME = __PACKAGE__) =~ s!::!-!g;

our $WANTARRAY;
our $EXIT_CODE;

use Class::Accessor::Lite ro => [qw/parent_pid child_pid/];
use Parallel::Async::Chain;

sub new {
    my ($class, %args) = @_;
    return bless +{
        %args,
        parent_pid     => $$,
        clild_pid      => undef,
        already_run_fg => 0,
    } => $class;
}

sub recv :method {
    my $self = shift;

    local $WANTARRAY = wantarray;
    local $self->{_run_on_parent} = sub {
        my $self = shift;

        $self->_wait();

        my $ret = $self->read_child_result();
        return $WANTARRAY ? @$ret : $ret->[0];
    };

    return $self->run();
}

sub as_anyevent_child {
    my ($self, $cb) = @_;

    local $WANTARRAY = 1;
    local $self->{_run_on_parent} = sub {
        my $self = shift;

        require AnyEvent;
        return AnyEvent->child(
            pid => $self->{child_pid},
            cb  => sub {
                my ($pid, $status) = @_;

                my $ret = $self->read_child_result();
                return $cb->($pid, $status, $WANTARRAY ? @$ret : $ret->[0]);
            }
        );
    };

    return $self->run();
}

sub run {
    my $self = shift;
    die 'this task already run.' if $self->{already_run_fg};

    my $pid = fork;
    die $! unless defined $pid;

    $self->{already_run_fg} = 1;
    if ($pid == 0) {## child
        $self->{child_pid} = $$;
        return $self->_run_on_child();
    }
    else {## parent
        $self->{child_pid} = $pid;
        return $self->_run_on_parent();
    }
}

sub _run_on_parent {
    my $self = shift;
    my $code = $self->{_run_on_parent} || sub { shift->{child_pid} };
    return $self->$code();
}

sub _run_on_child {
    my $self = shift;

    local $EXIT_CODE = 0;

    my $orig = $self->{code};
    my $ret = try {
        my @ret;

        # context proxy
        if ($WANTARRAY) {
            @ret = $orig->();
        }
        elsif (defined $WANTARRAY) {
            $ret[0] = $orig->();
        }
        else {
            $orig->();
        }

        return [0, undef, \@ret];
    }
    catch {
        $EXIT_CODE = $!      if $!;          # errno
        $EXIT_CODE = $? >> 8 if $? >> 8;     # child exit status
        $EXIT_CODE = 255     if !$EXIT_CODE; # last resort
        return [1, $_, undef];
    };

    $self->_write_storable_data($ret);

    CORE::exit($EXIT_CODE);
}

sub join :method {
    my $self = shift;
    return Parallel::Async::Chain->join($self, @_);
}

sub _wait {
    my $self = shift;

    my $pid = $self->{parent_pid};
    while ($self->{child_pid} != $pid) {
        $pid = waitpid(-1, WNOHANG);
        last if $pid == -1;
    }
}

sub _gen_storable_tempfile_path {
    my $self = shift;
    return File::Spec->catfile(File::Spec->tmpdir, join('-', $TMPDIR_BASENAME, $self->{parent_pid}, $self->{child_pid}) . '.txt');
}

sub _write_storable_data {
    my ($self, $data) = @_;

    my $storable_tempfile = $self->_gen_storable_tempfile_path();
    try {
        Storable::store($data, $storable_tempfile) or die 'faild store.';
    }
    catch {
        warn(qq|The storable module was unable to store the child's data structure to the temp file "$storable_tempfile":  | . join(', ', $_));
    };
}

sub _read_storable_data {
    my $self = shift;

    my $data;

    my $storable_tempfile = $self->_gen_storable_tempfile_path();
    if (-e $storable_tempfile) {
        try {
            $data = Storable::retrieve($storable_tempfile) or die 'faild retrieve.';
        }
        catch {
            warn(qq|The storable module was unable to retrieve the child's data structure from the temporary file "$storable_tempfile":  | . join(', ', $_));
        };

        # clean up after ourselves
        unlink $storable_tempfile;
    }

    return $data;
}

sub read_child_result {
    my $self = shift;
    my $data = $self->_read_storable_data() || [];

    if ($data->[0]) {## has error
        die $data->[1];
    }
    else {
        return $data->[2] || [];
    }
}

sub reset :method {
    my $self = shift;
    $self->{child_pid}      = undef;
    $self->{already_run_fg} = 0;
}

sub clone {
    my $self = shift;
    my $class = ref $self;
    return $class->new(%$self);
}

1;
__END__

=encoding utf-8

=head1 NAME

Parallel::Async::Task - It's new $module

=head1 DESCRIPTION

Parallel::Async::Task is ...

=head1 METHODS

=head1 LICENSE

Copyright (C) karupanerura.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

karupanerura E<lt>karupa@cpan.orgE<gt>

=cut

