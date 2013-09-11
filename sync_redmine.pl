#!/usr/bin/env perl

use strict;
use warnings;

use cat::db;
use cat::log;

use YAML qw(LoadFile);
use feature qw( switch );


my $config = LoadFile('config.yaml');
my $dbh = connectToDb('gitolite');
my $dbh_redmine = connectToDb('redmine');

my $sql = "select * from projects where status='pending' and type != 'none'";
my $sth = $dbh->prepare($sql);

$sth->execute or die "SQL Error: $DBI::errstr\n";

while ( my $row = $sth->fetchrow_hashref )
    {
      associateRepository($row)
    }

$dbh->disconnect;

sub associateRepository {
  my ($row) = @_;
  my $identifier = $row->{'identifier'};
  my $projectId  = getProjectId($identifier);
  my $type       = $row->{'type'};
  my $repotype   = repoToRedmine($type);
  my $url        = repopath($repotype, $identifier);
  my $root_url   = repopath($repotype, $identifier);

  if ( checkRepo($projectId, $identifier) == 0 )
  {
    my $update_sql = "insert into repositories (url, root_url, type, project_id, identifier) VALUES (?, ?, ?, ?, ?)";
    if (defined $projectId) {
      my $update_stmt = $dbh_redmine->prepare($update_sql);
      $update_stmt->execute($url, $root_url, $repotype, $projectId, $identifier) or die "SQL Error: $DBI::errstr\n";
      log('associateRepository()', "Associated project $identifier to repo");
    }
    else {
      errorlog('associateRepository()', "WARNING: Null value $identifier");
    }
  }
  else
  {
    # nothing to do
  }

}

sub checkRepo {
  my ($projectId, $identifier) = @_;
  my $dbh = connectToDb('redmine');
  my $sql = 'select count(*) as count from repositories where project_id=? and identifier=?';
  my $sth = $dbh->prepare($sql);
  $sth->execute($projectId,$identifier) or die "SQL Error: $DBI::errstr\n";
  my $count = $sth->fetchrow_hashref;
  $sth->finish;
  $dbh->disconnect;

  if ( $count->{'count'} > 0 ) {
    return 1;
  }
  else {
    return 0;
  }
}

sub getProjectId {
  my ($identifier) = @_;

  my $dbh = connectToDb('redmine');
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
      errorlog('repoToRedmine()', "Unsupported type $type");
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
      errorlog('repopath()', "Unsupported type $repotype");
      die "Unsupported type $repotype in repopath function";
    }
  }
}
