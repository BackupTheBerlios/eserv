######################################################################
#	CGI_lib.pl
#	���������� ������ � ����������� CGI-������
#
#	21 ������� 2001					��� "����"
######################################################################

######################################################################
#	CGI
#	����� �������� ������ ���������� CGI-������
######################################################################

package CGI;

######################################################################
#	Parse
#	�������� ���������� CGI-������
#	�����:
#		CGI->Parse ([Path])
#	���������:
#		Path - ���� � �������� ��� �������� ������. ���� ��
#		       �����, ���������� ������ �������� � ������.
#	���������� ������ �� ����� ��������� ������ CGI.
#
#	��������:
# Perl Routines to Manipulate CGI input
# S.E.Brenner@bioc.cam.ac.uk
# $Id: CGI_lib.pl,v 1.1 2003/12/28 16:27:15 spf Exp $
#
# Copyright (c) 1996 Steven E. Brenner  
# Unpublished work.
# Permission granted to use and modify this library so long as the
# copyright above is maintained, modifications are documented, and
# credit is given for any use of the library.
#
# Thanks are due to many people for reporting bugs and suggestions
# especially Meng Weng Wong, Maki Watanabe, Bo Frese Rasmussen,
# Andrew Dalke, Mark-Jason Dominus, Dave Dittrich, Jason Mathews
#
# For more information, see:
#     http://www.bio.cam.ac.uk/cgi-lib/
######################################################################

sub Parse {
   my $Class = shift;					# ��� ������
   my $Path = shift;					# ���� � ������� ��� �������� ������
   $Path = "" if (!defined ($Path));		# ������� ������
   my $Self = { parameters => {}, files => [], error => "" };	# ��������� �������
   bless ($Self, $Class);				# ��������� � ������
   binmode (STDIN);					# ��������� � �������� �����
   binmode (STDOUT);
   binmode (STDERR);
   my $Method = $ENV{"REQUEST_METHOD"};		# ����� ������
   my $Type = $ENV{"CONTENT_TYPE"};			# ��� ������
   my $Len  = $ENV{"CONTENT_LENGTH"};		# ������� ������


   if (!defined ($Method) || ($Method eq "") || ($Method =~ m/^GET$/i) || 
     ($Type =~ m#^application/x-www-form-urlencoded$#i)) {	# ������� �����
	my $CmdFlag = 0;					# ��������� ��������� ������ �� �����������
	my $In = "";					# ������ �������
	if (!defined ($Method) || ($Method eq "")) {	# ����� ����������
	   $In = $ENV{"QUERY_STRING"} if (defined ($ENV{"QUERY_STRING"}));	# ������ �������
	   $CmdFlag = 1;					# � ����� ��������� �� ��������� ������
	} elsif ($Method =~ m/^(GET|HEAD)$/i) {	# ����� ������� ������
	   $In = $ENV{"QUERY_STRING"};
	} elsif ($Method =~ m/^POST$/i) {		# ���������� �����
	   my $Got = sysread (STDIN, $In, $Len);	# ��������� ���������� �����
	   if ($Got < $Len) {				# ��������� ������, ��� ���������
		$Self->{"error"} =
		  "Broken CGI request: wanted " . $Len . " bytes, read " . $Got . " bytes";
		return $Self;				# �������� ���������
	   }
	} else {
	   $Self->{"error"} = "Unknown CGI request method: " . $Method;	# ����������� ����� - ��������� ����������
	   return $Self;					# �������� ���������
	}

	my @In = split (/[&;]/, $In);			# ������� ������ �� ���������
	push (@In, @ARGV) if ($CmdFlag);		# �������� ��������� ��������� ������
	for (@In) {						# ��� ��������� �������
	   if (defined ($_)) {				# �������� ���������
		s/\+/ /g;					# ��������������
		my ($Name, $Value) = split (/=/, $_, 2);	# ��������� �� ��� � ��������
		$Value = "" if (!defined ($Value));	# ������ �������� ��� ��������� ���������
		$Name =~ s/%([A-Fa-f0-9]{2})/pack ("c", hex ($1))/ge;	# �������� ����������������� �������������
		$Value =~ s/%([A-Fa-f0-9]{2})/pack ("c", hex ($1))/ge;
		$Self->Store (CGIParameter->New ($Name, $Value));	# �������� � ���������
	   }
	}
	return $Self;					# ����������
   } 

   if ($Type =~ m#^multipart/form-data#) {	# ����� � ��������� ������
	if ($Method ne "POST") {			# ������������ ����� ��� ������ ���� ������
	   $Self->{"error"} = "Invalid CGI request method for multipart/form-data: " . $Method;	# ��� �� ����� ���� ����������
	   return $Self;
	}
	my ($Boundary) = $Type =~ m/boundary="([^"]+)"/;	# �������� ����������� �����
	($Boundary) = $Type =~ m/boundary=(\S+)/ if (!defined ($Boundary) || ($Boundary eq ""));
	if (!defined ($Boundary) || ($Boundary eq "")) {	# ����������� �� ������
	   $Self->{"error"} =
	     "Boundary not provided for multipart CGI request: probably a server bug";
	   return $Self;					# �������� ���������
	}
	$Boundary =  "--" . $Boundary;		# �������� ��� �����������
	$BLen = length ($Boundary);			# � ��� ������
	my $BufferSize = $BLen + 8198;		# ������ ������
	$BufferSize = $BLen * 2 if ($BufferSize < $BLen * 2);
	my ($In, $Left) = ("", $Len);
	{
	   my ($Error, $Value, $Flag) =
	     CGI->_ReadValue (\$In, \$Left, $BufferSize, $Boundary, $BLen);	# ����� ������ �����������
	   if ($Error ne "") {				# ������
		$Self->{"error"} = $Error;		# ������������� ������
		return $Self;				# �������� ���������
	   }
	}
	$Boundary = "\r\n" . $Boundary;		# ����������� ������������ ����� ������
	$BLen += 2;						# ������
	{
	   my $Serial = 0;				# ���������������� ����� �����
	   my $Finish = 0;				# ����� ��� �� ������
	   while (!$Finish) {				# ���� ���������� ��������
		my ($Error, $Name, $FileName, $FileType) =
		  CGI->_ParseHeader (\$In, \$Left, $BufferSize, \$Finish);	# ��������� ���������
		if ($Error ne "") {			# ������
		   $Self->{"error"} = $Error;		# �������������
		   $Finish = 1;				# �������� ����������
		}
		if (!$Finish) {				# �� �����
		   my @Parameters = (\$In, \$Left, $BufferSize, $Boundary, $BLen);	# �������� ��������� ������
		   push (@Parameters, $Path, \$Serial) if (defined ($FileName));	# �������������� ��������� ��� �����
		   my ($Error, $Value, $Stored) = CGI->_ReadValue (@Parameters);	# ��������� ��������
		   if ($Error ne "") {			# ������
			$Self->{"error"} = $Error;	# �������������
			$Finish = 1;			# �������� ����������
		   } else {
			$Self->Store (CGIParameter->New ($Name, $Value, $FileName, $FileType,
			  $Stored));			# ������� �������� � �������
			push (@{$Self->{"files"}}, $Value) if ($Stored);	# �������� ��������� ��� �����
		   }
		}
	   }
	}
	if ($Self->{"error"} ne "") {			# ������ �������
	   unlink (@{$Self->{"files"}}) if (@{$Self->{"files"}});	# ������� �������� �����
	   @{$Self->{"files"}} = ();			# ������ �� ��������
	}
	return $Self;					# ����������
   }

   $Self->{"error"} = "Unknown Content-Type of CGI request: " . $Type;	# ����������� ��� ������ ��� �������
   return $Self;
}

######################################################################
#	_ParseHeader
#	������ ��������� ���������� ���������
#	�����:
#		CGI->_ParseHeader (Buffer, Length, Limit, Finish)
#	���������:
#		Buffer - ������ �� ����� �����;
#		Length - ������ �� ����� �������� ������;
#		Limit  - ����������� �� ����� ������;
#		Finish - ������ �� ������� ���������� ������.
#	���������� ������ ��������:
#		Error	   - ��������� ������. ���� ������ ���, ��
#			     ������ ������;
#		Name	   - ��� ���������� ���������;
#		FileName - ��� �����, ���� �������� �������� ������;
#		Type	   - Content-Type, ���� �������� �������� ������.
######################################################################

sub _ParseHeader {
   shift;							# ������ �� ����� ����������
   my $In = shift;					# ������ �� �����
   my $Left = shift;					# ������ �� ������ ������� ������
   my $Limit = shift;					# ����������� ������� ����������
   my $Finish = shift;					# ������ �� ������� ���������� ������
   my $Head = "";						# ������ ���������
   {
	my $EndHead;
	my $NotFirst = 0;					# ���� ������� �������
	my $NotEnd = 1;					# ���� �������������� ���������
	while ($NotEnd) {					# ��������� ��� �� ��������
	   my $Breaker = 0;				# ������� ������
	   if ($NotFirst) {				# �� ������ ������
		$Breaker = length ($$In);		# ������� ������
		if ($Breaker > 4) {			# ����� ������
		   $$In = substr ($$In, -4);		# ���������� �����
		   $Breaker = 4;				# ������ � ���� �������
		}
	   }
	   if ($NotFirst || (length ($$In) < 4)) {	# ��������� ������ ������
		my $Error = CGI->_ReadPart ($In, $Left, $Limit);	# ������ ��������� ��������
		return ($Error, undef, undef, undef) if ($Error ne "");	# ������ ������
		return ("Broken CGI request: final boundary not found", undef, undef, undef)
		  if (length ($$In) < 4);		# ��������� ���
	   }
	   if (!$NotFirst) {				# ������ ������
		if ($$In =~ m/^--\r\n/) {		# �������� ��������� �����������
		   $$Finish = 1;				# ���������� ������� ����������
		   return ("", undef, undef, undef);	# ���������
		}
		$NotFirst = 1;				# ������ ������ ��������
	   }
	   $EndHead = index ($$In, "\r\n\r\n");	# ����� ������������
	   if ($EndHead == -1) {			# �� ������
		$EndHead = length ($$In);		# �������� ���� �����
	   } else {
		$NotEnd = 0;				# �����
	   }
	   $Head .= substr ($$In, $Breaker, $EndHead - $Breaker);	# ��������� �������� ���������
	}
	$$In = substr ($$In, $EndHead + 4);		# �������� ������
   }
   {
	my ($CDisp, $CType) = ("", "");
	for (split (/\r\n/, $Head)) {			# �� ���� ������� ���������
	   $CDisp = $_ if (m/^\s*Content-Disposition:/i);	# ������ � ������ ���������
	   $CType = $_ if (m/^\s*Content-Type:/i);	# ������ � ��������� Content-Type
	}
	my ($FileName, $FileType) = (undef, undef);	# �����, ��� � �� ����
	my ($Name) = $CDisp =~ m/\bname="([^"]+)"/i;	# �������� ��� ���������
	($Name) = $CDisp =~ m/\bname=([^\s:;]+)/i if (!defined ($Name) || ($Name eq ""));
	$Name = "" if (!defined ($Name));		# ����� ����� ���������� ��������
	if ($CDisp =~ m/\bfilename=/) {		# ����
	   ($FileName) = $CDisp =~ m/\bfilename="([^"]*)"/i;	# �������� ��� �����
	   ($FileName) = $CDisp =~ m/\bfilename=([^\s:;]+)/i
	     if (!defined ($FileName) || ($FileName eq ""));
	   if (defined ($FileName) && ($FileName ne "")) {	# ��������
		($FileType) = $CType =~ m/^\s*Content-type:\s*"([^"]+)"/i;	# �������� Content-Type
		($FileType) = $CType =~ m/^\s*Content-Type:\s*([^\s:;]+)/i
		  if (!defined ($FileType) || ($FileType eq ""));
	   }
	}
	return ("", $Name, $FileName, $FileType);	# ������� ��������� ���������
   }
}

######################################################################
#	_ReadValue
#	������ �������� ���������
#	�����:
#		CGI->_ReadValue (Buffer, Length, Limit, Boundary, BLen[,
#				Path, Serial])
#	���������:
#		Buffer   - ������ �� ����� �����;
#		Length   - ������ �� ����� �������� ������;
#		Limit	   - ����������� �� ����� ������;
#		Boundary - ������ ������-�����������;
#		BLen	   - ����� ������-�����������;
#		Path	   - ���� ��� �������� �����;
#		Serial   - ������ �� ���������� ����� ���������� �����.
#	���������� ������ ��������:
#		Error  - ��������� ������. ���� ������ ���, �� ������
#			   ������;
#		Value  - �������� ��������� ��� ��� ���������� �����;
#		Stored - ������� �������� ����� �� �����
######################################################################

sub _ReadValue {
   shift;							# ������ �� ����� ����������
   my $In = shift;					# ������ �� �����
   my $Left = shift;					# ������ �� ������ ������� ������
   my $Limit = shift;					# ����������� ������� ����������
   my $Boundary = shift;				# ������ ������-�����������
   my $BLen = shift;					# ����� ������-����������� � �������������� ��������� ������
   my $Path = shift;					# ���� ��� �������� �����
   my $Serial = shift;					# ������ �� ���������� ����� ���������� �����
   my $Value = "";					# ������������ ��������
   {
	my $EndVal;
	my $NotFirst = 0;					# ���� ������� �������
	my $NotEnd = 1;					# ���� �������������� ������
	while ($NotEnd) {					# ������ ��� �� ���������
	   my $Breaker = 0;				# ������� ������
	   if ($NotFirst) {				# �� ������ ������
		$Breaker = length ($$In);		# ������� ������
		if ($Breaker > $BLen) {			# ����� ������
		   $$In = substr ($$In, -$BLen);	# ���������� �����
		   $Breaker = $BLen;			# ������ � ���� �������
		}
	   }
	   if ($NotFirst || (length ($$In) < $BLen)) {	# ��������� ������ ������
		my $Error = CGI->_ReadPart ($In, $Left, $Limit);	# ������ ��������� ��������
		return ($Error, "", 0) if ($Error ne "");	# ������ ������
		return ("Broken CGI request: final boundary not found", "", 0)
		  if (length ($$In) < $BLen);		# ��������� ���
	   }
	   $EndVal = index ($$In, $Boundary);	# ����� �����������
	   if ($EndVal == -1) {				# �� ������
		$EndVal = length ($$In);		# �������� ���� �����
	   } else {
		$NotEnd = 0;				# �����
	   }
	   $Value .= substr ($$In, $Breaker, $EndVal - $Breaker) if ($EndVal > $Breaker);	# ��������� �������� ������
	   $NotFirst = 1;					# ������ ������ ��������
	}
	$$In = substr ($$In, $EndVal + $BLen);	# �������� ������
   }
   {
	my $Stored = 0;					# ������ ���� �� ��������
	if (defined ($Path) && ($Path ne "")) {	# ����� ����� ����������
	   my $FileName = $Path . "/CGI-temp." . $$ . "." . $$Serial;	# ������������ ��� ��� ���������� �����
	   ++$$Serial;					# ��������� ���������� �����
	   my $ErrorFlag = 0;				# ������ �� �������������
	   local *STORED;					# ������� �������� � �������
	   if (open (STORED, ">" . $FileName)) {	# ���� ��������
		binmode (STORED);				# ��������� � �������� �����
		my ($Offset, $ToWrite) = (0, length ($Value));	# ���������� � ������
		while ($Offset < $ToWrite) {		# ���� ���� ���� ����������
		   my $PartSize = $ToWrite - $Offset;	# �������� �������
		   $PartSize = 32768 if ($PartSize > 32768);	# ����������
		   my $Written = syswrite (STORED, $Value, $PartSize, $Offset);	# �������� ��������� ��������
		   if (!$Written) {			# ������ �� ����������
			$ErrorFlag = 1;			# �������� ������
			$Offset = $ToWrite;		# �������� ������
		   } else {
			$Offset += $Written;		# �������������� �������
		   }
		}
		close (STORED);				# ������� ����
		if ($ErrorFlag) {				# ������ ������
		   unlink ($FileName);			# ������� ����
		} else {
		   $Stored = 1; $Value = $FileName;	# ������������ ��� ����� � ���� ��������
		}
	   }
	}
	return ("", $Value, $Stored);			# ������� ���������
   }
}

######################################################################
#	_ReadPart
#	���������� ����� ������� ������
#	�����:
#		CGI->_ReadPart (Buffer, Length, Limit)
#	���������:
#		Buffer - ������ �� ����� �����;
#		Length - ������ �� ����� �������� ������;
#		Limit  - ����������� �� ����� ������.
#	���������� ��������� ������. ���� ������ ���, ������������
#	������ ������.
######################################################################

sub _ReadPart {
   shift;							# ������ �� ����� ����������
   my $In = shift;					# ������ �� �����
   my $Left = shift;					# ������ �� ������ ������� ������
   my $Limit = shift;					# ����������� ������� ����������
   my $Wanted = $Limit - length ($$In);		# ������� ����� ���������
   $Wanted = $$Left if ($$Left < $Wanted);	# ���� �������
   return "" if ($Wanted <= 0);			# ����� ����� ��� ������ ������
   my $Buffer = "";					# ����� ��� ����������
   my $Got = sysread (STDIN, $Buffer, $Wanted);	# ��������� ������� ����
   return "Broken CGI request: wanted " . $Wanted . " bytes, read " . $Got . " bytes"
     if ($Got < $Wanted);				# ������ - ��������� ������� ����
   $$In .= $Buffer;					# ��������� ���������
   $$Left -= $Got;					# �������� ��������
   return "";						# ��� ������
}

######################################################################
#	Files
#	�����:
#		Object->Files ()
#	���������� ������ ����������� �� ����� ������.
######################################################################

sub Files { return @{$_[0]->{"files"}}; }		# ������� ������ ������

######################################################################
#	Parameters
#	�����:
#		Object->Parameters ()
#	���������� ������ ���� �������� ����������.
######################################################################

sub Parameters { return keys (%{$_[0]->{"parameters"}}); }	# ������� ����� ���� ����������

######################################################################
#	Count
#	������� ����� �������� ���������
#	�����:
#		Object->Count (Name)
#	���������:
#		Name - ��� ���������.
#	���������� ����� ����������� ��������� � ������ ������.
######################################################################

sub Count {
    my $Self = shift;					# ������ �� ������
    my $Name = shift;					# ��� ���������
    my $Param = $Self->{"parameters"}->{$Name};	# ������ �� ������ ����������� ����������
    return (defined ($Param) ? scalar (@$Param) : 0);	# ����� ����������
}

######################################################################
#	Retrieve
#	�����:
#		Object->Retrieve (Name[, Index])
#	���������:
#		Name  - ��� ���������;
#		Index - ������ ��������� � ������� �����������. ���� ��
#			  �����, �������������� ������� �������.
#	� ��������� ��������� ���������� ������ ������ �� �����������
#	���������. � ��������� ��������� ���������� ������ �� ��������
#	� ������������ � ��������. ���� ������ �������� ��� ���������
#	���, ������������ �������������� ��������.
######################################################################

sub Retrieve {
   my $Self = shift;					# ������ �� ������
   my $Name = shift;					# ��� ���������
   my $Index = shift () + 0;				# ������ � �������
   my $Param = $Self->{"parameters"}->{$Name};	# ������ �� ������ ����������� ����������
   return undef if (!defined ($Param));		# ��� ������ ���������
   return (wantarray) ? @$Param : $Param->[$Index];	# ������� ���������
}

######################################################################
#	RetrieveValue
#	�����:
#		Object->RetrieveValue (Name[, Index])
#	���������:
#		Name  - ��� ���������;
#		Index - ������ ��������� � ������� �����������. ���� ��
#			  �����, �������������� ������� �������.
#	���������� �������� ���������. ���� �������� �����������,
#	������������ �������������� ��������.
######################################################################

sub RetrieveValue {
   my $Self = shift;					# ������ �� ������
   my $Name = shift;					# ��� ���������
   my $Index = shift () + 0;				# ������ � �������
   my $Param = $Self->{"parameters"}->{$Name};	# ������ �� ������ ����������� ����������
   return undef if (!defined ($Param));		# ��� ������ ���������
   $Param = $Param->[$Index];				# ������ �� ������� ��������
   return undef if (!defined ($Param));		# ��� ������ ���������
   return $Param->Value ();				# ������� ��������
}

######################################################################
#	Store
#	�����:
#		Object->Store (Parameter)
#	���������:
#		Parameter - ������ �� ������ ���� ��������.
#	��������� ����� �������� � ���������.
######################################################################

sub Store {
   my $Self = shift;					# ������ �� ������
   my $Param = shift;					# ������ �� ����������� ��������
   my $Collection = $Self->{"parameters"};	# ������ �� ��������� ����������
   my $ParamName = $Param->Name ();			# ��� ���������
   $Collection->{$ParamName} = [] if (!defined ($Collection->{$ParamName}));	# ������� ������ ��������� ��� �����
   push (@{$Collection->{$ParamName}}, $Param);	# �������� � ������
}

######################################################################
#	Error
#	�����:
#		Object->Error ()
#	���������� �������� ������ �������.
######################################################################

sub Error { return $_[0]->{"error"}; }

######################################################################


######################################################################
#	CGIParameter
#	����� �������� ������ ��������� CGI-������
######################################################################

package CGIParameter;

######################################################################
#	New
#	����������� ��������� CGI-������
#	�����:
#		CGIParameter->New (Name, Value[, FileName, Type, Stored])
#	���������:
#		Name	   - ������������ ���������;
#		Value	   - �������� ���������;
#		FileName - �������� ��� �����, ���� �������� ��������
#			     ������;
#		Type	   - Content-Type, ���� �������� �������� ������;
#		Stored   - ������� �������� ����� �� �����, ���� ��������
#			     �������� ������.
#	���������� ������ �� ����� ��������� ������.
######################################################################

sub New {
   my $Class = shift;					# ��� ������
   my $Name = shift;					# ��� ���������
   my $Value = shift;					# �������� ���������
   my $FileName = shift;				# ��� �����
   my $Type = shift;					# Content-Type
   my $Stored = shift () + 0;				# ������� �������� �� �����
   my $Self = { name => $Name, value => $Value };	# ��� � �������� �����������
   if (defined ($FileName) && ($FileName ne "")) {	# ��� ����
	$Self->{"filename"} = $FileName;		# ������������� ��� �����
	$Self->{"type"} = $Type if (defined ($Type) && ($Type ne ""));	# � Content-Type
	$Self->{"stored"} = $Stored;			# ������� �������� �� �����
   }
   return bless ($Self, $Class);			# ��������� � ������
}

######################################################################
#	Name
#	�����:
#		Object->Name ()
#	���������� ��� ���������.
######################################################################

sub Name { return $_[0]->{"name"}; }

######################################################################
#	Value
#	�����:
#		Object->Value ()
#	���������� �������� ���������.
######################################################################

sub Value { return $_[0]->{"value"}; }

######################################################################
#	IsFile
#	����� �����������, �������� �� �������� ������
#	�����:
#		Object->IsFile ()
#	���������� ��������� ��������, ���� ������ �������� ������,
#	� ������� � ��������� ������.
######################################################################

sub IsFile { return (exists ($_[0]->{"filename"})) ? 1 : 0; }

######################################################################
#	IsStored
#	����� �����������, �������� �� ���� �� �����
#	�����:
#		Object->IsStored ()
#	���������� ��������� ��������, ���� ������ �������� ������ �
#	�������� �� �����, � ������� � ��������� ������.
######################################################################

sub IsStored { return (exists ($_[0]->{"filename"})) ? $_[0]->{"stored"} : 0; }

######################################################################
#	FileName
#	�����:
#		Object->FileName ()
#	���������� ��� ����� ���������.
######################################################################

sub FileName { return $_[0]->{"filename"}; }

######################################################################
#	Type
#	�����:
#		Object->Type ()
#	���������� Content-Type ���������.
######################################################################

sub Type { return (exists ($_[0]->{"type"})) ? $_[0]->{"type"} : ""; }

######################################################################


######################################################################
#	Cookies
#	����� �������� ������ ���������� Cookie
######################################################################

package Cookies;

######################################################################
#	Parse
#	�������� ���������� Cookie
#	�����:
#		Cookies->Parse ()
#	���������� ������ �� ����� ��������� ������ Cookies.
#
#	��������:
# Perl Routines to Manipulate Web Browser Cookies
# kovacsp@egr.uri.edu
# $Id: CGI_lib.pl,v 1.1 2003/12/28 16:27:15 spf Exp $
#
# Copyright (c) 1998 Peter D. Kovacs  
# Unpublished work.
# Permission granted to use and modify this library so long as the
# copyright above is maintained, modifications are documented, and
# credit is given for any use of the library.
#
# Portions of this library are taken, without permission (and much 
# appreciated), from the cgi-lib.pl.  You may get that at 
# http://cgi-lib.stanford.edu/cgi-lib
######################################################################

sub Parse {
   my $Class = shift;					# ��� ������
   my $Self = {};						# ������� ��������� �������
   bless ($Self, $Class);				# ��������� � ������
   if (exists ($ENV{"HTTP_COOKIE"})) {		# "������" �������
	for (split (/; /, $ENV{"HTTP_COOKIE"})) {	# ������� ���� ������
	   s/\+/ /g;					# ��������������
	   my ($Name, $Value) = split (/=/, $_, 2);	# ��������� �� ��� � ��������
	   $Name =~ s/%([A-Fa-f0-9]{2})/pack ("c", hex ($1))/ge;	# �������� ����������������� �������������
	   $Value =~ s/%([A-Fa-f0-9]{2})/pack ("c", hex ($1))/ge;
	   $Self->Store (Cookie->New ($Name, $Value));	# �������� � ���������
	}
   }
   return $Self;						# ������� ������ �� ����� ������
}

######################################################################
#	Parameters
#	�����:
#		Object->Parameters ()
#	���������� ������ ���� �������� ����������.
######################################################################

sub Parameters { return keys (%{$_[0]->{"parameters"}}); }	# ������� ����� ���� ����������

######################################################################
#	Count
#	������� ����� �������� ���������
#	�����:
#		Object->Count (Name)
#	���������:
#		Name - ��� ���������.
#	���������� ����� ����������� ��������� � ������ ������.
######################################################################

sub Count {
   my $Self = shift;					# ������ �� ������
   my $Name = shift;					# ��� ���������
   my $Param = $Self->{$Name};			# ������ �� ������ ����������� ����������
   return (defined ($Param) ? scalar (@$Param) : 0);	# ����� ����������
}

######################################################################
#	Retrieve
#	�����:
#		Object->Retrieve (Name[, Index])
#	���������:
#		Name  - ��� ���������;
#		Index - ������ ��������� � ������� �����������. ���� ��
#			  �����, �������������� ������� �������.
#	� ��������� ��������� ���������� ������ ������ �� �����������
#	���������. � ��������� ��������� ���������� ������ �� ��������
#	� ������������ � ��������. ���� ������ �������� ��� ���������
#	���, ������������ �������������� ��������.
######################################################################

sub Retrieve {
   my $Self = shift;					# ������ �� ������
   my $Name = shift;					# ��� ���������
   my $Index = shift () + 0;				# ������ � �������
   my $Param = $Self->{$Name};			# ������ �� ������ ����������� ����������
   return undef if (!defined ($Param));		# ��� ������ ���������
   return (wantarray) ? @$Param : $Param->[$Index];	# ������� ���������
}

######################################################################
#	RetrieveValue
#	�����:
#		Object->RetrieveValue (Name[, Index])
#	���������:
#		Name  - ��� ���������;
#		Index - ������ ��������� � ������� �����������. ���� ��
#			  �����, �������������� ������� �������.
#	���������� �������� ���������. ���� �������� �����������,
#	������������ �������������� ��������.
######################################################################

sub RetrieveValue {
   my $Self = shift;					# ������ �� ������
   my $Name = shift;					# ��� ���������
   my $Index = shift () + 0;				# ������ � �������
   my $Param = $Self->{$Name};			# ������ �� ������ ����������� ����������
   return undef if (!defined ($Param));		# ��� ������ ���������
   $Param = $Param->[$Index];				# ������ �� ������� ��������
   return undef if (!defined ($Param));		# ��� ������ ���������
   return $Param->Value ();				# ������� ��������
}

######################################################################
#	Store
#	�����:
#		Object->Store (Parameter)
#	���������:
#		Parameter - ������ �� ������ ���� ��������.
#	��������� ����� �������� � ���������.
######################################################################

sub Store {
   my $Self = shift;					# ������ �� ������
   my $Param = shift;					# ������ �� ����������� ��������
   my $ParamName = $Param->Name ();			# ��� ���������
   $Self->{$ParamName} = [] if (!exists ($Self->{$ParamName}));	# ������� ������ ��������� ��� �����
   push (@{$Self->{$ParamName}}, $Param);		# �������� � ������
}

######################################################################


######################################################################
#	Cookie
#	����� �������� ������ ��������� Cookie
######################################################################

package Cookie;

######################################################################
#	New
#	����������� ��������� Cookie
#	�����:
#		Cookie->New (Name, Value)
#	���������:
#		Name	 - ������������ ���������;
#		Value	 - �������� ���������;
#	���������� ������ �� ����� ��������� ������.
######################################################################

sub New {
   my $Class = shift;					# ��� ������
   my $Name = shift;					# ��� ���������
   my $Value = shift;					# �������� ���������
   my $Self = { name => $Name, value => $Value };	# ��� � �������� �����������
   return bless ($Self, $Class);			# ��������� � ������
}

######################################################################
#	Name
#	�����:
#		Object->Name ()
#	���������� ��� ���������.
######################################################################

sub Name { return $_[0]->{"name"}; }

######################################################################
#	Value
#	�����:
#		Object->Value ()
#	���������� �������� ���������.
######################################################################

sub Value { return $_[0]->{"value"}; }

1;
