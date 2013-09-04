#!/usr/bin/env perl

use strict;
use warnings;

use cat::db;

use Path::Class;
use Data::Dumper;

my $dbh = cat::db::connectToDb('gitolite');
my $sql = 'select * from keys';
my $sth = $dbh->prepare($sql);

$sth->execute or die "SQL Error: $DBI::errstr\n";

my $dir = dir( $ARGV[0] );

while ( my $row = $sth->fetchrow_hashref )
    {
    my $file        = $dir->file( $row->{'name'} . '.pub' );
    my $file_handle = $file->openw();
    $file_handle->print( $row->{'keydata'} . "\n" );
    }

$dbh->disconnect

