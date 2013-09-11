#!/usr/bin/env perl

package cat::log;

use strict;
use DBI;
use YAML qw(LoadFile);
use Exporter;
use base qw(Exporter);
use Date::Format;

use cat::db;

our (@EXPORT) = qw( log errorlog );
our (@EXPORT_OK) = qw( log errorlog );

sub errorlog 
    {
    my ($source, $message) = @_;

    my $config   = LoadFile('config.yaml');
    my $logfile  = $config->{'errorlog'};

    my($fh);

    if ( open($fh, '>>', $logfile) )
	{
	printf("%s %10s %s\n",
	    time2str( '%Y-%m-%d %H:%M', time() ), $source, $message);
	}
    else
	{
	print "Could not open log file\n";
	}
    }

sub log 
    {
    my ($source, $message) = @_;

    my $config   = LoadFile('config.yaml');
    my $logfile  = $config->{'logfile'};

    my($fh);

    if ( open($fh, '>>', $logfile) )
	{
	printf("%s %10s %s\n",
	    time2str( '%Y-%m-%d %H:%M', time() ), $source, $message);
	}
    else
	{
	print "Could not open log file\n";
	}

    my $dbh = cat::db::connectToDb('gitolite');

    my $sth = $dbh->prepare('INSERT INTO log ( source, message) 
	VALUES ( ?, ?)');

    $sth->execute($source, $message);

    $dbh->disconnect;

    }


1;
