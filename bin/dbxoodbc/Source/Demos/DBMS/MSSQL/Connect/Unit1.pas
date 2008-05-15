unit Unit1;

interface

// !!! dbx_mssql_connect

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DBXpress, DB, SqlExpr, StdCtrls, FMTBcd, Grids,
  {$IF CompilerVersion > 17.00}
  //WideStrings,
  {$IFEND}
// optional (static linking dbxoodbc.dll):
  {$IF CompilerVersion < 18.50}
  DbxOpenOdbc,
  {$IF CompilerVersion = 18.00}
  DbxOpenOdbc3,
  {$IFEND}
  {$IFEND}
// optional.
  DBGrids, DBClient, Provider, ExtCtrls, dbx_mssql_connect;

type
  TForm1 = class(TForm)
    SQLConnection: TSQLConnection;
    LSRV: TLabel;
    ESRV: TEdit;
    LUSER: TLabel;
    EUSER: TEdit;
    LPWD: TLabel;
    EPWD: TEdit;
    LDNS: TLabel;
    EDNS: TEdit;
    CDirectOdbc: TCheckBox;
    BConnect: TButton;
    BDisconnect: TButton;
    SQLStoredProc: TSQLStoredProc;
    BSPExec: TButton;
    LAdd: TLabel;
    EAdditional: TEdit;
    DataSource: TDataSource;
    DSProv: TDataSetProvider;
    CDS: TClientDataSet;
    Grid: TDBGrid;
    LDB: TLabel;
    EDB: TEdit;
    COSAuthentication: TCheckBox;
    CUnicodeDriver: TCheckBox;
    CUnicodeODBCAPI: TCheckBox;
    sh1: TShape;
    CAnsiFields: TCheckBox;
    procedure BConnectClick(Sender: TObject);
    procedure BDisconnectClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BSPExecClick(Sender: TObject);
    procedure SQLConnectionAfterConnect(Sender: TObject);
    procedure SQLConnectionAfterDisconnect(Sender: TObject);
  private
    { Private declarations }
    procedure CheckConnection();
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.BConnectClick(Sender: TObject);
begin
  if (not CDirectOdbc.Enabled) and (EDNS.Text = '') then
    raise Exception.Create('It is necessary to set DNS (DataSource Name).');

  dbx_mssql_connect.MsSqlConnect(
    SQLConnection,
    {SERVER=} ESRV.Text,
    {DATABASE=} EDB.Text,
    {User=} EUSER.Text,
    {Password=} EPWD.Text,
    {DirectOdbc=} CDirectOdbc.Checked,
    {LoginPrompt=} EUSER.Text = '',
    {OSAuthentication=}COSAuthentication.Checked,
    {DNS=}EDNS.Text,
    {AdditionalOptions=}EAdditional.Text,
    {LanguageName=}'',
    {bUnicodeDbxDriver=}CUnicodeDriver.Checked,
    {bUnicodeODBCAPI=}CUnicodeODBCAPI.Checked,
    {bAnsiFields=}CAnsiFields.Checked
  );
end;

procedure TForm1.BDisconnectClick(Sender: TObject);
begin
  SQLConnection.Connected := False;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  {$IF CompilerVersion >= 18.00}
  {$IF CompilerVersion >= 18.50}
  CUnicodeDriver.Checked := True;
  CUnicodeDriver.Enabled := False;
  CUnicodeDriver.Tag := 1;
  {$ELSE}
  CUnicodeDriver.Checked := True;
  CUnicodeDriver.Enabled := True;
  {$IFEND}
  {$ELSE}
  CUnicodeDriver.Checked := False;
  CUnicodeDriver.Enabled := False;
  CUnicodeDriver.Tag := 1;
  {$IFEND}
  { Grid position }
  Grid.Left := 4;
  Grid.Top := BConnect.Top + BConnect.Height + 10;
  Grid.Height := ClientHeight - Grid.Top - 4;
  Grid.Width := ClientWidth - 8;
  {}
  SQLConnectionAfterDisconnect(SQLConnection);
end;

procedure TForm1.CheckConnection();
begin
  if not SQLConnection.Connected then
    //Abort;
    raise Exception.Create('Set connection with server MSSQL');
end;

procedure TForm1.SQLConnectionAfterConnect(Sender: TObject);
begin
  sh1.Brush.Color := clRed;

  CDirectOdbc.Enabled := False;
  if CUnicodeDriver.Tag = 0  then
    CUnicodeDriver.Enabled := False;
  CUnicodeODBCAPI.Enabled := False;
  COSAuthentication.Enabled := False;

  ESRV.Enabled := False;
  EDB.Enabled := False;
  EUSER.Enabled := False;
  EPWD.Enabled := False;
  EDNS.Enabled := False;
  EAdditional.Enabled := False;

  BSPExec.Enabled := True;
end;

procedure TForm1.SQLConnectionAfterDisconnect(Sender: TObject);
begin
  if not (csDestroying in ComponentState) then
  begin
    sh1.Brush.Color := clGray;

    CDirectOdbc.Enabled := True;
    if CUnicodeDriver.Tag = 0  then
      CUnicodeDriver.Enabled := True;
    CUnicodeODBCAPI.Enabled := True;
    COSAuthentication.Enabled := True;

    ESRV.Enabled := True;
    EDB.Enabled := True;
    EUSER.Enabled := True;
    EPWD.Enabled := True;
    EDNS.Enabled := True;
    EAdditional.Enabled := True;

    BSPExec.Enabled := False;
  end;
end;

procedure TForm1.BSPExecClick(Sender: TObject);
var
  iResult: Integer;
//  S: string;
begin
  CheckConnection();

  SQLStoredProc.Close;
  SQLStoredProc.ParamCheck := False;
  iResult := SQLStoredProc.ExecProc();
  ShowMessage('Result = "' + IntToStr(iResult) + '"');
(*
  //S := SQLStoredProc.StoredProcName;
  //SQLStoredProc.StoredProcName := '';
  //SQLStoredProc.StoredProcName := S;
 // SQLStoredProc.Open();
  //ShowMessage('Result = "' + SQLStoredProc.Params[0].AsString);

  //SQLStoredProc.NextRecordSet();

  //CDS.Close;
  //DSProv.DataSet := SQLStoredProc.NextRecordSet();
  //CDS.Open;

//*)
end;

end.
