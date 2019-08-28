unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ExtCtrls,ActiveX,MSHTML,
  strutils,WinInet,UrlMon,
  Vcl.OleCtrls, SHDocVw, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, IdHTTP;
Const
  WM_DOWN_WORK = WM_USER+1000;
type
  TfMain = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    edtIP: TEdit;
    btnBrowse: TButton;
    btnDown: TButton;
    page1: TPageControl;
    tsPage: TTabSheet;
    tsLinks: TTabSheet;
    bar1: TStatusBar;
    web1: TWebBrowser;
    memLinks: TMemo;
    TabSheet1: TTabSheet;
    memCode: TMemo;
    tsLinks2: TTabSheet;
    memLinks2: TMemo;
    web2: TWebBrowser;
    btnDownAll: TButton;
    btnDownPage: TButton;
    edtCurURL: TEdit;
    Label2: TLabel;
    procedure btnBrowseClick(Sender: TObject);
    procedure web1DocumentComplete(ASender: TObject; const pDisp: IDispatch;
      const URL: OleVariant);
    procedure web1NavigateComplete2(ASender: TObject; const pDisp: IDispatch;
      const URL: OleVariant);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnDownClick(Sender: TObject);
    procedure web2DocumentComplete(ASender: TObject; const pDisp: IDispatch;
      const URL: OleVariant);
    procedure web2NavigateComplete2(ASender: TObject; const pDisp: IDispatch;
      const URL: OleVariant);
    procedure btnDownAllClick(Sender: TObject);

    procedure btnDownPageClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    mK:integer;//当前正在加载的网页
    bDocComplete:boolean;
    procedure getImgUrl(doc:IHTMLDocument2);
    procedure getCssUrl(doc:IHTMLDocument2);
    procedure getLinkUrl(doc:IHTMLDocument2);
    procedure getscriptUrl(doc:IHTMLDocument2);
    procedure getImgUrl2(doc:IHTMLDocument2);
    procedure getCssUrl2(doc:IHTMLDocument2);
    procedure getLinkUrl2(doc:IHTMLDocument2);
    procedure getscriptUrl2(doc:IHTMLDocument2);
    procedure downfileMsg(var MSG:TMessage); message WM_DOWN_WORK;
  public
    { Public declarations }
    procedure MsgHandle(var Msg :TMsg; var Handled :Boolean);
  end;

var
  fMain: TfMain;
  mPage,mSite,mProtocol,mWorkDir:string;//主页URL ，站点URL, 协议(http://,https://),工作目录
  mDowns,mPages:tstrings;//mDowns要下载的文件链接；mPages要分析的网页链接；
  FOleInPlaceActiveObject :IOleInPlaceActiveObject;
  bDownFiles:boolean;//下载工作线程变量；
procedure getUrlInPage(doc:IHTMLDocument2);//获取网页中的文件链接
function DownloadToFile(Source, Dest: string): Boolean; //uses urlmon;
procedure downloadfile(url:string); //下载指定链接的文件
function url2file(url:string):string;//链接转换为本地文件路径
function getSite(url:string):string;//获取主站地址；
procedure downloadFilesThread();//下载子线程；
implementation

{$R *.dfm}
procedure TfMain.downfileMsg(var msg:TMessage);
var
  i,j:integer;
begin
  i:=msg.LParam;
  j:=msg.WParam;
  if j=1 then
    bar1.Panels[1].Text:='下载完毕！'
  else
    bar1.Panels[1].Text:='共有下载项：'+inttostr(mdowns.Count)+'正在下载：'+inttostr(i)+'['+mdowns[i]+']';
end;

procedure TfMain.getscriptUrl(doc:IHTMLDocument2);
Var
  all:IHTMLElementCollection;
  len,I:integer;
  item:OleVariant;
begin
  all:=doc.scripts;
  len:=all.length;
  for I:=0 to len-1 do begin
    item:=all.item(I,varempty);
    memLinks.lines.add(item.src);
end;
end;
procedure TfMain.getLinkUrl(doc:IHTMLDocument2);
Var
  all:IHTMLElementCollection;
  len,I:integer;
  item:OleVariant;
  url:string;
begin
  all:=doc.links;
  len:=all.length;
  for I:=0 to len-1 do begin
    item:=all.item(I,varempty);
    url:=item.href;
    url:=trim(url);
    if(length(url)=0)then continue;
    //if pos('htm',url)=0 then continue;
    memLinks.lines.add(url);
    //if(pos('/',url)=1)then url:=mProtocol+msite+url;
end;
end;
procedure TfMain.getCssUrl(doc:IHTMLDocument2);
Var
  all:IHTMLstyleSheetsCollection;
  len,I:integer;
  item:OleVariant;
begin
  all:=doc.styleSheets;
  len:=all.length;
  for I:=0 to len-1 do begin
      item:=all.item(I);               //EmpryParam亦可  Variants
      if(not VarisNull(item))then
      if(not VarisNull(item.href))then
      memLinks.lines.add(item.href);
  end;
end;
procedure TfMain.getImgUrl(doc:IHTMLDocument2);
Var
  all:IHTMLElementCollection;
  len,I:integer;
  item:OleVariant;
begin
  all:=doc.images;                           //doc.Links亦可
  len:=all.length;
  for I:=0 to len-1 do begin
      item:=all.item(I,varempty);               //EmpryParam亦可
      memLinks.lines.add(item.src);
  end;
end;
procedure TfMain.getscriptUrl2(doc:IHTMLDocument2);
Var
  all:IHTMLElementCollection;
  len,I:integer;
  item:OleVariant;
  url:string;
begin
  all:=doc.scripts;
  len:=all.length;
  for I:=0 to len-1 do begin
    item:=all.item(I,varempty);
    url:=item.src;
    url:=trim(url);
    if(length(url)=0)then continue;
    if(pos('/',url)=1)then url:=mProtocol+mSite+url;
    if(pos(msite,url)=0)then continue;
    memLinks2.lines.add(url);
end;
end;
procedure TfMain.getLinkUrl2(doc:IHTMLDocument2);
Var
  all:IHTMLElementCollection;
  len,I:integer;
  item:OleVariant;
  url:string;
begin
  all:=doc.links;
  len:=all.length;
  for I:=0 to len-1 do begin
    item:=all.item(I,varempty);
    url:=item.href;
    url:=trim(url);
    if pos('htm',url)=0 then continue;
    if(pos('/',url)=1)then url:=mProtocol+msite+url;
    if(pos(msite,url)=0)then continue;
    memLinks2.lines.add(url);
end;
end;
procedure TfMain.getCssUrl2(doc:IHTMLDocument2);
Var
  all:IHTMLstyleSheetsCollection;
  len,I:integer;
  item:OleVariant;
  url:string;
begin
  all:=doc.styleSheets;
  len:=all.length;
  for I:=0 to len-1 do begin
    item:=all.item(I);               //EmpryParam亦可
    if(not VarisNull(item))then
    if(VarisNull(item.href))then continue;
    url:=item.href;
    url:=trim(url);
    if(length(url)=0)then continue;
    if(pos('/',url)=1)then url:=mProtocol+mSite+url;
    memLinks2.lines.add(url);
  end;
end;
procedure TfMain.getImgUrl2(doc:IHTMLDocument2);
Var
  all:IHTMLElementCollection;
  len,I:integer;
  item:OleVariant;
  url:string;
begin
  all:=doc.images;                           //doc.Links亦可
  len:=all.length;
  for I:=0 to len-1 do begin
    item:=all.item(I,varempty);               //EmpryParam亦可
    url:=item.src;
    url:=trim(url);
    if(length(url)=0)then continue;
    if(pos('/',url)=1)then url:=mProtocol+mSite+url;
    memLinks2.lines.add(url);
  end;
end;

procedure TfMain.btnDownClick(Sender: TObject);
var
  i:integer;
  url:string;
  doc:IHTMLDocument2;
begin
  //for I := 0 to memLinks.Lines.Count-1 do
 // begin
 //   url:=memLinks2.Lines[i];
 //   downloadfile(url);
    //GetLocalFileNameFromIECache(url,localfilename);
 // end;
  if not Assigned(web1.Document) then Exit;
  doc:=web1.Document as IHTMLDocument2;
  bDocComplete:=false;
  mPage:=doc.url;
  mSite:=doc.domain;
  mProtocol:=doc.protocol;
  if(mProtocol='HyperText Transfer Protocol with Privacy')then mProtocol:='https://' else mProtocol:='http://';
  //i:=pos('/',mPage);
  //mProtocol:=leftstr(mPage,i+1);
  //msite:=getsite(mpage);
  if(mDowns=nil)then mDowns:=tstringlist.Create;
  if(mPages=nil)then mPages:=tstringlist.Create;
  mDowns.Clear;
  mPages.Clear;
  mk:=0;
  getUrlInPage(doc);
  memLinks.Lines.Add(mdowns.Text);
  downloadFilesThread();
  bar1.Panels[0].Text:='正在解析：'+mPage;
end;

procedure TfMain.btnDownPageClick(Sender: TObject);
begin
  downloadfile(trim(edtCurURL.Text));
  showmessage('下载完成！');
end;
//将回车键事件映射到浏览器
procedure TfMain.MsgHandle(var Msg :TMsg; var Handled :Boolean);
var
  iOIPAO :IOleInPlaceActiveObject;
  Dispatch :IDispatch;
begin
  if web1 =nil then begin
    Handled :=False;
    Exit;
  end;
  Handled :=(IsDialogMessage(web1.Handle, Msg) =True);
  if (Handled) and (not web1.Busy) then begin
    if FOleInPlaceActiveObject =nil then begin
      Dispatch :=web1.Application;
      if Dispatch <>nil then begin
        Dispatch.QueryInterface(IOleInPlaceActiveObject, iOIPAO);
        if iOIPAO <>nil then
          FOleInPlaceActiveObject :=iOIPAO;
      end;
    end;
  end;
  if FOleInPlaceActiveObject <>nil then
    if ((Msg.message =WM_KEYDOWN) or (Msg.Message =WM_KEYUP)) and ((Msg.wParam =VK_BACK) or (Msg.wParam =VK_LEFT) or (Msg.wParam =VK_RIGHT)) then
  else
   FOleInPlaceActiveObject.TranslateAccelerator(Msg);
end;


procedure TfMain.FormCreate(Sender: TObject);
begin
  Application.OnMessage :=MsgHandle;
  mWorkDir:=extractfiledir(application.ExeName)+'\web';
  if(not directoryexists(mWorkDir))then forcedirectories(mWorkDir);
end;

procedure TfMain.FormDestroy(Sender: TObject);
begin
  FOleInPlaceActiveObject :=nil;
end;

procedure TfMain.FormShow(Sender: TObject);
begin
  fmain.Caption:='网页分析及整站下载工具v2.0(联系QQ1409232611VX:byc6352)';
end;

procedure TfMain.btnBrowseClick(Sender: TObject);
var
  i:integer;
begin
  page1.ActivePageIndex:=0;
  mPage:=trim(edtIp.Text);
  if pos('http',mPage)=0 then begin
    showmessage('缺少http协议头！');
    exit;
  end;
  bDocComplete:=false;
  i:=pos('/',mPage);
  mProtocol:=leftstr(mPage,i+1);
  msite:=getsite(mpage);
  web1.Navigate(mPage); //打开指定页面
end;
//s := WebBrowser1.OleObject.document.documentElement.innerHTML; //html内的所有代码
procedure TfMain.web1DocumentComplete(ASender: TObject; const pDisp: IDispatch;
  const URL: OleVariant);
var
  ms: TMemoryStream;
  doc:IHTMLDocument2;
begin
  if not Assigned(web1.Document) then Exit;
  if  (Web1.Busy) then exit;

  //if bDocComplete then exit;
  //bDocComplete:=true;
  ms := TMemoryStream.Create;
  (web1.Document as IPersistStreamInit).Save(TStreamAdapter.Create(ms), True);
  ms.Position := 0;
  memCode.Lines.LoadFromStream(ms, TEncoding.UTF8);
  // Memo1.Lines.LoadFromStream(ms, TEncoding.Default); {GB2312 等双字节}
  ms.Free;

  doc:=web1.Document as IHTMLDocument2;

  memLinks.Lines.Add('--------------------------------------------------');
  edtCurURL.Text:=doc.url;
  memLinks.Lines.Add(doc.url);
  memLinks.Lines.Add(doc.title);
  memLinks.Lines.Add(doc.protocol);
  memLinks.Lines.Add(doc.domain);
  memLinks.Lines.Add(doc.cookie);
  memLinks.Lines.Add(doc.charset);
  memLinks.Lines.Add(doc.defaultCharset);
      {
  if(not VarisEmpty(doc.mimeType))then
  memLinks.Lines.Add(doc.mimeType);
  if(not varIsNull(doc.fileSize))then
  memLinks.Lines.Add(doc.fileSize);
  if(not varIsNull(doc.fileCreatedDate))then
  memLinks.Lines.Add(doc.fileCreatedDate);
  if(not varIsNull(doc.fileModifiedDate))then
  memLinks.Lines.Add(doc.fileModifiedDate);
  if(not varIsNull(doc.fileUpdatedDate))then
  memLinks.Lines.Add(doc.fileUpdatedDate);
  //memLinks.Lines.Add(doc.Script.);
    }
  memLinks.Lines.Add('--------------------------------------------------');
  getImgUrl(doc);
  getCssUrl(doc);
  getscriptUrl(doc);
  getLinkUrl(doc);
  getImgUrl2(doc);
  getCssUrl2(doc);
  getscriptUrl2(doc);
  getLinkUrl2(doc);
  if   not(Web1.Busy)   then bar1.Panels[0].Text:='加载完毕';
end;

procedure TfMain.web1NavigateComplete2(ASender: TObject; const pDisp: IDispatch;
  const URL: OleVariant);
begin
  web1.Silent := True;
end;
//------------------------------------------整站下载区------------------------------------------
procedure getUrlInPage(doc:IHTMLDocument2);//获取网页中的文件链接
Var
  all:IHTMLElementCollection;
  sheets:IHTMLstyleSheetsCollection;
  len,I,p:integer;
  item:OleVariant;
  url:string;
begin
  //网页中的js文件：
  all:=doc.scripts;
  len:=all.length;
  for I:=0 to len-1 do begin
    item:=all.item(I,varempty);
    url:=item.src;
    url:=trim(url);
    if(length(url)=0)then continue;
    if(pos('/',url)=1)then url:=mProtocol+mSite+url;
    if(pos(msite,url)=0)then continue;  //排除外链
    if(pos(url,mDowns.Text)>0)then continue;//排除重复链接
    mDowns.add(url); //添加至待下载数组
  end;
  //网页中的css文件：
  sheets:=doc.styleSheets;
  len:=sheets.length;
  for I:=0 to len-1 do begin
    item:=sheets.item(I);               //EmpryParam亦可
    if(varisnull(item.href))then continue;
    url:=item.href;
    url:=trim(url);
    if(length(url)=0)then continue;
    if(pos('/',url)=1)then url:=mProtocol+mSite+url;
    if(pos(url,mDowns.Text)>0)then continue;//排除重复链接
    mDowns.add(url); //添加至待下载数组
  end;
  //网页中的图片文件：
  all:=doc.images;
  len:=all.length;
  for I:=0 to len-1 do begin
    item:=all.item(I,varempty);
    url:=item.src;
    url:=trim(url);
    if(length(url)=0)then continue;
    if(pos('/',url)=1)then url:=mProtocol+mSite+url;
    if(pos(url,mDowns.Text)>0)then continue;//排除重复链接
    mDowns.add(url); //添加至待下载数组
  end;
  //网页中的超链接文件：
  all:=doc.links;
  len:=all.length;
  for I:=0 to len-1 do begin
    item:=all.item(I,varempty);
    url:=item.href;
    url:=trim(url);
    if pos('htm',url)=0 then continue;
    if(pos('/',url)=1)then url:=mProtocol+msite+url;
    if (pos(msite,url)=0) or (pos(msite,url)>10) then continue;
    p:=pos('?',url);
    if(p>0)then url:=leftstr(url,p-1);
    p:=pos('#',url);
    if(p>0)then url:=leftstr(url,p-1);
    if(pos(url,mDowns.Text)>0)then continue;//排除重复链接
    mDowns.add(url);  //添加至待下载数组
    mPages.Add(url); //添加至页面数组
  end;

end;
procedure TfMain.btnDownAllClick(Sender: TObject);
var
  i:integer;
begin
  bDocComplete:=false;
  mPage:=trim(edtIp.Text);
  if pos('http',mPage)=0 then begin
    showmessage('缺少http协议头！');
    exit;
  end;
  bDocComplete:=false;
  i:=pos('/',mPage);
  mProtocol:=leftstr(mPage,i+1);
  msite:=getsite(mpage);
  web2.Navigate(mPage); //打开指定页面
  if(mDowns=nil)then mDowns:=tstringlist.Create;
  if(mPages=nil)then mPages:=tstringlist.Create;
  mDowns.Clear;
  mPages.Clear;
  mk:=0;
  downloadFilesThread();
  bar1.Panels[0].Text:='正在解析：'+mPage;
  page1.ActivePageIndex:=0;
end;
procedure TfMain.web2DocumentComplete(ASender: TObject; const pDisp: IDispatch;
  const URL: OleVariant);
var
  doc:IHTMLDocument2;
begin
  //if bDocComplete then exit;
  if bDocComplete then begin
    if(mk>=mPages.Count)then begin
      memLinks.Lines:=mdowns;
      memLinks2.Lines:=mPages;
      bar1.Panels[0].Text:='解析完毕！';
      exit;
    end;
    bar1.Panels[0].Text:='共有网页：'+inttostr(mPages.Count)+'正在解析：'+inttostr(mk)+'['+mPages[mk]+']';
    web2.Navigate(mPages[mk]); //加载超链数组里面的页面；
    //timer1.Enabled:=true;
    bDocComplete:=false;
    exit;
  end;
  bDocComplete:=true;
  doc:=web2.Document as IHTMLDocument2; //得到接口；
  getUrlInPage(doc); //解析网页；
  fmain.memLinks.Lines:=mdowns;
  fmain.memLinks2.Lines:=mpages;
  mk:=mk+1; //下一个要解析的网页；
  //timer1.Enabled:=false;
end;
//设置不弹出脚本提示
procedure TfMain.web2NavigateComplete2(ASender: TObject; const pDisp: IDispatch;
  const URL: OleVariant);
begin
  web2.Silent := True;
end;

//------------------------------------------下载线程区------------------------------------------
function ThreadProc(param: LPVOID): DWORD; stdcall;
var
  i,k:integer;//当前下载序号
  url:string;
begin
  i:=0;
  k:=0;
  while bDownFiles do begin
    if(i>=mDowns.Count)then begin if k>30 then break;sleep(1000);k:=k+1;continue;end;
    url:=mDowns[i];
    PostMessage(fMain.Handle, WM_DOWN_WORK,0,i);
    downloadfile(url);
    i:=i+1;
    k:=0;
  end;
  PostMessage(fMain.Handle, WM_DOWN_WORK,1,i);
  Result := 0;
end;

procedure downloadFilesThread();
var
  threadId: TThreadID;
begin
  bDownFiles:=true;
  CreateThread(nil, 0, @ThreadProc, nil, 0, threadId);
end;

//------------------------------------------公共函数区----------------------------------------------
//uses urlmon;
function DownloadToFile(Source, Dest: string): Boolean;
begin
  try
    Result := UrlDownloadToFile(nil, PChar(source), PChar(Dest), 0, nil) = 0;
  except
    Result := False;
  end;
end;
//下载指定链接的文件
procedure downloadfile(url:string);
var
  localpath,remotepath:string;
begin
  remotepath:=url;
  if pos('/',remotepath)=1 then remotepath:=mProtocol+msite+remotepath;
  localpath:=url2file(remotepath);
  if(fileexists(localpath))then exit;
  DownloadToFile(remotepath,localpath);
end;
//链接转换为本地文件路径
function url2file(url:string):string;
var
  p,i:integer;
  s,dir,fullDir:string; //forcedirectories(mWorkDir);
begin
  s:=url;
  p:=pos('/',s);
  dir:=leftstr(s,p-1);
  if(dir='http:')then s:=rightstr(s,length(s)-7);  //去除http头部
  if(dir='https:')then s:=rightstr(s,length(s)-8);  //去除https头部
  p:=pos('/',s);
  dir:=leftstr(s,p-1);
  if(dir<>msite)then s:=msite+s;  //添加主站地址
  fullDir:=mWorkDir;  //mWorkDir程序工作目录；
  p:=pos('/',s);
  while p>0 do begin
    dir:=leftstr(s,p-1);
    fullDir:=fullDir+'\'+dir;
    if(not directoryexists(fullDir))then forcedirectories(fullDir);  //创建本地文件目录
    s:=rightstr(s,length(s)-length(dir)-1);
    p:=pos('/',s);
  end;
  p:=pos('?',s);  //排除链接里面?后面的内容；
  if(p>0)then s:=leftstr(s,p-1);
  result:=fullDir+'\'+s;
end;
//获取主站地址；
function getSite(url:string):string;
var
  dir,s:string;
  p:integer;
begin
  s:=url;
  p:=pos('/',s);
  if(p<=0)then begin result:=url;exit;end;
  dir:=leftstr(s,p-1);
  if(dir='http:')then s:=rightstr(s,length(s)-7);
  if(dir='https:')then s:=rightstr(s,length(s)-8);
  p:=pos('/',s);
  if(p<=0)then begin result:=url;exit;end;
  s:=leftstr(s,p-1);
  result:=s;
end;
//---------------------------------------------------------------------------------------------------

initialization
  OleInitialize(nil);
finalization
  OleUninitialize;
end.
//------------------------------------------参考函数区------------------------------------------
{
 function GetLocalFileNameFromIECache(url:string; var LocalFileName:string):DWORD;
 procedure TfMain.downfile(url:string;localpath:string);
var
  fs:Tfilestream;
begin
  if(fileexists(localpath))then exit;
  fs:=Tfilestream.Create(localpath,fmcreate);
  IdHttp1.Get(url,fs);
  fs.Free;
end;
function GetLocalFileNameFromIECache(url:string; var LocalFileName:string):DWORD;
var
  D: Cardinal;
  T: PInternetCacheEntryInfo;
begin
  result := S_OK;
  D := 0;
  T:=nil;
  GetUrlCacheEntryInfo(PChar(Url), T^, D);
  Getmem(T, D);
  try
    if (GetUrlCacheEntryInfo(PChar(Url), T^, D)) then
      LocalFileName:=T^.lpszLocalFileName
    else
      Result := GetLastError;
  finally
    Freemem(T, D);
  end;
end;







}
