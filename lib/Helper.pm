package Helper;

use strict;
use warnings;
use POSIX qw(strftime);

use Data::Dumper;


$|=1;

# BOM entfernen
sub removeBom
{
	my $string = shift;
	$string =~ s/^\xEF\xBB\xBF//;

	return $string
}

# remove any line breaks
sub removeLineBreak
{
	my $string = shift;
	$string =~ s/\n//;
	$string =~ s/\r//;

	return $string;
}

# Timestamp erstellen
sub getTimeStamp
{
	my $dateString = strftime "%Y%m%d%H%M", localtime;

	return $dateString;
}

# Directory erstellen (falls es nicht bereits existiert)
sub createDirectory
{
	foreach my $directory_path(@_)
	{
		unless (-d $directory_path)
		{
			mkdir($directory_path);
		}
	}

}

# pruefen ob ein obligatorischer Ordner vorhanden ist (sonst die)
sub checkMandatoryDirectory
{
	foreach my $directory_path(@_)
	{

		unless (-d $directory_path)
		{
			die "Directory $directory_path does not exist";
		}
	}
}

#pruefen ob ein obligatorisches File vorhanden ist (sonst die)
sub checkMandatoryFile
{
	foreach my $file_path(@_)
	{
		unless (-e $file_path)
		{
			die "File $file_path does not exist";
		}
	}
}

#anlegen einer Previous Datei
sub createDummyPrevious
{
	my $filePath = shift;

	unless(-e $filePath)
	{
		system `touch $filePath`;
	}
}

#haengt "/" an directory wenn keiner vorhanden ist
sub correctDirectory
{
	my $directory = shift;
	unless($directory =~ /\/$/)
	{
		$directory.='/';
	}

	return $directory;

}

# Extrahiert den Namen des Files ohne die Endung
sub getFileNameWithoutEnding
{
	my $fileName = shift;
	my ($firstPart) = $fileName =~ /(^.+)\.\w{3}$/;

	return $firstPart;
}


#returns file name
sub getFileNameFromFilePath
{
  my $filePath = shift;
  my @pathArray = split("/", $filePath);
  my $arrayLength = scalar @pathArray;

  return ($pathArray[$arrayLength-1]);
}

1;
