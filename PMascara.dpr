program PMascara;

uses
  Forms,
  Arreglo in 'Arreglo.pas' {FMascara},
  ValidarMascara in 'ValidarMascara.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFMascara, FMascara);
  Application.Run;
end.
