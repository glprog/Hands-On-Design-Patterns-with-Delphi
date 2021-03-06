unit EditorMain;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, System.Generics.Collections,
  System.Actions,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ActnList, Vcl.ComCtrls, Vcl.ExtCtrls,
  Editor.Commands, Editor.Editor;

type
  // Client
  TfrmMemento = class(TForm)
    btnUndo: TButton;
    ActionList1: TActionList;
    actUndo: TAction;
    btnMacro: TButton;
    btnPlay: TButton;
    actRecord: TAction;
    actStop: TAction;
    actPlay: TAction;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Memo2: TMemo;
    Memo1: TMemo;
    procedure actPlayExecute(Sender: TObject);
    procedure actPlayUpdate(Sender: TObject);
    procedure actRecordExecute(Sender: TObject);
    procedure actStopExecute(Sender: TObject);
    procedure actUndoExecute(Sender: TObject);
    procedure actUndoUpdate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    FEditor: array [1..2] of TEditor;
    FMacro: TMacroCommand;
    FRecording: boolean;
    procedure Execute(command: TCommand);
  strict protected
    function ActiveEditor: TEditor;
    function ActiveMemo: TMemo;
  public
    { Public declarations }
  end;

var
  frmMemento: TfrmMemento;

implementation

uses
  System.Character;

{$R *.dfm}

function TfrmMemento.ActiveEditor: TEditor;
begin
  if PageControl1.ActivePageIndex = 0 then
    Result := FEditor[1]
  else
    Result := FEditor[2];
end;

function TfrmMemento.ActiveMemo: TMemo;
begin
  if PageControl1.ActivePageIndex = 0 then
    Result := Memo1
  else
    Result := Memo2;
end;

procedure TfrmMemento.actPlayExecute(Sender: TObject);
begin
  FMacro.Receiver := ActiveMemo;
  ActiveEditor.Execute(FMacro.Clone);
end;

procedure TfrmMemento.actPlayUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := (not FRecording) and assigned(FMacro);
end;

procedure TfrmMemento.actRecordExecute(Sender: TObject);
begin
  FRecording := true;
  btnMacro.Action := actStop;
  FreeAndNil(FMacro);
  FMacro := TMacroCommand.Create(nil);
end;

procedure TfrmMemento.actStopExecute(Sender: TObject);
begin
  FRecording := false;
  btnMacro.Action := actRecord;
end;

procedure TfrmMemento.actUndoExecute(Sender: TObject);
begin
  ActiveEditor.Undo(ActiveEditor.PopLastCommand);
end;

procedure TfrmMemento.actUndoUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := (not ActiveEditor.IsUndoEmpty);
end;

procedure TfrmMemento.Execute(command: TCommand);
begin
  if FRecording then
    FMacro.Add(command.Clone);
  ActiveEditor.Execute(command);
end;

procedure TfrmMemento.FormCreate(Sender: TObject);
begin
  FEditor[1] := TEditor.Create;
  FEditor[2] := TEditor.Create;
end;

procedure TfrmMemento.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FMacro);
  FreeAndNil(FEditor[1]);
  FreeAndNil(FEditor[2]);
end;

procedure TfrmMemento.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if key.IsLetterOrDigit or key.IsWhiteSpace then begin
    Execute(TKeyPressCommand.Create(ActiveMemo, key));
    Key := #0;
  end
  else if key = #8 then begin
    Execute(TDeleteLeftCommand.Create(ActiveMemo));
    Key := #0;
  end;
end;

end.
