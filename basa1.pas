unit basa1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, StdCtrls,
  ExtCtrls, LCLType, spisokobr;

type

  { TForm1 }

  TForm1 = class(TForm)
    BAdd: TButton;
    BDelite: TButton;
    BSearchGr: TButton;
    BPrintAll: TButton;
    BFixBaze: TButton;
    BExit: TButton;
    BErase: TButton;
    BChangeGr: TButton;
    ESearch: TEdit;
    EGroup: TEdit;
    EFam: TEdit;
    Label5: TLabel;
    EName: TEdit;
    EPName: TEdit;
    EYear: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label6: TLabel;
    MainMenu: TMainMenu;
    Memo: TMemo;
    Mm3: TMenuItem;
    Mm2: TMenuItem;
    Mm1: TMenuItem;
    OpenDialog: TOpenDialog;
    Panel1: TPanel;
    SaveDialog: TSaveDialog;
    procedure BAddClick(Sender: TObject);
    procedure BChangeGrClick(Sender: TObject);
    procedure BDeliteClick(Sender: TObject);
    procedure BEraseClick(Sender: TObject);
    procedure BExitClick(Sender: TObject);
    procedure BFixBazeClick(Sender: TObject);
    procedure BPrintAllClick(Sender: TObject);
    procedure BSearchGrClick(Sender: TObject);
    procedure EFamClick(Sender: TObject);
    procedure EFamKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EGroupClick(Sender: TObject);
    procedure EGroupKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EGroupKeyPress(Sender: TObject; var Key: char);
    procedure ENameKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EPNameKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ESearchClick(Sender: TObject);
    procedure ESearchKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
      );
    procedure ESearchKeyPress(Sender: TObject; var Key: char);
    procedure EYearKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure MemoClick(Sender: TObject);
    procedure MemoKeyPress(Sender: TObject; var Key: char);
    procedure Mm2Click(Sender: TObject);
    procedure Mm3Click(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

procedure inOrder(tree: Pnode);
procedure searchAllKey(key: string);
procedure searchAllNode(tree: Pnode; key: string; out n: integer);
procedure searchGrNode(tree: Pnode; key: string; out n: integer);
procedure searchGr(key: string);
function okonc(n: integer): string;
function razbor(var S: string): string;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Mm3Click(Sender: TObject);
begin
  if SaveDialog.Execute then
  begin
     Memo.Clear;
     if Pos('.txt', SaveDialog.FileName) > 0 then
     begin
          Memo.Lines.SaveToFile(SaveDialog.FileName);
          AssignFile(H, SaveDialog.FileName);
          Memo.Lines.Text := 'Создан файл базы пользователей ' +
          SaveDialog.FileName;
          SO_FileName := SaveDialog.FileName;
     end
     else
     begin
          Memo.Lines.SaveToFile(SaveDialog.FileName + '.txt');
          AssignFile(H, SaveDialog.FileName + '.txt');
          Memo.Lines.Text := 'Создан файл базы пользователей ' +
          SaveDialog.FileName + '.txt';
          SO_FileName := SaveDialog.FileName + '.txt'
     end;
  end;
  if root <> nil then     //SaveDialog создает пустой файл. Если до этого
     FixFile;             //набиралась новая база или старая сюда ложиться
  Pr := 0;                // необходимо ее вписать в файл
end;

procedure TForm1.Mm2Click(Sender: TObject);
begin
     if root <> nil then
     begin
        FixFile;
        Destroy_node(root);
        root := nil;
     end;

  if OpenDialog.Execute then
  begin
   SO_FileName := OpenDialog.FileName;
   Memo.Lines.Text:= ' Загружена база из файла : "' + SO_FileName +
   '". В базе ' + OpenF_Go(SO_FileName) + ' пользователей.';
  end;
end;

procedure TForm1.BSearchGrClick(Sender: TObject);
var S: string;
begin
  if root = nil then
     Memo.Lines.Text := 'В базе нет пользователей.' + #13#10 +
   'Добавте пользователей в базу и сохраните нажав FixBaze.'
   else
   begin
      Memo.Lines.Clear;
      S := EGroup.Text;
      if S = '' then
        Memo.Lines.Text:='Для вывода списка пользователей группы ' +
      'введите № группы в графе Group'
      else
        searchGr(S);
   end;
end;

procedure TForm1.EFamClick(Sender: TObject);
begin
        Memo.Lines.Text := 'Для добавления нового пользователя внимательно ' +
    'заполните поля: ' + #10 + ' "Family: "' + #10 + ' "Name: "' + #10 +
    ' "PName: "' + #10 + ' "Year of Birth: "' + '  and  ' + '"Group: "'
end;

procedure TForm1.EFamKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
  );
begin
     if Ord(key) = vk_up then
    ESearch.SetFocus
    else if Ord(key) = vk_down then
     EName.SetFocus;
end;

procedure TForm1.EGroupClick(Sender: TObject);
begin
    if root <> nil then
    Memo.Lines.Text:='Для вывода списка пользователей группы ' +
     'введите № группы в графе Group и нажмите Enter.'
  else
    Memo.Lines.Text := 'В базе нет пользователей.' + #13#10 +
   'Добавте пользователей в базу и сохраните нажав FixBaze.'
end;

procedure TForm1.EGroupKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
      if (Ord(key) = vk_left) or (Ord(key) = vk_up) then
    EYear.SetFocus;
end;

procedure TForm1.EGroupKeyPress(Sender: TObject; var Key: char);
var S: string;
begin
    if root = nil then
     Memo.Lines.Text := 'В базе нет пользователей.' + #13#10 +
   'Добавте пользователей в базу и сохраните нажав FixBaze.'
   else
   begin
     if key = #13 then
     begin
        Memo.Lines.Clear;
        S := EGroup.Text;
        if S = '' then
         Memo.Lines.Text:='Для поиска введите № группы в графе Group'
        else
         searchGr(S);
     end;
   end;
end;

procedure TForm1.ENameKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
  );
begin
    if Ord(key) = vk_down then
    EPName.SetFocus
  else if Ord(key) = vk_up then
    EFam.SetFocus;
end;

procedure TForm1.EPNameKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    if Ord(key) = vk_down then
    EYear.SetFocus
  else if Ord(key) = vk_up then
    EName.SetFocus;
end;

procedure TForm1.ESearchClick(Sender: TObject);
begin
    if root = nil then
    Memo.Lines.Text := 'В базе нет пользователей.' + #13#10 +
   'Добавте пользователей в базу и сохраните нажав FixBaze.'
   else if ESearch.Text = '' then
     Memo.Lines.Text := 'Для поиска начните вводить инициалы пользователя' +
        'в графе Search FIO и нажмите Enter.'
   else
      Memo.Lines.Add('Выбран пользователь ' + ESearch.Text + ' вы можете: '
      + #13#10 +
      '1. Удалить пользователя: BDell.' + #13#10 +
      '2. Изменить группу пользователя: BChGroup.')
end;

procedure TForm1.ESearchKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    if Ord(key) = vk_down then
    EFam.SetFocus
end;

function razbor(var S: string): string;
var n, j, ind: integer;
begin
  n := 0;
  ind := 0;
  for j := 1 to Length(S) do
    if S[j] = ' ' then
    begin
      inc(n);
      ind := j;
    end;
  if n = 4 then
    Result := copy(S, 1, ind-1)
  else
    Result := S;
end;

procedure TForm1.ESearchKeyPress(Sender: TObject; var Key: char);
begin
    S := '';
   if key = #13 then
   begin
      Memo.Lines.Clear;
      S := ESearch.Text;
      if S = '' then
      Memo.Lines.Text := 'Для поиска введите инициалы пользователя' +
      'в графе Search FIO'
      else
      begin
         S[1] := UpCase(S[1]);
         searchAllkey(razbor(S))
      end;
   end;
end;

procedure TForm1.EYearKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
  );
begin
    if Ord(key) = vk_up then
    EPname.SetFocus
  else if (Ord(key) = vk_right) or (Ord(key) = vk_down) then
    EGroup.SetFocus;
end;


procedure TForm1.FormCreate(Sender: TObject);
begin
    RB_Go;
    Memo.Clear;
  if Pr > 0 then
  begin
     Memo.Lines.Add('Загружена база пользователей из ' +
     ExpandFileName(SO_FileName)+ '.' + ' В базе '+ IntToStr(Pr) +
     ' пользователей.'+#13#10+'Для поиска начните вводить инициалы пользователя' +
     'в графе Search FIO и нажмите Enter.');
  end
  else if Pr < 0 then
       Memo.Lines.Add('Файл базы отсутствует либо испочен. ' +
       'Проверте файл или загрузите другой, воспользовавшись формой OpenFile.'
       +#13#10+'Если желаете ли создать файл базы добавте пользователей и '+
       'сохраните файл используя форму Save File.' + #13#10 +
       '(Базовый файл имеет имя/расширение "SpisokNew.txt")' )
  else if Pr = 0 then
       Memo.Lines.Add('Файл базы пуст.'+ #13#10 +
       'Если желаете ли создать новую базу добавте пользователей и ' +
       'сохраните используя форму Save File или FixBaze.');
end;

procedure TForm1.MemoClick(Sender: TObject);
begin
  if Pos('y or n', Memo.Lines.Text) = 0 then
      ESearch.Text := Memo.SelText;
end;

procedure TForm1.MemoKeyPress(Sender: TObject; var Key: char);
begin
  if key = 'y' then
begin
   if (Pos('Добавить', Memo.Lines.Text) > 0) then
   begin
   S := S  + ' ' + Trim(EGroup.Text);
   Memo.Lines.Text := 'Пользователь "' + S + '" добавлен в базу.';
   ShowMessage('Пользователь "' + S + '" добавлен в базу.');
   insert(S);
   key := #0;
   end
   else if (Pos('Удалить', Memo.Lines.Text) > 0) then
  begin
     Memo.Lines.Text:='Пользователь "'+deletenode^.key+'" удален из базы.';
     ShowMessage('Пользователь "'+deletenode^.key+'" удален из базы.');
     remove_node(deletenode);
     key := #0;
     ESearch.Clear;
  end
end
else if key = 'n'  then
begin
    Memo.Lines.Add('Отмена операции.');
    //ShowMessage('Отмена операции.');
    key := #0;
end;
end;

procedure TForm1.BAddClick(Sender: TObject);
var Fa, Na, Pa: string;
var n: Pnode;
begin
    if (EFam.Text <> '') and (EName.Text <> '') and (EPName.Text <> '')
  and(EYear.Text <> '') {and (EGroup.Text <> '')} then
  begin
    Fa := Trim(EFam.Text);  Na := Trim(EName.Text); Pa := Trim(EPName.Text);
    Fa[1] := UpCase(Fa[1]); Na[1] := UpCase(Na[1]); Pa[1] := UpCase(Pa[1]);
    S := Fa + ' ' + Na + ' ' + Pa + ' ' + Trim(EYear.Text); // Trim(EGroup.Text);
    n := search_node(root, S);
    if n = nil then
    begin
        Memo.Lines.Add('Пользователь "' + S + '" не найден в базе.');
        if EGroup.Text = '' then
          Memo.Lines.Add('Введите номер группы пользователя в графе Group' +#10+
          'Добавить пользователя в базу? (y or n) : ')
         else
          Memo.Lines.Add('Добавить пользователя в базу? (y or n) : ');
        Memo.SelStart:=Length(Memo.Text);
        Memo.SetFocus
    end
    else
    begin
      Memo.Lines.Text := 'Пользователь "' + S + '" уже имеется в базе.' ;
      ShowMessage('Пользователь "' + S + '" уже имеется в базе.');
    end
  end
  else
    Memo.Lines.Text := 'Для добавления нового пользователя внимательно ' +
    'заполните поля: ' + #10 + ' "Family: "' + #10 + ' "Name: "' + #10 +
    ' "PName: "' + #10 + ' "Year of Birth: "' + '    ' + '"Group: "'
end;

procedure TForm1.BChangeGrClick(Sender: TObject);
var
  ChNode: Pnode;
begin
  Memo.Clear;
  if root = nil then
    Memo.Lines.Text := 'В базе нет пользователей.' + #13#10 +
   'Добавте пользователей в базу и сохраните нажав FixBaze.'
  else
  begin
    S := ESearch.Text;
    if S = '' then
        Memo.Lines.Add('Воспользуйтесь поиском пользователя.')
    else
    begin
       T := EGroup.Text;
       if T = '' then
          Memo.Lines.Add('В поле Group введите номер группы для замены.')
       else
       begin
          l := LastDelimiter(' ', S);  //Gr := copy(S, l+1, Length(S) - l);
          S := copy(S, 1, l-1);
          ChNode := nil;
          ChNode := search_node(root, S);
          if ChNode <> nil then
          begin
            ChNode^.group := T;
            Memo.Lines.Add('Пользователь ' + ChNode^.key + ' переведен в группу ' +
            ChNode^.group);
            ShowMessage('Пользователь ' + ChNode^.key + ' переведен в группу ' +
            ChNode^.group);
            //Delete(ESearch.Text, l+1, Length(ESearch.Text)-l);
            //Insert(ESearch.Text + T);
            ESearch.Clear;
            ESearch.Text := S + ' ' + T;
          end;
       end;
    end;
  end;
end;

procedure TForm1.BDeliteClick(Sender: TObject);
begin
     if root = nil then
        Memo.Lines.Text := 'В базе нет пользователей.' + #13#10 +
        'Добавте пользователей в базу и сохраните нажав FixBaze.'
     else
     begin
          Memo.Lines.Clear;
          S := ESearch.Text;
          if S = '' then
          Memo.Lines.Text := 'Введите данные удаляемого пользователя' +
                                 'в графе Search FIO'
          else
          begin
               l := LastDelimiter(' ', S);
               S := copy(S, 1, l-1);

               deletenode := search_node(root,S);
               if deletenode <> nil then
               begin
                    Memo.Lines.Text:='Удалить пользователя "'+
                    deletenode^.key+ '" из базы? ( y or n): ' ;
                    Memo.SelStart:=Length(Memo.Text);
                    Memo.SetFocus;
               end
               else
                   Form1.Memo.Lines.Text:='Пользователь "'+S+'" не найден в базе, ' +
                   'удаление не возможно.';
          end;
     end;
end;

procedure TForm1.BEraseClick(Sender: TObject);
begin
  EFam.Clear;EName.Clear;EPName.Clear;EYear.Clear;EGroup.Clear;ESearch.Clear;
end;

procedure TForm1.BExitClick(Sender: TObject);
begin
    Application.Terminate;
end;

procedure TForm1.BFixBazeClick(Sender: TObject);
begin
     if Pr < 0 then
       Memo.Lines.Text := 'Для создания файла воспользуйтесь формой Save File.'
     else
     begin
       FixFile;
       MEMO.Lines.Text:='Обновлен файл базы ' + SO_FileName;
     end;
end;

procedure TForm1.BPrintAllClick(Sender: TObject);
begin
     if root = nil then
      Memo.Lines.Text := 'В базе нет пользователей.' + #13#10 +
      'Добавте пользователей в базу и сохраните нажав FixBaze.'
      else
      begin
       i := 0;
       Memo.Clear;
       inOrder(root);
       Memo.Lines.Add(IntToStr(i) + ' пользовател' + okonc(i) + ' в базе.')
      end;
end;

procedure searchGr(key: string);
var
  n: integer;
begin
    n := 0;
    searchGrNode(root, key, n);
    if n = 0 then
      Form1.Memo.Lines.Text:='Группы "' + key + '" не найдено в базе.'
    else
      Form1.Memo.Lines.Add('В группе '+'"'+key+'"'+'   '
      +IntToStr(n)+' пользовател'+okonc(n)+'.');
end;

procedure searchGrNode(tree: Pnode; key: string; out n: integer);
begin
    if(tree <> nil)  then
    begin
        searchGrNode(tree^.left, key, n);
        if StrComp(key, tree^.group) = 0 then
        begin
          Inc(n);
          Form1.Memo.Lines.Add(tree^.key);
        end;
        searchGrNode(tree^.right, key, n);
    end;
end;

procedure searchAllNode(tree: Pnode; key: string; out n: integer);
begin
    if(tree <> nil)  then
    begin
        searchAllNode(tree^.left, key, n);
        if StrComp(key, tree^.key) = 0 then
        begin
          Form1.Memo.Lines.Add(tree^.key + ' ' + tree^.group);
          Inc(n);
        end;
        searchAllNode(tree^.right, key, n);
    end;
end;

function okonc(n: integer): string;
begin
  case n of
  1,21,31,41,51: Result:='ь';
  2..4,22..24,32..34,42..44: Result:='я';
  5..20,25..30,35..40,45..50: Result:='ей';
  else Result:='ей';
  end;
end;

procedure searchAllKey(key: string);
var
  n: integer;
begin
    n := 0;
    searchAllNode(root, key, n);
    if n = 0 then
    Form1.Memo.Lines.Add('Пользователей с данными "' + key +
    '" не найдено в базе.' + #13#10 +
    'Проверьте строку поиска, или раскладку клавиатуры.')
  else
    Form1.Memo.Lines.Add('Найдено ' + IntToStr(n) + ' пользовател' + okonc(n) +
    '.  Для выбора кликните мышью по строке пользователя.');
end;

procedure inOrder(tree: Pnode);
begin
    if(tree <> nil)  then
    begin
        inOrder(tree^.left);
        Form1.Memo.Lines.Add(tree^.key + ' ' + tree^.group);
        inc(i);
        inOrder(tree^.right);
    end;
end;


end.







