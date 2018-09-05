unit Arreglo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,StrUtils, ExtCtrls, CurvyControls,ValidarMascara, AdvSmoothPanel, AdvGlowButton;

type
  TFMascara = class(TForm)
    edtMascara: TEdit;
    edtTexto: TEdit;
    lblMascara: TLabel;
    lblTexto: TLabel;
    btnMaskLoad: TButton;
    PanelCMascara: TCurvyPanel;
    PanelTexto: TPanel;
    Panel2: TPanel;
    procedure edtTextoKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure edtTextoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edtTextoExit(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FMascara: TFMascara;
  textoProcesado,mascara : String;
  MiMascara : TMask;

implementation


{$R *.dfm}


procedure TFMascara.edtTextoExit(Sender: TObject);
begin
  if not (MiMascara.ValidarTexto(mascara, textoProcesado)) then
    ShowMessage('Texto Invalido');
end;

procedure TFMascara.edtTextoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  posicion,count : Integer;
begin
  if (key = 46) then
  begin
      posicion := edtTexto.SelStart;
      count := edtTexto.SelLength;
      MiMascara.Suprimir(posicion,count, textoProcesado);

      edtTexto.Text := textoProcesado;
      edtTexto.SelStart := posicion;
      key := 0;
  end;

end;

procedure TFMascara.edtTextoKeyPress(Sender: TObject; var Key: Char);
var
  posicion,count : Integer;
begin
  posicion := edtTexto.SelStart;
  count := edtTexto.SelLength;
  MiMascara.TeclaPresionada(posicion, count, key, mascara, textoProcesado);

  edtTexto.Text := textoProcesado;
  edtTexto.SelStart := posicion;

  key:=#0;
end;

procedure TFMascara.FormCreate(Sender: TObject);
var
  outText : String;
  inputChar : AnsiChar;
begin
  mascara:= edtMascara.Text;
  textoProcesado := MiMascara.obtenerMarcadores(mascara);
  edtTexto.Text := '';
end;



end.
