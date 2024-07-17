program Ranking;

uses
  System.StartUpCopy,
  FMX.Forms,
  unPrincipal in 'unPrincipal.pas' {Form2};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
