######################################################################
#	Elog_Index.pl
#	����� ����� ������ ���������� ������ ���������� ��� �������
#	Elog
#
#	19 ����� 2003 ����				��� "����"
######################################################################

######################################################################
#	ProcessRequest
#	�������� ��������� ���������� �������.
######################################################################

sub ProcessRequest ($) {
   my @MonthNames = ("������", "�������", "�����", "������", "���", "����", "����", "�������",
     "��������", "�������", "������", "�������");	# ��������������� ������� �������
   Runtime->BeginPage ("Elog - ���������� ������ Eserv/3");	# ������� ������ ��������
   print HTML->Paragraph (Text => "������� ����� ���������", Param => { class => "title" });	# ������� ���������
   print HTML->Form (BeginOnly => 1, Param => { target => "_blank",
     action => ($Environment->CGIURL . "/Elog.cgi"), method => "GET", name => "QueryForm" });	# ������ �����
   print HTML->Table (BeginOnly => 1, Param => { class => "tborder", width => "100%",
     border => 0, cellspacing => 0, cellpadding => 0 });	# ������ �������-�����
   print HTML->Tr (BeginOnly => 1), HTML->Td (BeginOnly => 1);	# ������ ������ � ������
   print HTML->Table (BeginOnly => 1, Param => { width => "100%", border => 0,
     cellspacing => 1, cellpadding => 5 });	# ������ ��������� �������
   print HTML->Tr (Param => { class => "thead" }, Text =>
     HTML->Td (Param => { colspan => 2, align => "center" }, Text =>
     HTML->Bold (Text => "�������������")));	# ������� ������������ ������
   print HTML->Tr (Param => { class => "alt1" }, Text =>
     HTML->Td (Param => { class => "subtitle" }, Flags => { nowrap => 1 },
     Text => "�������� ������ ��:") .
     HTML->Td (Text =>
      HTML->NoBr (Text =>
	 HTML->Input (Param => { type => "radio", name => "m", value => "h" },
        Flags => { checked => ($Environment->Mode eq "h") }) . "������ &nbsp; ") .
      HTML->NoBr (Text =>
	 HTML->Input (Param => { type => "radio", name => "m", value => "i" },
        Flags => { checked => ($Environment->Mode eq "i") }) . "IP-������� &nbsp; ") .
      HTML->NoBr (Text =>
	 HTML->Input (Param => { type => "radio", name => "m", value => "u" },
        Flags => { checked => ($Environment->Mode eq "u") }) . "������������� &nbsp; ") .
      HTML->NoBr (Text =>
	 HTML->Input (Param => { type => "radio", name => "m", value => "o" },
        Flags => { checked => ($Environment->Mode eq "o") }) . "��������")));	# ������� ������ ������ ���� ����������
   print HTML->Tr (Param => { class => "alt2" }, Text =>
     HTML->Td (Param => { class => "subtitle" }, Flags => { nowrap => 1 },
     Text => "����������� ������ ��:") .
     HTML->Td (Text =>
      HTML->NoBr (Text =>
	 HTML->Input (Param => { type => "radio", name => "s", value => "h" },
        Flags => { checked => ($Environment->Sort eq "h") }) . "������ &nbsp; ") .
      HTML->NoBr (Text =>
	 HTML->Input (Param => { type => "radio", name => "s", value => "i" },
        Flags => { checked => ($Environment->Sort eq "i") }) . "IP-������� &nbsp; ") .
      HTML->NoBr (Text =>
	 HTML->Input (Param => { type => "radio", name => "s", value => "u" },
        Flags => { checked => ($Environment->Sort eq "u") }) . "������������� &nbsp; ") .
      HTML->NoBr (Text =>
	 HTML->Input (Param => { type => "radio", name => "s", value => "o" },
        Flags => { checked => ($Environment->Sort eq "o") }) . "�������� &nbsp; ") .
      HTML->NoBr (Text =>
	 HTML->Input (Param => { type => "radio", name => "s", value => "g" },
        Flags => { checked => ($Environment->Sort eq "g") }) . "������� ��������� &nbsp; ") .
      HTML->NoBr (Text =>
	 HTML->Input (Param => { type => "radio", name => "s", value => "p" },
        Flags => { checked => ($Environment->Sort eq "p") }) . "������� ������������� &nbsp; ") .
      HTML->NoBr (Text =>
	 HTML->Input (Param => { type => "radio", name => "s", value => "t" },
        Flags => { checked => ($Environment->Sort eq "t") }) . "������������ �������") .
      HTML->Hr (Param => { size => 1, width => "100%" }, Flags => { noshade => 1 }) .
      HTML->NoBr (Text =>
       HTML->Input (Param => { type => "radio", name => "r", value => 0 },
        Flags => { checked => !$Environment->Reverse }) . "�� ����������� &nbsp; ") .
      HTML->NoBr (Text =>
       HTML->Input (Param => { type => "radio", name => "r", value => 1 },
        Flags => { checked => $Environment->Reverse }) . "�� ��������")));	# ������� ������ ���� ����������
   print HTML->Tr (Param => { class => "thead" }, Text =>
     HTML->Td (Param => { colspan => 2, align => "center"}, Text =>
     HTML->Bold (Text => "�����")));		# ������� ������������ ������
   print HTML->Tr (Param => { class => "alt1" }, Text =>
     HTML->Td (Param => { class => "subtitle" }, Flags => { nowrap => 1 },
     Text => "���� � �����:") .
     HTML->Td (Text =>
      HTML->NoBr (Text => "� &nbsp;" .
       HTML->Select (Param => { name => "sd" }, Text =>
       join ("", map {
	   HTML->Option (Param => { value => $_ },
	     Flags => { selected => ($Environment->StartDate->Day == $_)
       }) . $_ } (1..31))) .
       HTML->Select (Param => { name => "sm" }, Text =>
       join ("", map {
	   HTML->Option (Param => { value => $_ },
	     Flags => { selected => ($Environment->StartDate->Month == $_)
       }) . $MonthNames[$_ - 1] } (1..12))) .
       HTML->Input (Param => { name => "sy", value => $Environment->StartDate->Year, size => 4,
        maxlength => 4 }) . " " .
       HTML->Select (Param => { name => "sh" }, Text =>
       join ("", map {
	   HTML->Option (Param => { value => sprintf ("%02d", $_) },
	     Flags => { selected => ($Environment->StartDate->Hour == $_)
       }) . sprintf ("%02d", $_) } (0..23))) . ":" .
       HTML->Select (Param => { name => "si" }, Text =>
       join ("", map {
	   HTML->Option (Param => { value => sprintf ("%02d", $_) },
	     Flags => { selected => ($Environment->StartDate->Minute == $_)
       }) . sprintf ("%02d", $_) } (0..59))) .
       " &nbsp; ") .
      HTML->NoBr (Text => "�� &nbsp;" .
       HTML->Select (Param => { name => "ed" }, Text =>
       join ("", map {
	   HTML->Option (Param => { value => $_ },
	     Flags => { selected => ($Environment->EndDate->Day == $_)
       }) . $_ } (1..31))) .
       HTML->Select (Param => { name => "em" }, Text =>
       join ("", map {
	   HTML->Option (Param => { value => $_ },
	     Flags => { selected => ($Environment->EndDate->Month == $_)
       }) . $MonthNames[$_ - 1] } (1..12))) .
       HTML->Input (Param => { name => "ey", value => $Environment->EndDate->Year, size => 4,
        maxlength => 4 }) . " " .
       HTML->Select (Param => { name => "eh" }, Text =>
       join ("", map {
	   HTML->Option (Param => { value => sprintf ("%02d", $_) },
	     Flags => { selected => ($Environment->EndDate->Hour == $_)
       }) . sprintf ("%02d", $_) } (0..23))) . ":" .
       HTML->Select (Param => { name => "ei" }, Text =>
       join ("", map {
	   HTML->Option (Param => { value => sprintf ("%02d", $_) },
	     Flags => { selected => ($Environment->EndDate->Minute == $_)
       }) . sprintf ("%02d", $_) } (0..59))))));	# ����� �� ���� � �������
   print HTML->Tr (Param => { class => "alt2" }, Text =>
     HTML->Td (Param => { class => "subtitle" }, Flags => { nowrap => 1 },
     Text => "����:") .
     HTML->Td (Text =>
     HTML->Input (Param => { type => "text", name => "h",
     value => HTML->HTMLCode ($Environment->Host), size => 80, maxlength => 80 })));	# ����� �� �����
   print HTML->Tr (Param => { class => "alt1" }, Text =>
     HTML->Td (Param => { class => "subtitle" }, Flags => { nowrap => 1 },
     Text => "IP-�����:") .
     HTML->Td (Text =>
     HTML->Input (Param => { type => "text", name => "i",
     value => HTML->HTMLCode ($Environment->PeerIP), size => 80, maxlength => 80 })));	# ����� �� IP-������
   print HTML->Tr (Param => { class => "alt2" }, Text =>
     HTML->Td (Param => { class => "subtitle" }, Flags => { nowrap => 1 },
     Text => "������������:") .
     HTML->Td (Text =>
     HTML->Input (Param => { type => "text", name => "u",
     value => HTML->HTMLCode ($Environment->User), size => 80, maxlength => 80 })));	# ����� �� ������������
   print HTML->Table (EndOnly => 1);		# ������� �������
   print HTML->Td (EndOnly => 1), HTML->Tr (EndOnly => 1),  HTML->Table (EndOnly => 1);	# ������� �������-�����
   print HTML->Input (Param => { type => "hidden", name => "a", value => "p" });	# ��� ��������
   print HTML->Paragraph (Param => { align => "center" }, Text =>
     HTML->Input (Param => { type => "submit", value => "���������" }) . " &nbsp; " .
     HTML->Input (Param => { type => "reset", value => "��������" }));	# ������� ������
   print HTML->Form (EndOnly => 1);			# ������� �����
   Runtime->EndPage ();				# ������� ��������
}

1;
