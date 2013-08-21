#!/usr/bin/env perl

use cat::db;

use strict;
use warnings;
use Path::Class;

my $dbh = cat::db::connectToDb();
my $sql = "select * from keys";
my $sth = $dbh->prepare($sql);

$sth->execute or die "SQL Error: $DBI::errstr\n";

my $dir = dir("/tmp/keydir");

while (my @row = $sth->fetchrow_array) {
  my $uid     = $row[1];
  my $keydata = $row[2];
  my $name    = $row[3];

  my $file = $dir->file("$name.pub");
  my $file_handle = $file->openw();
  $file_handle->print($keydata . "\n");
}

$dbh->disconnect

