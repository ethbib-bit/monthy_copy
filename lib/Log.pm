package Log;

use strict;
use warnings;
use POSIX qw(strftime);


$|=1;

#Log constructor
#1st param: complete path to log file
#2nd param: job name
sub new
{
	my $type = shift;
	my $self = {
		_n => "\n",
		_filePath => shift,
	};

	initializeLog($self);

	return bless $self, $type;
}


#creates log and adds first line to log file
sub initializeLog
{
	my $self = shift;
	my $content = Helper::getTimeStamp()." - Startet log".$self->{_n};

	writeToFile($self->{_filePath}, ">:utf8", $content);
}


#formats content with time stamp and line break
#and add it to current log file
sub addLogLine
{
	my $self = shift,
	my $content = shift;

	$content = Helper::getTimeStamp()." - ".$content.$self->{_n};

	writeToFile($self->{_filePath}, ">>:utf8", $content);
}


sub addEmptyLine
{
	my $self = shift;

	my $content = $self->{_n};

	writeToFile($self->{_filePath}, ">>:utf8", $content);
}


#1st param: file path
#2nd param: mode {>, >>}
#3rd param: content that should be written to file
#generic file writer - open file, write content, close file
sub writeToFile
{
	my $filePath = shift;
	my $mode = shift;
	my $content = shift;

	$content = '' unless(defined($content));
	$mode = ">>:utf8" unless(defined($mode));

	open(my $fh, $mode, $filePath) or die "Kann nicht in Datei $filePath schreiben.";
	print $fh $content;
	close $fh;
}
