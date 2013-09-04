#!/usr/bin/env perl

package cat::db;

use strict;
use DBI;
use YAML qw(LoadFile);
use Exporter;
use base qw(Exporter);

our (@EXPORT_OK) = qw( 'connectToDb' );

sub connectToDb {
  my ($name) = @_;

  my $config   = LoadFile('config.yaml');
  my $host     = $config->{"$name"}{'host'};
  my $dbname   = $config->{"$name"}{'dbname'};
  my $port     = $config->{"$name"}{'port'};
  my $username = $config->{"$name"}{'username'};
  my $password = $config->{"$name"}{'password'};
  my $driver   = $config->{"$name"}{'driver'};

  my ($dbh) = DBI->connect("dbi:$driver:dbname=$dbname;host=$host;port=$port;",
      "$username", "$password");

  if ( !$dbh ) {
    die("Cannot connect to database $dbname");
  }

  return ($dbh);
}

1;
