object fMain: TfMain
  Left = 0
  Top = 0
  Caption = #32593#39029#20998#26512#21450#25972#31449#19979#36733#24037#20855'v1.0('#32852#31995'QQ1409232611)'
  ClientHeight = 800
  ClientWidth = 800
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 800
    Height = 54
    Align = alTop
    TabOrder = 0
    object Label1: TLabel
      Left = 4
      Top = 8
      Width = 60
      Height = 13
      Caption = #36215#22987#22320#22336#65306
    end
    object Label2: TLabel
      Left = 4
      Top = 32
      Width = 60
      Height = 13
      Caption = #24403#21069#22320#22336#65306
    end
    object edtIP: TEdit
      Left = 60
      Top = 5
      Width = 240
      Height = 21
      TabOrder = 0
      Text = 'https://www.tlink.io/index.htm'
    end
    object btnBrowse: TButton
      Left = 349
      Top = 5
      Width = 60
      Height = 25
      Caption = #27983#35272
      TabOrder = 1
      OnClick = btnBrowseClick
    end
    object btnDown: TButton
      Left = 473
      Top = 5
      Width = 60
      Height = 25
      Caption = #19979#36733#38142#25509
      TabOrder = 2
      OnClick = btnDownClick
    end
    object btnDownAll: TButton
      Left = 535
      Top = 5
      Width = 60
      Height = 25
      Caption = #25972#31449#19979#36733
      TabOrder = 3
      OnClick = btnDownAllClick
    end
    object btnDownPage: TButton
      Left = 413
      Top = 5
      Width = 60
      Height = 25
      Caption = #19979#36733#26412#39029
      TabOrder = 4
      OnClick = btnDownPageClick
    end
    object edtCurURL: TEdit
      Left = 61
      Top = 29
      Width = 240
      Height = 21
      TabOrder = 5
      Text = 'https://www.tlink.io/index.htm'
    end
  end
  object page1: TPageControl
    Left = 0
    Top = 54
    Width = 800
    Height = 727
    ActivePage = tsPage
    Align = alClient
    TabOrder = 1
    ExplicitTop = 36
    ExplicitHeight = 745
    object tsPage: TTabSheet
      Caption = #32593#39029
      ExplicitHeight = 717
      object web1: TWebBrowser
        Left = 0
        Top = 0
        Width = 792
        Height = 699
        Align = alClient
        TabOrder = 0
        OnNavigateComplete2 = web1NavigateComplete2
        OnDocumentComplete = web1DocumentComplete
        ExplicitLeft = 368
        ExplicitTop = 352
        ExplicitWidth = 300
        ExplicitHeight = 150
        ControlData = {
          4C000000DB5100003E4800000000000000000000000000000000000000000000
          000000004C000000000000000000000001000000E0D057007335CF11AE690800
          2B2E126208000000000000004C0000000114020000000000C000000000000046
          8000000000000000000000000000000000000000000000000000000000000000
          00000000000000000100000000000000000000000000000000000000}
      end
      object web2: TWebBrowser
        Left = 368
        Top = 352
        Width = 20
        Height = 20
        TabOrder = 1
        OnNavigateComplete2 = web2NavigateComplete2
        OnDocumentComplete = web2DocumentComplete
        ControlData = {
          4C00000011020000110200000000000000000000000000000000000000000000
          000000004C000000000000000000000001000000E0D057007335CF11AE690800
          2B2E126208000000000000004C0000000114020000000000C000000000000046
          8000000000000000000000000000000000000000000000000000000000000000
          00000000000000000100000000000000000000000000000000000000}
      end
    end
    object TabSheet1: TTabSheet
      Caption = #20195#30721
      ImageIndex = 2
      ExplicitHeight = 717
      object memCode: TMemo
        Left = 0
        Top = 0
        Width = 792
        Height = 699
        Align = alClient
        ScrollBars = ssBoth
        TabOrder = 0
        ExplicitHeight = 717
      end
    end
    object tsLinks: TTabSheet
      Caption = #21407#22987#38142#25509
      ImageIndex = 1
      ExplicitHeight = 717
      object memLinks: TMemo
        Left = 0
        Top = 0
        Width = 792
        Height = 699
        Align = alClient
        ScrollBars = ssBoth
        TabOrder = 0
        ExplicitHeight = 717
      end
    end
    object tsLinks2: TTabSheet
      Caption = #20248#21270#38142#25509
      ImageIndex = 3
      ExplicitHeight = 717
      object memLinks2: TMemo
        Left = 0
        Top = 0
        Width = 792
        Height = 699
        Align = alClient
        ScrollBars = ssBoth
        TabOrder = 0
        ExplicitHeight = 717
      end
    end
  end
  object bar1: TStatusBar
    Left = 0
    Top = 781
    Width = 800
    Height = 19
    Panels = <
      item
        Width = 400
      end
      item
        Width = 200
      end>
  end
end
