#!/usr/bin/perl

###
# Repository https://gitlab.ethz.ch/bit/monthy_copy
# Author: hlars
#
# Collects data from source folder in configured directories
# from the previous month and creates a tar that is moved
# to the source
#
###

use strict;
use warnings;

#abs path needed because of shell script start
#TODO change according to you directory structure
use lib '/home/hlars/gitprojects/monthly_copy/lib';
use lib '/transdata/eth_cds/monthly_copy/lib';

use Config::Simple;
use Data::Dumper;
use Log;
use Helper;
use POSIX qw(strftime);

$|=1;

my $config;
my $log;
my $LASTRUN = '/last_run';
my $HISTORY = '/history';
my $TARCOMMAND = 'tar cfvP ';
my $TAREXTENSION = '.tar';
my $SHACOMMAND = 'sha512sum ';
my $SHAEXTENSION = '.sha512';
my $LISTEXTENSION = '.txt';
my $LISTSUFFIX = '_file-listing';

# main method
sub main {
  #initialize
  $config = new Config::Simple("config/monthly_copy.ini");
  Helper::checkMandatoryDirectory(($config->param('paths.source'), $config->param('paths.temp'), $config->param('paths.target')));

  #create current run's log file
  $log = Log->new($ENV{PWD}.'/logs/'.(strftime '%Y%m%d%H%M%S', localtime).'.log');

  if(isValidRun()==1)
  {
    startRun();
    sendInfoMail();
  }
  else
  {
    exit;
  }

  $log->addLogLine("Finished");
}

# start and orchestrate actual complete copy process
sub startRun
{
  $log->addLogLine(buildTarCommand());
  system(buildTarCommand());
  $log->addLogLine(buildShaCommand());
  system(buildShaCommand());
  $log->addLogLine(buildMoveFilesCommand());
  system(buildMoveFilesCommand());

  setHistory();
  setLastRun();
}

# construct command to move files form temp to target
sub buildMoveFilesCommand
{
  my $moveCommand = 'mv ';
  $moveCommand.= $config->param("paths.temp").'/'.getLastMonth().'* ';
  $moveCommand.= $config->param("paths.target");

  return $moveCommand
}

# extract last month in format YYYYMM
sub getLastMonth
{
  my $lastMonth;
  my $currentYear = strftime '%Y', localtime;
  my $currentMonth = strftime '%-m', localtime;

  #Debug only
  #my $currentYear = 2019;
  #my $currentMonth = 2;

  if($currentMonth < 2)
  {
    $lastMonth = ($currentYear-1).'-'.12;
  }
  else
  {
    $lastMonth = ($currentYear).'-'.(sprintf("%02d", $currentMonth-1));
  }

  return $lastMonth;
}

# construct complete tar command for compressing source to $time
# also export verbose in list
sub buildTarCommand
{
  my $tarCommand = $TARCOMMAND;
  my $toCopyPath;
  my $toCopyCount = 0;
  $tarCommand.= $config->param('paths.temp').'/'.getLastMonth().$TAREXTENSION;

  foreach($config->param('paths.tocopy'))
  {
    $toCopyPath = $config->param('paths.source').$_;
    $toCopyPath.= '/'.substr(getLastMonth(),0,4);
    $toCopyPath.= '/'.substr(getLastMonth(),5,2);

    if(-e $toCopyPath)
    {
      $tarCommand.= ' '.$toCopyPath;
      $toCopyCount++;
    }
    else
    {
      $log->addLogLine($toCopyPath.' does not exist');
    }
  }

  $tarCommand.= ' > ';
  $tarCommand.= $config->param('paths.temp').'/';
  $tarCommand.= getLastMonth().$LISTSUFFIX.$LISTEXTENSION;

  if($toCopyCount==0) {
    $log->addLogLine('Nothing to put into tar available.');
    exit;
  }

  return $tarCommand;
}

# construct sha hash command
sub buildShaCommand
{
  my $shaCommand = $SHACOMMAND;
  $shaCommand.= $config->param('paths.temp').'/';
  $shaCommand.= getLastMonth().$TAREXTENSION;
  $shaCommand.= ' > ';
  $shaCommand.= $config->param('paths.temp').'/';
  $shaCommand.= getLastMonth().$TAREXTENSION.$SHAEXTENSION;

  return $shaCommand;
}

# returns if this run
sub isValidRun
{
  if(getLastRun() eq getLastMonth())
  {
    $log->addLogLine("No need to run. Last run from ".getLastRun());
    return 0;
  }
  else
  {
    $log->addLogLine("Last run: ".getLastRun().", new run for ".getLastMonth());
    return 1;
  }
}

# return value from lastrun file
sub getLastRun
{
  my $lastRunValue;
  my $fileName = $ENV{PWD}.$LASTRUN;

  open(my $fh, '<', $fileName) or die "Cannot open $fileName";
  $lastRunValue = <$fh>;
  close $fh;

  return Helper::removeLineBreak($lastRunValue);
}

# sets lastrun file value
# add current date to history
sub setLastRun
{
  my $fileName = $ENV{PWD}.$LASTRUN;

  open(my $fh, '>', $fileName) or die "Cannot open $fileName";
  print $fh getLastMonth();

  close $fh;

  $log->addLogLine($LASTRUN.' updated');
}

# add current date to history file
sub setHistory
{
  my $timestamp = strftime '%Y-%m-%d %H:%M', localtime;
  my $fileName = $ENV{PWD}.$HISTORY;

  open(my $fh, '>>', $fileName) or die "Cannot open $fileName";
  print $fh $timestamp."\n";

  close $fh;

  $log->addLogLine($HISTORY.' entry added');
}

# generate and send mail to defined recipients
sub sendInfoMail
{
  my $lastMonth = getLastMonth();
  my $mailSubject = $config->param('mail.subject');
  my $mailBody = $config->param('mail.body');

  $mailSubject =~ s/#month#/$lastMonth/g;
  $mailBody =~ s/#month#/$lastMonth/g;

  for($config->param('mail.recipients'))
  {
    `echo $mailBody | mail -s "$mailSubject" $_`;
  }
}


main();
