unit basa1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, StdCtrls,
  ExtCtrls, StrUtils, spisokobr;

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
    procedure BDeliteClick(Sender: TObject);
    procedure BEraseClick(Sender: TObject);
    procedure BFixBazeClick(Sender: TObject);
    procedure BPrintAllClick(Sender: TObject);
    procedure BSearchGrClick(Sender: TObject);
    procedure EGroupKeyPress(Sender: TObject; var Key: char);
    procedure ESearchKeyPress(Sender: TObject; var Key: char);
    procedure FormCreate(Sender: TObject);
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

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Mm3Click(Sender: TObject);
begin
  if SaveDialog.Execute then
  begin
     if Pos('.txt', SaveDialog.FileName) >0 then
        Memo.Lines.SaveToFile(SaveDialog.FileName)
     else
       Memo.Lines.SaveToFile(SaveDialog.FileName + '.txt')
  end;
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
     opf := 1;
     Memo.Lines.Text:= ' Загружена база из файла : "' + OpenDialog.FileName +
     '". В базе ' + OpenF_Go(OpenDialog.FileName) + ' пользователей.';
  end;
end;

procedure TForm1.BSearchGrClick(Sender: TObject);
var S: string;
begin
  Memo.Lines.Clear;
  S := EGroup.Text;
  if S = '' then
     Memo.Lines.Text:='Для поиска введите № группы в графе Group'
  else
     searchGr(S);
  //EGroup.Clear;
end;

procedure TForm1.EGroupKeyPress(Sender: TObject; var Key: char);
var S: string;
begin
     if key = #13 then
     begin
     S := EGroup.Text;
     if S <> '' then
        begin
        Memo.Lines.Clear;
        searchGr(S);
        end;
     end;
end;


procedure TForm1.ESearchKeyPress(Sender: TObject; var Key: char);
var S: string;
begin
     if key = #13 then
     begin
     Memo.Lines.Clear;
     S := ESearch.Text;
     if S = '' then
        Memo.Lines.Text := 'Для поиска введите инициалы пользователя' +
        'в графе Search FIO'
     else
        begin
        //ESearch.SelStart:=Length(S);
        //ESearch.SetFocus;
        searchAllkey(S);
        end;
     end;
end;


procedure TForm1.FormCreate(Sender: TObject);
begin
     RB_Go;
     if Pr > 0 then
        Memo.Lines.Add('Загружена база пользователей из ' +
        ExpandFileName('SpisokNew.txt') + #10+ 'В базе '+ IntToStr(Pr) +
        ' пользователей.'+#10+'Для поиска введите инициалы пользователя' +
     'в графе Search FIO и нажмите Enter')
     else if Pr < 0 then
          Memo.Lines.Add('Файл базы отсутствует либо испочен.' + #10 +
          'Проверте файл или загрузите другой.')
     else if Pr = 0 then
          Memo.Lines.Add('Файл базы пуст.'+ #10 +
          'Если желаете ли создать новую базу добавте пользователей и ' +
          'сохраните используя форму Save File.');
end;


procedure TForm1.MemoKeyPress(Sender: TObject; var Key: char);
begin
  if key = 'y' then
  begin
     if (Pos('Добавить', Memo.Lines.Text) > 0) then
     begin
     Memo.Lines.Text := 'Пользователь "' + S + '" добавлен в базу.';
     insert(S);
     key := #0;
     //EFam.Clear; EName.Clear; EPName.Clear; EYear.Clear; EGroup.Clear;
     end
     else if (Pos('Удалить', Memo.Lines.Text) > 0) then
    begin
       Memo.Lines.Text:='Пользователь "'+deletenode^.key+'" удален из базы.';
       remove_node(deletenode);
       key := #0;
       ESearch.Clear;
    end
  end
  else if key = 'n'  then
  begin
      Memo.Lines.Text:='Отмена операции удаления';
      key := #0;
   end
end;

procedure TForm1.BAddClick(Sender: TObject);
var n: Pnode;
begin
    if (EFam.Text <> '') and (EName.Text <> '') and (EPName.Text <> '')
  and(EYear.Text <> '') and (EGroup.Text <> '') then
  begin
    S := Trim(EFam.Text) + ' ' + Trim(EName.Text) + ' ' + Trim(EPName.Text) + ' ' +
    Trim(EYear.Text) + ' ' + Trim(EGroup.Text);
    n := search_node(root, S);
    if n = nil then
    begin
      Memo.Lines.Text := 'Пользователь "' + S + '" не найден в базе.' + #10 +
      'Добавить пользователя в базу? (y or n) : ' ;
      Memo.SelStart:=Length(Memo.Text);
      Memo.SetFocus;
    end
    else
      Memo.Lines.Text := 'Пользователь "' + S + '" уже имеется в базе.'
  end
  else
    Memo.Lines.Text := 'Для добавления нового пользователя внимательно ' +
    'заполните поля: ' + #10 + ' "Family: "' + #10 + ' "Name: "' + #10 +
    ' "PName: "' + #10 + ' "Year of Birth: "' + '    ' + '"Group: "'
end;

procedure TForm1.BDeliteClick(Sender: TObject);
begin
  Memo.Lines.Clear;
  S := ESearch.Text;
  if S = '' then
     Memo.Lines.Text := 'Введите данные удаляемого пользователя' +
                                 'в графе Search FIO'
  else
  begin
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

procedure TForm1.BEraseClick(Sender: TObject);
begin
  EFam.Clear;EName.Clear;EPName.Clear;EYear.Clear;EGroup.Clear;ESearch.Clear;
end;

procedure TForm1.BFixBazeClick(Sender: TObject);
begin
  FixFile;
  if opf = 0 then
  MEMO.Lines.Text:='Обновлен файл базы ' + FileOfBaze
  else
  Memo.Lines.Text:='Обновлен файл базы ' + OpenDialog.FileName;
end;

procedure TForm1.BPrintAllClick(Sender: TObject);
begin
  i := 0;
  Memo.Clear;
  inOrder(root);
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
      +IntToStr(n)+' пользовател'+IfThen(n <= 4, 'я', 'ей'));
end;

procedure searchGrNode(tree: Pnode; key: string; out n: integer);
begin
    if(tree <> nil)  then
    begin
        searchGrNode(tree^.left, key, n);
        if StrComp(key, tree^.group) = 0 then
        begin
          Inc(n);
          Form1.Memo.Lines.Add(IntToStr(n) + '. ' + tree^.key);
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
          Form1.Memo.Lines.Add(tree^.key);
          Inc(n);
        end;
        searchAllNode(tree^.right, key, n);
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
      '" не найдено в базе.' + #10)
    else
      Form1.Memo.Lines.Add('Найдено ' + IntToStr(n) + ' пользовател' +
      IfThen(n <= 4, 'я', 'ей'));
end;

procedure inOrder(tree: Pnode);
begin
    if(tree <> nil)  then
    begin
        inOrder(tree^.left);
        Form1.Memo.Lines.Add(IntToStr(inc_i(i)) + '. ' + tree^.key);
        inOrder(tree^.right);
    end;
end;


end.







