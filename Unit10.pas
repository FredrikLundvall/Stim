unit Unit10;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, LMDCustomComponent, LMDClass, ExtCtrls,Math, Generics.Collections;

type
  TPointExt = record
    x: Extended;
    y: Extended;
    function CalculateDistance(aPoint : TPointExt) : double;
    function CalculateDirection() : TPointExt;
    function CalculateLength() : double;
    procedure ChangeLength(speed : double);
  end;

  TIndivid = class
  protected
    fPos : TPointExt;
    fColor : TColor;
    fDirectionSpeed : TPointExt;
    fUpdateCount : Integer;
    fWingMan : TIndivid;
    fPointMan : TIndivid;
  public
    constructor Create(aPos : TPointExt; aColor : TColor; aDirectionSpeed : TPointExt);
  end;

  TForm10 = class(TForm)
    Timer1: TTimer;
    procedure FormPaint(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    fFlockLista : TList<TIndivid>;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form10: TForm10;

implementation

{$R *.dfm}

procedure TForm10.FormCreate(Sender: TObject);
var
  i : Integer;
  p : TPointExt;
  c : TColor;
  ds : TPointExt;
begin
  Randomize();

  fFlockLista := TList<TIndivid>.Create();
  for i := 0 to 20 do
  begin
    p.X := Random(Self.ClientWidth);
    p.Y := Random(Self.ClientHeight);
    c := RGB(Random(255), Random(255), Random(255));
    ds.X := (Random(30) - 15) / 2.0;
    ds.Y := (Random(30) - 15) / 2.0;
    fFlockLista.Add(TIndivid.Create(p,c,ds));
  end;
end;

procedure TForm10.FormPaint(Sender: TObject);
var
  ind,indFriend : TIndivid;
  dir : TPointExt;
begin
  Canvas.Lock();

  for ind in fFlockLista do
  begin
    //Check window boundary
    if( ind.fPos.X < 0) then
      ind.fPos.X := Self.ClientWidth + ind.fPos.X;
    if( ind.fPos.Y < 0) then
      ind.fPos.Y := Self.ClientHeight + ind.fPos.Y;
    if( ind.fPos.X > Self.ClientWidth) then
      ind.fPos.X := ind.fPos.X - Self.ClientWidth;
    if( ind.fPos.Y > Self.ClientHeight) then
      ind.fPos.Y := ind.fPos.Y - Self.ClientHeight;

    Canvas.Pen.Color := ind.fColor;
    Canvas.Brush.Color := ind.fColor;
    Canvas.Ellipse(Trunc(ind.fPos.X - 1),Trunc(ind.fPos.Y - 1),Trunc(ind.fPos.X + 2),Trunc(ind.fPos.Y + 2));
    Canvas.MoveTo(Trunc(ind.fPos.X),Trunc(ind.fPos.Y));
    dir := ind.fDirectionSpeed.CalculateDirection();
    Canvas.LineTo(Trunc(ind.fPos.X + dir.x * 6),Trunc(ind.fPos.Y + dir.y * 6));
    ind.fPos.X := ind.fPos.X + ind.fDirectionSpeed.X;
    ind.fPos.Y := ind.fPos.Y + ind.fDirectionSpeed.Y;
  end;

  for ind in fFlockLista do
  begin
    //Loose wingman
    if(Assigned(ind.fWingMan) and (ind.fPos.CalculateDistance(ind.fWingMan.fPos) > 100)) then
    begin
      ind.fWingMan := nil;
    end;
    //Loose pointman
    if(Assigned(ind.fPointMan) and (ind.fPos.CalculateDistance(ind.fPointMan.fPos) > 150)) then
    begin
      ind.fPointMan := nil;
    end;

   //Choose wingman
   if(not Assigned(ind.fWingMan)) then
    begin
      for indFriend in fFlockLista do
      begin
        if(ind <> indFriend) and (ind.fPointMan <> indFriend) and ( ind.fPos.CalculateDistance(indFriend.fPos) < 30) then
        begin
          ind.fWingMan := indFriend;
          Break;
        end;
      end;
    end;

    //Choose pointman
    if(not Assigned(ind.fPointMan)) then
    begin
      for indFriend in fFlockLista do
      begin
        if(ind <> indFriend) and (ind.fWingMan <> indFriend)  and ( ind.fPos.CalculateDistance(indFriend.fPos) < 70) then
        begin
          ind.fPointMan := indFriend;
          Break;
        end;
      end;
    end;
  end;

  for ind in fFlockLista do
  begin
    //Add some random factor to speed and direction
    if(ind.fUpdateCount > 10) then
    begin
      ind.fDirectionSpeed.x := ind.fDirectionSpeed.x + (RandomRange(-10,11) / 3.0);
      ind.fDirectionSpeed.y := ind.fDirectionSpeed.y + (RandomRange(-10,11) / 3.0);
      ind.fUpdateCount := 0;
    end
    else
      ind.fUpdateCount := ind.fUpdateCount + RandomRange(1,11);

    if(Assigned(ind.fWingMan)) then
    begin
      indFriend := ind.fWingMan;
      //Adjust speed and direction to wingman
      ind.fDirectionSpeed.x := ind.fDirectionSpeed.x + (indFriend.fDirectionSpeed.x - ind.fDirectionSpeed.x) * 0.2;
      ind.fDirectionSpeed.y := ind.fDirectionSpeed.y + (indFriend.fDirectionSpeed.y - ind.fDirectionSpeed.y) * 0.2;

      if ind.fDirectionSpeed.CalculateLength() < 3 then
        ind.fDirectionSpeed.ChangeLength(3.0)
      else if ind.fDirectionSpeed.CalculateLength() > 8 then
        ind.fDirectionSpeed.ChangeLength(8.0);

      //Adjust position to wingman if too far
      if( ind.fPos.CalculateDistance(indFriend.fPos) > 20) then
      begin
        if(ind.fPos.x < indFriend.fPos.x) then
          ind.fPos.x := ind.fPos.x + 1
        else
          ind.fPos.x := ind.fPos.x - 1;
        if(ind.fPos.y < indFriend.fPos.y) then
          ind.fPos.y := ind.fPos.y + 1
        else
          ind.fPos.y := ind.fPos.y - 1;
      end;
    end;

    if(Assigned(ind.fPointMan)) then
    begin
      indFriend := ind.fPointMan;
      //Adjust speed and direction to pointman
      ind.fDirectionSpeed.x := ind.fDirectionSpeed.x + (indFriend.fDirectionSpeed.x - ind.fDirectionSpeed.x) * 0.2;
      ind.fDirectionSpeed.y := ind.fDirectionSpeed.y + (indFriend.fDirectionSpeed.y - ind.fDirectionSpeed.y) * 0.2;

      if ind.fDirectionSpeed.CalculateLength() < 3 then
        ind.fDirectionSpeed.ChangeLength(3.0)
      else if ind.fDirectionSpeed.CalculateLength() > 8 then
        ind.fDirectionSpeed.ChangeLength(8.0);

      //Adjust position to pointman if too far
      if( ind.fPos.CalculateDistance(indFriend.fPos) > 30) then
      begin
        if(ind.fPos.x < indFriend.fPos.x) then
          ind.fPos.x := ind.fPos.x + 1
        else
          ind.fPos.x := ind.fPos.x - 1;
        if(ind.fPos.y < indFriend.fPos.y) then
          ind.fPos.y := ind.fPos.y + 1
        else
          ind.fPos.y := ind.fPos.y - 1;
      end;
    end;

    for indFriend in fFlockLista do
    begin
      if(ind <> indFriend ) then
      begin
         //Adjust position to anyone if too near
        if( ind.fPos.CalculateDistance(indFriend.fPos) < 10) then
        begin
          if(ind.fPos.x < indFriend.fPos.x) then
            ind.fPos.x := ind.fPos.x - 1
          else
            ind.fPos.x := ind.fPos.x + 1;
          if(ind.fPos.y < indFriend.fPos.y) then
            ind.fPos.y := ind.fPos.y - 1
          else
            ind.fPos.y := ind.fPos.y + 1;
        end;
      end;
    end;

  end;

  Canvas.UnLock();
end;

procedure TForm10.Timer1Timer(Sender: TObject);
begin
  Self.Refresh();
end;

{ TIndivid }

constructor TIndivid.Create(aPos: TPointExt; aColor : TColor; aDirectionSpeed : TPointExt);
begin
  fPos := aPos;
  fColor := aColor;
  fDirectionSpeed := aDirectionSpeed;
  fUpdateCount := 0;
end;

{ TPointExt }

function TPointExt.CalculateDirection: TPointExt;
var
  dist : Double;
begin
  dist := Self.CalculateLength();
  if(dist = 0) then
    dist := 1;
  Result.x := self.x / dist;
  Result.y := self.y / dist;
end;

function TPointExt.CalculateDistance(aPoint: TPointExt): double;
begin
  Exit(Sqrt(Sqr(self.x - aPoint.x) + Sqr(self.y - aPoint.y)));
end;

procedure TPointExt.ChangeLength(speed: double);
var
  dir : TPointExt;
begin
  dir := Self.CalculateDirection();
  self.x := dir.x * speed;
  self.y := dir.y * speed;
end;

function TPointExt.CalculateLength(): double;
var
  origo : TPointExt;
begin
  origo.x := 0;
  origo.y := 0;
  Result := Self.CalculateDistance(origo);
end;

end.
