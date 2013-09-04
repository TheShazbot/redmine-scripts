#!/usr/bin/env perl

use strict;
use warnings;

use cat::db;

use YAML qw(LoadFile);
use feature qw( switch );


my $config = LoadFile('config.yaml');
my $dbh = cat::db::connectToDb('gitolite');
my $dbh_redmine = cat::db::connectToDb('redmine');

my $sql = "select * from projects where status='pending' and type != 'none'";
my $sth = $dbh->prepare($sql);

$sth->execute or die "SQL Error: $DBI::errstr\n";

while ( my $row = $sth->fetchrow_hashref )
    {
      associateRepository($row)
    }

$dbh->disconnect;


# TODO: Add logging
sub associateRepository {
  my ($row) = @_;
  my $identifier = $row->{'identifier'};
  my $projectId  = getProjectId($identifier);
  my $type       = $row->{'type'};
  my $repotype   = repoToRedmine($type);
  my $url        = repopath($repotype, $identifier);
  my $root_url   = repopath($repotype, $identifier);
  my $update_sql = "insert into repositories (url, root_url, type, project_id, identifier) VALUES (?, ?, ?, ?, ?)";
  if (defined $projectId) {
    print "Associated project $identifier to repo\n";
    my $update_stmt = $dbh_redmine->prepare($update_sql);
    $update_stmt->execute($url, $root_url, $repotype, $projectId, $identifier) or die "SQL Error: $DBI::errstr\n";
  }
  else {
    print "Null value $identifier\n";
  }
}

sub getProjectId {
  my ($identifier) = @_;

  my $dbh = cat::db::connectToDb('redmine');
  my $sql = 'select id from projects where identifier=? and id is not null';
  my $sth = $dbh->prepare($sql);
  $sth->execute($identifier) or die "SQL Error: $DBI::errstr\n";
  my $row = $sth->fetchrow_hashref;
  my $projectId =  $row->{'id'};
  $sth->finish;
  $dbh->disconnect;
  return $projectId;
}

sub repoToRedmine {
  my ($type) = @_;

  given ($type) {
    when ('Svn') {
      return 'Repository::Subversion';
    }
    when ('Git') {
      return 'Repository::Git';
    }
    default {
      die "Unsupported type $type in repo_to_redmine function";
    }
  }
}

sub repopath {
  my ($repotype, $identifier) = @_;

  given ($repotype) {
    when ('Repository::Subversion') {
      return $config->{'svn_root'} . "$identifier";
    }
    when ('Repository::Git') {
      return $config->{'git_root'} . "$identifier.git";
    }
    default {
      die "Unsupported type $repotype in repopath function";
    }
  }
}
