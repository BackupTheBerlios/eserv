######################################################################
#	Elog_Parse.pl
#	������� � ������������� ���������� �������������� ������.
#
#	19 ����� 2003 ����				��� "����"
######################################################################

my $CurrentTime;						# �������� �������� �������

######################################################################
#	DisplayState
#	��������� ������ �������� ��������� � ���� ��������.
######################################################################

sub DisplayState ($) {
   my $Message = HTML->JSCode (shift);		# ����� ���������
   my $InsideScript = qq(window.status = "$Message";);	# ����� �������
   print HTML->Script (Param => { Language => "Javascript" }, Text => $InsideScript);	# ������� ������ ��������� ���������
}

######################################################################
#	ModeHeader
#	��������� ����������� ������������ ������� ������
######################################################################

sub ModeHeader ($) {
   my $Mode = shift;					# ��� ������
   return "����" if ($Mode eq "h");
   return "IP-�����" if ($Mode eq "i");
   return "������������" if ($Mode eq "u");
   return "������";
}

######################################################################
#	ProcessRequest
#	�������� ��������� ���������� �������.
######################################################################
#	������ ���������� ������������ ����� ������ ���������� �������:
#	[0] - ���� ����������;
#	[1] - ����� ������������ �������� � �������������;
#	[2] - ������� ����;
#	[3] - �������� ����;
#	[4] - ����� ����� ��������;
#	[5] - ����� �������� �������� (���� ������ 1xx, 2xx, 3xx);
#	[6] - ������, �� �������� ��������� ����������;
#	[7] - ���� (������������ ��� �������� �� ��������).
######################################################################

sub ProcessRequest ($) {
   my $Action = shift;					# ��� ��������
   my $CountMode = $Environment->Mode;		# ����� �������� ����������
   my $SortMode = $Environment->Sort;		# ����� ����������
   Runtime->BeginPage ("Elog - ���������� ������ Eserv/3");	# ������� ������ ��������
   $| = 1;							# ���������� ������

#	��������� ����������, ���������� �������������

   DisplayState ("������ ���������");		# ������� ��������� ���������
   $CurrentTime = time;					# ������������� ������� �����
   my $FileCount = 0;					# ������� ������������ ������
   my $StartTime = substr ($Environment->StartDate->ToInternalString (), 8);	# ����� ������ ���������
   my $EndTime = substr ($Environment->EndDate->ToInternalString (), 8);	# ����� ��������� ���������
   my $StartDay = Date->ToJulian ($Environment->StartDate->Month,
     $Environment->StartDate->Day, $Environment->StartDate->Year);	# ���� ������ ���������
   my $EndDay = Date->ToJulian ($Environment->EndDate->Month,
     $Environment->EndDate->Day, $Environment->EndDate->Year);	# ���� ��������� ���������
   my $HostFilter = $Environment->Host;		# ������ �� �����
   my $UserFilter = $Environment->User;		# ������ �� ������������
   my $PeerIPFilter = $Environment->PeerIP;	# ������ �� IP-������
   my $IgnoreHosts = $Environment->IgnoreHosts;	# ��������� ���������� �� ������
   my $HotActions = $Environment->HotActions;	# ��������� ������ �� ��������
   my ($TotalGet, $TotalPost, $TotalTime) = (0, 0, 0);	# ������������ �������� ����
   my %Stat = ();						# ������� ����������

#	������ ������ �� ������ ����������

   for (my $CurrentDay = $StartDay;
     ($CurrentDay < $EndDay) || (($CurrentDay == $EndDay) && !$EndTime); ++$CurrentDay) {	# ��� ���� � ��������� �� ��������
	local *LOGFILE;					# ��������� �������� ��������
	my $FileName;
	{
	   my ($CMonth, $CDay, $CYear);		# ��������� ����������
	   ($CMonth, $CDay, $CYear, undef) = Date->FromJulian ($CurrentDay);	# ��������� ���� �� ������������
	   $FileName = sprintf ("%04d%02d%02d", $CYear, $CMonth, $CDay) . "stat.log";	# ��� �����
	}
	if (open (LOGFILE, $Environment->LogDataPath . "/" . $FileName)) {	# ���� ��������
	   DisplayState ("�������������� ���� " . $FileName . ", ����� ����������: " . $FileCount);	# ������� ���������
	   $CurrentTime = time;				# ������������� ������� �����
	   while (my $LogLine = <LOGFILE>) {	# ���� ���� ��������
		{
		   my $NewTime = time;			# ��������� ������� �����
		   if ($NewTime > $CurrentTime + 60) {	# ������ ������
			DisplayState ("�������������� ���� " . $FileName .
			  ", ����� ����������: " . $FileCount);	# ������� ���������
			$CurrentTime = time;		# ������������� ������� �����
		   }
		}
		chomp ($LogLine);				# ������ ����� ������
		my @LogLine = split (/ /, $LogLine);	# ������� ������ �� ������������
		pop (@LogLine) if (@LogLine > 10);	# ������� ������ ������� ������
		$LogLine = pop (@LogLine);		# ������� Content-Type
		$LogLine = $1 if ($LogLine =~ m/(.*),$/);		# �������� �������� �������
		push (@LogLine, $LogLine);		# �������� �������
		my $Got = ($CurrentDay != $StartDay) && ($CurrentDay != $EndDay);	# ������� ��������� ��� ������
		if (!$Got) {				# ����������� �����
		   my @Time = localtime ($LogLine[0]);	# �����
		   my $Time = sprintf ("%02d%02d%02d", $Time[2], $Time[1], $Time[0]);	# ����� �� ���������� ������������� 
		   $Got = (($CurrentDay == $StartDay) && ($Time >= $StartTime)) ||
		     (($CurrentDay == $EndDay) && ($Time <= $EndTime));	# �������������� ������ �� �������
		}
		my @Actions;				# ������� � ���� ������
		my @Hosts;					# �����
		if ($Got) {					# ��������� ��� ������
		   @Actions = split (/\//, $LogLine[3]);	# �������
		   $Actions[0] = uc ($Actions[0]);	# �������� � �������� ��������
		   $Got = $HotActions->{$Actions[0]} + 0;	# �������� ������ �� ��������
		}
		if ($Got) {					# ��� ��� ��������
		   @Hosts = split (/\//, $LogLine[8]);	# �����
		   $Hosts[1] = lc ($Hosts[1]);	# �������� � ������� ��������
		   $Got = !($IgnoreHosts->{$Hosts[1]} + 0);	# �������� ������ �� ������
		}
		$Got = (($HostFilter eq "") || ($HostFilter eq $Hosts[1])) if ($Got);	# ���������������� ������ �� �����
		if ($Got) {					# ��� ��� ��������
		   $LogLine[7] = lc ($LogLine[7]);	# �������� ������������� � ������� ��������
		   $Got = (($UserFilter eq "") || ($UserFilter eq $LogLine[7]));	# ���������������� ������ �� ������������
		}
		$Got = (($PeerIPFilter eq "") || ($PeerIPFilter eq $LogLine[2])) if ($Got);	# ���������������� ������ �� IP-������
		if ($Got) {					# ������ �������� ��� ������
		   my $RecordKey = $LogLine[2];	# ����� ����� IP-�����
		   if ($CountMode eq "h") {		# ������� �� ������
			$RecordKey = $Hosts[1];		# ������ �������� ����
		   } elsif ($CountMode eq "o") {	# ������� �� ��������
			$RecordKey = $LogLine[6];	# ������ �������� ������ URL �������
		   } elsif ($CountMode eq "u") {	# ������� �� �������������
			$RecordKey = $LogLine[7];	# ������ �������� ������������
		   }
		   $Stat{$RecordKey} = [ "", 0, 0, 0, 0, 0, $RecordKey, $Hosts[1] ]
		     unless (exists ($Stat{$RecordKey}));	# ������� ����� ������ ����������
		   my $StatRecord = $Stat{$RecordKey};	# ������ ������ �� ������
		   $StatRecord->[1] += $LogLine[1];	# ������� ������������ ��������
		   $TotalTime += $LogLine[1];
		   my @Sizes = split (/\//, $LogLine[4]);	# ��������� ��������
		   $StatRecord->[2] += $Sizes[0];	# ������� �������� ����
		   $TotalGet += $Sizes[0];
		   $StatRecord->[3] += ($Sizes[1] + 0);	# ������� ���������� ����
		   $TotalPost += ($Sizes[1] + 0);
		   ++$StatRecord->[4];			# ��������� ����� ����� ��������
		   ++$StatRecord->[5] if ($Actions[1] =~ m/^[1-3]/);	# ��������� ������� �������� ��������
		   my $SortKey = $LogLine[2];		# ����� ����� IP-�����
		   if ($SortMode eq "h") {		# ���������� �� ������
			$SortKey = $Hosts[1];		# ������ �������� ����
		   } elsif ($SortMode eq "o") {	# ���������� �� ��������
			$SortKey = $LogLine[6];		# ������ �������� ������ URL �������
		   } elsif ($SoftMode eq "u") {	# ���������� �� �������������
			$SortKey = $LogLine[7];		# ������ �������� ������������
		   } elsif ($SortMode eq "g") {	# ���������� �� ������� ���������
			$SortKey = $StatRecord->[2];	# ������ �������� ������������ �����
		   } elsif ($SortMode eq "p") {	# ���������� �� ������� �������������
			$SortKey = $StatRecord->[3];	# ������ �������� ������������ �����
		   } elsif ($SortMode eq "t") {	# ���������� �� ������������ ����������
			$SortKey = $StatRecord->[1];	# ������ �������� ������������ ������������
		   }
		   $StatRecord->[0] = $SortKey;	# �������� ���� ����������
		}
	   }
	   close (LOGFILE);				# ������� ����
	   ++$FileCount;					# ��������� �������
	   DisplayState ("����� ����������: " . $FileCount);	# ������� ���������
	   $CurrentTime = time;				# ������������� ������� �����
	} else {
	   my $NewTime = time;				# ��������� ������� �����
	   if ($NewTime > $CurrentTime + 60) {	# ������ ������
		DisplayState ("����� ����������: " . $FileCount);	# ������� ���������
		$CurrentTime = time;			# ������������� ������� �����
	   }
	}
   }

#	����������

   my @Stat;						# ������ ��� ����������
   if ($Environment->Reverse) {			# ���������� �� ��������
	if ($SortMode =~ m/(g|p|t)/) {		# ���������� �� ������
	   @Stat = sort { $b->[0] <=> $a->[0] } values (%Stat);	# ������������� ������ ����������
	} else {
	   @Stat = sort { $b->[0] cmp $a->[0] } values (%Stat);	# ������������� ������ ����������
	}
   } else {
	if ($SortMode =~ m/(g|p|t)/) {		# ���������� �� ������
	   @Stat = sort { $a->[0] <=> $b->[0] } values (%Stat);	# ������������� ������ ����������
	} else {
	   @Stat = sort { $a->[0] cmp $b->[0] } values (%Stat);	# ������������� ������ ����������
	}
   }
   %Stat = ();						# �������� ��� ������ �� �����

#	���������� ������ ��� ���������� �����������

   my $LinkIndex = 0;					# ����������, ���� �� ����������� ������
   my $BaseLink = "";					# ��������� ��� ������
   {
	my ($NewCountMode, $NewFilter);		# ��� ������������ ������ �� ���������� �����������
	my $NewSortMode = $SortMode;			# �� ��������� ����� ���������� �����������
	my %Filters = ();					# ��������� ����������
	$Filters{"h"} = $HostFilter if ($HostFilter ne "");	# ���� ������ �� �����
	$Filters{"i"} = $PeerIPFilter if ($PeerIPFilter ne "");	# ���� ������ �� IP-������
	$Filters{"u"} = $UserFilter if ($UserFilter ne "");	# ���� ������ �� ������������
	if ($CountMode eq "h") {			# ���������� ��������� �� ������
	   $NewCountMode = (($UserFilter eq "") && ($PeerIPFilter eq "")) ? "i" : "o";	# ����� ����� �������� ����������
	   $NewSortMode = $NewCountMode if ($SortMode eq $CountMode);	# ���������� ��������, ���� ���� �� ������
	   $NewFilter = "h";				# ������������� ������ �� �����
	   $LinkIndex = 6;				# ������ �������� ������� ��� ���������� �������
	   delete ($Filters{"h"}) if (exists ($Filters{"h"}));	# � ������������ ������ ������
	} elsif ($CountMode eq "i") {			# ���������� ��������� �� IP-�������
	   $NewCountMode = ($HostFilter eq "") ? "h" : "o";	# ����� ����� �������� ����������
	   $NewSortMode = $NewCountMode if ($SortMode eq $CountMode);	# ���������� ��������, ���� ���� �� ������
	   $NewFilter = "i";				# ������������� ������ �� IP-������
	   $LinkIndex = 6;				# ������ �������� ������� ��� ���������� �������
	   delete ($Filters{"i"}) if (exists ($Filters{"i"}));	# � ������������ ������ ������
	} elsif ($CountMode eq "u") {			# ���������� ��������� �� �������������
	   $NewCountMode = ($HostFilter eq "") ? "h" : "o";	# ����� ����� �������� ����������
	   $NewSortMode = $NewCountMode if ($SortMode eq $CountMode);	# ���������� ��������, ���� ���� �� ������
	   $NewFilter = "u";				# ������������� ������ �� ������������
	   $LinkIndex = 6;				# ������ �������� ������� ��� ���������� �������
	   delete ($Filters{"u"}) if (exists ($Filters{"u"}));	# � ������������ ������ ������
	} else {						# �������� ��������� �� ��������
	   if ($HostFilter eq "") {			# ���� ���� �����������
		$NewCountMode = "o";			# ���������� ���������� ��������� �� ��������
		$NewFilter = "h";				# ������������� ������ �� �����
		$LinkIndex = 7;				# ������ �������� ������� ��� ���������� �������
	   }
	}
	if ($LinkIndex) {					# ������ �����������
	   $BaseLink = $Environment->CGIURL . "/Elog.cgi?a=i&amp;m=" . $NewCountMode .
	     "&amp;s=" . $NewSortMode . "&amp;r=" . $Environment->Reverse . "&amp;dd=" .
	     $Environment->StartDate->ToInternalString () . "," .
	     $Environment->EndDate->ToInternalString ();	# ��������� ����������� ����� ������
	   while (my ($Key, $Value) = each (%Filters)) {	# ��� ���������� �������
		$Value =~ s/(?![a-zA-Z0-9._])(.)/"%" . sprintf ("%02x", ord ($1))/ge;	# �������������� ��������� �������
		$BaseLink .= "&amp;" . $Key . "=" . HTML->HTMLCode ($Value);	# ��������� � ������
	   }
	   $BaseLink .= "&amp;" . $NewFilter . "=";		# � �������� ��������� ����������� �������
	}
   }

#	����� ����� ������

   print HTML->Paragraph (Text => "���������� ������ Eserv/3", Param => { class => "title" });	# ������� ���������
   {
	my $MonthNames = [ "������", "�������", "�����", "������", "���", "����", "����",
	  "�������", "��������", "�������", "������", "�������" ];	# ��������������� ������� �������
	my $DateFormat = "\aD \aT \aC, \a2H:\a2I";	# ������ �������������� ����-�������
	my @Filters = ();					# ������ ������������ ���������� ������
	push (@Filters, "���� � �����: � " .
	  HTML->HTMLCode ($Environment->StartDate->Format ($DateFormat, $MonthNames)) . " �� " .
	  HTML->HTMLCode ($Environment->EndDate->Format ($DateFormat, $MonthNames)));	# ����� �� ���� � �������
	push (@Filters, "����: " . HTML->HTMLCode ($HostFilter)) if ($HostFilter ne "");	# ����� �� �����
	push (@Filters, "IP-�����: " . HTML->HTMLCode ($PeerIPFilter)) if ($PeerIPFilter ne "");	# ����� �� IP-������
	push (@Filters, "������������: " . HTML->HTMLCode ($UserFilter)) if ($UserFilter ne "");	# ����� �� ������������
	print HTML->Paragraph (Text => join (HTML->Break (), @Filters));	# ������� ��������� ������
   }
   print HTML->Table (BeginOnly => 1, Param => { class => "tborder", width => "100%",
     border => 0, cellspacing => 0, cellpadding => 0 });	# ������ �������-�����
   print HTML->Tr (BeginOnly => 1), HTML->Td (BeginOnly => 1);	# ������ ������ � ������
   print HTML->Table (BeginOnly => 1, Param => { width => "100%", border => 0,
     cellspacing => 1, cellpadding => 2 });	# ������ ��������� �������
   print HTML->Tr (Param => { class => "thead" }, Text =>
     HTML->Td (Param => { align => "center" }, Text => HTML->Bold (Text => "N")) .
     HTML->Td (Param => { align => "center" },
      Text => HTML->Bold (Text => ModeHeader ($CountMode))) .
     HTML->Td (Param => { align => "center" }, Text => HTML->Bold (Text => "��������")) .
     HTML->Td (Param => { align => "center" }, Text => HTML->Bold (Text => "�������")) .
     HTML->Td (Param => { align => "center" }, Text => HTML->Bold (Text => "������������")) .
     HTML->Td (Param => { align => "center" }, Text => HTML->Bold (Text => "�����������")));	# ������� ������������ ������

#	����� �������

   my $LineCount = 0;					# ������� ���������� �����
   my $Stat;						# ������ �� ������ ����������
   for $Stat (@Stat) {					# ��� ������
	++$LineCount;					# ��������� ������� �����
	my $Object = HTML->HTMLCode ($Stat->[6]);	# ��� ������������� �������
	if ($LinkIndex) {					# ��������� ������
	   my $ActiveFilter = $Stat->[$LinkIndex];	# ��� ����������� �������
	   $ActiveFilter =~ s/(?![a-zA-Z0-9._])(.)/"%" . sprintf ("%02x", ord ($1))/ge;	# �������������� ��������� �������
	   $Object = HTML->Anchor (Param => { href => $BaseLink . HTML->HTMLCode ($ActiveFilter),
	     target => "_blank" }, Text => $Object);	# ��������� ������
	}
	print HTML->Tr (Param => { class => ("alt1", "alt2")[$LineCount & 1] }, Text =>
	  HTML->Td (Param => { align => "right" }, Text => $LineCount) .
	  HTML->Td (Param => { align => "left" }, Text => $Object) .
	  HTML->Td (Param => { align => "right" }, Text => $Stat->[3] . " (" .
	   sprintf ("%05.2f", ($TotalPost) ? $Stat->[3] * 100 / $TotalPost: 0) . "%)") .
	  HTML->Td (Param => { align => "right" }, Text => $Stat->[2] . " (" .
	   sprintf ("%05.2f", ($TotalGet) ? $Stat->[2] * 100 / $TotalGet : 0) . "%)") .
	  HTML->Td (Param => { align => "right" }, Text => $Stat->[1] . " (" .
	   sprintf ("%05.2f", ($TotalTime) ? $Stat->[1] * 100 / $TotalTime : 0) . "%)") .
	  HTML->Td (Param => { align => "right" }, Text =>
	   sprintf ("%05.2f", ($Stat->[4]) ? $Stat->[5] * 100 / $Stat->[4] : 0) . "%"));	# ������� ������
   }

#	���������� ������

   print HTML->Tr (Param => { class => "thead" }, Text =>
     HTML->Td (Param => { align => "center" }, Text => "&nbsp;") .
     HTML->Td (Param => { align => "right" }, Text => HTML->Bold (Text => "�����:")) .
     HTML->Td (Param => { align => "right" }, Text => HTML->Bold (Text => $TotalPost)) .
     HTML->Td (Param => { align => "right" }, Text => HTML->Bold (Text => $TotalGet)) .
     HTML->Td (Param => { align => "right" }, Text => HTML->Bold (Text => $TotalTime)) .
     HTML->Td (Param => { align => "center" }, Text => "&nbsp;"));	# ������� ������������ ������
   print HTML->Table (EndOnly => 1);		# ������� �������
   print HTML->Td (EndOnly => 1), HTML->Tr (EndOnly => 1),  HTML->Table (EndOnly => 1);	# ������� �������-�����
   DisplayState ("��������� ���������");		# ������� ��������� ���������
   Runtime->EndPage ();					# ������� ��������
}

1;
