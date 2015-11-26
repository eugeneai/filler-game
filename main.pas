unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Buttons, StdCtrls;

const
  BOARD_X=50;
  BOARD_Y=30;
  MAX_HALF_STEPS=4;
  MAX_COLOR=5; { 1..5 }
  COLORS: array [1..MAX_COLOR] of TColor =(
  clYellow, clGreen, clWhite, clBlack, clPurple
  );
type
  TD = array [1..4] of integer;

  TBoard = class
    b:array [1..BOARD_X, 1..BOARD_Y] of byte;
    c,h:byte;
    correct:boolean;
  end;

  { TFillerForm }

  TFillerForm = class(TForm)
    human: TLabel;
    computer: TLabel;
    NewGame: TButton;
    Choice: TPaintBox;
    human_col: TPaintBox;
    computer_col: TPaintBox;
    PlayBoard: TPaintBox;
    procedure ChoiceMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure humanClick(Sender: TObject);
    procedure human_colPaint(Sender: TObject);
    procedure NewGameClick(Sender: TObject);
    function MiniMax(hum:boolean; d:integer; board:TBoard; var best_board: TBoard):integer;
    function Account(board:TBoard):integer;
    procedure MakeStep(hum:boolean; board:TBoard; var new_board:TBoard; var n:byte);
    procedure FillBoard(var board:TBoard; n,pn:byte; x, y:integer);
    procedure ChoiceClick(Sender: TObject);
    procedure PlayBoardPaint(Sender: TObject);
    procedure ChoicePaint(Sender: TObject);
  private
    { private declarations }
    procedure BoardCreate;
  public
    { public declarations }
    board:TBoard;
  end;

var
  FillerForm: TFillerForm;

implementation

{$R *.lfm}

{ TFillerForm }

procedure TFillerForm.NewGameClick(Sender: TObject);
begin
  BoardCreate;
  human_col.Repaint;
  computer_col.Repaint;
  PlayBoard.Repaint;
end;

procedure TFillerForm.BoardCreate;
var
  x,y:integer;
begin
  board:=TBoard.Create;
  Randomize;
  for x:=1 to BOARD_X do
  begin
    for y:=1 to BOARD_Y do
    begin
      board.b[x,y]:=Random(MAX_COLOR)+1;
    end;
  end;
  board.c:=board.b[1,BOARD_Y];
  board.h:=board.b[BOARD_X,1];
  if board.c=board.h then
  begin
    board.c:=((board.c) mod MAX_COLOR)+1;
    board.b[1,BOARD_Y]:=board.c;
  end;
  board.correct:=true;
end;

procedure TFillerForm.FormCreate(Sender: TObject);
begin
  BoardCreate;
end;

procedure TFillerForm.ChoiceMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  nh:Byte;
  W:Integer;
  s:Integer;
begin
  W:=Choice.ClientWidth;
  s:=W div MAX_COLOR;
  nh:=(X div s)+1;
  if board.h=nh then
  begin
    ShowMessage('You cannot take this color as it already takey by You!');
    exit;
  end;
  if board.c=nh then
  begin
    ShowMessage('You cannot take this color as it already taken by computer!');
    exit;
  end;
  board.h:=nh;
  human_col.Repaint;
end;

procedure TFillerForm.humanClick(Sender: TObject);
begin

end;

procedure TFillerForm.human_colPaint(Sender: TObject);
var
  C:TCanvas;
  W,H:Integer;
begin
  C:=human_col.Canvas;
  W:=human_col.ClientWidth;
  H:=human_col.ClientHeight;
  C.Brush.Color:=COLORS[board.h];
  C.Rectangle(0,0, W,H);

  C:=computer_col.Canvas;
  W:=computer_col.ClientWidth;
  H:=computer_col.ClientHeight;
  C.Brush.Color:=COLORS[board.c];
  C.Rectangle(0,0, W,H);
end;

function TFillerForm.MiniMax(hum:boolean; d:integer; board:TBoard;
                                          var best_board: TBoard):integer;
var
  acc,bacc:integer;
  new_board, _board:TBoard;
  n:byte;
begin
  if d>=MAX_HALF_STEPS then
  begin
    acc:=Account(board);
    best_board:=board;
  end
  else
  begin
    { MiniMax }
    if hum then
    begin
      acc:=-32767;
    end else
    begin
      acc:=+32767;
    end;
    best_board:=board;
    n:=1;
    repeat
      MakeStep(hum, board, new_board, n);
      if new_board=nil then break;
      bacc:=MiniMax(not hum, d+1, new_board, _board);
      if hum then
      begin
        if acc<bacc then
        begin
           acc:=bacc;
           best_board:=new_board;
        end;
      end else
      begin
        if acc>bacc then
        begin
          acc:=bacc;
          best_board:=new_board;
        end;
      end;
    until false;
  end;
  MiniMax:=acc;
end;

function TFillerForm.Account(board:TBoard):integer;
var
  cc,hc:integer;
  x,y:integer;
begin
  cc:=0; hc:=0;
  for x:=1 to BOARD_X do
  begin
    for y:=1 to BOARD_Y do
    begin
      if board.b[x,y]=board.c then cc:=cc+1;
      if board.b[x,y]=board.h then hc:=hc+1;
    end;
  end;
  Account:=cc-hc;
end;

procedure TFillerForm.MakeStep(hum:boolean; board:TBoard; var new_board:TBoard; var n:byte);
var
  hc,cc:byte;
begin
  new_board.correct:=false;
  if n>MAX_COLOR then EXIT;
  new_board:=board;
  cc:=new_board.b[1,BOARD_Y];
  hc:=new_board.b[BOARD_X,1];
  if (hc=n) or (cc=n) then
  begin
    n:=n+1;
    MakeStep(hum, board, new_board, n);
  end
  else { n is of a correct colour }
  begin
    if hum then
    FillBoard(new_board, n, hc, BOARD_X, 1)
    else
    FillBoard(new_board, n, cc, 1, BOARD_Y);
    n:=n+1;
  end;
end;

const
  dx:TD = (0,0,1,-1);
  dy:TD = (-1,1,0,0);

procedure TFillerForm.FillBoard(var board:TBoard; n,pn:byte; x,y:integer);
var
  p:byte;
  s:integer;
begin
  if (x<0) or (y<0) or (x>BOARD_X) or (y>BOARD_Y) then exit;
  p:=board.b[x,y];
  if p<>pn then exit;
  board.b[x,y]:=n;
  for s:=1 to 4 do
  begin
    x:=x+dx[s];
    y:=y+dy[s];
    FillBoard(board, n, pn, x,y);
  end;
end;

procedure TFillerForm.ChoiceClick(Sender: TObject);
var
  m:TPoint;
begin
  m:=Mouse.CursorPos;

end;

procedure TFillerForm.PlayBoardPaint(Sender: TObject);
var
  i, r, f, x,y: integer;
  C:TCanvas;
  W,H:Integer;
  sx,sy:Integer;
begin
  C:=PlayBoard.Canvas;
  C.Brush.Color:= clRed;
  C.Pen.Color := clBlue;
  W:=PlayBoard.ClientWidth;
  H:=PlayBoard.ClientHeight;
  sx:=W div BOARD_X;
  sy:=H div BOARD_Y;
  //C.Rectangle(0,0,C.Width, C.Height);
  for x:=0 to BOARD_X-1 do
  begin
    for y:=0 to BOARD_Y-1 do
    begin
      C.Brush.Color:=COLORS[board.b[x+1,y+1]];
      C.Rectangle(x*sx,y*sy,(x+1)*sx,(y+1)*sy);
    end;
  end;
end;


procedure TFillerForm.ChoicePaint(Sender: TObject);
var
  i, r, f, x,y: integer;
  C:TCanvas;
  W,H:Integer;
  sx,sy:Integer;
begin
  C:=Choice.Canvas;
  C.Brush.Color:= clRed;
  C.Pen.Color := clBlue;
  W:=Choice.ClientWidth;
  H:=Choice.ClientHeight;
  sx:=W div MAX_COLOR;
  for x:=0 to MAX_COLOR-1 do
  begin
    C.Brush.Color:=COLORS[x+1];
    C.Rectangle(x*sx,0,(x+1)*sx,H);
  end;
end;
end.

