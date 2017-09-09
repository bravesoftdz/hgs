unit File2xlsThread;

interface

uses
  Windows, SysUtils, Classes, Forms, MyKernelObject, CommonUtil, janSQL,
  CopyData, CSV2xlsConst, FindFile_Pjh, xlsThread;

type
  TDataFile2xlsThread = class(TThread)
  private
    FOwner: TForm;

    procedure SetFile2DBEvent(AEvent: TEvent);
    procedure SetFileName(AFileName: string);
  protected
    procedure Execute; override;
  public
    FData2xlsThread: TData2xlsThread;
    //FFindFile: TFindFile;// Directory option�� ���� �Ͽ��� ��� ���� ����Ʈ �ۼ��ϴ� ��ü
    FjanDB : TjanSQL; //text ��� SQL DB
    FFileName: string; //����Ÿ�� �о���� File �̸�(������ ���� �����)
    FDataSaveEvent: TEvent;//Data Save Thread�� ���� ������ �˸��� Event Handle
    FSaving: Boolean; //����Ÿ �������̸� True
    //FDataSaveEvent2: TEvent;//Data Save Thread�� ���� ������ �˸��� Event Handle
    FRecordCount: integer; //��ü ����Ÿ �Ǽ�
    FRestart: Boolean; //True�̸� ó������ �ٽ� ������.
    FSuspendInsert: Boolean; //True�̸� Thread�� Suspend��
    //������ ó�� ������ �� ����Ÿ�� ó�� ����� ��� True
    FIsFileFirst: Boolean;    //���� �Ӹ��� ������ ����ϱ� ����
    FFileList: TStringList;//Insert�� File name list

    FDate, FTime: string;
    FAryTime1 : array[0..7] of string;
    FAryTime2 : array[0..3] of string;

    constructor Create(AOwner: TForm);
    destructor Destroy; override;

    procedure ReadCSVData(AryTime: array of string);
    procedure InitVar;
    procedure FileMatch(Sender: TObject; const Folder: String;
                                                    const FileInfo: TSearchRec);
  published
    property FullFileName: string read FFileName write SetFileName;
    property SaveEvent: TEvent read FDataSaveEvent write SetFile2DBEvent;
  end;

implementation

uses Main;

{ TDataSaveThread }

constructor TDataFile2xlsThread.Create(AOwner: TForm);
begin
  inherited Create(True);
  FOwner := AOwner;
  FDataSaveEvent := TEvent.Create('DataFromFileEvent'+IntToStr(GetCurrentThreadID),False);
  FData2xlsThread := TData2xlsThread.Create(FOwner);
  FData2xlsThread.FDataSaveEvent2 := FDataSaveEvent;
  FFileList := TStringList.Create;
  FFileList.Sorted := False;//insert ������� 
  //FFindFile := nil;
end;

destructor TDataFile2xlsThread.Destroy;
begin
  InitVar;

  if Assigned(FData2xlsThread) then
  begin
    FData2xlsThread.Terminate;
    FData2xlsThread.FDataSaveEvent.Signal;
    FData2xlsThread.Free;
    FData2xlsThread := nil;
  end;//if

  //if Assigned(FFindFile) then
  //begin
  //  FFindFile.Free;
  //  FFindFile := nil;
  //end;

  FDataSaveEvent.Free;
  FDataSaveEvent:= nil;

  FFileList.Free;

  inherited;
end;

procedure TDataFile2xlsThread.Execute;
var i: integer;
begin
  while not terminated do
  begin
    FSaving := True;
    TCsv2XlsF(FOwner).CurrentState := S_INSERTING;

    for i := 0 to FFileList.Count - 1 do
    begin
      if Terminated or FRestart then
        break;

      FFileName := FFileList.Strings[i];
      FDate := Copy(FFileName, 0, 10);
      FFileName := ReplaceStr(FFileName, '-', '');
      if FDate = DateToStr(Main.Csv2XlsF.DateTimePicker1.Date) then
        ReadCSVData(FAryTime2)
      else
        ReadCSVData(FAryTime1);
    end;

    TCsv2XlsF(FOwner).CurrentState := S_FINISHED_INSERT;
    FSaving := False;

    if not (FRestart or Terminated) then
      Suspend;
  end;//while
end;

procedure TDataFile2xlsThread.FileMatch(Sender: TObject;
  const Folder: String; const FileInfo: TSearchRec);
begin
  FFileList.Add(Folder + FileInfo.Name);
end;

procedure TDataFile2xlsThread.InitVar;
begin
  if Assigned(FjanDB) then
  begin
    FjanDB.Free;
    FjanDB := nil;
  end;

  FRestart := False;
  FSuspendInsert := False;

  FAryTime1[0] := '9:00';
  FAryTime1[1] := '11:00';
  FAryTime1[2] := '13:00';
  FAryTime1[3] := '15:00';
  FAryTime1[4] := '17:00';
  FAryTime1[5] := '19:00';
  FAryTime1[6] := '21:00';
  FAryTime1[7] := '23:00';

  FAryTime2[0] := '1:00';
  FAryTime2[1] := '3:00';
  FAryTime2[2] := '5:00';
  FAryTime2[3] := '6:00';

  //if not Assigned(FFindFile) then
  //begin
  //  FFindFile := TFindFile.Create(nil);
  //  FFindFile.Threaded := False;
  //  FFindFile.OnFileMatch := FileMatch;
  //end;

  //FFindFile.Criteria.Files.Location := FullFileName;
  //FFindFile.Criteria.Files.FileName := '*.csv';
  //FFindFile.Execute;
end;

procedure TDataFile2xlsThread.ReadCSVData(AryTime: array of string);
var
  sqltext: string;
  sqlresult, fldcnt: integer;
  i,j: integer;
  Filename, Filepath: string;
  //Time2: string;
begin
  if fileexists(FullFileName) then
  begin
    Filename := ExtractFileName(FullFileName);
    Filepath := ExtractFilePath(FullFileName);
    if FilePath = '' then
      FilePath := '.\';
    FileName := Copy(Filename,1, Pos('.',Filename) - 1);
    FjanDB :=TjanSQL.create(',');
    sqltext := 'connect to ''' + FilePath + '''';

    sqlresult := FjanDB.SQLDirect(sqltext);
    //Connect ����
    if sqlresult <> 0 then
    begin
      //FTime := '9:00';
      //Time2 := '9:10';
      with FjanDB do
      begin
        FileExt := '.csv';//���� Ȯ���� ���� (Default = '.txt')

        for j := Low(AryTime) to High(AryTime) do
        begin
          sqltext := 'select * from ' + FileName + ' where Save_DateTime = ''' +
              FDate + ' ' + AryTime[j] + '''';// and Save_DateTime < ''' + FDate + ' ' + Time2 + '''';

          sqlresult := SQLDirect(sqltext);
          //Query ����
          if sqlresult <> 0 then
          begin
            //����Ÿ �Ǽ��� 1�� �̻� ������
            if sqlresult>0 then
            begin
              fldcnt := RecordSets[sqlresult].FieldCount;
              //Field Count�� 0 �̸�
              if fldcnt = 0 then exit;

              FRecordCount := RecordSets[sqlresult].RecordCount;
              //Record Count�� 0 �̸�
              if FRecordCount = 0 then exit;

              SendCopyData2(FOwner.Handle, ExtractFileName(FullFileName)+' ó����...', Ord(SB_LED));

              for i := 0 to FRecordCount - 1 do
              begin
                if Terminated or FRestart then
                  exit;

                if FSuspendInsert then
                begin
                  Suspend;
                  FSuspendInsert := False;
                end;

                FData2xlsThread.FjanRecord := RecordSets[SqlResult].Records[i];
                FData2xlsThread.FDataSaveEvent.Signal;
                SendCopyData2(FOwner.Handle, IntToStr(Round((i / FRecordCount) * 100)), Ord(SB_PROGRESS));
                SendCopyData2(FOwner.Handle, IntToStr(i+1), Ord(SB_RECORDCOUNT));
                FDataSaveEvent.Wait(INFINITE);
              end;//for

              SendCopyData2(FOwner.Handle, '100', Ord(SB_PROGRESS));
              SendCopyData2(FOwner.Handle, ExtractFileName(FullFileName)+' ó�� �Ϸ�', Ord(SB_LED));
            end;

          end
          else
            SendCopyData2(FOwner.Handle, FjanDB.Error, Ord(SB_SIMPLE));
        end;//for
      end;//with
    end
    else
      Application.MessageBox('Connect ����',
          PChar('���� ' + FilePath + ' �� ���� �� �ٽ� �Ͻÿ�'),MB_ICONSTOP+MB_OK);
  end
  else
  begin
    Application.MessageBox('Data file does not exist!' + #13#10,
            PChar(FullFileName +' ������ ���� �Ŀ� �ٽ� �Ͻÿ�'),MB_ICONSTOP+MB_OK);
  end;
end;

procedure TDataFile2xlsThread.SetFile2DBEvent(AEvent: TEvent);
begin
  if FDataSaveEvent = nil then
    FDataSaveEvent := AEvent;
end;

procedure TDataFile2xlsThread.SetFileName(AFileName: string);
begin
  if FFileName <> AFileName then
    FFileName := AFileName;
end;

end.
