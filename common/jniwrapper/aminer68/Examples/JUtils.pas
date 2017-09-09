{
Copyright (C) 1998-2001 Jonathan Revusky
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:
1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. All advertising materials mentioning features or use of this software
   must display the following acknowledgement:
     This product includes software developed by Jonathan Revusky
4. The name of the author may not be used to endorse or promote products
   derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
}

unit JUtils;

// Global utility routines

interface
   {$IFDEF FPC}
    uses Classes,Windows;
   {$ELSE}
   uses System.Classes, WinAPI.Windows,System.ansistrings;
   {$endif}

    
// Outputs a message. Sends it to the console or
// to a GUI message window depending.
    
  function dotToSlash(const s : AnsiString) : AnsiString;
  function slashToDot(const s : AnsiString) : AnsiString;
          
  function ConvertStrings(Strings : TStrings) : Pointer;
    
//wrappers around the Win32 API calls.
  function getEnvironmentString(S : AnsiString) : AnsiString;
  procedure setEnvironmentString(key, value : AnsiString);
    
  // redeclared here because in D2, the prototype in Window.pas is incorrect.
  function SearchPath(lpPath, lpFileName, lpExtension: PAnsiChar; 
                          nBufferLength: DWORD; 
                          lpBuffer: PAnsiChar; 
                          var lpFilePart: PAnsiChar): DWORD; stdcall;
    
  //uses the above SearchPath routine to
  // find the file on path. Returns full path or empty string.
  function FindOnSystemPath(Filename : AnsiString) : AnsiString;
    
  // converts the dots or forward slashes to backslashes
  function toBackSlash(const s : ansistring) : ansiString; 

  procedure ChopExtension(var Filename : AnsiString);

implementation
    {$IFDEF FPC}
    uses SysUtils, JavaRuntime;
    {$ELSE}
    uses System.SysUtils, JavaRuntime;
   {$endif}

    
var
  Buf : array[0..1023] of AnsiChar;
    
{little routine to convert the dots to slashes for fully
qualified Class names.}
    
  function dotToSlash(const s : ansistring) : AnsiString;
  var
    I: Integer;
  begin
    Result:= s;
    for I := 1 to length(Result) do
      if Result[I] = '.' then 
        Result[I] := '/';
  end;
    
  function slashToDot(const s: AnsiString) : AnsiString;
  var
    I : Integer;
  begin
    Result := s;
    for I :=  1 to length(Result) do
      if Result[I] = '/' then 
        Result[I] := '.';
  end;


  function toBackSlash(const s : ansistring) : AnsiString;
  var
    I: Integer;
  begin
    Result:= S;
    for I := 1 to length(S) do
      if (Result[I] = '.') or (Result[I] = '/') then 
        Result[I] := '\';
  end;

{Convert a TStrings object to a null-terminated 
  sequence of pointers to PAnsiChar. }
    
  function ConvertStrings(Strings : TStrings) : Pointer;
  var   
    PPC : ^PAnsiChar;
    I : Integer;
   str:ansistring;
  begin
    Result  := Nil;
    if Strings = Nil then 
      Exit;
    if Strings.Count =0 then 
      Exit;
    PPC  := allocMem((1 + Strings.Count) * sizeof(PAnsiChar));
    result := PPC;
    for I := 0 to  Strings.Count-1 do 
    begin
      PPC^ := PAnsiChar(ansistring(Strings[I])); 
      inc(PPC);
    end;
  end;


   {Trivial wrapper of the SearchPath API call.}
    
  function FindOnSystemPath(Filename : AnsiString) : AnsiString;
  var
    PC : PAnsiChar;
  begin
    if SearchPath(Nil, PAnsiChar(Filename), Nil, MAX_PATH, @Buf, PC)<>0 then
    Result := AnsiString(Buf);
  end;
    
    
  function getEnvironmentString(S : AnsiString) : AnsiString;
  begin
   {$IFDEF FPC}
   result:=getEnvironmentVariable(S)
   {$ELSE}
   if getEnvironmentVariable(Pchar(S), @Buf, 1023) >0 then
      result := AnsiString(Buf);
   {$endif}
   end;
    
  procedure SetEnvironmentString(key, value : AnsiString);
  begin
  
    SetEnvironmentVariable(PChar(key), PChar(value));
  end;

  procedure ChopExtension(var Filename : AnsiString);
  var
    Ext : AnsiString;
  begin
   {$IFDEF FPC}
    Ext := ExtractFileExt(Filename);
   {$ELSE}
    Ext := system.ansistrings.ExtractFileExt(Filename);
   {$endif}

    Filename := Copy(Filename, 1, Length(Filename) - Length(Ext));
  end;

    
  function SearchPath; external kernel32 name 'SearchPathA';

end.
