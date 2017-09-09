unit UnitHhiOfficeNewsInterface;

interface

uses SynCommons, mORMot, Sea_Ocean_News_Class;

type
  IHhiOfficeNewsList = interface(IInvokable)
  ['{9D4FFA7F-73D5-43D5-B5DF-F0FA0102C422}']
    function GetHhiOfficeNewsList: TRawUTF8DynArray; //�ϰ� ���� �ؾ� ����
    function GetTimeOnHhiOfficeNews: RawUTF8; //�ϰ� ���� �ؾ� ���� �������� �ð�(RAlarm ���� ��)
    function GetAttachFileHhiOfficeNews(AFileName: RawUTF8): TServiceCustomAnswer; //�ϰ� ���� �ؾ� ���� ÷������(pdf) ��ȯ
    procedure GetHhiOfficeNewsList2(out ASeaOceanNewsCollect: TSONewsCollect);
//    procedure GetAttachFileHhiOfficeNews(Ctxt: TSQLRestServerURIContext); //�ϰ� ���� �ؾ� ���� ÷������(pdf) ��ȯ
  end;

const
  HHIOFFICE_ROOT_NAME = 'root';
  HHIOFFICE_PORT_NAME = '702';
  HHIOFFICE_APPLICATION_NAME = 'HhiOfficeNews_RestService';
  SHIP_OCEAN_PDF_FILE = 'c:\temp\�ϰ������ؾ�.pdf';

implementation

end.
