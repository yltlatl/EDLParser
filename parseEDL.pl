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

my %edlContent;
my $currentItemId;


while (<$data>) {
    chomp;

    if (m/^\d+.*\d{2}\:\d{2}\:\d{2}\:\d{2}\s\d{2}\:\d{2}\:\d{2}\:\d{2}\s\d{2}\:\d{2}\:\d{2}\:\d{2}\s\d{2}\:\d{2}\:\d{2}\:\d{2}/)
    {
        if (m/^(\d+)\s/)
        {
            $currentItemId = $1;
        }

        my @times = m/\d{2}\:\d{2}\:\d{2}\:\d{2}\s/g;
        foreach my $time (@times)
        {
            $time =~ s/\s//g;
        }

        $edlContent{$currentItemId} = { "startTime" => $times[2], "endTime" => $times[3] };

    }

    if (m/^(\*\sFROM\sCLIP\sNAME\:\s+)(.*)/)
    {
        $edlContent{$currentItemId}{"clipName"} = $2;
    }

}

my ($name, $dirs, $suffix) = fileparse($ARGV[0]);
my $outputFile = $dirs . $name . "_output.csv";
open (my $output, ">", $outputFile) or die "Can't open output file $outputFile";

print $output "\"Item Id\",\"Clip Name\",\"Start Time\",\"End Time\",\"Duration\"\n";

foreach my $key (sort (keys %edlContent))
{
    my $duration = calculateDuration ($edlContent{$key}{'startTime'}, $edlContent{$key}{'endTime'});
    print $output "\"$key\",\"$edlContent{$key}{'clipName'}\",\"$edlContent{$key}{'startTime'}\",\"$edlContent{$key}{'endTime'}\",\"$duration\"\n";
}


sub calculateDuration {
    my ($startTime, $endTime) = @_;

    my ($startTimeHours, $startTimeMinutes, $startTimeSeconds, $startTimeFrames) = split (/\:/,$startTime);
    my $totalStartTimeFrames = $startTimeFrames + ($startTimeSeconds * 24) + ($startTimeMinutes * 24 * 60) + ($startTimeHours * 24 * 3600);

    my ($endTimeHours, $endTimeMinutes, $endTimeSeconds, $endTimeFrames) = split (/\:/,$endTime);
    my $totalEndTimeFrames = $endTimeFrames + ($endTimeSeconds * 24) + ($endTimeMinutes * 24 * 60) + ($endTimeHours * 24 * 3600);

    my $durationInFrames = $totalEndTimeFrames - $totalStartTimeFrames;

    my $resultFrames = $durationInFrames % 24;
    my $remainingDurationInSeconds = ($durationInFrames - $resultFrames) / 24;
    my $resultSeconds = $remainingDurationInSeconds % 60;
    my $remainingDurationInMinutes = ($remainingDurationInSeconds - $resultSeconds) / 60;
    my $resultMinutes = $remainingDurationInMinutes % 60;
    my $resultHours = ($remainingDurationInMinutes - $resultMinutes) / 60;

    #need to round out frames
    if ($resultFrames >= 13.5) { $resultSeconds += 1; }
    if ($resultSeconds == 60) {
        $resultSeconds = 0; 
        $resultMinutes += 1;
        if ($resultMinutes == 60)
        {
            $resultMinutes = 0;
            $resultHours += 1;
        }
    }


    my $format = "%02d";
    return join (":", sprintf($format, $resultHours), sprintf($format, $resultMinutes), sprintf($format, $resultSeconds));
} 