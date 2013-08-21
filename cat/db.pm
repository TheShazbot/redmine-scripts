#!/usr/bin/env perl

package cat::db;

use strict;
use DBI;
use YAML qw(LoadFile);
use Exporter;
use base qw(Exporter);

our (@EXPORT_OK) = qw( 'connectToDb' );

sub connectToDb {

  my $config   = LoadFile('config.yaml');
  my $host     = $config->{'host'};
  my $dbname   = $config->{'dbname'};
  my $port     = $config->{'port'};
  my $username = $config->{'username'};
  my $password = $config->{'password'};

  my ($dbh) = DBI->connect("dbi:Pg:dbname=$dbname;host=$host;port=$port;",
      "$username", "$password");

  if ( !$dbh ) {
    die("Cannot connect to database $dbname");
  }

  return ($dbh);
}

1;
