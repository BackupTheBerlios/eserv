######################################################################
#	Elog_lib.pl
#	�������� ���������� ��������� ������� ��������� ����������
#	Elog
#
#	19 ����� 2003 ����				��� "����"
######################################################################


######################################################################
#	Runtime
#	����� ��������������� �������
######################################################################

package Runtime;

######################################################################
#	BeginPage
#	����� ���������� ��������� HTML-��������.
#	�����:
#		Runtime->BeginPage (Title)
#	���������:
#		Title - ��������� ��������.
######################################################################

sub BeginPage {
   shift;							# ��� ������ �� ���������
   my $Title = shift;					# ��������� ��������
   ::DisplayHTTPHeader ("200 OK", "windows-1251");	# ������� ��������� HTTP
   print HTML->BeginPage (Title => $Title, Charset => "windows-1251",
     Body => { bgcolor => "#F7FBFF", text => "#000000", link => "#000080",
      alink => "#C00000", vlink => "#4040C0" });	# ������� ���� ������ ��������
   print HTML->Style (Style => { "select, input, textarea, td, p" => { "font-family" => "Arial",
     "font-size" => "10pt" },
     td => { "vertical-align" => "top" },
     hr => { color => "#404040" },
     ".title" => { color => "#800000", "font-size" => "12pt", "font-weight" => "bold",
      "text-align" => "center" },
     ".subtitle" => { color => "#008080", "font-weight" => "bold" },
     ".subtitlec" => { color => "#008080", "font-weight" => "bold", "text-align" => "center" },
     ".copyright" => { "font-size" => "8pt", "text-align" => "center" },
     ".thead" => { color => "#000080", "background-color" => "#C0E0FF" },
     ".tborder" => { "background-color" => "#404040" },
     ".alt1" => { "background-color" => "#F7FFF7" },
     ".alt2" => { "background-color" => "#F7FBFB" }});	# ������� ������� ������ ��� Internet Explorer
   print HTML->Style (Style => { "select, input, textarea, td, p" => { fontfamily => "'Arial'",
     fontsize => "10pt" },
     td => { verticalalign => "top" },
     hr => { color => "#404040" },
     ".title" => { color => "#800000", fontsize => "12pt", fontweight => "bold",
      textalign => "center" },
     ".subtitle" => { color => "#008080", fontweight => "bold" },
     ".subtitlec" => { color => "#008080", fontweight => "bold", textalign => "center" },
     ".copyright" => { fontsize => "8pt", textalign => "center" },
     ".thead" => { color => "#000080", backgroundcolor => "#C0E0FF" },
     ".tborder" => { backgroundcolor => "#404040" },
     ".alt1" => { backgroundcolor => "#F7FFF7" },
     ".alt2" => { backgroundcolor => "#F7FBFB" }});	# ������� ������� ������ ��� Netscape Navigator
}

######################################################################
#	EndPage
#	����� ���������� ��������� HTML-��������.
######################################################################

sub EndPage {
   print HTML->Paragraph (Param => { class => "copyright" }, Text => "Elog 1.0 RC1" .
     HTML->Break () . "&copy; " .
     HTML->Anchor (Param => { href => "mailto:dimisaev\@mail.ru" }, Text => "������� �����") .
      " 1999, ����" . HTML->Break () . "&copy; " .
     HTML->Anchor (Param => { href => "http://www.lankgroup.ru/", target => "_blank"},
     Text => "��� &quot;����&quot;") . " 2003");	# ������� ��������
   print HTML->EndPage ();				# ������� ��������
}


######################################################################
#	Environment
#	����� ������� ��������� ������� �����
######################################################################

package Environment;

######################################################################
#	Load
#	��������� ������� ����� �� ������ ���������������� ������.
#	�����:
#		Environment->Load ([SoftErrors])
#	���������:
#		SoftErrors - ���� ���������� ������ ��������.
#	���������� ������ �� ����� ��������� ��� �������� ������
#	Environment.
######################################################################

sub Load {
   my $Self = shift;					# ������ �� ������ ��� ��� ������
   my $SoftErrors = shift () + 0;			# ���� ���������� ������
   if (ref ($Self) eq "") {				# ������ ����� ������
	my $New = { error => "", logdatapath => "", cgiurl => "", noncgiurl => ".",
	  hotactions => "", ignorehosts => "",
	  startdate => undef, enddate => undef,
	  host => "", peerip => "", user => "", mode => "h", sort => "g", reverse => 1 };	# ������� ����� ������
	$Self->{"timezone"} = Time->SystemTimeOffset ();	# �������� ��������� �������� �������� �������
	$Self = bless ($New, $Self);			# ��������� � ������
   }
   $Self->{"inipath"} = ".";				# �� ��������� ����� � ������� ��������
   if (!$Self->_ReadIni ("config.ini", qw (IniPath))) {	# ��������� ������� ��������� ������������ �� �������
	$Self->{"error"} = "Error reading configuration file config.ini";
	return $Self;					# ������� ������
   }
   if (!$Self->_ReadIni ("path.ini", qw (LogDataPath))) {	# �� ������� ��������� ������� ���������
	if (!$SoftErrors) {				# ������ �� �����������
	   $Self->{"error"} =
	     "Error reading configuration file " . $Self->{"inipath"} . "/path.ini";
	   return $Self;					# ������� ������
	}
   }
   if (!$SoftErrors && ($Self->{"logdatapath"} eq "")) {	# �� ������ ������ ����
	$Self->{"error"} = "Undefined critical data path in " . $Self->{"inipath"} . "/path.ini";
	return $Self;
   }
   if (!$Self->_ReadIni ("setup.ini", qw (CGIURL NonCGIURL HotActions IgnoreHosts TimeZone))) {	# �� ������� ��������� ���������
	$Self->{"error"} =
	  "Error reading configuration file " . $Self->{"inipath"} . "/setup.ini";
   }
   my %HotActions = map { uc ($_) => 1 } split (/ /, $Self->{"hotactions"});	# ������� �������������� �������
   my %IgnoreHosts = map { lc ($_) => 1 } split (/ /, $Self->{"ignorehosts"});	# ������� ������������ ������
   $Self->{"hotactions"} = \%HotActions;		# �������� ������ �������� �� ����
   $Self->{"ignorehosts"} = \%IgnoreHosts;
   if (!defined ($Self->{"startdate"})) {		# ��������� ���������� �� ����-������� ��� �� ������
	my $DayTime = DateTime->Now ($Self->{"timezone"})->MidNight ();	# ������� �������� ���
	$Self->{"startdate"} = $DayTime->GoDay (1 - $DayTime->Day ());	# ������ ����� ������
	$Self->{"enddate"} = $DayTime->Copy ()->GoMonth (1);	# ������ ������
   }
   return $Self;						# ������� ������
}

######################################################################
#	AttachUserSettings
#	����� ����������� ���������������� ���������.
#	�����:
#		Object->AttachUserSettings (CGI, Cookies)
#	���������:
#		CGI	  - ������ �� ������ CGI;
#		Cookies - ������ �� ������ Cookies.
######################################################################

sub AttachUserSettings {
   my $Self = shift;					# ������ �� ������
   my $CGI = shift;					# ������ �� CGI
   my $Cookies = shift;					# ������ �� Cookies
   my $Temp = $CGI->RetrieveValue ("h");		# ������ �� ������
   $Temp = $Cookies->RetrieveValue ("h") if (!defined ($Temp));	# ����� �� �������������� ��������
   $Self->{"host"} = lc ($Temp) if (defined ($Temp));	# ���������� � ����������
   $Temp = $CGI->RetrieveValue ("i");		# ������ �� IP-�������
   $Temp = $Cookies->RetrieveValue ("i") if (!defined ($Temp));	# ����� �� �������������� ��������
   $Self->{"peerip"} = $Temp if (defined ($Temp));	# ���������� � ����������
   $Temp = $CGI->RetrieveValue ("u");		# ������ �� �������������
   $Temp = $Cookies->RetrieveValue ("u") if (!defined ($Temp));	# ����� �� �������������� ��������
   $Self->{"user"} = lc ($Temp) if (defined ($Temp));	# ���������� � ����������
   $Temp = $CGI->RetrieveValue ("m");		# ����� �������
   $Temp = $Cookies->RetrieveValue ("m") if (!defined ($Temp));	# ����� �� �������������� ��������
   $Self->{"mode"} = $Temp if (defined ($Temp));	# ���������� � ����������
   $Temp = $CGI->RetrieveValue ("s");		# ����� ����������
   $Temp = $Cookies->RetrieveValue ("s") if (!defined ($Temp));	# ����� �� �������������� ��������
   $Self->{"sort"} = $Temp if (defined ($Temp));	# ���������� � ����������
   $Temp = $CGI->RetrieveValue ("r");		# ���� ��������� ����������
   $Temp = $Cookies->RetrieveValue ("r") if (!defined ($Temp));	# ����� �� �������������� ��������
   $Self->{"reverse"} = $Temp if (defined ($Temp));	# ���������� � ����������
   if ($CGI->Count ("sd")) {				# ���� � ����� �������� �� �����
	my ($SD, $SM, $SY, $SH, $SI, $ED, $EM, $EY, $EH, $EI) =
	  Misc->Define ($CGI->RetrieveValue ("sd"), $CGI->RetrieveValue ("sm"),
	  $CGI->RetrieveValue ("sy"), $CGI->RetrieveValue ("sh"), $CGI->RetrieveValue ("si"),
	  $CGI->RetrieveValue ("ed"), $CGI->RetrieveValue ("em"), $CGI->RetrieveValue ("ey"),
	  $CGI->RetrieveValue ("eh"), $CGI->RetrieveValue ("ei"));		# �������
	my ($StartDate, $EndDate) =
	  sort (DateTime->Create ($SY, $SM, $SD, $SH, $SI, 0)->ToInternalString (),
	  DateTime->Create ($EY, $EM, $ED, $EH, $EI, 0)->ToInternalString ());	# ��������������� ������ �������
	$Self->{"startdate"} = DateTime->FromInternalString ($StartDate);	# ������������ ������
	$Self->{"enddate"} = DateTime->FromInternalString ($EndDate);
   } else {
	$Temp = $CGI->RetrieveValue ("dd");		# ������������ ������ �������
	$Temp = $Cookies->RetrieveValue ("dd") if (!defined ($Temp));	# ����� �� �������������� ��������
	if (defined ($Temp)) {				# ����������
	   my ($StartDate, $EndDate) = sort (split (/,/, $Temp));	# ������� �� ��������� � �������� � ������ �������������
	   $Self->{"startdate"} = DateTime->FromInternalString ($StartDate);	# ������������ ������
	   $Self->{"enddate"} = DateTime->FromInternalString ($EndDate);
	}
   }
}

######################################################################
#	_ReadIni
#	������ ����������������� �����.
#	�����:
#		Object->_ReadIni (File[, List])
#	���������:
#		File - ��� ����������������� �����. ���� ������ �
#		       ��������, ���������� ���������� IniPath;
#		List - ������ ����������� �������� ����. ���� ������
#		       ����, ���� ����������� � ��������� �������.
#	���������� ��������� ��������, ���� ���� ������� ��������, �
#	������� � ��������� ������.
######################################################################

sub _ReadIni {
   my $Self = shift;					# ������ �� ������
   my $File = shift;					# ��� ����������������� �����
   my %KeyList = map { (lc ($_) => 1) } @_;	# ������� �������� ����
   local *CONFIG;						# ������� �������� � �������
   return 0 if (!open (CONFIG, $Self->{"inipath"} . "/" . $File));	# ���� �� �������� - ������
   while (my $String = <CONFIG>) {			# �� ����� �����
	chomp ($String);					# ������ ����� ������
	if ($String =~ m/\t/) {				# ������ ����������� �������
	   my ($Name, $Value) = split (/\t/, $String, 2);	# ������� �� ��� � ��������
	   $Name = lc ($Name);				# �������� � ������� ��������
	   $Self->{$Name} = $Value if (!%KeyList || $KeyList{$Name});	# ��� ���������� ��� �������� ��������
	}
   }
   close (CONFIG);					# ������� ����
   return 1;						# ���������
}

######################################################################
#	AUTOLOAD
#	��������������� ������� ��������� �������� ����������� ����������
######################################################################

use vars qw ($AUTOLOAD %AllowedParameters);
for (qw (inipath logdatapath cgiurl noncgiurl hotactions ignorehosts host peerip user
  timezone startdate enddate mode sort reverse error)) {
   $AllowedParameters{$_} = 1; }			# ������������ ������� ����������

sub AUTOLOAD {
   my $Name = lc ($AUTOLOAD);				# ��� ����������� ������
   $Name =~ s/.*:://;					# ������ ������
   return $_[0]->{$Name} if (exists ($AllowedParameters{$Name}));	# �������� ����������� ���������
   return undef;						# ��� ������ ���������
}

1;
