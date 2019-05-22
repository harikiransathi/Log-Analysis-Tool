use Tk;
use strict;
use File::Find;

my $bkgrndColor      = "#68BDAA";
my $bkgrndLogoClr    = "#52699B";
my $bkgrndMenuClr    = "#52699B";
my $bkgrndButton     = "#C6C6C6";
my $bkgrndSelectClr  = "#C6C6C6";
my $blueHighLightClr = "#4D79CE";

my $heading_font   = "-*-helvetica-bold-r-normal--18-180-*-*-*-*-*-*";
my $text_font      = "-*-helvetica-medium-r-normal--12-120-*-*-*-*-*-*";
my $text_font_bold = "-*-helvetica-bold-r-normal--12-120-*-*-*-*-*-*";
my $tbl_font       = "-*-helvetica-medium-r-normal--10-100-*-*-*-*-*-*";
my $textEntryFont  = "-*-fixed-medium-r-normal--18-120-*-*-*-*-*-*";
my $textEntryBold  = "-*-fixed-bold-r-normal--13-120-*-*-*-*-*-*";

open(STDOUT, '>', 'output.log') or die "Can't open log";
open(STDERR, '>', 'output_error.log') or die "Can't open log";
my $dbFile = "db.txt";
#local $/;
open (my $fh, '<', $dbFile) or die "Could not open file '$dbFile' $!";
my $debug = 0;
my $showbox = 0;
my $file;
my @matchederrorarray;
my @matchedsolutionarray;
my @matchedjiraarray;	
ImportDb();
#OpenInBrowser('import status');	
#GotoJira('TM-9200');	
my %errors = (
			'group not found' =>[0,'modify the xml and resend work'],
			'put on hold' => [1,'issue with cds database']);
our %hash;
my $errorvalue;
my $location;
my $globalfilename;
my $globalerrorname;
my $mw = MainWindow->new;
$mw->geometry("1000x760+50+50");
$mw->title("Log Analysis Tool");

my $menu = $mw->Frame(-relief => 'sunken',-borderwidth => 2,-background  => $bkgrndMenuClr)->pack(-fill => 'x');

$menu->Menubutton(
            -text       => 'File',
            -underline  => 0,
            -tearoff    => 0,
            -background => $bkgrndMenuClr,
            -foreground => 'white',
            -menuitems  => [
				[Button => '~Import database...', -command => [\&ImportDb],
                                                            -font             => $text_font,
                                                            -foreground       => 'black',
                                                            -activeforeground => 'white',
                                                            -activebackground => 'blue'],
				[Button => '~Find a solution', -command => [\&FindSol],
                                                            -font             => $text_font,
                                                            -foreground       => 'black',
                                                            -activeforeground => 'white',
                                                            -activebackground => 'blue'],
				[separator => "-----------------"],													
															
                [Button => 'E~xit...',              -command => [\&ExitTool],
                                                    -font             => $text_font,
                                                    -foreground       => 'black',
                                                    -activeforeground => 'white',
                                                    -activebackground => 'blue'],
                
                
                
            ])->pack(-side => 'left');

$menu->Menubutton(
            -text       => 'Add',
            -underline  => 0,
            -tearoff    => 0,
            -background => $bkgrndMenuClr,
            -foreground => 'white',
            -menuitems  => [
                [Button => 'Add ~New error',   -command => [\&AddNew],
                                                    -font             => $text_font,
                                                    -foreground       => 'black',
                                                    -activeforeground => 'white',
                                                    -activebackground => 'blue'],
                
                [separator => "-----------------"],
                [Button => 'Upload Logs       ',-command => [\&UploadLogs],
                                                    -font             => $text_font,
                                                    -foreground       => 'black',
                                                    -activeforeground => 'white',
                                                    -activebackground => 'blue'],
            ])->pack(-side => 'left');
			
$menu->Menubutton(
            -text       => 'Scan',
            -underline  => 0,
            -tearoff    => 0,
            -background => $bkgrndMenuClr,
            -foreground => 'white',
            -menuitems  => [
                [Button => 'Scan ~files',   -command => [\&Scanfile],
                                                    -font             => $text_font,
                                                    -foreground       => 'black',
                                                    -activeforeground => 'white',
                                                    -activebackground => 'blue'],
				[Button => 'Scan fol~ders',   -command => [\&Scanfolders],
                                                    -font             => $text_font,
                                                    -foreground       => 'black',
                                                    -activeforeground => 'white',
                                                    -activebackground => 'blue'],
                
            ])->pack(-side => 'left');

			
#####ExitTool function ####

sub ExitTool {
	my $subname = (caller(0))[3];
	print "Came to $subname\n" if $debug;
	print "Exiting from tool" if $debug;
	exit;
} 

#### AddNew Function ########

sub AddNew {
	
	my $subname = (caller(0))[3];
	print "Came to $subname\n" if $debug;
	$mw->messageBox(-message => "AddNew Pushed", -type => "ok") if $showbox;
	
	
	}

sub FindSol{
	
	my $subname = (caller(0))[3];
	print "Came to $subname\n" if $debug;
	my $dialog = $mw->Toplevel() ;
	$dialog->title("Search for solution");
	#$dialog->resizable(0,0);
	$dialog->configure(-background => 'white');
	$dialog->geometry("800x460");
	
	my $logentry = $dialog->Frame(-background   => $blueHighLightClr,
                                                       )->pack(-side => 'top',
                                                               -fill => 'x',
                                                               );
	my $bottomentry = $dialog->Frame(-background   => $blueHighLightClr,
                                                       )->pack(-side => 'bottom',
                                                               -fill => 'x',
                                                               );
															   
	my $entry1 = $logentry->Label(-text         => "Enter the error below",
                                         -font         => $heading_font,
                                         -background   => $blueHighLightClr,
                                         -foreground   => 'black',										 
                                        )->pack(-side => 'left');
	
	$errorvalue = $dialog->Entry(-selectborderwidth => 40,-width      => '68',-background => $bkgrndSelectClr,-font       => $textEntryFont,  -relief     => 'sunken' )->pack(-expand => 1, 
                                                -fill => 'x',
                                                -ipadx => 10,
                                                -ipady => 30);
	
	                                                              
	my $button1 = $bottomentry->Button(-text => "Find", -command => \&button1_sub)->pack();
		
	while( my( $key, $value ) = each %errors )
	{
   # print "$key: $value->[1]\n";
	}
		
	
	}

sub ImportDb{
	
	### Loading file into a hash
	
	
	# open (my $fh, '<', $dbFile) or die "Could not open file '$dbFile' $!";
	my $subname = (caller(0))[3];
	print "Came to $subname\n" if $debug;
	while (my $row = <$fh>)
	{
	chomp $row;
	#print $row;
	my @word2;
	
	my ($word1,$word2) = split (/=>/, $row);
	my @word = split (/=>/, $row);
	
	$hash{$word1} = $word2;
	 
	}
	
while( my( $key, $value ) = each %hash )
	{
    #print "$key => $value\n";
	my @array = split(/,/,$value);
	$key =~s/'//g;
	$array[1] =~s/'//g;
	$array[1] =~s/]//g;
	#print $array[1];
	#print "\n";
	print "$key => $array[1]\n" if $debug;
	}	
	

}

sub button1_sub {

	my $subname = (caller(0))[3];
	print "Came to $subname\n" if $debug;
	my $copied_text = $errorvalue->get();
	#print $copied_text;
	print "\n" if $debug;
	#Commenting below two lines as new algorithm compares with whole string
	#my @error_array = split(/ /,$copied_text);
	#Match(\@error_array);
	NewMatch($copied_text);
	# foreach my $keyword (@error_array)
	# {
	# chomp $keyword;
	# print $keyword;
	# print"\n";
	
	# } 
  
  
}

sub NewMatch {
	my $subname = (caller(0))[3];
	print "Came to $subname\n" if $debug;
	my $arg = shift;
	#print $arg;
	print"\n" if $debug;
	my @key2 = keys(%hash);
	## Key 2 has stored error keys
	
	foreach my $key2 (@key2)
	{
	print $key2 if $debug;
	print"\n" if $debug;
	my $true = 0;
	$true = ($key2 =~ m/$arg/i);
	print $true if $debug;
	print $key2;
	print"\n" if $debug;
	
	if ($true == 1)
	{
	print $hash{$key2} if $debug;
	print"\n" if $debug;
	my @output = split(/,/,$hash{$key2});
	
	foreach my $output (@output)
	{
	RemoveChar($output);
	}
		
	print $output[0] if $debug;
	print"\n" if $debug;
	print $output[1] if $debug;
	print"\n" if $debug;
	print $output[2] if $debug;
	print"\n" if $debug;
	$mw->messageBox(-message=>"The likely root cause or fix  is '$output[1]'", -type => "ok") if $showbox;
	
	OpenInBrowser($arg);
	if ($output[2] ne '')
	{
	GotoJira($output[2]);
	}
	}
	}
		
	
	exit;	
	
	}
	
sub RemoveChar {
	my $subname = (caller(0))[3];
	print "Came to $subname\n" if $debug;
	
	#my $output = shift;
	#$output = $$output;
	$_[0] =~s/'//g;
	$_[0] =~s/]//g;
	$_[0] =~s/\[//g;
	
	print"\n" if $debug;
	#$output =~s/[//g;

}	

sub Match {
	my $subname = (caller(0))[3];
	print "Came to $subname\n" if $debug;
	our %errhashcount;
	our @output;
	our $great;
	my ($one) = @_;
	my @one = @{$one};
	foreach my $key1 (@one)
	{
	#print $key1;  ##Key 1 has typed errors
	#print"\n";
	my @key2 = keys(%hash);
	## Key 2 has stored error keys
	
	foreach my $key2 (@key2)
	{
	#print $key2;
	print"\n" if $debug;
	my $true = 0;
	$true = ($key2 =~ m/$key1/i);
	print $true if $debug;
	
	print"\n" if $debug;
	if ($true == 1)
	{
	print $hash{$key2} if $debug;
	print"\n" if $debug;
	$errhashcount{$key2} = $errhashcount{$key2} + 1;
	print $key2." count is ".$errhashcount{$key2} if $debug;
	print"\n" if $debug;
	@output = split(/,/,$hash{$key2});
	
	$output[1] =~s/'//g;
	$output[1] =~s/]//g;	
	
	### Here blacklist common words like is, not, and that are found in logs, they will be shown as matches
	
	}
		
	}
	
	}
	my @heights = sort { $errhashcount{$a} <=> $errhashcount{$b} } values %errhashcount;
	my $highest = $heights[-1];
 
	print "$highest\n" if $debug;
	my @k =  keys(%errhashcount);
	my @v =  values(%errhashcount);
	my $hashcount = scalar(%errhashcount);
	
	for (my $i=0;$i<$hashcount;$i=$i+1)
	{
	if ($v[$i] == $highest)
	{
	print $k[$i] if $debug;
	print"\n" if $debug;
	#$output[1] = $i;
	}
	}
		
	
	$mw->messageBox(-message=>"The likely root cause or solution is '$output[1]'", -type => "ok") if $showbox;	
	
	exit;
}

sub Scanfile {
	
	my $subname = (caller(0))[3];
	print "Came to $subname\n" if $debug;
	my $dialog = $mw->Toplevel() ;
	$dialog->title("Upload logs");
	#$dialog->resizable(0,0);
	$dialog->configure(-background => 'white');
	$dialog->geometry("500x260");
	
	my $logentry = $dialog->Frame(-background   => $blueHighLightClr,
                                                       )->pack(-side => 'top',
                                                               -fill => 'x',
                                                               );
	my $bottomentry = $dialog->Frame(-background   => $blueHighLightClr,
                                                       )->pack(-side => 'bottom',
                                                               -fill => 'x',
                                                               );
															   
	my $entry1 = $logentry->Label(-text         => "Give the location of file below to analyze",
                                         -font         => $heading_font,
                                         -background   => $blueHighLightClr,
                                         -foreground   => 'black',										 
                                        )->pack(-side => 'left');
	
	$location = $dialog->Entry(-selectborderwidth => 40,-width      => '68',-background => $bkgrndSelectClr,-font       => $textEntryFont,  -relief     => 'sunken' )->pack(-expand => 1, 
                                                -fill => 'x',
                                                -ipadx => 10,
                                                -ipady => 30);
	
	                                                              
	my $button1 = $bottomentry->Button(-text => "Upload and Analyze", -command => \&UploadAll)->pack();
		
		

}

sub UploadAll {
	
	my $subname = (caller(0))[3];
	print "Came to $subname\n" if $debug;
	my $copied_text = $location->get();
	print $copied_text if $debug;
	print "\n" if $debug;
	
	#my @files = glob($copied_text .'/*.*');
	# my @files = glob($copied_text .'/*.*');
	
	# foreach my $file (@files)
	# {
	# print "$file\n" if $debug;
	# Loadfile($file);
	# }
	find({ wanted => \&getfiles, no_chdir => 1 }, $copied_text);
	
	$mw->messageBox(-message=>"Scan finished", -type => "ok");
	exit;
	
	}

sub Loadfile {
	
	my $subname = (caller(0))[3];
	print "Came to $subname\n" if $debug;
	my ($filename) = @_;
	$globalfilename = $filename;
	
	print "$filename\n" if $debug;
	
		
	open (my $fh, '<', $filename) or die "Could not open file '$dbFile' $!";
	
	while (my $row = <$fh>)
	{
	
	next if /^\s$/;
	
	chomp $row;
	
	MatchWithError($row);
	
		
	}


}

sub MatchWithError {
	
	my $subname = (caller(0))[3];
	print "Came to $subname\n" if $debug;
	my ($text) = @_;	
	my $count = 0;
	
	my @errorarray = keys(%hash);
	
	## Key 2 has stored error keys
	#print "@errorarray\n";
	foreach my $errortext (@errorarray)
	{
	my $true = 0;
	$globalerrorname = $errortext;
	#print "$errortext\n";
	#print $hash{$errortext};
	#print "\n";
	$errortext =~s/'//g;     # removing ' present in hash
	$errortext =~ s/\s+$//;  #removing space at end
	#print "$errortext\n";
	
	if($text ne "")
	{
	print "$text\n" if $debug;
	
	if ($text =~ m/$errortext/i)
	{
	#print"We got matching for error '$errortext' in the line $text in $globalfilename\n\n";	
	push(@matchederrorarray,$errortext);
	
	my @output = split(/,/,$hash{$globalerrorname});
	
	foreach my $output (@output)
	{
	RemoveChar($output);
	}
		
	print $output[0] if $debug;
	print"\n" if $debug;
	print $output[1] if $debug;
	print"\n" if $debug;
	print $output[2] if $debug;
	print"\n" if $debug;
	#print"Root cause is '$output[1]'\n\n";
	push(@matchedsolutionarray,$output[1]);
	push(@matchedjiraarray,$output[2]);
	foreach my $displayerror (@matchederrorarray)
	{
	print "errortext=$errortext\n" if $debug;
	print "displayerror=$displayerror\n" if $debug;
	if($errortext eq $displayerror)
	{
	$count = $count + 1;
	print "$count\n" if $debug;
	}	
	}
	if($count == 1)
	{
	print"We got matching for error '$errortext' in the line '$text' in the file $globalfilename\n\n";
	print"Root cause or fix is '$output[1]'\n\n";	
	$mw->messageBox(-message=>"The likely root cause or fix for $globalerrorname is '$output[1]'", -type => "ok");
	
	OpenInBrowser($errortext);
	if ($output[2] ne '')
	{
	GotoJira($output[2]);
	}
	}
	}		
	}
	}
	
}

sub OpenInBrowser {
	
	my $subname = (caller(0))[3];
	print "Came to $subname\n" if $debug;
	my ($filename) = @_;
	print "$filename\n" if $debug;
	my ($query) = "http://jira.ncr.com/issues/?jql=project%20in%20(IABMR%2C%20TM%2C%20TGSR%2C%20XPAY)%20AND%20text%20~%20%22$filename%22";
	
	my @args = ("start","C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe","$query");
	system @args;
	
	
}

sub GotoJira {
	
	my $subname = (caller(0))[3];
	print "Came to $subname\n" if $debug;
	my ($filename) = @_;
	print "$filename\n" if $debug;
	my ($query) = "http://jira.ncr.com/browse/$filename";
	
	my @args = ("start","C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe","$query");
	system @args;
	
	
}

# When jira is mentioned in db.txt, open jira page directly when searched for.

	
sub Scanfolders {
	
	my $subname = (caller(0))[3];
	print "Came to $subname\n" if $debug;
	my $loglocations = "locations.txt";
	open (my $handle, '<', $loglocations) or die "Could not open file '$loglocations' $!";	
	while (my $row = <$handle>)
	{
	chomp $row;
	print "$row\n" if $debug;
	find({ wanted => \&getfiles, no_chdir => 1 }, $row);
	
	}
	}

sub getfiles {

if (-f $_)
{
$file = $_;
print $file if $debug;
print "\n" if $debug;
Loadfile($file);
}



}	


MainLoop;