######################################################################
#	HTML_lib.pl
#	���������� ������������ HTML-�����
#
#	5 ����� 2003					��� "����"
######################################################################

package HTML;

######################################################################
#	BeginPage
#	������������ ��������� ����� HTML-��������:
#	<html>, <head>, <title>, <meta>, <body>
#	�����:
#		HTML->BeginPage (Title => s, Charset => s, HTTP-Equiv => r,
#			Name => r, Body => r)
#	���������:
#		Title	     - ��������� ��������;
#		Charset    - ����� ������� �������� ��� ������;
#		HTTP-Equiv - ������ �� ��� ��� ������ ���������� ����
#				 meta http-equiv;
#		Name	     - ������ �� ��� ��� ������ ���������� ����
#				 meta name;
#		Body	     - ������ �� ��� ��� ������ ����������
#				 ���� body;
#		Style	     - ������ �� ��� ��� ������ ���������� �����
#				 ���� body
######################################################################

sub BeginPage {
   shift;							# ��� ������ �� ���������
   my %Parameters = HTML->_GetParameters (\@_, 1);	# ��������� ������
   my $String = "<html><head>\n<meta name='Generator' content='Script'>\n";	# ������������ ���������
   $String .= "<title>" . $Parameters{"title"} . "</title>\n"
     if (defined ($Parameters{"title"}));		# ������� �����
   my %Data = HTML->_GetParameters ($Parameters{"http-equiv"}, 0);	# ��������� HTTP
   $Data{"Content-Type"} = "text/html; charset=" . $Parameters{"charset"}
     if (defined ($Parameters{"charset"}) || ($Parameters{"charset"} ne ""));	# ������ ������� ��������
   while (my ($Param, $Value) = each (%Data)) {	# ��� ���������� ���������
	$String .= "<meta http-equiv='" . $Param . "' content='" . $Value . "'>\n";
   }
   %Data = HTML->_GetParameters ($Parameters{"name"}, 0);	# ���������� � ���������
   while (my ($Param, $Value) = each (%Data)) {	# ��� ���������� ���������
	$String .= "<meta name='" . $Param . "' content='" . $Value . "'>\n";
   }
   return $String . "</head>\n" . HTML->_GenericTag (Tag => "body", BeginOnly => 1,
     Param => $Parameters{"body"}, Style => $Parameters{"style"}) . "\n"; # �������� ��� body � ���������
}

######################################################################
#	EndPage
#	������������ ����������� ����� HTML-��������
#	�����:
#		HTML->EndPage
######################################################################

sub EndPage { return "</body></html>\n"; }

######################################################################
#	Script
#	������������ ���� �������� �������
#	�����:
#		HTML->Script (Text => s, BeginOnly => n, EndOnly => n,
#			Param => r)
#		Text	    - ����� �������;
#		BeginOnly - ���� ������������ ������ ������������ ����;
#		EndOnly   - ���� ������������ ������ ������������ ����;
#		Param	    - ������ �� ������ ��� ��� ���������� ����.
######################################################################

sub Script {
   shift;							# ��� ������ �� ���������
   my %Parameters = HTML->_GetParameters (\@_, 1);	# ��������� ������
   my %Param = HTML->_GetParameters ($Parameters{"param"}, 1);	# �������� ��������� ���������� ����
   $Param{"language"} = "JavaScript" if (!defined ($Param{"language"}));	# ���� �� ���������
   my $JavaFlag = ($Param{"language"} =~ m/^(javascript|js|jscript)\b/i);	# ���� JavaScript
   my $String = "";					# �������������� ������
   if (!$Parameters{"endonly"}) {			# ������ ���������
	$String .= HTML->_GenericTag (Tag => "script", Param => \%Param, BeginOnly => 1);	# ������� ���
	$String .= "<!--" if ($JavaFlag);		# ����������� ��� JavaScript
	$String .= "\n";					# ������ ������
   }
   $String .= $Parameters{"text"} if (defined ($Parameters{"text"}) && !$Parameters{"beginonly"} && !$Parameters{"endonly"});	# ����� ������ ����
   if (!$Parameters{"beginonly"}) {			# ���������� ���������
	$String .= "\n";					# ������ ������
	$String .= "//-->" if ($JavaFlag);		# ����������� ��� JavaScript
	$String .= "</script>";				# ����������� ���
   }
   return $String;					# ������� ���������
}

######################################################################
#	Style
#	������������ ������� ������
# 	�����:
#		HTML->Style (Param => r, Flags => r, Import => r,
#			Style => r)
#	���������:
#		Param  - ������ �� ������ ��� ��� �������� ����������
#			   ������� ������;
#		Flags  - ������ �� ������ ��� ��� �������� ����������
#			   ������� �����;
#		Import - ������ �� ������ URL ������������� ������;
#		Style  - ������ �� ������ ��� ���, ����������
#			   ����������� ������� ������, ����
#			   ("tag" => r, ...), ���
#			   "tag" - ������ �� ������ ��� ���, ��������
#				     ��������� ������ �����.
######################################################################

sub Style {
   shift;							# ��� ������ �� ���������
   my %Parameters = HTML->_GetParameters (\@_, 1);	# ��������� ������
   my $String = HTML->_GenericTag (Tag => "style", Param => $Parameters{"param"},
     Flags => $Parameters{"flags"}, BeginOnly => 1) . "<!--\n";	# ������������ ����������� ���
   {
	my $Import = $Parameters{"import"};		# ������ ������������� ������
	if (ref ($Import) eq "ARRAY") {		# ������ ����������
	   for (@$Import) {				# ��� URL
		$String .= "\@import URL('" . $_ . "');\n" if (defined ($_) && ($_ ne ""));	# ��������� �������
	   }
	}
   }
   {
	my %Param = HTML->_GetParameters ($Parameters{"style"}, 0);	# �������� ��������� �����
	while (my ($Code, $Value) = each (%Param)) {	# ��� ������ �������
	   my %Styler = HTML->_GetParameters ($Value, 0);	# ����� � ���� ���
	   my @Styler = ();				# ������ ���� ������
	   while (my ($Param, $Value) = each (%Styler)) {	# ��� ��������� ������
		push (@Styler, $Param . ": " . $Value);	# ��������� � ������
	   }
	   $String .= $Code . " {" . join ("; ", @Styler) . "}\n" if (@Styler);	# ������� ������ �����
	}
   }
   return $String . "--></style>";			# ������� ������� �����
}

######################################################################
#	_GenericTag
#	��������������� ������� ��������������� ���� HTML
#	�����:
#		HTML->_GenericTag (Tag => s, Text => s, BeginOnly => n,
#			EndOnly => n, Param => r, Flags => r, Style => r)
#	���������:
#		Tag	    - ��� ����;
#		Text	    - �����, ����������� ������ ����
#				(<tag>Text</tag>);
#		BeginOnly - ���� ������������ ������ ������������ ����;
#		EndOnly   - ���� ������������ ������ ������������ ����;
#		Param	    - ������ �� ������ ��� ��� ���������� ����;
#		Flags	    - ������ �� ������ ��� ��� �������� ����������
#				����;
#		Style	    - ������ �� ������ ��� ��� ���������� �����
#				����.
######################################################################

sub _GenericTag {
   shift;							# ��� ������ �� ���������
   my %Parameters = HTML->_GetParameters (\@_, 1);	# ��������� ������
   my $String = "";					# ������ ��� ������ ����
   if (defined ($Parameters{"tag"}) && ($Parameters{"tag"} ne "")) {	# ��� ���� ������
	if (!$Parameters{"endonly"}) {		# ������ ���������
	   $String .= "<" . $Parameters{"tag"};	# ��� ����
	   my %Data = HTML->_GetParameters ($Parameters{"param"}, 1);	# ��������� ����
	   while (my ($Param, $Value) = each (%Data)) {	# ��� ���������
		$String .= " " . $Param;
		$String .= "='" . $Value . "'" if (defined ($Value));	# ��������, ������� ��������
	   }
	   %Data = HTML->_GetParameters ($Parameters{"flags"}, 1);	# �������� ��������� ����
	   while (my ($Param, $Value) = each (%Data)) {	# ��� �����
		$String .= " " . $Param if ($Value);	# �������� ����
	   }
	   %Data = HTML->_GetParameters ($Parameters{"style"}, 1);	# ��������� ����
	   my @Styler = ();				# ������ ���� �� ������
	   while (my ($Param, $Value) = each (%Data)) {	# ��� ��������� ������
		push (@Styler, $Param . ": " . $Value);	# ��������� � ������
	   }
	   $String .= " style='" . join ("; ", @Styler) . "'" if (@Styler);	# �������� �������� ��������
	   $String .= ">";				# ��������� ���
	}
	$String .= $Parameters{"text"} if (defined ($Parameters{"text"}) && !$Parameters{"beginonly"} && !$Parameters{"endonly"});	# ����� ������ ����
	$String .= "</" . $Parameters{"tag"} . ">" if (!$Parameters{"beginonly"});	# ���������� ����
   }
   return $String;
}

######################################################################
#	_GetParameters
#	��������������� ������� ������� ���������� � ��� �� �������
#	��� ����
#	�����:
#		HTML->_GetParameters (ref, ic)
#	���������:
#		ref - �������������� ������ �� ������ ��� ���;
#		ic  - ���� �������������� ������ �������� ���� �
#		      ������� ��������.
######################################################################

sub _GetParameters {
   shift;							# ��� ������ �� ���������
   my $Reference = shift;				# �������������� ������
   my $IgnoreCase = shift;				# ���� ������������� ��������
   if ($IgnoreCase) {					# ������������ �������
	if (ref ($Reference) eq "ARRAY") {		# ������ � ��������
	   my %TempHash = @$Reference;		# ����� � ������������� ���
	   $Reference = \%TempHash;			# ��������� ������
	}
	if (ref ($Reference) eq "HASH") {		# ��������� � ����
	   my @TempArray = ();				# ��������� ������
	   while (my ($Code, $Value) = each (%$Reference)) {	# ��� ���������
		push (@TempArray, lc ($Code), $Value);	# ��������� � ������
	   }
	   return @TempArray;				# ������� ���������
	}
   } else {
	return @$Reference if (ref ($Reference) eq "ARRAY");	# ������� ������
	return %$Reference if (ref ($Reference) eq "HASH");	# ������� ���
   }
   return ();						# ����� ������
}

######################################################################
#	HTMLCode
#	����������� ����������� �������� HTML
#	�����:
#		HTML->HTMLCode (array)
#	���������:
#		array - ������ �������������� �����
######################################################################

sub HTMLCode {
   shift;							# ��� ������ �� ���������
   my @TheMessage = @_;					# �������������� ������
   @TheMessage = @$_[0] if (ref ($_[0]) eq "ARRAY");	# ��� �������� �� ������
   for (@TheMessage) {
	s/&/&amp;/g;					# ���������
	s/</&lt;/g;						# ����� ������� ������
	s/>/&gt;/g;						# ������ ������� ������
	s/"/&quot;/g;					# �������
	s/'/&\#039;/g;					# ��������
	s/\|/&\#124;/g;					# ������ ���������
	s/\n\r/<p>/g;					# ������� ������� � ������� ������
	s/\n/<br>/g;					# ������� ������ ����
	s/\r//g;						# ������� ������� ����
   }
   return (wantarray) ? @TheMessage : $TheMessage[0];	# ������� ���������
}

######################################################################
#	HTMLDecode
#	��������� ������������� ����������� �������� HTML
#	�����:
#		HTML->HTMLDecode (array)
#	���������:
#		array - ������ �������������� �����
######################################################################

sub HTMLDecode {
   shift;							# ��� ������ �� ���������
   my @TheMessage = @_;					# �������������� ������
   @TheMessage = @$_[0] if (ref ($_[0]) eq "ARRAY");	# ��� �������� �� ������
   for (@TheMessage) {
	s/<br>/\n/g;					# ������� ������ ����
	s/<p>/\n\r/g;					# ������� ������� � ������� ������
	s/&\#124;/\|/g;					# ������ ���������
	s/&\#039;/'/g;					# ��������
	s/&quot;/"/g;					# �������
	s/&gt;/>/g;						# ������ ������� ������
	s/&lt;/</g;						# ����� ������� ������
	s/&amp;/&/g;					# ���������
   }
   return (wantarray) ? @TheMessage : $TheMessage[0];	# ������� ���������
}

######################################################################
#	JSCode
#	����������� ����������� �������� ��� �������� JavaScript
#	�����:
#		HTML->JSCode (array)
#	���������:
#		array - ������ �������������� �����
######################################################################

sub JSCode {
   shift;						# ��� ������ �� ���������
   my @TheMessage = @_;				# �������������� ������
   @TheMessage = @$_[0] if (ref ($_[0]) eq "ARRAY");	# ��� �������� �� ������
   for (@TheMessage) {
	s/\\/\\\\/g;				# �������� �����
	s/"/\\"/g;					# �������
	s/\n/\\n/g;					# ������� ������
	s/\r/\\r/g;					# ������� �������
   }
   return (wantarray) ? @TheMessage : $TheMessage[0];	# ������� ���������
}

######################################################################
#	AUTOLOAD
#	��������������� ������� ���������� ��������� �����
######################################################################

use vars qw ($AUTOLOAD %ComplexTags %SimpleTags %UniqueTags);
%ComplexTags = (anchor => "a", bold => "b", emphasied => "em", italic => "i", paragraph => "p",
  underline => "u");					# ���������� ��������� �����
for (qw (a address b big blockquote bq button caption center cite code colgroup comment
  dd dfn dir div dl dt em fieldset font form frameset h1 h2 h3 h4 h5 h6 i iframe kbd label
  layer legend li listing map marquee menu nobr noframes nolayer noscript object ol p plaintext
  pre s samp select small span strike strong sub sup table tbody td textarea tfoot th thead tr
  tt u ul var xmp)) {
   $ComplexTags{$_} = $_; }				# ������������ ������� ��������� �����
%SimpleTags = (break => "br", image => "img", softbreak => "wbr");	# ���������� ��������� �����
for (qw (area base basefont bgsound br col embed frame hr img input link option param wbr)) {
   $SimpleTags{$_} = $_; }				# ������������ ������� ��������� �����
%UniqueTags = (beginpage => \&BeginPage, endpage => \&EndPage, script => \&Script,
  style => \&Style,					# ������� ���������� �����
  htmlcode => \&HTMLCode, htmldecode => \&HTMLDecode, javacode => \&JSCode, jscode => \&JSCode,
  javascriptcode => \&JSCode);			# � ��������������� ��������

sub AUTOLOAD {
   shift;							# ��� ������ �� ���������
   my $Tag = lc ($AUTOLOAD);				# ��� ����������� ������
   $Tag =~ s/.*:://;					# ������ ������
   return HTML->_GenericTag (@_, Tag => $ComplexTags{$Tag}) if (exists ($ComplexTags{$Tag}));	# ������� ������ ���
   return HTML->_GenericTag (@_, Tag => $SimpleTags{$Tag}, BeginOnly => 1, EndOnly => 0)
     if (exists ($SimpleTags{$Tag}));		# ������� ������� ���
   return $UniqueTags{$Tag}->("", @_) if (exists ($UniqueTags{$Tag}));	# ������� ���������� ���
   return "";						# �������� ��� ���������
}

1;
