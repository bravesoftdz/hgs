unit UnitNewsInterface;

interface

uses SynCommons, UnitRSSAddressClass;

type
  INewsList = interface(IInvokable)
    ['{33EC6495-4B4F-407E-B148-DA339E293726}']
    function GetNewsList: TRawUTF8DynArray;  //KBS ����
    function GetNewsList2: TRawUTF8DynArray; //�ϰ� ���� �ؾ� ����
    function GetrssNewsList(out ACollect: TRSSNewsList): Boolean;  //RSS ����
  end;

const
  NEWS_ROOT_NAME = 'root';
  NEWS_PORT_NAME = '700';
  NEWS_APPLICATION_NAME = 'News_RestService';
  NEWS_DEFAULT_IP = '10.14.21.117';
  SHIP_OCEAN_PDF_FILE = 'c:\temp\�ϰ������ؾ�.pdf';

implementation

end.
