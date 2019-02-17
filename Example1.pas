uses dos, crt;

const UPPER_LEFT_BOX_SINGLE  = 'Ú';  {218;}
const UPPER_RIGHT_BOX_SINGLE = '¿';  {191;}
const LOWER_LEFT_BOX_SINGLE  = 'À';  {192;}
const LOWER_RIGHT_BOX_SINGLE = 'Ù';  {217;}
const TOP_BOX_SINGLE         = 'Ä';  {196;}
const SIDE_BOX_SINGLE        = '³';  {179;}

const UPPER_LEFT_BOX_DOUBLE  = 'É';  {201;}
const UPPER_RIGHT_BOX_Double = '»';  {187;}
const LOWER_LEFT_BOX_Double  = 'È';  {200;}
const LOWER_RIGHT_BOX_Double = '¼';  {188;}
const TOP_BOX_Double         = 'Í';  {205;}
const SIDE_BOX_Double        = 'º';  {186;}

{ for saving the screen so we can restore it later }
type SaveScreen = array[0..4000] of byte;
type ScrPtr = ^SaveScreen;

{ let's us get at video memory easily }
var video : array[0..4000] of char absolute $B800:0000;
var attr  : array[0..4000] of byte absolute $B800:0000;

var OrigScreen : ScrPtr;

{ original cursor position }
var OrigX : byte;
var OrigY : byte;

var ClockX, ClockY, ClockFore, ClockBack : Byte;

{ Just saves a copy of the whole screen }
procedure SaveScr(Dest : ScrPtr);
var
     index : integer;
begin
     for index := 0 to 4000 do
     begin
         Dest^[index] := ord(video[index]);
     end;
end;

{ restores the entire screen }
procedure RestoreScr(Src : ScrPtr);
var
     index : integer;
begin
     for index := 0 to 4000 do
     begin
         video[index] := chr(Src^[index]);
     end;
end;

{ draws a single character at the specified location }
procedure DrawChar(X, Y : Byte; Ch: Char; ForeColor: byte; BackColor : Byte);
var offset : integer;

begin
     offset := Y * 160 + (X * 2);
     video[offset] := CH;
     attr[offset + 1] := ForeColor + (BackColor SHL 4);
end;

{ draws a horizontal line }
procedure HLine(X1, X2, Y : Byte;
          ForeColor, BackColor : Byte; BeSingle: Boolean);

     var offset  : integer;
     var index   : integer;
     var HLineChar : char;

begin
     if BeSingle then HLineChar := TOP_BOX_SINGLE else HLineChar := TOP_BOX_DOUBLE;
     for index := X1 to X2 do
     begin
          offset := (Y * 160) + (index * 2);
          video[offset] := HLineChar;
          attr[offset+1] := ForeColor + (BackColor SHL 4);
     end;
end;

{ draws a vertical line }
procedure VLine(X, Y1, Y2 : Byte;
          ForeColor, BackColor : Byte; BeSingle: Boolean);

     var offset  : integer;
     var index   : integer;
     var VLineChar : char;

begin
     if BeSingle then VLineChar := SIDE_BOX_SINGLE else VLineCHar := SIDE_BOX_DOUBLE;
     for index := Y1 to Y2 do
     begin
          offset := (index * 160) + (X * 2);
          video[offset] := VLineChar;
          attr[offset+1] := ForeColor + (BackColor SHL 4);
     end;
end;

{ draws a box, optionally fills it in }
procedure DrawBox
          (X1, Y1, X2, Y2 : Byte;
          ForeColor : Byte; BackColor : Byte;
          ShouldFillIn : Boolean;
          ShouldBeSingle : Boolean);

     var offset: integer;
     var index1, index2 : integer;

begin
     if (ShouldBeSingle) then
     begin
          DrawChar(X1, Y1, UPPER_LEFT_BOX_SINGLE, ForeColor, BackColor);
          DrawChar(X2, Y1, UPPER_RIGHT_BOX_SINGLE, ForeColor, BackColor);
          DrawChar(X1, Y2, LOWER_LEFT_BOX_SINGLE, ForeColor, BackColor);
          DrawChar(X2, Y2, LOWER_RIGHT_BOX_SINGLE, ForeColor, BackColor);
     end else
     begin
          DrawChar(X1, Y1, UPPER_LEFT_BOX_DOUBLE, ForeColor, BackColor);
          DrawChar(X2, Y1, UPPER_RIGHT_BOX_DOUBLE, ForeColor, BackColor);
          DrawChar(X1, Y2, LOWER_LEFT_BOX_DOUBLE, ForeColor, BackColor);
          DrawChar(X2, Y2, LOWER_RIGHT_BOX_DOUBLE, ForeColor, BackColor);
     end;

     HLine(X1+1, X2-1, Y1, ForeColor, BackColor, ShouldBeSingle);
     HLine(X1+1, X2-1, Y2, ForeColor, BackColor, ShouldBeSingle);
     VLine(X1,Y1+1,Y2-1, ForeColor, BackColor, ShouldBeSingle);
     VLIne(X2,Y1+1,Y2-1, ForeColor, BackColor, ShouldBeSingle);

     if (ShouldFillIn) then
     begin
          for Index1 := (Y1 + 1) to (Y2 - 1) do
              for Index2 := (X1 + 1) to (X2 - 1) do
                  begin
                       offset := (Index1 * 160) + (index2 * 2);
                       video[offset] := ' ';
                       attr[offset+1] := ForeColor + (BackColor SHL 4);
                  end;
     end;
end;

{ displays string; 0 means to dispay whole string }
procedure DisplayString(S : String;
          X,Y : Byte;
          ForeColor, BackColor : Byte; LengthToDisplay : Byte);

     var TmpString : String;
     var Offset    : Integer;
     var Index     : Byte;

begin
     TmpString := S;
     if (Length(TmpString) > LengthToDisplay) and (LengthToDisplay <> 0) then
     begin
       TmpString[0] := Chr(LengthToDisplay);
     end;
     Offset := (Y * 160) + (X * 2);
     For Index := 0 to (Length(TmpString) - 1) do
     begin
         Offset := (Y * 160) + (X * 2) + (Index * 2);
         video[offset] := TmpString[Index+1];
         Attr[offset+1] := ForeColor + (BackColor SHL 4);
     end;
end;

procedure BoxWithString(Y : Byte; S : String; ForeColor, BackColor : Byte; ShouldBeSingle : Boolean);

const border = 1;

var
   X1, Y1,
   X2, Y2 : Byte;
   Center : Byte;

begin
  Center := ((80 - Ord(S[0])) div 2);
  Y1 := Y;
  X1 := Center;
  DrawBox(X1-Border-1, Y1-1, X1+Ord(S[0]) + Border, Y1+1, ForeColor, BackColor, True, ShouldBeSingle);
  DisplayString(S, x1, y1, forecolor, backcolor, 0);
end;

procedure SetClockOptions(X, Y, ForeColor, BackColor : Byte);
begin
     ClockX := X;
     ClockY := Y;
     ClockFore := ForeColor;
     ClockBack := BackColor;
end;

procedure UpdateClock;
var
  h, m, s, hund : Word;

  function LeadingZero(w : Word) : String;
  var
     s : String;
  begin
       Str(w:0,s);
       if Length(s) = 1 then
          s := '0' + s;
       LeadingZero := s;
  end;

begin
  GetTime(h,m,s,hund);
  displayString(
    LeadingZero(h) + ':' + LeadingZero(m) + ':' + LeadingZero(s),
    ClockX, ClockY,
    ClockFore, ClockBack, 0);
end;

procedure WaitForKey;
var
   Ch : char;

begin
     repeat
           { hang around; do nothing }
           UpdateClock;
     until Keypressed;

     { eat the character typed in }
     Ch := ReadKey;
end;

procedure AddMenuItem;
begin
end;

procedure Init;
begin
     OrigX := WhereX;
     OrigY := WhereY;

     GetMem(OrigScreen, sizeof(SaveScreen));
     SaveScr(OrigScreen);

     SetClockOptions(70,0, White,Blue);
end;

procedure ShutDown;
begin
     RestoreScr(OrigScreen);
     GotoXY(origX, origY);
end;

begin
     Init;

     clrscr;
     drawbox(0,0,79,24, white, blue, TRUE, false);
     DisplayString('[        ]', 69, 0, white, blue, 0);
     {DisplayString('hello world',35,13, white, blue, 0);}
     BoxWithString(3, 'Benjamin Pritchard Demo Software, Turbo Pascal', white, blue, true);
     mem[$B800:1] := 100; {ord('a');}
     WaitForKey;

     Shutdown;
end.