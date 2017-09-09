unit UnitAlarmConst;

interface

uses HiMECSConst, UnitAlarmConfigClass, System.Generics.Collections, messages,
  System.Classes, System.SysUtils, mORMot, SynCommons,SerializableObjectList;

type
  //�˶� ����Ʈ ǥ�ÿ� �ʿ�(�������� DB�� ���� �ÿ��� AlarmConfigCollect �����
  PAlarmListRecord = ^TAlarmListRecord;
  TAlarmListRecord = packed record
    FUserID: string;
    FCategory: string;
    FProjNo: string;
    FEngNo: string;
    FTagName: string;
    FAlarmSetType: TAlarmSetType; //���� �˶��� � �������� ������
    FIssueDateTime: TDateTime;
    FReleaseDateTime: TDateTime;
    FAcknowledgedTime: TDateTime;
    FSuppressedTime: TDateTime; //���� 0�� �ƴϸ� Suppressed �� ����
    FIsOutLamp: Boolean; //�汤�� ���
    FAlarmPriority: TAlarmPriority;
    FNeedAck: Boolean;
    FSetValue: string;    //�˶� ���� ��(limit value)
    FSensorValue: string; //�����κ���  ������ ��
    FAlarmMessage: string; //������ ��� EngineParameter�� Descript�� ǥ�õ�
    FDelay: integer;
    FDeadBand: integer;
    FNotifyApps: integer;
    FAlarmAction: TAlarmAction;
    FRecipients: string; //���� ������ ����Ʈ(���;���;...)
    FIsOnlyRun: Boolean; //1: ���� Running �ÿ��� �˶� �߻� ��Ŵ
  end;

  TMonitoringEngInfo = class//(TSerializable)
  private
    FProjNo,
    FEngNo,
    FMonTableName,
    FRunCondTagName,
    FRunCondTagDesc,
    FRunCondParamIndex: string;
  published
    property ProjNo: string read FProjNo write FProjNo;
    property EngNo: string read FEngNo write FEngNo;
    property MonTableName: string read FMonTableName write FMonTableName;
    property RunCondTagName: string read FRunCondTagName write FRunCondTagName;
    property RunCondTagDesc: string read FRunCondTagDesc write FRunCondTagDesc;
    property RunCondParamIndex: string read FRunCondParamIndex write FRunCondParamIndex;
  end;

  TAlarmListRecords = array of TAlarmListRecord;
  TAlarmConfigDict = TDictionary<string, TList<TAlarmConfigItem>>;

  TMonEngInfoDict = class(TDictionary<string, TMonitoringEngInfo>)
  private
    procedure LoadFromStream(stream: TStream);
    procedure SaveToStream(stream: TStream);
  public
    procedure LoadFromZip(const AFileName: string);
    procedure LoadFromFile(const AFileName: string);
    procedure SaveToZip(const AFileName: string);
    procedure SaveToFile(const AFileName: string);
  end;

Const
  WM_DISPLAYMESSAGE = WM_USER + 200;
  //Alarm List Grid Column Index
  CI_ACKED = 0;
  CI_TIME_IN = 1;
  CI_TIME_OUT = 2;
  CI_ENGINE_NO = 3;
  CI_TAG_DESC = 4;
  CI_ALARM_LEVEL = 5;
  CI_ALARM_MSG = 6;
  CI_ALARM_PRIO = 7;
  //Alarm List Grid Column Index
implementation

{ TMonEngInfoDict }

procedure TMonEngInfoDict.LoadFromFile(const AFileName: string);
var
  LDict: System.Generics.Collections.TPair<string, TMonitoringEngInfo>;
  LMonitoringEngInfo: TMonitoringEngInfo;
  LKey: string;
//  LMonEngInfos: TObjectList<TMonitoringEngInfo>;
  LMonEngInfos: TRawUTF8DynArray;
  LArr: TDynArray;
  LUtf8: RawUTF8;
  LFS: TStringList;
  i: integer;
  LSucceed: Boolean;
begin
//  LMonEngInfos := TObjectList<TMonitoringEngInfo>.create;
  LArr.Init(TypeInfo(TRawUTF8DynArray), LMonEngInfos, @i);
  LFS := TStringList.Create;
  try
//    TJSONSerializer.RegisterClassForJSON([TMonitoringEngInfo]);
//    JSONFileToObject(AFileName, LMonEngInfos);
    LFS.LoadFromFile(AFileName);
    LUtf8 := StringToUTF8(LFS.Text);
    LArr.LoadFromJSON(@LUtf8[1]);

//    if LArr.Count > 0 then
//    begin
//      for LDict in Self do
//        LDict.Value.Free;
//
//      Self.Clear;
//    end;

    LMonitoringEngInfo := TMonitoringEngInfo.Create;
    try
      for i := 0 to LArr.Count - 1 do
      begin
        LUtf8 := LMonEngInfos[i];
        JSONToObject(LMonitoringEngInfo, @LUtf8[1], LSucceed);
        LKey := GetUniqueEngName(LMonitoringEngInfo.FProjNo, LMonitoringEngInfo.FEngNo);

        if Self.ContainsKey(LKey) then
        begin
          Self[LKey].FRunCondTagName := LMonitoringEngInfo.FRunCondTagName;
          Self[LKey].FRunCondTagDesc := LMonitoringEngInfo.FRunCondTagDesc;
          Self[LKey].FRunCondParamIndex := LMonitoringEngInfo.FRunCondParamIndex;
        end;
      end;
    finally
      LMonitoringEngInfo.Free;
    end;
  finally
    LFS.Free;
  end;
end;

procedure TMonEngInfoDict.LoadFromStream(stream: TStream);
var
  sFiles: TMonitoringEngInfo;
  size: Integer;
  i: Integer;
  sWord: string;
  reader: TReader;
  sFile: string;
begin
  Clear;
  reader := TReader.Create(stream, 1024);
  try
    reader.ReadListBegin;
    while not reader.EndOfList do
    begin
      sWord := reader.ReadString;
      sFiles := TMonitoringEngInfo.Create;
      reader.ReadListBegin;
      while not reader.EndOfList do
      begin
        sFile := reader.ReadString;
        size := reader.ReadInteger;
//        sFiles.Add(sFile, Copy(aPosi));
      end;
      reader.ReadListEnd;
//      Add(sWord, sFiles);
    end;
    reader.ReadListEnd;
  finally
    reader.Free;
  end;end;

procedure TMonEngInfoDict.LoadFromZip(const AFileName: string);
//var
//  stream: TStream;
//  localHeader: TZipHeader;
//  zipFile: TZipFile;
begin
//  zipFile := TZipFile.Create;
//  try
//    zipFIle.Open(AFIleName, zmRead);
//    zipFile.Read('worddict', stream, localHeader);
//    try
//      LoadFromStream(stream);
//    finally
//      stream.Free;
//    end;
//    zipFile.Close;
//  finally
//    zipFile.Free;
//  end;
end;

procedure TMonEngInfoDict.SaveToFile(const AFileName: string);
var
  LKey: string;
  i: integer;
//  LMonEngInfos: TObjectList<TMonitoringEngInfo>;
  LMonEngInfos: TRawUTF8DynArray;
  LMonitoringEngInfo: TMonitoringEngInfo;
  LArr: TDynArray;
  LUtf8: RawUTF8;
  LFS: TStringList;
begin
//  LMonEngInfos := TObjectList<TMonitoringEngInfo>.create;
  if not FileExists(AFileName) then
    FileClose(FileCreate(AFileName));

  LArr.Init(TypeInfo(TRawUTF8DynArray), LMonEngInfos, @i);
  LFS := TStringList.Create;//(AFileName, fmOpenWrite);
  try
    for LKey in Self.Keys do
    begin
      LMonitoringEngInfo := Self[LKey];
      LUtf8 := ObjectToJSON(LMonitoringEngInfo);
      LArr.Add(LUtf8);
    end;
//      LMonEngInfos.Add(Self[LKey]);

//    TJSONSerializer.RegisterClassForJSON([TMonitoringEngInfo]);
//    ObjectToJSONFile(LMonEngInfos,AFileName);
//    LUtf8 := ObjectToJSON(LMonEngInfos);
      LUtf8 := LArr.SaveToJSON;
      LFS.Text := UTF8ToString(LArr.SaveToJSON);
//      LFS.Text := StringReplace(LFS.Text,'\','',[rfReplaceAll]);
      LFS.SaveToFile(AFileName);
  finally
    LFS.Free;
//    LMonEngInfos.Free;
  end;
end;

procedure TMonEngInfoDict.SaveToStream(stream: TStream);
var
  posi: TMonitoringEngInfo;
  i: Integer;
  pair: System.Generics.Collections.TPair<string, TMonitoringEngInfo>;
  writer: TWriter;
begin
//  writer := TWriter.Create(stream, 4096);
//  try
//    writer.WriteListBegin;
//    for pair in Self do
//    begin
//      writer.WriteString(pair.Key);
//      writer.WriteListBegin;
//      for posi in pair.Value do
//      begin
//        writer.WriteString(posi.Key);
//        writer.WriteInteger(Length(posi.Value));
//        for i in posi.Value do
//        begin
//          writer.WriteInteger(i);
//        end;
//      end;
//      writer.WriteListEnd;
//    end;
//    writer.WriteListEnd;
//  finally
//    writer.Free;
//  end;
end;

procedure TMonEngInfoDict.SaveToZip(const AFileName: string);
//var
//  stream: TStream;
//  zipFile: TZipFile;
begin
//  stream := TMemoryStream.Create;
//  try
//    SaveToStream(stream);
//    stream.Position := 0;
//    zipFile := TZipFile.Create;
//    try
//      zipFile.Open(AFileName, zmWrite);
//      zipFile.Add(stream, 'worddict');
//      zipFile.Close;
//    finally
//      zipFile.Free;
//    end;
//  finally
//    stream.Free;
//  end;
end;

end.
