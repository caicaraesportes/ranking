unit unPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.JSON,
  System.Net.HttpClient,
  System.Generics.Collections,
  System.Actions,
  System.Net.URLClient, System.Net.HttpClientComponent,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.ListBox, FMX.Edit, FMX.EditBox, FMX.NumberBox,
  FMX.DateTimeCtrls, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo;

type

  TAtleta = class
    Id: Integer;
    Nome: string;
    Ranking :Integer;
  end;
  TSelecionadosArray = array[0..3] of TAtleta;
  TAtletasArray = array[0..1000] of TAtleta;

  TForm2 = class(TForm)
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    ComboBox3: TComboBox;
    ComboBox4: TComboBox;
    Label2: TLabel;
    lbDupla1: TLabel;
    resDupla1: TNumberBox;
    Label8: TLabel;
    resDupla2: TNumberBox;
    lbDupla2: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Button2: TButton;
    Label6: TLabel;
    DateEdit1: TDateEdit;
    Panel4: TPanel;
    pnJogos: TPanel;
    Label1: TLabel;
    pnSeq1: TPanel;
    pnSeq3: TPanel;
    lbDupla5: TLabel;
    Label4: TLabel;
    lbDupla6: TLabel;
    resDupla5: TNumberBox;
    resDupla6: TNumberBox;
    pnSeq2: TPanel;
    lbDupla3: TLabel;
    Label12: TLabel;
    lbDupla4: TLabel;
    resDupla3: TNumberBox;
    resDupla4: TNumberBox;
    btnPreparaGravacao: TButton;
    Timer1: TTimer;
    Memo1: TMemo;
    pnConfirma: TPanel;
    lbSeq1: TLabel;
    lbSeq3: TLabel;
    lbSeq2: TLabel;
    btConfirmar: TButton;
    lbRan1: TLabel;
    lbRan2: TLabel;
    lbRan3: TLabel;
    btSair: TSpeedButton;
    Button1: TButton;
    procedure Button2Click(Sender: TObject);
    procedure btnPreparaGravacaoClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure btConfirmarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btSairClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    function fGetApi(tabela: string; Campo: String; Condicao: String = ''): string;
    function fAbreTabelaAqrquivoAPI: String;
    procedure LoadJSONToList(const JSONString: string; List: TObjectList<TAtleta>);
    function fPostApi(tabela, Campos: String): boolean;
    procedure EncheCombos;
    procedure Log(texto: String);
    function PegaAtleta(id: integer): TAtleta;
  public
    { Public declarations }
  end;

var
  Form2: TForm2;
  Selecionados: TSelecionadosArray;
  ListaAtletas : TAtletasArray;


Const
   ApiKey  = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN3aHVua2tuZWd0dm9kaGF3dmx3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjExNTU2OTksImV4cCI6MjAzNjczMTY5OX0.CpPU_zAqYY803HWWAhpdSqGg_WZiNka5HR3_W6W0mvo';
   BaseURL = 'https://swhunkknegtvodhawvlw.supabase.co';
   senhabd = 'V2gTvsgwwNYlaJh1';

implementation

{$R *.fmx}
{$R *.LgXhdpiTb.fmx ANDROID}
{$R *.Surface.fmx MSWINDOWS}
{$R *.Windows.fmx MSWINDOWS}
{$R *.LgXhdpiPh.fmx ANDROID}
{$R *.NmXhdpiPh.fmx ANDROID}
{$R *.iPhone55in.fmx IOS}

procedure TForm2.Log(texto : String);
Begin
  Memo1.lines.add(texto);
  Application.ProcessMessages;
End;


procedure TForm2.LoadJSONToList(const JSONString: string; List: TObjectList<TAtleta>);
var
  JSONArray: TJSONArray;
  JSONValue: TJSONValue;
  JSONObject: TJSONObject;
  AtletaItem: TAtleta;
  Data: TDateTime;
begin
  JSONArray := TJSONObject.ParseJSONValue(JSONString) as TJSONArray;
  try
    for JSONValue in JSONArray do
    begin
      JSONObject := JSONValue as TJSONObject;
      AtletaItem := TAtleta.Create;
      try
        AtletaItem.Id := JSONObject.GetValue<Integer>('id');
        AtletaItem.Nome := JSONObject.GetValue<string>('nome');
        AtletaItem.Ranking := JSONObject.GetValue<Integer>('ranking');
//        AtletaItem.Versao := JSONObject.GetValue<string>('versao');
//        if TryISO8601ToDate(JSONObject.GetValue<string>('data'), Data) then
//          AtletaItem.Data := Data;
//        AtletaItem.ArqMd5 := JSONObject.GetValue<string>('arq_md5');
        List.Add(AtletaItem);
      except
        AtletaItem.Free;
        raise;
      end;
    end;
  finally
    JSONArray.Free;
  end;
end;

procedure TForm2.Timer1Timer(Sender: TObject);
begin
timer1.Enabled:=False;
EncheCombos();
{$IFDEF DEBUG}
Combobox1.ItemIndex:=1;
Combobox2.ItemIndex:=2;
Combobox3.ItemIndex:=3;
Combobox4.ItemIndex:=4;
{$ENDIF}

end;

procedure TForm2.EncheCombos();
var
  JSONString: string;
  Records: TObjectList<TAtleta>;
  I: Integer;

  TempDirVV : String;
  ExeBdMD5,ExeWebMD5 : String;

  procedure EncheCombo(ComboBox: TComboBox);
  begin
    ComboBox.Items.Add(Records[I].Nome + ' - ' + IntToStr(Records[I].Ranking));
    ComboBox.Items.Objects[ComboBox.Items.Count - 1] := TObject(Records[I].Id);
  end;
Begin
   JSONString := fAbreTabelaAqrquivoAPI();
   Records := TObjectList<TAtleta>.Create;
     try
       LoadJSONToList(JSONString, Records);
       // Navegando pelos registros
       for I := 0 to Records.Count - 1 do
          begin
          EncheCombo(ComboBox1);
          EncheCombo(ComboBox2);
          EncheCombo(ComboBox3);
          EncheCombo(ComboBox4);
          ListaAtletas[i] := TAtleta.Create;
          ListaAtletas[i].id:= Records[i].id;
          ListaAtletas[i].Nome:= Records[i].Nome;
          ListaAtletas[i].Ranking:= Records[i].Ranking;
          end;
     finally
       Records.Free;
     end;
end;


procedure TForm2.btConfirmarClick(Sender: TObject);
Var
campos,confere, idjogo : string;
i : integer;

    Procedure GravaSequencia(seq : integer; SeqAtleta:string; ResA,ResB:tNumberBox);
    Var
    y : integer;
    idSeq : string;
    Begin
    //gravando jogo_sequencia id_jogo sequencia pontos_a pontos_b
    //Sequencia1
    campos:=' "id_jogo": "'+idJogo+'", ';
    campos:= campos+' "sequencia": "'+IntToStr(seq)+'", ';
    campos:= campos+'  "pontos_a": "'+FloatToStr(ResA.Value)+'", ';
    campos:= campos+'  "pontos_b": "'+FloatToStr(ResB.Value)+'" ';
    campos:= '{ '+campos+' }';
    fPostApi('jogo_sequencia',campos);
    idSeq:= fGetApi('jogo_sequencia','id','id_jogo=eq.'+idJogo+'&sequencia=eq.'+IntToStr(seq));

    for y:=0 to 3 do //grava os 4 atletas por sequencia, 1 em cada registro, ficara mais facil somar depoi
       Begin
        //gravando jogo_sequencia_atleta id_jogo_sequencia id_atleta pontos_ranking
        campos:=' "id_jogo_sequencia": "'+idSeq+'", ';
        campos:= campos+'  "id_atleta": "'+IntToStr(Selecionados[StrToInt(SeqAtleta[y+1])].Id)+'", ';
        if y<2 then
          campos:= campos+'  "pontos_ranking": "'+IntToStr(ResA.Tag)+'" '
          else
          campos:= campos+'  "pontos_ranking": "'+IntToStr(ResB.Tag)+'" ';
        campos:= '{ '+campos+' }';
        fPostApi('jogo_sequencia_atleta',campos);
       End;
    End;
begin

//o campo confere do jogo vai ser os 4 id dos jogadores + final 24
//exemplo 3 + 7 + 14 + 4 precisa ordenar
//confere = 003+004+007+014+24
confere := FormatFloat('000', Selecionados[0].ID)+
           FormatFloat('000', Selecionados[1].ID)+
           FormatFloat('000', Selecionados[2].ID)+
           FormatFloat('000', Selecionados[3].ID)+'24';
//gravando jogo
fPostApi('jogo','{ "confere": "'+confere+'" }');
idJogo:= fGetApi('jogo','id','confere=eq.'+confere );

//gravando jogo_atleta ID id_jogo  id_atleta ranking_inicio
for i:=0 to 3 do
     Begin
      campos:=' "id_jogo": "'+idJogo+'", ';
      campos:= campos+' "id_atleta": "'+IntToStr(Selecionados[i].Id)+'", ';
      campos:= campos+'  "ranking_inicio": "'+IntToStr(Selecionados[i].Ranking)+'" ';
      campos:= '{ '+campos+' }';
      fPostApi('jogo_atleta',campos);
     End;

GravaSequencia(1, '0123',resDupla1,resDupla2);
GravaSequencia(2, '0321',resDupla3,resDupla4);
GravaSequencia(3, '0231',resDupla5,resDupla6);

ShowMessage('Gravado com sucesso!!!');
end;

Function TForm2.PegaAtleta(id:integer):TAtleta;
Var
i : integer;
AtletaItem : TAtleta;
Begin
    try
     AtletaItem := TAtleta.Create;

     for I := 0 to 1000 - 1 do
        begin
        if id = ListaAtletas[i].Id then
           Begin
           AtletaItem := ListaAtletas[i];
           result:= AtletaItem;
           break;
           End;
        end;
    except
      AtletaItem.Free;
      raise;
    end;
End;

procedure TForm2.Button1Click(Sender: TObject);
var
  HTTPClient: THTTPClient;
  RequestBody: TStringStream;
  Response: IHTTPResponse;
  JsonObj: TJSONObject;
  SequenciasArray: TJSONArray;
  SequenciaObj: TJSONObject;
  AtletasArray: TJSONArray;
  AtletaObj: TJSONObject;
begin
  HTTPClient := THTTPClient.Create;
  try
    HTTPClient.CustomHeaders['apikey'] := ApiKey;
    HTTPClient.CustomHeaders['Accept'] := 'application/json';
    HTTPClient.CustomHeaders['Content-Type'] := 'application/json';
    HTTPClient.SecureProtocols := [THTTPSecureProtocol.TLS12];

    JsonObj := TJSONObject.Create;
    try
      JsonObj.AddPair('p_confere', '001002003004');
      JsonObj.AddPair('p_data_jogo', '2023-07-20');

      SequenciasArray := TJSONArray.Create;

      // Adicione o conteúdo JSON correspondente às sequências
      SequenciaObj := TJSONObject.Create;
      SequenciaObj.AddPair('sequencia', TJSONNumber.Create(1));
      SequenciaObj.AddPair('pontos_a', TJSONNumber.Create(10));
      SequenciaObj.AddPair('pontos_b', TJSONNumber.Create(20));

      AtletasArray := TJSONArray.Create;
      AtletaObj := TJSONObject.Create;
      AtletaObj.AddPair('id_atleta', TJSONNumber.Create(1));
      AtletaObj.AddPair('pontos_ranking', TJSONNumber.Create(30));
      AtletasArray.AddElement(AtletaObj);

      AtletaObj := TJSONObject.Create;
      AtletaObj.AddPair('id_atleta', TJSONNumber.Create(2));
      AtletaObj.AddPair('pontos_ranking', TJSONNumber.Create(40));
      AtletasArray.AddElement(AtletaObj);

      SequenciaObj.AddPair('atletas', AtletasArray);
      SequenciasArray.AddElement(SequenciaObj);

      // Continue adicionando outras sequências conforme necessário

      JsonObj.AddPair('p_sequencias', SequenciasArray);

      RequestBody := TStringStream.Create(JsonObj.ToJSON, TEncoding.UTF8);
      try
        Response := HTTPClient.Post(BaseURL+'/rest/v1/rpc/inserir_jogo_e_sequencias', RequestBody);

        if Response.StatusCode = 204 then
        begin
          // Processar a resposta se necessário
          Log('Gravado com sucesso! '+Response.ContentAsString);
        end
        else
        begin
          // Tratar erros
          Log('Erro: ' +IntToStr(Response.StatusCode)+'-'+ Response.StatusText +#13+Response.ContentAsString);
        end;
      finally
        RequestBody.Free;
      end;
    finally
      JsonObj.Free;
    end;
  finally
    HTTPClient.Free;
  end;
end;


procedure TForm2.Button2Click(Sender: TObject);
Var
idJogo,confere : String;

    function HasDuplicateIDs(const Item: TSelecionadosArray): Boolean;
    var
      IDs: TDictionary<Integer, Boolean>;
      Person: TAtleta;
    begin
      Result := False;
      IDs := TDictionary<Integer, Boolean>.Create;
      try
        for Person in Item do
        begin
          if IDs.ContainsKey(Person.ID) then
          begin
            Result := True;
            Exit;
          end
          else
          begin
            IDs.Add(Person.ID, True);
          end;
        end;
      finally
        IDs.Free;
      end;
    end;

    procedure Ordena(var Item: TSelecionadosArray);
    var
      I, J: Integer;
      Key: TAtleta;
    begin
      for I := 1 to High(Item) do
      begin
        Key := Item[I];
        J := I - 1;
        while (J >= 0) and (Item[J].ID > Key.ID) do
        begin
          Item[J + 1] := Item[J];
          Dec(J);
        end;
        Item[J + 1] := Key;
      end;
    end;

begin

pnConfirma.Visible:=False;
pnJogos.Visible := False;
ResDupla1.Value:=0;
ResDupla2.Value:=0;
ResDupla3.Value:=0;
ResDupla4.Value:=0;
ResDupla5.Value:=0;
ResDupla6.Value:=0;
lbDupla1.Text := '';
lbDupla2.Text := '';
lbDupla3.Text := '';
lbDupla4.Text := '';
lbDupla5.Text := '';
lbDupla6.Text := '';


if (ComboBox1.ItemIndex<0) or
   (ComboBox2.ItemIndex<0) or
   (ComboBox3.ItemIndex<0) or
   (ComboBox4.ItemIndex<0) then
   Begin
   ShowMEssage('Precisa selecionar todos os jogadores!' );
   exit;
   End;




Selecionados[0] := PegaAtleta(Integer(ComboBox1.Items.Objects[ComboBox1.ItemIndex]));
Selecionados[1] := PegaAtleta(Integer(ComboBox2.Items.Objects[ComboBox2.ItemIndex]));
Selecionados[2] := PegaAtleta(Integer(ComboBox3.Items.Objects[ComboBox3.ItemIndex]));
Selecionados[3] := PegaAtleta(Integer(ComboBox4.Items.Objects[ComboBox4.ItemIndex]));

if HasDuplicateIDs(Selecionados) then
   Begin
   ShowMEssage('Selecione Jogadores Diferentes');
   exit;
   end;

Ordena(Selecionados);

//verificar se quarteto ja jogou
//o campo confere do jogo vai ser os 4 id dos jogadores+final 24
//exemplo 3 + 7 + 14 + 4 precisa ordenar
//confere = 003+004+007+014+24
confere := FormatFloat('000', Selecionados[0].ID)+
           FormatFloat('000', Selecionados[1].ID)+
           FormatFloat('000', Selecionados[2].ID)+
           FormatFloat('000', Selecionados[3].ID)+'24';
idJogo:= fGetApi('jogo','id','confere=eq.'+confere );
if idjogo <> '' then
   Begin
   ShowMessage('Esses 4 ja jogaram !');
   exit;
   end;

lbDupla1.Text := Selecionados[0].Nome+'/'+Selecionados[1].Nome+#13+'Ranking '+IntToStr(Selecionados[0].Ranking+Selecionados[1].Ranking);
lbDupla1.Hint := Selecionados[0].Nome+'/'+Selecionados[1].Nome;
lbDupla2.Text := Selecionados[2].Nome+'/'+Selecionados[3].Nome+#13+'Ranking '+IntToStr(Selecionados[2].Ranking+Selecionados[3].Ranking);
lbDupla2.Hint := Selecionados[2].Nome+'/'+Selecionados[3].Nome;

lbDupla3.Text := Selecionados[0].Nome+'/'+Selecionados[3].Nome+#13+'Ranking '+IntToStr(Selecionados[0].Ranking+Selecionados[3].Ranking);
lbDupla3.Hint := Selecionados[0].Nome+'/'+Selecionados[3].Nome;
lbDupla4.Text := Selecionados[2].Nome+'/'+Selecionados[1].Nome+#13+'Ranking '+IntToStr(Selecionados[2].Ranking+Selecionados[1].Ranking);
lbDupla4.Hint := Selecionados[2].Nome+'/'+Selecionados[1].Nome;

lbDupla5.Text := Selecionados[0].Nome+'/'+Selecionados[2].Nome+#13+'Ranking '+IntToStr(Selecionados[0].Ranking+Selecionados[2].Ranking);
lbDupla5.Hint := Selecionados[0].Nome+'/'+Selecionados[2].Nome;
lbDupla6.Text := Selecionados[3].Nome+'/'+Selecionados[1].Nome+#13+'Ranking '+IntToStr(Selecionados[3].Ranking+Selecionados[1].Ranking);
lbDupla6.Hint := Selecionados[3].Nome+'/'+Selecionados[1].Nome;
pnJogos.Visible := True;

{$IFDEF DEBUG}
ResDupla1.Value:=15;
ResDupla2.Value:=8;
ResDupla3.Value:=8;
ResDupla4.Value:=15;
ResDupla5.Value:=17;
ResDupla6.Value:=15;
{$ENDIF}
end;

procedure TForm2.btnPreparaGravacaoClick(Sender: TObject);
Var
max : integer;
IndiceA, IndiceB : Extended;
RankingA, RankingB  : String;

  function fnDiferenca(Valor1, Valor2: double; baixo, alto: Integer): Boolean;
  var
    diferenca: Integer;
  begin
    diferenca := trunc(Valor1) - Trunc(Valor2);
    Result := (diferenca >= baixo) and (diferenca <= alto);
  end;

  function Enche(const S: string; Tamanho: Integer; Lado : string): string;
  begin
    Result := S;
    while Length(Result) < Tamanho do
      if lado='direita' then
         Result := Result + ' '
         else
         Result := ' ' + Result;
  end;

  Function PegaTamanhoMaximo():integer;
  Var
  Maximo : Integer;
  Begin
  Maximo:= Length(lbDupla1.hint);
  if Length(lbDupla2.hint)>Maximo then
     Maximo:= Length(lbDupla2.hint);
  if Length(lbDupla3.hint)>Maximo then
     Maximo:= Length(lbDupla3.hint);
  if Length(lbDupla4.hint)>Maximo then
     Maximo:= Length(lbDupla4.hint);
  if Length(lbDupla5.hint)>Maximo then
     Maximo:= Length(lbDupla5.hint);
  if Length(lbDupla6.hint)>Maximo then
     Maximo:= Length(lbDupla6.hint);
  Result := Maximo;
  End;

  Procedure CalculaInidice(A,B,C,D : Integer; ValorAb, ValorCD : Integer; Var ResA,ResB : TNumberBox);
  Begin
  ResA.Tag:=0;
  ResB.Tag:=0;
  if Selecionados[A].Ranking+Selecionados[B].Ranking = Selecionados[C].Ranking+Selecionados[D].Ranking then
     Begin
     IndiceA := 1;
     IndiceB := 1;
     end else
     if Selecionados[A].Ranking+Selecionados[B].Ranking > Selecionados[C].Ranking+Selecionados[D].Ranking then
        Begin
         IndiceA := (Selecionados[C].Ranking+Selecionados[D].Ranking) / (Selecionados[A].Ranking+Selecionados[B].Ranking);
         IndiceB := (Selecionados[A].Ranking+Selecionados[B].Ranking) / (Selecionados[C].Ranking+Selecionados[D].Ranking);
        end else
        Begin
        IndiceA := (Selecionados[A].Ranking+Selecionados[B].Ranking) / (Selecionados[C].Ranking+Selecionados[D].Ranking);
        IndiceB := (Selecionados[C].Ranking+Selecionados[D].Ranking) / (Selecionados[A].Ranking+Selecionados[B].Ranking);
        end;
  if ValorAb > ValorCD then
     Begin
     RankingA := ' +'+FormatFloat('00',(ValorAb - ValorCD)*IndiceA);
     RankingB := ' .';
     ResA.Tag:=Trunc((ValorAb - ValorCD)*IndiceA);
     End else
     Begin
     RankingA := ' .';
     RankingB := ' +'+FormatFloat('00',(ValorCD - ValorAb)*IndiceB);
     ResB.Tag:=Trunc((ValorCD - ValorAb)*IndiceB);
     end;
  End;

begin
pnConfirma.Visible:=False;
//verificando se todos os jogos alcaram >=15 pontos
if (resDupla1.Value+resDupla2.Value<15) or
   (resDupla3.Value+resDupla4.Value<15) or
   (resDupla5.Value+resDupla6.Value<15) or
   (not(fnDiferenca(resDupla1.Value,resDupla2.Value,-15,15))) or
   (not(fnDiferenca(resDupla3.Value,resDupla4.Value,-15,15))) or
   (not(fnDiferenca(resDupla5.Value,resDupla6.Value,-15,15))) or
   (fnDiferenca(resDupla1.Value,resDupla2.Value,-1,1)) or
   (fnDiferenca(resDupla3.Value,resDupla4.Value,-1,1)) or
   (fnDiferenca(resDupla5.Value,resDupla6.Value,-1,1)) then
   Begin
   ShowMessage('Pontuação errada!');
   exit;
   End;
max:= PegaTamanhoMaximo()+1;

//Calculando
//Sequencia 1   0/1 x 2/3
CalculaInidice(0,1,2,3,Trunc(resDupla1.Value),Trunc(resDupla2.Value),resDupla1,resDupla2);
lbSeq1.Text := Enche(lbDupla1.hint,max,'direita')+' '+FormatFloat('00',resDupla1.Value)+' X '+FormatFloat('00',resDupla2.Value)+Enche(lbDupla2.hint,max,'esquerda');
lbRan1.Text := Enche(RankingA ,max,'direita')+'        '+ Enche(RankingB,max,'esquerda');

//Sequencia 2   0/3 x 2/1
CalculaInidice(0,3,2,1,Trunc(resDupla3.Value),Trunc(resDupla4.Value),resDupla3,resDupla4);
lbSeq2.Text := Enche(lbDupla3.hint,max,'direita')+' '+FormatFloat('00',resDupla3.Value)+' X '+FormatFloat('00',resDupla4.Value)+Enche(lbDupla4.hint,max,'esquerda');
lbRan2.Text := Enche(RankingA ,max,'direita')+'        '+ Enche(RankingB,max,'esquerda');

//Sequencia 3   0/2 x 3/1
CalculaInidice(0,2,3,1,Trunc(resDupla5.Value),Trunc(resDupla6.Value),resDupla5,resDupla6);
lbSeq3.Text := Enche(lbDupla5.hint,max,'direita')+' '+FormatFloat('00',resDupla5.Value)+' X '+FormatFloat('00',resDupla6.Value)+Enche(lbDupla6.hint,max,'esquerda');
lbRan3.Text := Enche(RankingA ,max,'direita')+'        '+ Enche(RankingB,max,'esquerda');

pnConfirma.Visible:=True;
end;

procedure TForm2.btSairClick(Sender: TObject);
begin
Close();
end;

function TForm2.fAbreTabelaAqrquivoAPI(): String;
var
  jsonArray: TJSONArray;
  jsonObject: TJSONObject;
  JsonRet: TJSONObject;
  Valor : String;

  HTTPClient: THTTPClient;
  Response: IHTTPResponse;
begin
result := '';
    try
    HTTPClient := THTTPClient.Create;
    HTTPClient.CustomHeaders['apikey'] := ApiKey;
    HTTPClient.CustomHeaders['Accept'] := 'application/json';
    HTTPClient.SecureProtocols := [THTTPSecureProtocol.TLS12];
//    Response := HTTPClient.Get(BaseURL+'/rest/v1/atleta?&select=*');
    Response := HTTPClient.Get(BaseURL+'/rest/v1/rpc/get_atleta_details');
    if Response.StatusCode.ToString='200' then
       result := Response.ContentAsString;
    except on ex:exception do
      begin
      Log(FormatDateTime('hh:nn:ss', Now()) + ' Erro fAbreTabelaAqrquivoAPI: ' + ex.Message);
      exit;
      end;
    end;
  Log(FormatDateTime('hh:nn:ss', Now()) + ' Busca de Jogadores OK = ' + Response.StatusCode.ToString );
end;

function TForm2.fPostApi(tabela: string; Campos: String): boolean;
var
  Response: IHTTPResponse;
  HTTPClient: THTTPClient;
  RequestBody: TStringStream;
Begin
result := false;
try
  try
  HTTPClient := THTTPClient.Create;
  HTTPClient.CustomHeaders['apikey'] := ApiKey;
  HTTPClient.CustomHeaders['Accept'] := 'application/json';
  HTTPClient.SecureProtocols := [THTTPSecureProtocol.TLS12];
  RequestBody := TStringStream.Create(Campos, TEncoding.UTF8);
  Response := HTTPClient.Post(BaseURL + '/rest/v1/' + Tabela, RequestBody, nil, [TNetHeader.Create('Content-Type', 'application/json')]);
  if Response.StatusCode = 201 then
     Begin
     Result:=true;
     Log(FormatDateTime('hh:nn:ss', Now()) + ' Gravado : '+Response.StatusCode.ToString +' '+Response.ContentAsString(TEncoding.UTF8));
     end else
     Begin
     Log(FormatDateTime('hh:nn:ss', Now()) + ' Erro fPostApi HTTP: ' + Response.StatusText);
     End;
  except
    on e: exception do
       Begin
       Log(FormatDateTime('hh:nn:ss', Now()) + ' Falha no fPostApi '+campos+' Motivo ... ' + e.Message);
       End;
  end;
finally
  RequestBody.Free;
  HTTPClient.Free;
end;
End;

function TForm2.fGetApi(tabela: string; Campo: String; Condicao: String = ''): string;
var
  jsonArray: TJSONArray;
  jsonObject: TJSONObject;
  JsonRet: TJSONObject;
  Valor : String;

  HTTPClient: THTTPClient;
  Response: IHTTPResponse;
begin
result := '';
  try
    try
    HTTPClient := THTTPClient.Create;
    HTTPClient.CustomHeaders['apikey'] := ApiKey;
    HTTPClient.CustomHeaders['Accept'] := 'application/json';
    HTTPClient.SecureProtocols := [THTTPSecureProtocol.TLS12];
    Response := HTTPClient.Get(BaseURL+'/rest/v1/'+tabela+'?'+condicao+'&select='+Campo);
    except on ex:exception do
      begin
      Log(FormatDateTime('hh:nn:ss', Now()) + ' Erro fGetApi: ' + ex.Message);
      exit;
      end;
    end;
  Log(FormatDateTime('hh:nn:ss', Now()) + ' Busca OK : ' + Response.StatusCode.ToString);

  if Response.StatusCode.ToSingle = 400 then
     exit;

  if Response.ContentAsString= '[]' then  //isso acontece quando nao encontra o registro ou nao tem permissao
     exit;

    try
      jsonArray := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(Response.ContentAsString(TEncoding.UTF8)), 0) as TJSONArray;
      jsonObject := jsonArray.Items[0] as TJSONObject;
      if NOT Assigned(jsonObject) then
         Begin
         Log(FormatDateTime('hh:nn:ss', Now()) + ' Não foi possível verificar o retorno do servidor (JSON inválido)');
         End;
    except on ex:exception do
      begin
      Log(FormatDateTime('hh:nn:ss', Now()) + ' '+ex.Message);
      end;
    end;
    Application.ProcessMessages;

  if jsonObject.TryGetValue('error', JsonRet) then
     begin
      Log(FormatDateTime('hh:nn:ss', Now()) + ' jsonObject.TryGetValue(error, JsonRet) '+jsonRet.Values['message'].Value);
      exit;
     end;

  if jsonObject.TryGetValue(campo, valor) then
     begin
     result :=valor;
      if valor='null' then
         result := '';
     end else
     Begin
     Log(FormatDateTime('hh:nn:ss', Now()) + ' jsonObject.TryGetValue(campo, valor) '+Response.StatusCode.ToString +' '+Response.ContentAsString);
     End;
  finally
  if Assigned(jsonObject) then
     Begin
     jsonObject := nil;
     FreeAndNil(jsonObject);
     End;
  if Assigned(JsonRet) then
     Begin
     JsonRet := nil;
     FreeAndNil(JsonRet);
     End;
  if Assigned(jsonArray) then
     Begin
     jsonArray := nil;
     FreeAndNil(jsonArray);
     End;
     //jsonArray.Free; // só funciona com .free no VCL

  HTTPClient.Free;
  end;
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
pnConfirma.Visible:=False;
pnJogos.Visible := False;
end;

end.
