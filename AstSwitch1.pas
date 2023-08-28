{------------------------------------------------------------------------------}
{         written by Victor Borodinov, borodinov.v@gmail.com                   }
{         AstSwitch component for VCL - animated toggle switches               }
{         Borland Delphi (32-bit)                                              }
{------------------------------------------------------------------------------}
unit AstSwitch1;

interface

uses
  SysUtils, Classes, Controls, ExtCtrls, messages, Graphics, Forms, StdCtrls;

type
  TAstSwitchEvent=procedure(Sender: TObject) of object;

  TAstSwitch = class;
  TKind = (asHorizontal, asVertical);

  TColorProperties = class(TPersistent)
    private
    FAstSwitch: TAstSwitch;

    FBottomBaseColor: TColor;
    FBaseColor: TColor;
    FSwitchColor: TColor;

    FLabelOffFontColor: TColor;
    FLabelOnFontColor: TColor;

    FLabelFont: TFont;

    procedure SetBottomBaseColor(Value: TColor);
    procedure SetBaseColor(Value: TColor);
    procedure SetSwitchColor(Value: TColor);
    procedure SetLabelOffFontColor(Value: TColor);
    procedure SetLabelOnFontColor(Value: TColor);
    procedure SetLabelFont(Value: TFont);

    procedure LabelFontChanged(Sender: TObject);

  public
    constructor Create(const AstSwitch: TAstSwitch);
//    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;

  published
    property sBottomBaseColor: TColor read FBottomBaseColor write SetBottomBaseColor;
    property sBaseColor: TColor read FBaseColor write SetBaseColor;
    property sSwitchColor: TColor read FSwitchColor write SetSwitchColor;

    property LabelOffFontColor: TColor read FLabelOffFontColor write SetLabelOffFontColor;
    property LabelOnFontColor: TColor read FLabelOnFontColor write SetLabelOnFontColor;
    property LabelFont: TFont read FLabelFont write SetLabelFont;
  end;



  TAstSwitch = class(TCustomPanel)
  private
    { Private declarations }
    FControl: TControl;

    FSwitchOn: Boolean;

    FBottomBaseShape: TShape;
    FBaseShape:       TShape;
    FSwitchShape:     TShape;

    FSwitchOffLabel:  TLAbel;
    FSwitchOnLabel:   TLAbel;

    FChange:  TAstSwitchEvent;

    FAnimationDelay: Integer;
    FAnimationStep: Integer;
    FKind: TKind;


    FAstSwitchColors: TColorProperties;
    procedure SetAstSwitchColors(Value: TColorProperties);

    procedure WMSize(var Message: Tmessage); message WM_SIZE;

    procedure MouseDown(Sender: TObject;
              Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

    function  GetSwitchStatus: Boolean;
    procedure SetSwitchStatus(const Value: Boolean);

    function  GetAnimationDelay: Integer;
    procedure SetAnimationDelay(const Value: Integer);

    function  GetAnimationStep: Integer;
    procedure SetAnimationStep(const Value: Integer);

    procedure SetKind(const Value: TKind);
    procedure repaintProc;

  protected
    { Protected declarations }

  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;

  published
    { Published declarations }
//    property ParentColor;
//    property Color;
    property BevelOuter;
    property Kind: TKind read FKind write SetKind;
    property AstSwitchColors: TColorProperties read FAstSwitchColors write SetAstSwitchColors;
    property Switch_On: Boolean read GetSwitchStatus write SetSwitchStatus;
    property AnimationDelay: Integer read GetAnimationDelay write SetAnimationDelay;
    property AnimationStep: Integer read GetAnimationStep write SetAnimationStep;
    property Change: TAstSwitchEvent read FChange write FChange;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Samples', [TAstSwitch]);
end;


{TColorProperties}
constructor TColorProperties.Create(const AstSwitch: TAstSwitch);
begin
  inherited Create;

  FAstSwitch := AstSwitch;
  FBottomBaseColor := clGray;
  FBaseColor := clWhite;
  FSwitchColor := clNavy;
  FLabelOffFontColor := $008080FF;
  FLabelOnFontColor := clBlack;
  FLabelFont:= TFont.Create;
  FLabelFont.Name:='Arial';
  FLabelFont.OnChange := LabelFontChanged;
end;


procedure TColorProperties.Assign(Source: TPersistent);
var
  CP: TColorProperties;
begin
  if Source is TColorProperties then
     begin
     CP := TColorProperties(Source);
     LabelFont := CP.LabelFont;
     LabelOnFontColor := CP.LabelOnFontColor;
     LabelOffFontColor := CP.LabelOffFontColor;
     sBottomBaseColor := CP.sBottomBaseColor;
     sBaseColor := CP.sBaseColor;
     sSwitchColor := CP.sSwitchColor;
     end
  else
     inherited;
end;


procedure TColorProperties.SetBottomBaseColor(Value: TColor);
begin
  if Value <> FBottomBaseColor then
     begin
     FBottomBaseColor := Value;
     FAstSwitch.Invalidate;
     FAstSwitch.repaintProc;
    end;
end;

procedure TColorProperties.SetBaseColor(Value: TColor);
begin
  if Value <> FBaseColor then
     begin
     FBaseColor := Value;
     FAstSwitch.Invalidate;
     FAstSwitch.repaintProc;
     end;
end;

procedure TColorProperties.SetSwitchColor(Value: TColor);
begin
  if Value <> FSwitchColor then
     begin
     FSwitchColor := Value;
     FAstSwitch.Invalidate;
     FAstSwitch.repaintProc;
     end;
end;


procedure TColorProperties.SetLabelOffFontColor(Value: TColor);
begin
  FLabelOffFontColor := Value;
  FAstSwitch.repaintProc;
end;


procedure TColorProperties.SetLabelOnFontColor(Value: TColor);
begin
  FLabelOnFontColor := Value;
  FAstSwitch.repaintProc;
end;


procedure TColorProperties.SetLabelFont(Value: TFont);
begin
  FLabelFont.Assign(Value);
end;


procedure TColorProperties.LabelFontChanged(Sender: TObject);
begin
  FAstSwitch.Invalidate;
  FAstSwitch.repaintProc;
end;


{TAstSwitch}
constructor TAstSwitch.Create(AOwner: TComponent);
var
  i: Integer;
begin
  inherited Create(AOwner);

  FAstSwitchColors := TColorProperties.Create(Self);

  //initial
  Caption:='.';
  ParentColor:=True;
  Self.BevelInner:=bvNone;
  Self.BevelOuter:=bvNone;
  FSwitchOn:=True;

  Width:=32;
  Height:=43;

  FAnimationDelay:=5;
  FAnimationStep:=2;
  FKind:=asVertical;

  FBottomBaseShape:=TShape.Create(Self);
  FBottomBaseShape.Parent:=Self;
  FBottomBaseShape.Left:=3;
  FBottomBaseShape.Top:=2;
  FBottomBaseShape.Width:=28;
  FBottomBaseShape.Height:=36;
  FBottomBaseShape.Shape:=stRoundRect;
  FBottomBaseShape.Brush.Color:=FAstSwitchColors.FBottomBaseColor;
  FBottomBaseShape.Pen.Color:=FAstSwitchColors.FBottomBaseColor;
  FBottomBaseShape.Pen.Width:=1;

  FBaseShape:=TShape.Create(Self);
  FBaseShape.Parent:=Self;
  FBaseShape.Left:=6;
  FBaseShape.Top:=4;
  FBaseShape.Width:=22;
  FBaseShape.Height:=33;
  FBaseShape.Shape:=stRoundRect;
  FBaseShape.OnMouseDown:=MouseDown;
  FBaseShape.Brush.Color:=FAstSwitchColors.FBaseColor;
  FBaseShape.Pen.Width:=1;
  FBaseShape.Pen.Color:=clBlack;

  FSwitchShape:=TShape.Create(Self);
  FSwitchShape.Parent:=Self;
  FSwitchShape.Left:=5;
  FSwitchShape.Top:=4;
  FSwitchShape.Width:=24;
  FSwitchShape.Height:=18;
  FSwitchShape.Shape:=stRoundRect;
  FSwitchShape.OnMouseDown:=MouseDown;
  FSwitchShape.Brush.Color:=FAstSwitchColors.FSwitchColor;
  FSwitchShape.Pen.Width:=1;
  FSwitchShape.Pen.Color:=clBlack;

  FSwitchOffLabel:=TLabel.Create(Self);
  FSwitchOffLabel.Parent:=Self;
  FSwitchOffLabel.Top:=5;
  FSwitchOffLabel.Width:=20;
  FSwitchOffLabel.Height:=10;
  FSwitchOffLabel.Visible:=True;
  FSwitchOffLabel.Font:=FAstSwitchColors.LabelFont;
  FSwitchOffLabel.Font.Color:=FAstSwitchColors.FLabelOffFontColor;
  FSwitchOffLabel.Caption:='off';
  FSwitchOffLabel.Left:=FBaseShape.Left + (FBaseShape.Width div 2) - (FSwitchOffLabel.Width div 2);
  FSwitchOffLabel.Transparent:=True;
  FSwitchOffLabel.OnMouseDown:=MouseDown;
  FSwitchOffLabel.Visible:=False;

  FSwitchOnLabel:=TLabel.Create(Self);
  FSwitchOnLabel.Parent:=Self;
  FSwitchOnLabel.Top:=23;
  FSwitchOnLabel.Width:=20;
  FSwitchOnLabel.Height:=10;
  FSwitchOnLabel.Font:=FAstSwitchColors.LabelFont;
  FSwitchOnLabel.Font.Color:=FAstSwitchColors.FLabelOnFontColor;
  FSwitchOnLabel.Visible:=True;
  FSwitchOnLabel.Caption:='on';
  FSwitchOnLabel.Left:=FBaseShape.Left + (FBaseShape.Width div 2) - (FSwitchOnLabel.Width div 2);
  FSwitchOnLabel.Transparent:=True;
  FSwitchOnLabel.OnMouseDown:=MouseDown;
end;


procedure TAstSwitch.SetAstSwitchColors(Value: TColorProperties);
begin
  FAstSwitchColors.Assign(Value);
end;


procedure TAstSwitch.SetKind(const Value: TKind);
begin
   FKind:=Value;
   repaintProc;
end;


procedure TAstSwitch.repaintProc;
begin

  FSwitchOffLabel.Font:= FAstSwitchColors.LabelFont;
  FSwitchOnLabel.Font := FAstSwitchColors.LabelFont;

  FSwitchOffLabel.Font.Color:= FAstSwitchColors.FLabelOffFontColor;
  FSwitchOnLabel.Font.Color := FAstSwitchColors.FLabelOnFontColor;

  FSwitchOnLabel.Repaint;
  FSwitchOffLabel.Repaint;

  FBottomBaseShape.Width := Width-4;
  FBottomBaseShape.Height := Height-6;

  FBaseShape.Width := FBottomBaseShape.Width-6;// 3| |3
  FBaseShape.Height := FBottomBaseShape.Height-4;

  if FKind=asVertical then
     begin
     FSwitchShape.Left:=FBottomBaseShape.Left+1;
     FSwitchShape.Width:=FBottomBaseShape.Width - 2; //  1| |1
     FSwitchShape.Height:=FBottomBaseShape.Height div 2;

     if FSwitchOn then
        FSwitchShape.Top:=FBottomBaseShape.Top + 1
     else
        FSwitchShape.Top:=FBottomBaseShape.Top + FBottomBaseShape.Height - FSwitchShape.Height - 1;


     FSwitchOffLabel.Top:=FBaseShape.Top  + (FSwitchShape.Height div 2) - (FSwitchOffLabel.Height div 2);
     FSwitchOnLabel.Top:=FBaseShape.Top + (FBaseShape.Height div 2) + (FSwitchShape.Height div 2) - (FSwitchOnLabel.Height div 2);

     FSwitchOffLabel.Left:=FBaseShape.Left + (FBaseShape.Width div 2) - (FSwitchOffLabel.Width div 2);
     FSwitchOnLabel.Left:=FBaseShape.Left + (FBaseShape.Width div 2) - (FSwitchOnLabel.Width div 2);

     FSwitchShape.Brush.Color:=FAstSwitchColors.FSwitchColor;
     FBaseShape.Brush.Color:=FAstSwitchColors.FBaseColor;
     FBottomBaseShape.Brush.Color:=FAstSwitchColors.FBottomBaseColor;
     FBottomBaseShape.Pen.Color:=FAstSwitchColors.FBottomBaseColor;
     end
  else
     begin

     FSwitchShape.Width:=FBottomBaseShape.width div 2;
     FSwitchShape.Height:=FBottomBaseShape.Height - 2;
     FSwitchShape.Top:=FBottomBaseShape.Top + 1 ;

     FSwitchOffLabel.Top:=FBaseShape.Top + (FBaseShape.Height div 2) - (FSwitchOffLabel.Height div 2);
     FSwitchOnLabel.Top:=FSwitchOffLabel.Top;

     FSwitchOffLabel.Left:=FBaseShape.Left + (FBaseShape.Width div 2)  + (FSwitchShape.Width div 2) - (FSwitchOffLabel.Width div 2); //off
     FSwitchOnLabel.Left:=FBaseShape.Left + (FSwitchShape.Width div 2) - (FSwitchOnLabel.Width div 2); //on

     FSwitchShape.Brush.Color:=FAstSwitchColors.FSwitchColor;
     FBaseShape.Brush.Color:=FAstSwitchColors.FBaseColor;
     FBottomBaseShape.Brush.Color:=FAstSwitchColors.FBottomBaseColor;
     FBottomBaseShape.Pen.Color:=FAstSwitchColors.FBottomBaseColor;

     if FSwitchOn then
        FSwitchShape.Left:=FBottomBaseShape.Left + FBottomBaseShape.Width - FSwitchShape.Width
     else
        FSwitchShape.Left:=FBottomBaseShape.Left;

     end;

end;


function TAstSwitch.GetSwitchStatus: Boolean;
begin
   Result:=FSwitchOn;
end;


procedure TAstSwitch.SetSwitchStatus(const Value: Boolean);
procedure verticalInition;
begin
   if value=True then
      begin
        FSwitchShape.Top:=FBaseShape.Top;

        FSwitchOffLAbel.Visible:=False;
        FSwitchOnLAbel.Visible:=True;

        FSwitchOn:=True;
      end
   else
      begin
        FSwitchShape.Top:=FBaseShape.Top+FBaseShape.Height-FSwitchShape.Height;

        FSwitchOffLAbel.Visible:=True;
        FSwitchOnLAbel.Visible:=False;

        FSwitchOn:=False;
      end;
end;

procedure HorizontalInition;
begin
   if value=True then
      begin
      FSwitchShape.Top:=FBottomBaseShape.Top;
      FSwitchShape.Left:=FBottomBaseShape.Left + FBottomBaseShape.Width - FSwitchShape.width;

      FSwitchOffLAbel.Visible:=False;
      FSwitchOnLAbel.Visible:=True;

      FSwitchOn:=True;
      end
   else
      begin
      FSwitchShape.Top:=FBottomBaseShape.Top;
      FSwitchShape.Left:=FBottomBaseShape.Left;

      FSwitchOffLAbel.Visible:=True;
      FSwitchOnLAbel.Visible:=False;

      FSwitchOn:=False;
      end;
end;

begin
   if FKind=asVertical then
      verticalInition
   else
      horizontalInition;
end;


function TAstSwitch.GetAnimationDelay: Integer;
begin
   Result:=FAnimationDelay;
end;

procedure TAstSwitch.SetAnimationDelay(const Value: Integer);
begin
  FAnimationDelay:=Value;
end;


function TAstSwitch.GetAnimationStep: Integer;
begin
   Result:=FAnimationStep;
end;

procedure TAstSwitch.SetAnimationStep(const Value: Integer);
begin
   FAnimationStep:=Value;
end;


procedure TAstSwitch.WMSize(var Message: TMessage);
begin
   inherited;
   repaintProc;
end;


procedure TAstSwitch.MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

procedure verticalAnimation;
begin
   if FSwitchOn=True then
      begin
      while FSwitchShape.Top+FSwitchShape.Height < FBaseShape.Top+FBaseShape.Height do
            begin
            FSwitchShape.Top:=FSwitchShape.Top + FAnimationStep;
            sleep(FAnimationDelay);
            Application.ProcessMessages;
            end;

      FSwitchShape.Top:=FBaseShape.Top + FBaseShape.Height - FSwitchShape.Height;

      FSwitchOffLAbel.Visible:=True;
      FSwitchOnLAbel.Visible:=False;

      FSwitchOn:=False;
      end
   else
      begin

      while FSwitchShape.Top > FBaseShape.Top do
            begin
            FSwitchShape.Top:=FSwitchShape.Top - FAnimationStep;
            sleep(FAnimationDelay);
            Application.ProcessMessages;
            end;

      FSwitchShape.Top := FBaseShape.Top;

      FSwitchOffLAbel.Visible:=False;
      FSwitchOnLAbel.Visible:=True;

      FSwitchOn:=True;
      end;
  end;

procedure horizontalAnimation;
begin
   FSwitchShape.Top:=FBottomBaseShape.Top + 1;

   if FSwitchOn=True then
      begin
      while FSwitchShape.Left + FSwitchShape.Width < FBottomBaseShape.Left+FBottomBaseShape.Width do
            begin
            FSwitchShape.Left:=FSwitchShape.Left + FAnimationStep;
            sleep(FAnimationDelay);
            Application.ProcessMessages;
            end;

      FSwitchShape.Left := FBaseShape.Left + FBaseShape.Width - FSwitchShape.Width;

      FSwitchOffLAbel.Visible:=False;
      FSwitchOnLAbel.Visible:=True;

      FSwitchOn:=False;

      end
   else
      begin
      while FSwitchShape.Left > FBottomBaseShape.Left do
            begin
            FSwitchShape.Left:=FSwitchShape.Left - FAnimationStep;
            sleep(FAnimationDelay);
            Application.ProcessMessages;
            end;

      FSwitchShape.Left := FBaseShape.Left;

      FSwitchOffLAbel.Visible:=True;
      FSwitchOnLAbel.Visible:=False;

      FSwitchOn:=True;
      end;
   end;

begin //main TAstSwitch.MouseDown

   if FKind=asVertical then
      verticalAnimation
   else
      horizontalAnimation;

   if Assigned(FChange) then FChange(Self);
end;


end.
