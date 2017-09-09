unit UnitBWQueryInterface4WebSocket;

interface

uses SynCommons, BW_Query_Class, mORMot, Sea_Ocean_News_Class,
  UnitClientInfoClass, UnitDPMSInfoClass;

type
  IBWQueryCallback = interface(IInvokable)
    ['{523F0002-F30C-4C53-BA21-9F7948DE6763}']
    procedure ServerReboot(const ASecAfter: integer);
    procedure GetCellData(AQueryName: RawUTF8; ACellDataCollect: TBWQryCellDataCollect);
  end;

  IBWQuery4WS = interface(IServiceWithCallbackReleased)
    ['{169FA046-41EA-4287-90A4-B1EF28D992AB}']
    function GetBWQryClass(AQueryName: RawUTF8; out AServerBusy: Boolean): TRawUTF8DynArray;
    function GetCellData(AQueryName: RawUTF8; out AEPCollect: TBWQryCellDataCollect): Boolean;
    function GetRowHeaderData(AQueryName: RawUTF8; out AColCountOfRow: integer;  out AEPCollect: TBWQryRowHeaderCollect): Boolean;
    function GetColHeaderData(AQueryName: RawUTF8; out AEPCollect: TBWQryColumnHeaderCollect): Boolean;
    function GetOrderPlanPerProduct(out ACollect: TBWQryCellDataCollect): Boolean; //��ǰ�� ���� ���� �濵��ȹ
    function GetSalesPlanPerProduct(out ACollect: TBWQryCellDataCollect): Boolean; //��ǰ�� ���� ���� �濵��ȹ
    function GetProfitPlanPerProduct(out ACollect: TBWQryCellDataCollect): Boolean; //��ǰ�� ���� ���� �濵��ȹ
    function GetNewsList2: TRawUTF8DynArray; //�ϰ� ���� �ؾ� ����
//    function GetAttachFileHhiOfficeNews(AFileName: RawUTF8): TServiceCustomAnswer; //�ϰ� ���� �ؾ� ���� ÷������(pdf) ��ȯ
    procedure GetAttachFileHhiOfficeNews2(AFileName:RawUTF8; out AFile: RawByteString); //�ϰ� ���� �ؾ� ���� ÷������(pdf) ��ȯ
    procedure GetHhiOfficeNewsList2(out ASeaOceanNewsCollect: TSONewsCollect);

    function GetDPMSInfo(AFrom, ATo: string): RawUTF8;

    procedure Join(ClientInfo: RawUTF8; const callback: IBWQueryCallback);
    function SetRequestOnlyChanged(ClientInfo, AQueryName: RawUTF8):Boolean;
    procedure ExecCallback(AClientInfo: TClientInfo; AQryName: string;
      ACellDataCollect: TBWQryCellDataCollect);
  end;

const
  BWQRY_ROOT_NAME_4_WS = 'root';
  BWQRY_PORT_NAME_4_WS = '704';
  BWQRY_APPLICATION_NAME_4_WS = 'BWQRY_RestService_WebSocket';
  BWQRY_DEFAULT_IP = '10.14.21.117';

  BWQRY4WS_TRANSMISSION_KEY = 'BWQRY_PrivateKey';

implementation

initialization
  TInterfaceFactory.RegisterInterfaces([
    TypeInfo(IBWQuery4WS),TypeInfo(IBWQueryCallback)]);
end.
