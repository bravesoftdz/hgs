unit UnitExtraMH;

interface

uses System.SysUtils, System.StrUtils, System.DateUtils, SynCommons, UnitExtraMHInfoClass;

type
  TExtraMH = class
  public
    FExtraMHInfo: TExtraMHInfo;

    constructor Create;
    destructor Destroy;

    function GetExtraMHInfo(AFrom, ATo: string): RawUTF8;
    //��ǰ�� ���� �߰� ����
    procedure GetExtraMHPerProductPerMonth(AFrom, ATo: string);
    //���� �߰� ����
    procedure GetExtraMHPerMonth(AFrom, ATo: string);
    //�μ��� �߰� ����
    procedure GetExtraMHPerDept(AFrom, ATo: string);
    //��ǰ�� �μ��� �߰� ����
    procedure GetExtraMHPerProductPerDept(AFrom, ATo: string);
    //���� ���� ��� (�ݾ׺��� �߰�����)
    procedure GetFailureExtraMHPerMonth(AYear: string);
    //���� ������
    procedure GetOriginalMHPerMonth(AYear: string);
  end;

implementation

uses UnitDM;

{ TExtraMH }

constructor TExtraMH.Create;
begin
  FExtraMHInfo := TExtraMHInfo.Create(nil);
end;

destructor TExtraMH.Destroy;
begin
  FExtraMHInfo.Free;
end;

//AFrom : YYYYMM
//ATO: YYYYMM
function TExtraMH.GetExtraMHInfo(AFrom, ATo: string): RawUTF8;
begin
  GetExtraMHPerProductPerMonth(AFrom, ATo);
  GetExtraMHPerMonth(AFrom, ATo);
  GetExtraMHPerDept(AFrom, ATo);
  GetExtraMHPerProductPerDept(AFrom, ATo);
  GetFailureExtraMHPerMonth(LeftStr(AFrom, 4));
  GetOriginalMHPerMonth(LeftStr(AFrom, 4));

  Result := ObjectToJson(FExtraMHInfo);
end;

//�μ��� �߰� ���� ��������
procedure TExtraMH.GetExtraMHPerDept(AFrom, ATo: string);
var
  LSql: string;
  i: integer;
  LMHInfo: TExtraMHPerDeptItem;
begin
  LSql := 'SELECT  b.WKDEPT, SUM( ' +
          '                  (SELECT SUM (MANH) ' +
          '                  FROM kh15.PVW_TPCB330_KTUCA001 ' +
          '                  WHERE     YYMM = B.YYMM ' +
          '                  AND PROJNO = A.PROJNO ' +
          '                  AND SUBPROJNO = A.SUBPROJNO ' +
          '                  AND PARTNO = A.PARTNO || ''-'' || A.PARTNO5 ' +
          '                  AND DEPT = A.DEPT ' +
          '                  AND PROCNO = A.PROCNO) ) MANH ' +
          'FROM KH15.KTPE025 A, KH16.TPCA120 B ' +
          'WHERE A.PROJNO = B.PROJNO ' +
          '      AND A.SUBPROJNO = B.SUBPROJNO ' +
          '      AND A.DEPT = NVL (B.VENDOR, B.DEPT) ' +
          '      AND A.PARTNO = B.PARTNO1 ' +
          '      AND A.PARTNO5 = B.PARTNO5 ' +
          '      AND A.DOCNO = B.WKNO ' +
          '      AND A.YOIN IN (''A1'', ''A4'', ''D1'', ''E1'' ) ' +
          '      and b.yymm >= :F ' +
          '      and b.yymm <= :T ' +
          'GROUP BY  b.WKDEPT';

  with DM1.ExtraMHQuery do
  begin
    Close;
    SQL.Clear;
    SQL.Add(LSql);
    ParamByName('F').AsString := AFrom;
    ParamByName('T').AsString := ATo;
    Open;

    if RecordCount > 0 then
    begin
      FExtraMHInfo.ExtraMHPerDeptCollect.Clear;

      for i := 0 to RecordCount - 1 do
      begin
        LMHInfo := FExtraMHInfo.ExtraMHPerDeptCollect.Add;

        with LMHInfo do
        begin
          DeptCode := FieldByName('WKDEPT').AsString;
          M_H := FieldByName('MANH').AsFloat;
        end;

        Next;
      end;//for
    end;
  end;//with DM1
end;

//���� �߰� ���� ��������
procedure TExtraMH.GetExtraMHPerMonth(AFrom, ATo: string);
var
  LSql: string;
  i: integer;
  LMHInfo: TExtraMHPerMonthItem;
begin
  LSql := 'SELECT B.YYMM, SUM( ' +
          '              (SELECT SUM (MANH) ' +
          '              FROM kh15.PVW_TPCB330_KTUCA001 ' +
          '              WHERE YYMM = B.YYMM ' +
          '              AND PROJNO = A.PROJNO ' +
          '              AND SUBPROJNO = A.SUBPROJNO ' +
          '              AND PARTNO = A.PARTNO || ''-'' || A.PARTNO5 ' +
          '              AND DEPT = A.DEPT ' +
          '              AND PROCNO = A.PROCNO) ) MANH ' +
          'FROM KH15.KTPE025 A, KH16.TPCA120 B ' +
          'WHERE A.PROJNO = B.PROJNO ' +
          '     AND A.SUBPROJNO = B.SUBPROJNO ' +
          '     AND A.DEPT = NVL (B.VENDOR, B.DEPT) ' +
          '     AND A.PARTNO = B.PARTNO1 ' +
          '     AND A.PARTNO5 = B.PARTNO5 ' +
          '     AND A.DOCNO = B.WKNO ' +
          '     AND A.YOIN IN (''A1'', ''A4'', ''D1'', ''E1'' ) ' +
          '     and b.yymm >= :F ' +
          '     and b.yymm <= :T ' +
          'GROUP BY B.YYMM';

  with DM1.ExtraMHQuery do
  begin
    Close;
    SQL.Clear;
    SQL.Add(LSql);
    ParamByName('F').AsString := AFrom;
    ParamByName('T').AsString := ATo;
    Open;

    if RecordCount > 0 then
    begin
      FExtraMHInfo.ExtraMHPerMonthCollect.Clear;

      for i := 0 to RecordCount - 1 do
      begin
        LMHInfo := FExtraMHInfo.ExtraMHPerMonthCollect.Add;

        with LMHInfo do
        begin
          YYYYMM := FieldByName('yymm').AsString;
          YYYY := StrToInt(LeftStr(YYYYMM, 4));
          MM := StrToInt(RightStr(YYYYMM,2));
          M_H := FieldByName('MANH').AsFloat;
        end;

        Next;
      end;//for
    end;
  end;//with DM1
end;

//��ǰ�� �μ��� �߰� ���� ��������
procedure TExtraMH.GetExtraMHPerProductPerDept(AFrom, ATo: string);
var
  LSql: string;
  i: integer;
  LMHInfo: TExtraMHPerProductPerDeptItem;
begin
  LSql := 'SELECT  decode(c.projgb,''A'',''����'',''B'',''����'',''D'',''������'', ' +
          '                ''H'',''ȯ����'',''K'',''������'',''J'',''�ͺ����'', ' +
          '                ''E'',''��������'',''R'',''�κ�'',c.projgb) projgb,b.WKDEPT, ' +
          '                SUM( (SELECT SUM (MANH) ' +
          '                  FROM kh15.PVW_TPCB330_KTUCA001 ' +
          '                  WHERE     YYMM = B.YYMM ' +
          '                  AND PROJNO = A.PROJNO ' +
          '                  AND SUBPROJNO = A.SUBPROJNO ' +
          '                  AND PARTNO = A.PARTNO || ''-'' || A.PARTNO5 ' +
          '                  AND DEPT = A.DEPT ' +
          '                  AND PROCNO = A.PROCNO) ) MANH ' +
          'FROM KH15.KTPE025 A, KH16.TPCA120 B,kh15.ktpb001 c ' +
          'WHERE A.PROJNO = B.PROJNO ' +
          '     AND A.SUBPROJNO = B.SUBPROJNO ' +
          '     AND A.DEPT = NVL (B.VENDOR, B.DEPT) ' +
          '     AND A.PARTNO = B.PARTNO1 ' +
          '     AND A.PARTNO5 = B.PARTNO5 ' +
          '     AND A.DOCNO = B.WKNO ' +
          '     AND A.YOIN IN (''A1'', ''A4'', ''D1'', ''E1'' ) ' +
          '     and b.yymm >= :F ' +
          '     and b.yymm <= :T ' +
          '     and a.projno = c.projno ' +
          '     and a.subprojno = c.subprojno ' +
          'GROUP BY  c.projgb,b.WKDEPT';

  with DM1.ExtraMHQuery do
  begin
    Close;
    SQL.Clear;
    SQL.Add(LSql);
    ParamByName('F').AsString := AFrom;
    ParamByName('T').AsString := ATo;
    Open;

    if RecordCount > 0 then
    begin
      FExtraMHInfo.ExtraMHPerProductPerDeptCollect.Clear;

      for i := 0 to RecordCount - 1 do
      begin
        LMHInfo := FExtraMHInfo.ExtraMHPerProductPerDeptCollect.Add;

        with LMHInfo do
        begin
          ProductName := FieldByName('projgb').AsString;
          DeptCode := FieldByName('WKDEPT').AsString;
          M_H := FieldByName('MANH').AsFloat;
        end;

        Next;
      end;//for
    end;
  end;//with DM1
end;

//��ǰ�� ���� �߰� ���� ��������
procedure TExtraMH.GetExtraMHPerProductPerMonth(AFrom, ATo: string);
var
  LSql: string;
  i: integer;
  LMHInfo: TExtraMHPerProductPerMonthItem;
begin
//  LSql := 'SELECT  decode(c.projgb,''A'',''����'',''B'',''����'',''D'',''������'', ' +
//          '               ''H'',''ȯ����'',''K'',''������'',''J'',''�ͺ����'', ' +
//          '               ''E'',''��������'',''R'',''�κ�'',c.projgb) projgb,b.yymm, ' +
//          '               SUM( (SELECT SUM (MANH) ' +
//          '                    FROM kh15.PVW_TPCB330_KTUCA001 ' +
//          '                    WHERE     YYMM = B.YYMM ' +
//          '                    AND PROJNO = A.PROJNO ' +
//          '                    AND SUBPROJNO = A.SUBPROJNO ' +
//          '                    AND PARTNO = A.PARTNO || ''-'' || A.PARTNO5 ' +
//          '                    AND DEPT = A.DEPT ' +
//          '                   AND PROCNO = A.PROCNO) ) MANH ' +
//          'FROM KH15.KTPE025 A, KH16.TPCA120 B,KH15.ktpb001 c ' +
//          'WHERE  A.PROJNO = B.PROJNO ' +
//          '   AND A.SUBPROJNO = B.SUBPROJNO ' +
//          '   AND A.DEPT = NVL (B.VENDOR, B.DEPT) ' +
//          '   AND A.PARTNO = B.PARTNO1 ' +
//          '   AND A.PARTNO5 = B.PARTNO5 ' +
//          '   AND A.DOCNO = B.WKNO ' +
//          '   AND A.YOIN IN (''A1'', ''A4'', ''D1'', ''E1'' ) ' +
//          '   and b.yymm >= :F ' + //YYYYMM (String)
//          '   and b.yymm <= :T ' +
//          '   and a.projno = c.projno ' +
//          '   and a.subprojno = c.subprojno ' +
//          'GROUP BY  c.projgb,b.yymm';

//�� SQL������ ������ := ������ + �ͺ���� �� ���� ǥ����
//  LSql := 'SELECT  decode(c.projgb,''A'',''����'',''B'',''����'',''D'',''������'', ' +
//          '               ''H'',''ȯ����'',''K'',''������'',''J'',''������'', ' +
//          '               ''E'',''��������'',''R'',''�κ�'',c.projgb) projgb,b.yymm, ' +
//          '               SUM( (SELECT SUM (MANH) ' +
//          '                    FROM kh15.PVW_TPCB330_KTUCA001 ' +
//          '                    WHERE     YYMM = B.YYMM ' +
//          '                    AND PROJNO = A.PROJNO ' +
//          '                    AND SUBPROJNO = A.SUBPROJNO ' +
//          '                    AND PARTNO = A.PARTNO || ''-'' || A.PARTNO5 ' +
//          '                    AND DEPT = A.DEPT ' +
//          '                   AND PROCNO = A.PROCNO) ) MANH ' +
//          'FROM KH15.KTPE025 A, KH16.TPCA120 B,KH15.ktpb001 c ' +
//          'WHERE  A.PROJNO = B.PROJNO ' +
//          '   AND A.SUBPROJNO = B.SUBPROJNO ' +
//          '   AND A.DEPT = NVL (B.VENDOR, B.DEPT) ' +
//          '   AND A.PARTNO = B.PARTNO1 ' +
//          '   AND A.PARTNO5 = B.PARTNO5 ' +
//          '   AND A.DOCNO = B.WKNO ' +
//          '   AND A.YOIN IN (''A1'', ''A4'', ''D1'', ''E1'' ) ' +
//          '   and b.yymm >= :F ' + //YYYYMM (String)
//          '   and b.yymm <= :T ' +
//          '   and a.projno = c.projno ' +
//          '   and a.subprojno = c.subprojno ' +
//          'GROUP BY  decode(c.projgb,''A'',''����'',''B'',''����'',''D'',''������'',''H'',''ȯ����'',''K'',''������'',''J'',''������'',''E'',''��������'',''R'',''�κ�'',c.projgb),b.yymm';

//�� SQL ������ �����Ͱ� ���� ���� 0���� ä��
//  LSql := 'select y.projgb,y.yymm,nvl(x.manh,0) MANH ' +
//          'from (SELECT  decode(c.projgb,''A'',''����'',''B'',''����'',''D'', ' +
//          '''������'',''H'',''ȯ����'',''K'',''������'',''J'',''������'', ' +
//          '''E'',''��������'',''R'',''�κ�'',c.projgb) projgb,b.yymm, ' +
//          '       SUM( (SELECT SUM (MANH) ' +
//          '             FROM kh15.PVW_TPCB330_KTUCA001 ' +
//          '                  WHERE YYMM = B.YYMM ' +
//          '                  AND PROJNO = A.PROJNO ' +
//          '                  AND SUBPROJNO = A.SUBPROJNO ' +
//          '                  AND PARTNO = A.PARTNO || ''-'' || A.PARTNO5 ' +
//          '                  AND DEPT = A.DEPT ' +
//          '                  AND PROCNO = A.PROCNO) ) MANH ' +
//          '       FROM KH15.KTPE025 A, KH16.TPCA120 B,KH15.ktpb001 c ' +
//          'WHERE A.PROJNO = B.PROJNO ' +
//          '      AND A.SUBPROJNO = B.SUBPROJNO ' +
//          '      AND A.DEPT = NVL (B.VENDOR, B.DEPT) ' +
//          '      AND A.PARTNO = B.PARTNO1 ' +
//          '      AND A.PARTNO5 = B.PARTNO5 ' +
//          '      AND A.DOCNO = B.WKNO ' +
//          '      AND A.YOIN IN (''A1'', ''A4'', ''D1'', ''E1'' ) ' +
//          '      and b.yymm >= :F ' +
//          '      and b.yymm <= :T ' +
//          '      and a.projno = c.projno ' +
//          '      and a.subprojno = c.subprojno ' +
//          'GROUP BY  decode(c.projgb,''A'',''����'',''B'',''����'',''D'', ' +
//          ' ''������'',''H'',''ȯ����'',''K'',''������'',''J'',''������'', ' +
//          '''E'',''��������'',''R'',''�κ�'',c.projgb),b.yymm)  x, ' +
//          '   (select a.yymm,b.projgb ' +
//          '    from (select distinct yymm from kh15.ktpk023 ' +
//          '    where yymm >= :F ' +
//          '         and yymm <= :T ) a, ' +
//          '       (select ''����'' projgb from dual union ' +
//          '       select ''����'' projgb from dual union ' +
//          '       select ''������'' projgb from dual union ' +
//          '       select ''ȯ����'' projgb from dual union ' +
//          '       select ''������'' projgb from dual union ' +
//          '       select ''��������'' projgb from dual ) b) y ' +
//          ' where y.yymm = x.yymm(+) and ' +
//          '   y.projgb = x.projgb(+) ' +
//          'order by y.projgb,y.yymm';

  //������ ���� ���� 0���� ä��� ���� SQL�� ó����
  LSql := 'SELECT decode(projgb,''A'',''��������'',''B'',''��������'',''D'',''������'', ' +
          '       ''H'',''�ڿ�����'',''K'',''������'',''F'',''ȯ����'', ' +
          '       ''E'',''��������'',''R'',''�κ�'',projgb) PROJGB, ' +
          '        SUM(DECODE(SUBSTR(YYMM,5,2),''01'',MANH,0)) M01, ' +
          '        SUM(DECODE(SUBSTR(YYMM,5,2),''02'',MANH,0)) M02, ' +
          '        SUM(DECODE(SUBSTR(YYMM,5,2),''03'',MANH,0)) M03, ' +
          '        SUM(DECODE(SUBSTR(YYMM,5,2),''04'',MANH,0)) M04, ' +
          '        SUM(DECODE(SUBSTR(YYMM,5,2),''05'',MANH,0)) M05, ' +
          '        SUM(DECODE(SUBSTR(YYMM,5,2),''06'',MANH,0)) M06, ' +
          '        SUM(DECODE(SUBSTR(YYMM,5,2),''07'',MANH,0)) M07, ' +
          '        SUM(DECODE(SUBSTR(YYMM,5,2),''08'',MANH,0)) M08, ' +
          '        SUM(DECODE(SUBSTR(YYMM,5,2),''09'',MANH,0)) M09, ' +
          '        SUM(DECODE(SUBSTR(YYMM,5,2),''10'',MANH,0)) M10, ' +
          '        SUM(DECODE(SUBSTR(YYMM,5,2),''11'',MANH,0)) M11, ' +
          '        SUM(DECODE(SUBSTR(YYMM,5,2),''12'',MANH,0)) M12 ' +
          '  FROM ' +
          '  ( ' +
          '     SELECT DECODE(C.PROJGB,''J'',''K'',C.PROJGB) PROJGB,B.YYMM,SUM ( (SELECT SUM(MANH) ' +
          '              FROM KH15.PVW_TPCB330_KTUCA001 ' +
          '              WHERE     YYMM = B.YYMM ' +
          '              AND PROJNO = A.PROJNO ' +
          '              AND SUBPROJNO = A.SUBPROJNO ' +
          '              AND PARTNO = A.PARTNO || ''-'' || A.PARTNO5 ' +
          '              AND DEPT = A.DEPT ' +
          '              AND PROCNO = A.PROCNO)) MANH ' +
          '    FROM KH15.KTPE025 A, KH16.TPCA120 B,KH15.ktpb001 c ' +
          '    WHERE     A.PROJNO = B.PROJNO ' +
          '           AND A.SUBPROJNO = B.SUBPROJNO ' +
          '           AND A.DEPT = NVL (B.VENDOR, B.DEPT) ' +
          '           AND A.PARTNO = B.PARTNO1 ' +
          '           AND A.PARTNO5 = B.PARTNO5 ' +
          '           AND A.DOCNO = B.WKNO ' +
          '           and a.yoin not in(''A5'', ''E1'', ''S1'', ''J2'', ''D5'', ''E2'', ''S6'', ''A6'',DECODE(A.YOINDEPT,''K1J'',''S5'',''000'')) ' +
          '           AND B.YYMM LIKE :F ' +
          '           and a.projno = c.projno ' +
          '           and a.subprojno = c.subprojno ' +
          '        GROUP BY DECODE(C.PROJGB,''J'',''K'',C.PROJGB), B.YYMM ' +
          '    ) ' +
          '     GROUP BY projgb';

  with DM1.ExtraMHQuery do
  begin
    Close;
    SQL.Clear;
    SQL.Add(LSql);
    ParamByName('F').AsString := FormatDateTIme('yyyy',StartOfTheYear(Date)) + '%';//AFrom; ////YYYYMM (String) = 201501
//    ParamByName('T').AsString := FormatDateTIme('yyyymm',EndOfTheYear(Date));//ATo;   // = 201512 (�ݵ�� 12�� ���� �ؾ� ��: �׷��� 12������ 0�� ä����)
    Open;

    if RecordCount > 0 then
    begin
      FExtraMHInfo.ExtraMHPerProductPerMonthCollect.Clear;

      for i := 0 to RecordCount - 1 do
      begin
        LMHInfo := FExtraMHInfo.ExtraMHPerProductPerMonthCollect.Add;

        with LMHInfo do
        begin
          ProductName := FieldByName('projgb').AsString;
          YYYYMM := FormatDateTIme('yyyy',StartOfTheYear(Date));
          YYYY := StrToInt(LeftStr(YYYYMM, 4));
          MM := 1;
          M_H := FieldByName('M01').AsFloat;
        end;

        LMHInfo := FExtraMHInfo.ExtraMHPerProductPerMonthCollect.Add;

        with LMHInfo do
        begin
          ProductName := FieldByName('projgb').AsString;
          YYYYMM := FormatDateTIme('yyyy',StartOfTheYear(Date));
          YYYY := StrToInt(LeftStr(YYYYMM, 4));
          MM := 2;
          M_H := FieldByName('M02').AsFloat;
        end;

        LMHInfo := FExtraMHInfo.ExtraMHPerProductPerMonthCollect.Add;

        with LMHInfo do
        begin
          ProductName := FieldByName('projgb').AsString;
          YYYYMM := FormatDateTIme('yyyy',StartOfTheYear(Date));
          YYYY := StrToInt(LeftStr(YYYYMM, 4));
          MM := 3;
          M_H := FieldByName('M03').AsFloat;
        end;

        LMHInfo := FExtraMHInfo.ExtraMHPerProductPerMonthCollect.Add;

        with LMHInfo do
        begin
          ProductName := FieldByName('projgb').AsString;
          YYYYMM := FormatDateTIme('yyyy',StartOfTheYear(Date));
          YYYY := StrToInt(LeftStr(YYYYMM, 4));
          MM := 4;
          M_H := FieldByName('M04').AsFloat;
        end;

        LMHInfo := FExtraMHInfo.ExtraMHPerProductPerMonthCollect.Add;

        with LMHInfo do
        begin
          ProductName := FieldByName('projgb').AsString;
          YYYYMM := FormatDateTIme('yyyy',StartOfTheYear(Date));
          YYYY := StrToInt(LeftStr(YYYYMM, 4));
          MM := 5;
          M_H := FieldByName('M05').AsFloat;
        end;

        LMHInfo := FExtraMHInfo.ExtraMHPerProductPerMonthCollect.Add;

        with LMHInfo do
        begin
          ProductName := FieldByName('projgb').AsString;
          YYYYMM := FormatDateTIme('yyyy',StartOfTheYear(Date));
          YYYY := StrToInt(LeftStr(YYYYMM, 4));
          MM := 6;
          M_H := FieldByName('M06').AsFloat;
        end;

        LMHInfo := FExtraMHInfo.ExtraMHPerProductPerMonthCollect.Add;

        with LMHInfo do
        begin
          ProductName := FieldByName('projgb').AsString;
          YYYYMM := FormatDateTIme('yyyy',StartOfTheYear(Date));
          YYYY := StrToInt(LeftStr(YYYYMM, 4));
          MM := 7;
          M_H := FieldByName('M07').AsFloat;
        end;

        LMHInfo := FExtraMHInfo.ExtraMHPerProductPerMonthCollect.Add;

        with LMHInfo do
        begin
          ProductName := FieldByName('projgb').AsString;
          YYYYMM := FormatDateTIme('yyyy',StartOfTheYear(Date));
          YYYY := StrToInt(LeftStr(YYYYMM, 4));
          MM := 8;
          M_H := FieldByName('M08').AsFloat;
        end;

        LMHInfo := FExtraMHInfo.ExtraMHPerProductPerMonthCollect.Add;

        with LMHInfo do
        begin
          ProductName := FieldByName('projgb').AsString;
          YYYYMM := FormatDateTIme('yyyy',StartOfTheYear(Date));
          YYYY := StrToInt(LeftStr(YYYYMM, 4));
          MM := 9;
          M_H := FieldByName('M09').AsFloat;
        end;

        LMHInfo := FExtraMHInfo.ExtraMHPerProductPerMonthCollect.Add;

        with LMHInfo do
        begin
          ProductName := FieldByName('projgb').AsString;
          YYYYMM := FormatDateTIme('yyyy',StartOfTheYear(Date));
          YYYY := StrToInt(LeftStr(YYYYMM, 4));
          MM := 10;
          M_H := FieldByName('M10').AsFloat;
        end;

        LMHInfo := FExtraMHInfo.ExtraMHPerProductPerMonthCollect.Add;

        with LMHInfo do
        begin
          ProductName := FieldByName('projgb').AsString;
          YYYYMM := FormatDateTIme('yyyy',StartOfTheYear(Date));
          YYYY := StrToInt(LeftStr(YYYYMM, 4));
          MM := 11;
          M_H := FieldByName('M11').AsFloat;
        end;

        LMHInfo := FExtraMHInfo.ExtraMHPerProductPerMonthCollect.Add;

        with LMHInfo do
        begin
          ProductName := FieldByName('projgb').AsString;
          YYYYMM := FormatDateTIme('yyyy',StartOfTheYear(Date));
          YYYY := StrToInt(LeftStr(YYYYMM, 4));
          MM := 12;
          M_H := FieldByName('M12').AsFloat;
        end;

        Next;
      end;//for
    end;
  end;//with DM1
end;

procedure TExtraMH.GetFailureExtraMHPerMonth(AYear: string);
var
  LSql: string;
  i: integer;
  LMHInfo: TFailExtraMHPerMonthItem;
begin
  LSql := 'SELECT SUM(DECODE(SUBSTR(YYMM,5,2),''01'',MANH3,0)) M01 ' +
          '       ,SUM(DECODE(SUBSTR(YYMM,5,2),''02'',MANH3,0)) M02 ' +
          '       ,SUM(DECODE(SUBSTR(YYMM,5,2),''03'',MANH3,0)) M03 ' +
          '       ,SUM(DECODE(SUBSTR(YYMM,5,2),''04'',MANH3,0)) M04 ' +
          '       ,SUM(DECODE(SUBSTR(YYMM,5,2),''05'',MANH3,0)) M05 ' +
          '       ,SUM(DECODE(SUBSTR(YYMM,5,2),''06'',MANH3,0)) M06 ' +
          '       ,SUM(DECODE(SUBSTR(YYMM,5,2),''07'',MANH3,0)) M07 ' +
          '       ,SUM(DECODE(SUBSTR(YYMM,5,2),''08'',MANH3,0)) M08 ' +
          '       ,SUM(DECODE(SUBSTR(YYMM,5,2),''09'',MANH3,0)) M09 ' +
          '       ,SUM(DECODE(SUBSTR(YYMM,5,2),''10'',MANH3,0)) M10 ' +
          '       ,SUM(DECODE(SUBSTR(YYMM,5,2),''11'',MANH3,0)) M11 ' +
          '       ,SUM(DECODE(SUBSTR(YYMM,5,2),''12'',MANH3,0)) M12 ' +
          ' FROM ( ' +
          '     SELECT B.YYMM, ' +
          '      (select SUM(MANH) ' +
          '      from KH15.PVW_TPCB330_KTUCA001 ' +
          '       WHERE YYMM = B.YYMM ' +
          '         AND PROJNO = A.PROJNO ' +
          '         AND SUBPROJNO =A.SUBPROJNO ' +
          '         AND PARTNO = A.PARTNO||''-''||A.PARTNO5 ' +
          '         AND DEPT = A.DEPT AND PROCNO = A.PROCNO) MANH3 ' +
          '      FROM KH15.KTPE025 A, KH16.TPCA120 B ' +
          '             WHERE A.PROJNO       = B.PROJNO ' +
          '                 AND A.SUBPROJNO  = B.SUBPROJNO ' +
          '                 AND A.DEPT       = NVL(B.VENDOR,B.DEPT) ' +
          '                 AND A.PARTNO     = B.PARTNO1 ' +
          '                 AND A.PARTNO5    = B.PARTNO5 ' +
          '                 AND A.DOCNO      = B.WKNO ' +
          '                 AND ( A.YOIN IN ( ''A5'',''E1'',''S1'',''J2'',''D5'',''E2'',''S6'',''A6'') ' +
          '                       OR (A.YOINDEPT =''K1J'' AND A.YOIN = ''S5'') ' +
          '                     ) ' +
          '         AND B.YYMM LIKE :F ' +
          '    )';

  with DM1.ExtraMHQuery do
  begin
    Close;
    SQL.Clear;
    SQL.Add(LSql);
    ParamByName('F').AsString := AYear + '%';
    Open;

    if RecordCount > 0 then
    begin
      FExtraMHInfo.FailExtraMHPerMonthCollect.Clear;

      if RecordCount > 0 then
      begin
        LMHInfo := FExtraMHInfo.FailExtraMHPerMonthCollect.Add;
        with LMHInfo do
        begin
          MM := 1;
          M_H := FieldByName('M01').AsFloat;
        end;
        LMHInfo := FExtraMHInfo.FailExtraMHPerMonthCollect.Add;
        with LMHInfo do
        begin
          MM := 2;
          M_H := FieldByName('M02').AsFloat;
        end;
        LMHInfo := FExtraMHInfo.FailExtraMHPerMonthCollect.Add;
        with LMHInfo do
        begin
          MM := 3;
          M_H := FieldByName('M03').AsFloat;
        end;
        LMHInfo := FExtraMHInfo.FailExtraMHPerMonthCollect.Add;
        with LMHInfo do
        begin
          MM := 4;
          M_H := FieldByName('M04').AsFloat;
        end;
        LMHInfo := FExtraMHInfo.FailExtraMHPerMonthCollect.Add;
        with LMHInfo do
        begin
          MM := 5;
          M_H := FieldByName('M05').AsFloat;
        end;
        LMHInfo := FExtraMHInfo.FailExtraMHPerMonthCollect.Add;
        with LMHInfo do
        begin
          MM := 6;
          M_H := FieldByName('M06').AsFloat;
        end;
        LMHInfo := FExtraMHInfo.FailExtraMHPerMonthCollect.Add;
        with LMHInfo do
        begin
          MM := 7;
          M_H := FieldByName('M07').AsFloat;
        end;
        LMHInfo := FExtraMHInfo.FailExtraMHPerMonthCollect.Add;
        with LMHInfo do
        begin
          MM := 8;
          M_H := FieldByName('M08').AsFloat;
        end;
        LMHInfo := FExtraMHInfo.FailExtraMHPerMonthCollect.Add;
        with LMHInfo do
        begin
          MM := 9;
          M_H := FieldByName('M09').AsFloat;
        end;
        LMHInfo := FExtraMHInfo.FailExtraMHPerMonthCollect.Add;
        with LMHInfo do
        begin
          MM := 10;
          M_H := FieldByName('M10').AsFloat;
        end;
        LMHInfo := FExtraMHInfo.FailExtraMHPerMonthCollect.Add;
        with LMHInfo do
        begin
          MM := 11;
          M_H := FieldByName('M11').AsFloat;
        end;
        LMHInfo := FExtraMHInfo.FailExtraMHPerMonthCollect.Add;
        with LMHInfo do
        begin
          MM := 12;
          M_H := FieldByName('M12').AsFloat;
        end;
      end;//if
    end;
  end;//with DM1
end;

procedure TExtraMH.GetOriginalMHPerMonth(AYear: string);
var
  LSql: string;
  i: integer;
  LMHInfo: TOriginalMHPerMonthItem;
begin
//  LSql := 'SELECT SUM(DECODE(SUBSTR(YYMM,5,2),''01'',MANH,0)) M01, ' +
//          '       SUM(DECODE(SUBSTR(YYMM,5,2),''02'',MANH,0)) M02, ' +
//          '       SUM(DECODE(SUBSTR(YYMM,5,2),''03'',MANH,0)) M03, ' +
//          '       SUM(DECODE(SUBSTR(YYMM,5,2),''04'',MANH,0)) M04, ' +
//          '       SUM(DECODE(SUBSTR(YYMM,5,2),''05'',MANH,0)) M05, ' +
//          '       SUM(DECODE(SUBSTR(YYMM,5,2),''06'',MANH,0)) M06, ' +
//          '       SUM(DECODE(SUBSTR(YYMM,5,2),''07'',MANH,0)) M07, ' +
//          '       SUM(DECODE(SUBSTR(YYMM,5,2),''08'',MANH,0)) M08, ' +
//          '       SUM(DECODE(SUBSTR(YYMM,5,2),''09'',MANH,0)) M09, ' +
//          '       SUM(DECODE(SUBSTR(YYMM,5,2),''10'',MANH,0)) M10, ' +
//          '       SUM(DECODE(SUBSTR(YYMM,5,2),''11'',MANH,0)) M11, ' +
//          '       SUM(DECODE(SUBSTR(YYMM,5,2),''12'',MANH,0)) M12 ' +
//          'FROM KH15.KTOA011 A ' +
//          'WHERE MHGBT = 11 AND ' +
//          '      SUBSTR(YYMM,1,4) = :F ';

  LSql := 'SELECT SUM(DECODE(SUBSTR(YYMM,5,2),''01'',MANH,0)) M01, ' +
          '        SUM(DECODE(SUBSTR(YYMM,5,2),''02'',MANH,0)) M02, ' +
          '        SUM(DECODE(SUBSTR(YYMM,5,2),''03'',MANH,0)) M03, ' +
          '        SUM(DECODE(SUBSTR(YYMM,5,2),''04'',MANH,0)) M04, ' +
          '        SUM(DECODE(SUBSTR(YYMM,5,2),''05'',MANH,0)) M05, ' +
          '        SUM(DECODE(SUBSTR(YYMM,5,2),''06'',MANH,0)) M06, ' +
          '        SUM(DECODE(SUBSTR(YYMM,5,2),''07'',MANH,0)) M07, ' +
          '        SUM(DECODE(SUBSTR(YYMM,5,2),''08'',MANH,0)) M08, ' +
          '        SUM(DECODE(SUBSTR(YYMM,5,2),''09'',MANH,0)) M09, ' +
          '        SUM(DECODE(SUBSTR(YYMM,5,2),''10'',MANH,0)) M10, ' +
          '        SUM(DECODE(SUBSTR(YYMM,5,2),''11'',MANH,0)) M11, ' +
          '        SUM(DECODE(SUBSTR(YYMM,5,2),''12'',MANH,0)) M12 ' +
          '  FROM ' +
          '  ( ' +
          '  SELECT YYMM,SUM(ACTMANH) MANH ' +
          '  FROM ( ' +
          '      SELECT yymm, PROJGB,SALECD,SUM(GSMANH) �⼺,SUM(MANH) ACTMANH, ROUND(SUM(GSMANH)/SUM(MANH)*100,1) �ɷ� ' +
          '      FROM KH15.KTOA011 ' +
          '      WHERE  YYMM between :F and :T ' +
          '      AND MHGB = ''1'' ' +
          '      and substr(PROJNO, 1, 1) || substr(PROJNO, 3, 1) != ''KZ'' ' +
          '      AND PROJGB NOT IN(''R'',''Y'') ' +
          '      GROUP BY  yymm, PROJGB,SALECD ' +
          '      ) ' +
          '  GROUP BY PROJGB,YYMM) ';

  with DM1.ExtraMHQuery do
  begin
    Close;
    SQL.Clear;
    SQL.Add(LSql);
    ParamByName('F').AsString := AYear+'01';
    ParamByName('T').AsString := AYear+'12';
    Open;

    if RecordCount > 0 then
    begin
      FExtraMHInfo.OriginalMHPerMonthCollect.Clear;

      if RecordCount > 0 then
      begin
        LMHInfo := FExtraMHInfo.OriginalMHPerMonthCollect.Add;
        with LMHInfo do
        begin
          MM := 1;
          M_H := FieldByName('M01').AsFloat;
        end;
        LMHInfo := FExtraMHInfo.OriginalMHPerMonthCollect.Add;
        with LMHInfo do
        begin
          MM := 2;
          M_H := FieldByName('M02').AsFloat;
        end;
        LMHInfo := FExtraMHInfo.OriginalMHPerMonthCollect.Add;
        with LMHInfo do
        begin
          MM := 3;
          M_H := FieldByName('M03').AsFloat;
        end;
        LMHInfo := FExtraMHInfo.OriginalMHPerMonthCollect.Add;
        with LMHInfo do
        begin
          MM := 4;
          M_H := FieldByName('M04').AsFloat;
        end;
        LMHInfo := FExtraMHInfo.OriginalMHPerMonthCollect.Add;
        with LMHInfo do
        begin
          MM := 5;
          M_H := FieldByName('M05').AsFloat;
        end;
        LMHInfo := FExtraMHInfo.OriginalMHPerMonthCollect.Add;
        with LMHInfo do
        begin
          MM := 6;
          M_H := FieldByName('M06').AsFloat;
        end;
        LMHInfo := FExtraMHInfo.OriginalMHPerMonthCollect.Add;
        with LMHInfo do
        begin
          MM := 7;
          M_H := FieldByName('M07').AsFloat;
        end;
        LMHInfo := FExtraMHInfo.OriginalMHPerMonthCollect.Add;
        with LMHInfo do
        begin
          MM := 8;
          M_H := FieldByName('M08').AsFloat;
        end;
        LMHInfo := FExtraMHInfo.OriginalMHPerMonthCollect.Add;
        with LMHInfo do
        begin
          MM := 9;
          M_H := FieldByName('M09').AsFloat;
        end;
        LMHInfo := FExtraMHInfo.OriginalMHPerMonthCollect.Add;
        with LMHInfo do
        begin
          MM := 10;
          M_H := FieldByName('M10').AsFloat;
        end;
        LMHInfo := FExtraMHInfo.OriginalMHPerMonthCollect.Add;
        with LMHInfo do
        begin
          MM := 11;
          M_H := FieldByName('M11').AsFloat;
        end;
        LMHInfo := FExtraMHInfo.OriginalMHPerMonthCollect.Add;
        with LMHInfo do
        begin
          MM := 12;
          M_H := FieldByName('M12').AsFloat;
        end;
      end;//if
    end;
  end;//with DM1
end;

end.
