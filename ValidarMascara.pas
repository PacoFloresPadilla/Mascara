{*

 Mascara de captura

 Clase genereda para validar la captura de caracteres en un texto con forma,
 tamaño  y campos especificos.  Se realiza un validación en tiempo real y
 otra al salir del texto.

.
  @Author INEGI
  @Version 1.0.0.8
}

unit ValidarMascara;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,StrUtils;

type
  Tmask=class
  function ObtenerMarcadores(s : String): String;
  function MarcadoresAnteriores(pos : Integer):Integer;
  function PosicionMarcadorIzq(texto : String; marcasAnteriores : Integer):Integer;
  function SaltarMarcadoresDer(texto : String; posCasillaInicial : Integer):Integer;
  function SaltarMarcadoresIzq(texto : String; posCasillaInicial : Integer):Integer;
  function ContarLetrasEntreMarcadores(texto : String; MarcasAnteriores : Integer):Integer;
  function PosicionMarcadorTextoIzq(marcasAnteriores : Integer):Integer;
  function SaltarMarcadoresTextoDer(posCasillaInicial : Integer):Integer;
  function SaltarMarcadoresTextoIzq(posCasillaInicial : Integer):Integer;
  function ContarLetrasEntreMarcadoresTexto(MarcasAnteriores : Integer):Integer;
  function CaracterInvalido(input, maskedChar : Char):Boolean;
  function EsMarcador(letra : Char):Boolean;
  function EsPermitido(letra : Char):Boolean;
  procedure Eliminar(var posicion: Integer; var texto : String);
  procedure EliminarMultiples(var posicion: Integer; cantidad : Integer; var texto : String);
  procedure Suprimir(var posicion: Integer; selCount : Integer; var texto : String);
  function Agregar(var posicion : Integer;key : Char ;mascara:String; var texto : String; recursivo : Boolean = False):Boolean;
  procedure TeclaPresionada(var posicion : Integer; selCount : Integer; key : Char ;mascara:String; var texto : String );
  function ValidarTexto(mascara, texto : String) : Boolean;

  private
    const ValoresRyP : String = 'LlAa09#';
    const ValoresPermitidos : String = 'la9#';
    const ok : Char = '1';
    const ng : Char = '0';
  public
  end;


  var
    bufferPosicion : Integer = 0;
    markups, bandMarcadores : String;

implementation



{*
  Funcion para obtener todos los marcadores o caracteres constantes dentro de una
  cadena de texto predefina.  El algóritmo requiere de una bandera que concentre
  todos los marcadores con el mismo caracter para distinguir entre los
  marcadores iniciales y los que se introduzcan como texto variable.

  @param s Cadena con la mascara de control.
  @return Marcadores incluidos en la cadenas.
}
function Tmask.ObtenerMarcadores(s : String): String;
var
  i,j,counter:Integer;
begin
  counter:=0;
  markups := '';
  bandMarcadores := '';
  for i := 1 to Length(s) do
  begin
    if not ContainsText(ValoresRyP,s[i]) then
    begin
      inc(counter);
      Insert(s[i], markups, counter);  //Llenar dinamicamente los marcadores
      Insert(ok, bandMarcadores, counter);//Crear bandera de marcadores
    end;
  end;//s

  result := markups;
end;
{*
Contar los marcadores anterioriores que aparecen en la bandera
de los marcadores.}
function Tmask.MarcadoresAnteriores(pos : Integer):Integer;
var
  i: Integer;
begin
 result := 0;
  for i := 1 to pos - 1 do
    if bandMarcadores[i] = ok then
      inc(result);
end;

{*
Detectar la posición del marcador izquierdo que corresponda con los marcadores
anteriores en la bandera de marcadores.}
function Tmask.PosicionMarcadorTextoIzq(marcasAnteriores : Integer):Integer;
var
marcasMascara,i :Integer;
begin
    marcasMascara := 0;
    result := 0;
    if  ((Length(bandMarcadores) = 0) or (marcasAnteriores = 0)) then result := 1
    else
    begin
      for i := 1 to Length(bandMarcadores) do
      begin
        if bandMarcadores[i] = ok then
          inc(marcasMascara);
        if marcasMascara = marcasAnteriores then
        begin
          result:= i;//Detecta posición en la bandera del texto
          break;
        end;
      end;
    end;
end;

{*
Detectar la posición del marcador izquierdo que corresponda con los marcadores
anteriores en la mascara.

@param  texto Texto a procesar
@param  marcasAnteriores Cantidad de marcas a la izquierda del cursor
}
function Tmask.PosicionMarcadorIzq(texto : String; marcasAnteriores : Integer):Integer;
var
marcasMascara,i :Integer;
begin
    marcasMascara := 0;
    result := 0;
    if  ((Length(texto) = 0) or (marcasAnteriores = 0)) then result := 1
    else
    begin
      for i := 1 to Length(texto) do
      begin
        if EsMarcador(texto[i]) then
          inc(marcasMascara);
        if marcasMascara = marcasAnteriores then
        begin
          result:= i;//Detecta posición en el texto
          break;
        end;
      end;
    end;
end;

{*
Conteo de marcadores encontrados en la posicion actual, el ciclo aumenta el valor
por cada marcador contiguo en la mascara encontrado a la derecha}

function Tmask.SaltarMarcadoresDer(texto : String; posCasillaInicial : Integer):Integer;
var
i : Integer;
begin
    result := 0;
    for i := posCasillaInicial  to length(texto) do
        if EsMarcador(texto[i]) then
          inc(result)
        else
          break;
end;


{*
Conteo de marcadores encontrados en la posicion actual, el ciclo aumenta el valor
por cada marcador contiguo en la bandera de Marcadores encontrado a la derecha}

function Tmask.SaltarMarcadoresTextoDer(posCasillaInicial : Integer):Integer;
var
i : Integer;
begin
  result := 0;
  if bandMarcadores <> '' then
  begin
    for i := posCasillaInicial  to length(bandMarcadores) do
        if bandMarcadores[i] = ok then
          inc(result)
        else
          break;
  end;
end;

{*
Conteo de marcadores encontrados en la posicion actual, el ciclo aumenta el valor
por cada marcador contiguo en la mascara encontrado a la izquierda}
function Tmask.SaltarMarcadoresIzq(texto : String; posCasillaInicial : Integer):Integer;
var
i : Integer;
begin
    result := 0;
    for i := posCasillaInicial downto 1  do
        if EsMarcador(texto[i]) then
          inc(result)
        else
          break;
end;

{*
 Conteo de marcadores encontrados en la posicion actual, el ciclo aumenta el valor
por cada marcador contiguo en la bandera de Marcadores encontrado a la izquierda}
function Tmask.SaltarMarcadoresTextoIzq(posCasillaInicial : Integer):Integer;
var
i : Integer;
begin
  result := 0;
  if bandMarcadores <> '' then
  begin
    for i := posCasillaInicial downto 1  do
        if bandMarcadores[i] = ok then
          inc(result)
        else
          break;
  end;
end;

{*
Contador de espacios detectados entre dos marcadores de la mascara, tomando como referencia
las marcas anteriores detectadas en el texto}
function Tmask.ContarLetrasEntreMarcadores(texto : String; MarcasAnteriores : Integer):Integer;
var
marcasMascara,i : Integer;
begin
      marcasMascara := 0;
      result  := 0;
      for i := 1 to Length(texto) do
      begin
        if EsMarcador(texto[i]) then
          inc(marcasMascara);
        if marcasMascara = marcasAnteriores then
          if not( EsMarcador(texto[i])) then inc(result);
      end;
end;

{*
Contador de espacios detectados entre dos marcadores de la bandera de marcadores,
 tomando como referencia las marcas anteriores detectadas en el texto}
function Tmask.ContarLetrasEntreMarcadoresTexto(MarcasAnteriores : Integer):Integer;
var
marcasMascara,i : Integer;
begin
      marcasMascara := 0;
      result  := 0;
      for i := 1 to Length(bandMarcadores) do
      begin
        if bandMarcadores[i] = ok then
          inc(marcasMascara);
        if marcasMascara = marcasAnteriores then
          if not( bandMarcadores[i]= ok) then
             inc(result);
      end;
end;


{*
Comparación simple entre un caracter de entrada y el caracter correspondiente
a la mascara.}
function Tmask.CaracterInvalido(input, maskedChar : Char):Boolean;
begin
  result := True;
  case maskedChar of
    '0': if (input in ['0'..'9']) then result := False;
    '9': if (input in ['0'..'9']) then result := False;
    '#': if (input in ['0'..'9','+','-']) then result := False;
    'L': if (input in ['a'..'z','A'..'Z', 'ñ', 'Ñ']) then result := False;
    'l': if (input in ['a'..'z','A'..'Z', 'ñ', 'Ñ']) then result := False;
    'A': if (input in ['a'..'z','A'..'Z','0'..'9', 'ñ', 'Ñ']) then result := False;
    'a': if (input in ['a'..'z','A'..'Z','0'..'9', 'ñ', 'Ñ']) then result := False;
  else
    if EsMarcador(input) then       //Utilizado para la validación
      result := False;
  end;
end;

{*
Función para detectar cuando un caracter forma parte de los marcadores detectados
en la mascara}
function Tmask.EsMarcador(letra : Char):Boolean;
begin
  result := AnsiContainsStr(markups,letra);
end;

{*
Función para detectar cuando un caracter es de un tipo permitido en la mascara,
su función es especifica para la validación final de la cadena}
function Tmask.EsPermitido(letra : Char):Boolean;
begin
  result := AnsiContainsStr(ValoresPermitidos,letra);
end;

{*
Selector inicial del metodo a lanzar, depende de la tecla presionada}
procedure Tmask.TeclaPresionada(var posicion: Integer;selCount : Integer; key: Char; mascara: String;
  var texto: String);
begin
  if (key = #8)  then
    case selCount of
    0: Eliminar(posicion,texto);
    else
    EliminarMultiples(posicion,selCount,texto)
    end
  else
  begin
    inc(posicion);
    Agregar(posicion,key,mascara,texto);
  end;

end;


{*
Función para eliminar un caracter único en el texto de entrada, la función
calcula cuando marcadores hay a la izquierda y desplaza la posición hasta la ubicación
del proximo caracter variable}
procedure Tmask.Eliminar(var posicion: Integer; var texto : String);
var
  saltaMarcadores : Integer;
begin
  if (texto <> '') then
  begin
  saltaMarcadores := SaltarMarcadoresTextoIzq(posicion); //Detecta cuantos marcadores se deben saltar
  posicion := posicion - saltaMarcadores;//Avanza el cursor los espacios necesarios para saltar los marcadores

  if bandMarcadores = '' then
    Delete(texto,posicion,1)
  else
  if not(bandMarcadores[posicion] = ok) then
  begin
    Delete(texto,posicion,1);
    Delete(bandMarcadores, posicion,1);
  end;
  dec(posicion);
  end;
end;


{*
Funcion para eliminar mas de un caracter, el ciclo almacena en la memoria
la bandera de posición para saltar los marcadores necesarios y a su vez borrar
los caracteres variables del texto y de la bandera de posición del grupo seleccionado}
procedure Tmask.EliminarMultiples(var posicion: Integer; cantidad : Integer; var texto : String);
var
  i, posFinal,eliminados : Integer;
  bufferText : String;
begin
  if (texto <> '') then
  begin
    inc(posicion);
    posFinal := cantidad + posicion - 1;
    bufferText := bandMarcadores;
    eliminados := 0;
    if bandMarcadores = '' then
    begin
      for i := posicion to posFinal do
      begin
        Delete(Texto,i - eliminados, 1);
        inc(eliminados);
      end;
    end
    else
    for i := posicion to posFinal do
      if not(bufferText[i] = ok) then
      begin
        Delete(Texto,i - eliminados, 1);
        Delete(bandMarcadores, i - eliminados,1);
        inc(eliminados);
      end;
  dec(posicion);
  end;
end;

{*
Función para suprimir un caracter único en el texto de entrada, la función
calcula cuando marcadores hay a la derecha y desplaza la posición hasta la ubicación
del proximo caracter variable, en caso de tener mas de uno seleccionado se llama
a la función EliminarMultiples}
procedure Tmask.Suprimir(var posicion: Integer; selCount : Integer; var texto : String);
var
  saltaMarcadores : Integer;
begin
  if (texto <> '') then
  begin
    if selCount > 0 then
      EliminarMultiples(posicion,selCount,texto)
    else
    begin
      inc(posicion);
      saltaMarcadores := SaltarMarcadoresTextoDer(posicion); //Detecta cuantos marcadores se deben saltar
      posicion := posicion + saltaMarcadores;//Avanza el cursor los espacios necesarios para saltar los marcadores
      if bandMarcadores = '' then
        Delete(texto,posicion,1)
      else
      if not( bandMarcadores[posicion] = ok) then
      begin
        Delete(texto,posicion,1);
        Delete(bandMarcadores, posicion, 1);
      end;
      dec(posicion);
    end;
  end;
end;


{*
Funcion recursiva para Agregar un caracter previamente validado y ubicado en la
posición correspondiente.  El proceso detecta en cual marcador se encuentra el
cursor del texto y obtiene la posición de los marcadores más proximos a la
izquierda en la mascara y en el texto.  Despues obtiene la posición
correspondiente en la mascara, cuenta los marcadores que hay a la derecha en la
mascara y lo suma a la posición del cursor, obtiene la cantidad de letras que deberia de
llevar el grupo en la mascara y cuenta las que se han ingresado hasta el momento en el texto,
se valida que el caracter es valido, si si lo es y aun hay espacios por llenar se inserta
en el texto, caso contrario lo modifica y llama a la función de forma recursiva hasta que el
caracter no sea valido o ya no exitan espacios en el texto. }
function Tmask.Agregar(var posicion : Integer;key : Char ;mascara:String; var texto : String; recursivo : Boolean = False):Boolean;
var
  saltaMarcadores,marcasAnteriores, letrasMedias, letrasDentro,
  posMarcadorMascara,posMarcadorTexto,posCasillaMascara: Integer;
  buffer : Char;
begin
    if (mascara = '') then
    begin
     Insert(key, texto,posicion);
     System.Exit;
    end;


    marcasAnteriores:= MarcadoresAnteriores(posicion);//Contar la marcas anteriores en el texto
    posMarcadorMascara := PosicionMarcadorIzq(mascara,marcasAnteriores);//Detectar posicion del ultimo marcador en la mascara
    posMarcadorTexto := PosicionMarcadorTextoIzq(marcasAnteriores);//Detectar posicion del ultimo marcador en el texto
    //Detectar cual es la casilla correspondiente en la mascara a la posicion del cursor.
    posCasillaMascara :=  posMarcadorMascara + posicion - posMarcadorTexto ;
    saltaMarcadores := SaltarMarcadoresDer(mascara,posCasillaMascara); //Detecta cuantos marcadores se deben saltar
    posicion := posicion + saltaMarcadores;//Avanza el cursor los espacios necesarios para saltar los marcadores

    letrasMedias  := ContarLetrasEntreMarcadores(mascara,marcasAnteriores + saltaMarcadores);
    letrasDentro  := ContarLetrasEntreMarcadoresTexto(marcasAnteriores + saltaMarcadores);

    //Valida el caracter introducido contra la mascara correspondiente
    result := false;
    if not (caracterInvalido(key,mascara[posCasillaMascara + saltaMarcadores])) then
    begin
    // Si la posicion cae dentro de la cadena y no es un marcador  se actualiza el valor
      if ((posicion <= Length(texto))and not(bandMarcadores[posicion] = ok)) then
      begin
        buffer := texto[posicion];
        texto[posicion] := key;
        if not recursivo then
          bufferPosicion := posicion;
        inc(posicion);
        Agregar(posicion, buffer, mascara, texto,True);
      end
      else
        if  ((letrasDentro < letrasMedias)  and (Length(bandMarcadores) < Length(mascara))) then
        begin
          Insert(key, texto,posicion);
          Insert(ng, bandMarcadores, posicion);
        end;
    result:= True;
    end
    else
    posicion := posicion - saltaMarcadores - 1;


    if recursivo then
    begin
      posicion := bufferPosicion;
    end;
end;


{*
Validación final del texto contra la mascara, el texto debera coincidir con
cada valor requerido, los valores permitidos seran brincados}
function TMask.ValidarTexto(mascara, texto : String) : Boolean;
var
  i,avanza: Integer;
begin

  if (length(texto) > 0) then
  begin
    result := True;
    for i := 1 to Length(mascara) do
    begin
      if EsPermitido(mascara[i]) then
      begin
      if Length(texto) < Length(mascara) then
        Insert('?',texto,i);
      Continue;
      end;

      if CaracterInvalido(texto[i],mascara[i]) then
      begin
        result := False;
        Break;
      end;
    end;
  end;

  if (Length(mascara) = 0) then
    result := True;

end;


end.
