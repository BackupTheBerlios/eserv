######################################################################
#	Elog.cgi
#	�������� ����������� ������ ������� ��������� ���������� Elog
#
#	20 ������� 2003 ����				��� "����"
######################################################################

use strict 'refs';					# ������� ����������� �� ������������� ������
my $Feedback = "admins\@lankgroup.ru";		# ����������� ����� ��� �������� �����
my $PrintHTTPHead = 1;					# ���� ������ ��������� HTTP/1.0

######################################################################
#	DisplayHTTPHeader
#	������� ������ ��������� ��������� HTTP.
######################################################################

sub DisplayHTTPHeader ($;$) {
   my $Header = shift;					# ��� ��������
   my $Charset = shift;
   print ("HTTP/1.0 " . $Header . "\n") if ($PrintHTTPHead);	# ������� ��������� HTTP
   print ("Content-type: text/html" . ($Charset ? ("; charset=" . $Charset) : "") . "\n\n");	# ������� ������� HTML-��������
}

######################################################################
#	DisplayError
#	������� �������� �������� ��������� �� ������ �������������.
######################################################################

sub DisplayError ($@) {
   my $ErrorText = shift;				# �������� ������ ���������
   my $Reason = join ("<br>\n", @_);		# ������� ������ ���������
   DisplayHTTPHeader ("200 OK");			# ������� ��������� HTTP
   print <<ERRORPAGE;
<html><head>
<title>System Error</title>
</head><body bgcolor='#FFFFFF' text='#000000'>
<h1 align='center'>$ErrorText</h1>
<p>$Reason</p>
<p>If the problem persists please inform server administrator
<a href='mailto:$Feedback?subject=CC+Problem'>$Feedback</a>.</p>
</body></html>
ERRORPAGE
}

######################################################################
#	�������� �������� ���������.
######################################################################

eval {
   require "./Misc_lib.pl";				# ���������� "������" �������
   require "./HTML_lib.pl";				# ���������� ��������� HTML
   require "./DateTime_lib.pl";			# ���������� ������ � ������
   require "./CGI_lib.pl";				# ���������� ��������� CGI
   require "./Elog_lib.pl";				# �������� ���������� ���������
};
if ($@) {							# ������ �������� ���������
   DisplayError ("Error loading runtime libraries", split ("\n", $@));	# �������� �� ������
   exit;
}

######################################################################
#	�������� ������������.
######################################################################

local $Environment = Environment->Load (0);	# ��������� ������� �����
my $Error = $Environment->Error ();			# ������� ������
if ($Error) {						# ����� �� ���������
   DisplayError ("Error loading configuration data", $Error);	# �������� �� ������
   exit;
}

######################################################################
#	��������� ���������������� ����������.
######################################################################

local $CGI = CGI->Parse ();				# ��������� ������ �������
$Error = $CGI->Error ();				# ������� ������
if ($Error) {						# ��������� � ��������
   DisplayError ("Error processing request", $Error);	# �������� �� ������
   exit;
}

local $Cookies = Cookies->Parse ();			# ��������� ������
$Environment->AttachUserSettings ($CGI, $Cookies);	# �������� ���������������� ���������

my $Action = $CGI->RetrieveValue ("a");		# ��� ��������
$Action = "i" if (!defined ($Action));		# �������� �� ���������
if ($Action eq "i") {					# ����� ����� �������
   eval { require "./Elog_Index.pl"; };		# ���������� ��������� �����������
} elsif ($Action eq "p") {				# ��������� �������
   eval { require "./Elog_Parse.pl"; };		# ���������� ��������� �����������
} else {							# ����������� ��������
}
if ($@) {
   DisplayError ("Error loading runtime libraries", split ("\n", $@));	# �������� �� ������
   exit;
}
ProcessRequest ($Action);				# ��������� ������
