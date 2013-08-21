#!/usr/bin/env perl

use cat::db;

use strict;
use warnings;

my $dbh = cat::db::connectToDb();

# TODO make it not run everytime
#my $sql_count = "select count(*) from keys where in_gitolite='false';";
#my $sth_count = $dbh->prepare($sql_count);

my $sql = "select * from keys";
my $sth = $dbh->prepare($sql);

$sth->execute or die "SQL Error: $DBI::errstr\n";

while (my @row = $sth->fetchrow_array) {
  my $uid     = $row[1];
  my $keydata = $row[2];
  my $name    = $row[3];
  print "\@$uid = $name\n";
  # TODO:
  # set in_gitolite='true'
}

$dbh->disconnect
