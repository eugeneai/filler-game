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
type
  TD = array [1..4] of integer;

  TBoard = class
    b:array [1..BOARD_X, 1..BOARD_Y] of byte;
    c,h:byte;
    correct:boolean;
  end;

  { TFillerForm }

  TFillerForm = class(TForm)
    NewGame: TButton;
    PlayBoard: TPaintBox;
    procedure NewGameClick(Sender: TObject);
    function MiniMax(hum:boolean; d:integer; board:TBoard; var best_board: TBoard):integer;
    function Account(board:TBoard):integer;
    procedure MakeStep(hum:boolean; board:TBoard; var new_board:TBoard; var n:byte);
    procedure FillBoard(var board:TBoard; n,pn:byte; x, y:integer);
    procedure PlayBoardPaint(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  FillerForm: TFillerForm;

implementation

{$R *.lfm}

{ TFillerForm }

procedure TFillerForm.NewGameClick(Sender: TObject);
begin

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

procedure TFillerForm.PlayBoardPaint(Sender: TObject);
var
  C:TCanvas;
begin
  C:=PlayBoard.Canvas;
  //Cx:=Figure.ClientWidth >> 1;
  //Cy:=Figure.ClientHeight >> 1;
  //C.Draw(Cx-Sx,by,bmp);  //TCanvas
  //C.Ellipse(xi-SR,yi-SR,xi+SR,yi+SR);
end;

end.

