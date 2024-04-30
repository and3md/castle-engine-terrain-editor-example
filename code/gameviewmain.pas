{ Main view, where most of the application logic takes place.

  Feel free to use this code as a starting point for your own projects.
  This template code is in public domain, unlike most other CGE code which
  is covered by BSD or LGPL (see https://castle-engine.io/license). }
unit GameViewMain;

interface

uses Classes,
  CastleVectors, CastleComponentSerialize,
  CastleUIControls, CastleControls, CastleKeysMouse, CastleTerrain,
  CastleViewport, CastleTransform;

type

  TTerrainOperation = (
    toRaise,
    toLower,
    toLevel
  );

  TTerrainOperations = set of TTerrainOperation;

  { Main view, where most of the application logic takes place. }

  { TViewMain }

  TViewMain = class(TCastleView)
  published
    { Components designed using CGE editor.
      These fields will be automatically initialized at Start. }
    LabelFps: TCastleLabel;

    Terrain: TCastleTerrain;
    TerrainImage: TCastleTerrainImage;
    Viewport: TCastleViewport;

    StrengthSlider: TCastleIntegerSlider;
    BrushMaxHeightSlider: TCastleIntegerSlider;
    BrushSizeSlider: TCastleIntegerSlider;

    RaiseTerrainButton: TCastleButton;
    LowerTerrainButton: TCastleButton;
    LevelTerrainButton: TCastleButton;

    FixedSquareBrushButton: TCastleButton;
    SquareBrushButton: TCastleButton;
    PyramidBrushButton: TCastleButton;
    CircleBrushButton: TCastleButton;
    ConeBrushButton: TCastleButton;
    RingBrushButton: TCastleButton;

    LabelOperation: TCastleLabel;
  private
    Operation: TTerrainOperation;
    FBrush: TCastleTerrainBrush;
    procedure OperationClick(Sender: TObject);
    procedure BrushTypeClick(Sender: TObject);
    procedure UpdateOperationAndBrushLabel;
    function BrushToString(ABrush: TCastleTerrainBrush): String;
    function OperationToString(AOperation: TTerrainOperation): String;
  public
    TimeAccumulator: Single;
    constructor Create(AOwner: TComponent); override;
    procedure Start; override;
    procedure Update(const SecondsPassed: Single; var HandleInput: Boolean); override;
    function Press(const Event: TInputPressRelease): Boolean; override;
  end;

var
  ViewMain: TViewMain;

implementation

uses SysUtils, CastleLog;

{ TViewMain ----------------------------------------------------------------- }

procedure TViewMain.OperationClick(Sender: TObject);
begin
  if Sender = RaiseTerrainButton then
    Operation := toRaise
  else if Sender = LowerTerrainButton then
    Operation := toLower
  else if Sender = LevelTerrainButton then
    Operation := toLevel;

  UpdateOperationAndBrushLabel;
end;

procedure TViewMain.BrushTypeClick(Sender: TObject);
begin
  if Sender = FixedSquareBrushButton then
    FBrush := ctbFixedSquare
  else if Sender = SquareBrushButton then
    FBrush := ctbSquare
  else if Sender = PyramidBrushButton then
    FBrush := ctbPyramid
  else if Sender = CircleBrushButton then
    FBrush := ctbCircle
  else if Sender = ConeBrushButton then
    FBrush := ctbCone
  else if Sender = RingBrushButton then
    FBrush := ctbRing;

  UpdateOperationAndBrushLabel;
end;

procedure TViewMain.UpdateOperationAndBrushLabel;
begin
  LabelOperation.Caption := OperationToString(Operation) + ': ' + BrushToString(FBrush);
end;

function TViewMain.BrushToString(ABrush: TCastleTerrainBrush): String;
begin
  case ABrush of
    ctbFixedSquare:
      Result := 'Fixed Square';
    ctbSquare:
      Result := 'Square';
    ctbPyramid:
      Result := 'Pyramid';
    ctbCircle:
      Result := 'Circle';
    ctbCone:
      Result := 'Cone';
    ctbRing:
      Result := 'Ring';
  end;
end;

function TViewMain.OperationToString(AOperation: TTerrainOperation): String;
begin
  case AOperation of
    toRaise:
      Result := 'Raise terrain';
    toLower:
      Result := 'Lower terrain';
    toLevel:
      Result := 'Level terrain';
  end;
end;

constructor TViewMain.Create(AOwner: TComponent);
begin
  inherited;
  DesignUrl := 'castle-data:/gameviewmain.castle-user-interface';
  Operation := toRaise;
  FBrush := ctbCone;
end;

procedure TViewMain.Start;
begin
  inherited;
  RaiseTerrainButton.OnClick := {$ifdef FPC}@{$endif}OperationClick;
  LowerTerrainButton.OnClick := {$ifdef FPC}@{$endif}OperationClick;
  LevelTerrainButton.OnClick := {$ifdef FPC}@{$endif}OperationClick;

  FixedSquareBrushButton.OnClick := {$ifdef FPC}@{$endif}BrushTypeClick;
  SquareBrushButton.OnClick := {$ifdef FPC}@{$endif}BrushTypeClick;
  PyramidBrushButton.OnClick := {$ifdef FPC}@{$endif}BrushTypeClick;
  CircleBrushButton.OnClick := {$ifdef FPC}@{$endif}BrushTypeClick;
  ConeBrushButton.OnClick := {$ifdef FPC}@{$endif}BrushTypeClick;
  RingBrushButton.OnClick := {$ifdef FPC}@{$endif}BrushTypeClick;

  UpdateOperationAndBrushLabel;
end;

procedure TViewMain.Update(const SecondsPassed: Single; var HandleInput: Boolean);
var
  RayCollision: TRayCollision;
  HitInfo: TRayCollisionNode;
begin
  inherited;
  { This virtual method is executed every frame (many times per second). }
  Assert(LabelFps <> nil, 'If you remove LabelFps from the design, remember to remove also the assignment "LabelFps.Caption := ..." from code');
  LabelFps.Caption := 'FPS: ' + Container.Fps.ToString;

  if Container.MousePressed = [buttonLeft] then
  begin
    RayCollision := Viewport.MouseRayHit;
    if (RayCollision <> nil) and RayCollision.Info(HitInfo) then
    begin
      WritelnLog('Punkt uderzenia: ', HitInfo.Point.ToString);
      case Operation of
        toRaise:
          //Terrain.RaiseTerrain(HitInfo.Point, StrengthSlider.Value);
          Terrain.RaiseTerrainShader(HitInfo.Point, FBrush, BrushSizeSlider.Value,
            StrengthSlider.Value, BrushMaxHeightSlider.Value);
        toLower:
          Terrain.LowerTerrain(HitInfo.Point, StrengthSlider.Value);
      end;
      // Terrain.RaiseTerrain(HitInfo.Point, StrengthSlider.Value);
      //TerrainImage.SetHeight(Vector2(HitInfo.Point.X, -HitInfo.Point.Z), Vector2(HitInfo.Point.X, -HitInfo.Point.Z), 255);
    end;
  end;
end;

function TViewMain.Press(const Event: TInputPressRelease): Boolean;
var
  RayOrigin, RayDirection: TVector3;
  RayCollision: TRayCollision;
  HitInfo: TRayCollisionNode;
begin
  Result := inherited;
  if Result then Exit; // allow the ancestor to handle keys

  {if Event.IsMouseButton(buttonLeft) then
  begin
    RayCollision := Viewport.MouseRayHit;
    WritelnLog('Distance :' + FloatToStr(RayCollision.Distance));
    WritelnLog('Transform :' + RayCollision.Transform.Name);
    if RayCollision.Info(HitInfo) then
    begin
      WritelnLog('Point: ' + HitInfo.Point.ToString);
      WritelnLog('Terrain.Size: ' + Terrain.Size.ToString);
      WritelnLog('Terrain.Translation ' + Terrain.Translation.ToString);

      TerrainImage.SetHeight(Vector2(HitInfo.Point.X, -HitInfo.Point.Z), Vector2(HitInfo.Point.X, -HitInfo.Point.Z), 255);
      //Terrain.Data := nil;
      //Terrain.Data := TerrainImage;
    end;

  end;}

  { This virtual method is executed when user presses
    a key, a mouse button, or touches a touch-screen.

    Note that each UI control has also events like OnPress and OnClick.
    These events can be used to handle the "press", if it should do something
    specific when used in that UI control.
    The TViewMain.Press method should be used to handle keys
    not handled in children controls.
  }

  // Use this to handle keys:
  {
  if Event.IsKey(keyXxx) then
  begin
    // DoSomething;
    Exit(true); // key was handled
  end;
  }
end;

end.
