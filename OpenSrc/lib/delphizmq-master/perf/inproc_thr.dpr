{
    Copyright (c) 2012 Varga Bal�zs (bb.varga@gmail.com)

    This file is part of 0MQ Delphi binding

    0MQ Delphi binding is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public License as
    published by the Free Software Foundation; either version 3 of the
    License, or (at your option) any later version.

    0MQ Delphi binding is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
}
program inproc_thr;

{$APPTYPE CONSOLE}

uses
    SysUtils
  , Windows
  , zmqapi
  ;

var
  msgsize: Integer;
  msgcount: Integer;

procedure worker( cntx: TZMQContext );
var
  socket: TZMQSocket;
  msg: TZMQFrame;
  i: Integer;
begin
  socket := cntx.Socket( stPush );
  socket.connect( 'inproc://thr_test' );

  for i := 0 to msgcount - 1 do
  begin
    msg := TZMQFrame.create( msgsize );
    FillMemory( msg.data, msgsize, 0 );
    socket.send( msg );
  end;
  socket.Free;
end;

var
  context: TZMQContext;
  socket: TZMQSocket;
  msg: TZMQFrame;
  tid: Cardinal;
  i: Integer;

  elapsed,
  throughput,
  megabits: Real;

  fFrequency,
  fstart,
  fStop : Int64;

  localThread: THandle;
  rc2: Cardinal;
  rc3: LongBool;
begin
  if ParamCount <> 2 then
  begin
    Writeln('usage: thread_thr <message-size> <message-count>' );
    exit;
  end;

  msgsize := StrToInt( ParamStr( 1 ) );
  msgcount := StrToInt( ParamStr( 2 ) );

  context := TZMQContext.Create;

  socket := context.Socket( stPull );
  socket.bind( 'inproc://thr_test' );

  localThread := BeginThread( nil, 0, @worker, context, 0, tid );
  if localThread = 0 then
    raise Exception.Create( 'error in BeginThread' );

  msg := TZMQFrame.create;

  Writeln( Format('message size: %d [B]', [msgsize] ) );
  Writeln( Format('message count: %d', [msgcount] ) );

  if socket.recv( msg ) <> msgsize then
    raise Exception.Create( 'message of incorrect size received' );

  QueryPerformanceFrequency( fFrequency );
  QueryPerformanceCounter( fStart );

  for i := 0 to msgcount - 2 do
  begin
    if socket.recv( msg ) <> msgsize then
      raise Exception.Create( 'message of incorrect size received' );
  end;

  QueryPerformanceCounter( fStop );
  elapsed := 1000*1000*(fStop - fStart) / fFrequency;
  if elapsed = 0 then
    elapsed := 1;

  msg.Free;

  rc2 := WaitForSingleObject( localThread, INFINITE );
  if rc2 = WAIT_FAILED then
    raise Exception.Create( 'error in WaitForSingleObject' );

  rc3 := CloseHandle( localThread );
  if not rc3 then
    raise Exception.Create( 'error in CloseHandle' );

  socket.Free;
  context.Free;

  throughput := msgcount / elapsed * 1000000;
  megabits := throughput * msgsize * 8 / 1000000;

  Writeln( Format('mean throughput: %f [msg/s]', [ throughput ] ) );
  Writeln( Format('mean throughput: %.3f [Mb/s]', [ megabits ] ) );

end.

