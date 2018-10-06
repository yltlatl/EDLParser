#!/usr/bin/perl
use strict;
use warnings;
use File::Basename;


my $file = $ARGV[0] or die "Pass the name of the EDL to process as an argument to the script.\n";
 
open(my $data, '<', $file) or die "Could not open '$file' $!\n";

my $currentByte;
my @newLineArray;

#with this approach there is a slight chance we will end up thinking non-adjacent crs/lfs are part of a line ending
#hopefully that chance is minimal
while (read($data,$currentByte,1))
{
    if ($currentByte eq chr 0x0D)
    {
        push @newLineArray, $currentByte;
        next;
    }

    if ($currentByte eq chr 0x0A)
    {
        push @newLineArray, $currentByte;
        last;
    }

}

#set the record delimiter to whatever line breaks we have
$/ = join '', @newLineArray;


my @reverseData = reverse <$data>;
my $lineCount = scalar @reverseData;
my $currentSourceFile;
my @outputData;

for (my $i = 0; $i < $lineCount; $i++) 
{
    my $currentLine = $reverseData[$i];

    if ($currentLine =~ m/\*\sSOURCE FILE:\s(\w{2}_\w{3}\d{4})/)
    {
        $currentSourceFile = $1;
    }
    elsif ($currentLine =~ m/\*\sSOURCE FILE:\s(.*)$/)
    {
        $currentSourceFile = $1;
        $currentSourceFile =~ tr/\r\n//d;
        #truncate value to 10 characters
        $currentSourceFile = substr $currentSourceFile, 0, 10;
    }

    #skip BL lines
    if ($currentLine =~ m/^(\d{3})\s+BL\s+/)
    {
        next;
    }

    if ($currentLine =~ m/^(\d{3}\s+)(\w+)(\s+V\s+\w\s+)(.*)$/)
    {
        my $newSpaces = $3;
        my $currentSourceFileLength = length $currentSourceFile;
        #if the source file name is too short, add spaces to the source file name as filler
        if ($currentSourceFileLength < 8)
        {
            my $missingSpaces = 8 - $currentSourceFileLength;
            $currentSourceFile = $currentSourceFile . (" " x $missingSpaces);
        }
        #otherwise, make sure the overall string is not too long
        #strings that don't match the pattern should already be truncated to 10 characters
        else
        {
            $newSpaces = substr $3, 0, -2;
        }

        $reverseData[$i] = $1 . $currentSourceFile . $newSpaces . $4;
        $currentSourceFile = undef;
        $currentSourceFileLength = undef;
    }

}

my @regularData = reverse @reverseData;

my ($name, $dirs, $suffix) = fileparse($ARGV[0]);
my $outputFile = $dirs . $name . "_output.txt";
open (my $output, ">", $outputFile) or die "Can't open output file $outputFile";

foreach my $line (@regularData)
{
    print $output $line;
}