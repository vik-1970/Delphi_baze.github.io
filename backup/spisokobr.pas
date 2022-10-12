unit spisokObr;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, LCLType;

const
  MaxAr = 23;

type
    Enum = (BLACK, RED);
    Pnode = ^Tnode;
    Tnode = record
          key: string;
          group: string;
          color: Enum;
          parent: Pnode;
          left: Pnode;
          right: Pnode;
    end;

var
  color: Enum;
  root, deletenode: Pnode;
  H, F: TextFile;
  S, T: String;
  Fam, Name, PName, BathYear, Gr: string;
  Pr, i, l: integer;
  FileOfBaze: ShortString = 'SpisokNew.txt';
  SO_FileName: string;
  //opf: integer; //индикатор OpenFile

function StrComp(S: string; T: string): Integer;
procedure rotate_left( var x: Pnode);
procedure rotate_right(var y: Pnode);
procedure swap_t(var x, y: Pnode);
procedure InsertFixUp(n: Pnode);
procedure insert(key: string);
function search_node(n: Pnode; key: string): Pnode;     //
procedure removeFixUp(n: Pnode; parent: Pnode);  //
procedure remove_node(n: Pnode);     //
procedure FixSpisok(tree: Pnode);
procedure FixFile;
function OpenF_Go(Name_F: string): string;
function inc_i(var i: integer): integer;
procedure RB_Go;
procedure Destroy_node(node: Pnode);

implementation
var last: integer;

procedure FixFile;
begin
  Rewrite(H);
  FixSpisok(root);
  CloseFile(H);
end;

procedure FixSpisok(tree: Pnode);
begin
  if tree <> nil then
     begin
      FixSpisok(tree^.left);
      writeln(H, tree^.key + ' ' + tree^.group);
      FixSpisok(tree^.right);
     end;
end;

function search_node(n: Pnode; key: string): Pnode;
begin
    if (n = nil) or (StrComp(key, n^.key) = 0)  then
        Result := n
    else
        if StrComp(key, n^.key) > 0  then
            Result := search_node(n^.right, key)
        else
            Result := search_node(n^.left, key);
end;

procedure remove_node(n: Pnode);
var
  child, parent, replace: Pnode;
  color: Enum;
begin
	// Левый и правый узлы удаленного узла не пусты (не конечные узлы)
	if (n^.left <> nil) and (n^.right <> nil) then
  begin
		replace := n;
		// Найти узел-преемник (самый нижний левый узел правого поддерева текущего узла)
		replace := n^.right;
		while (replace^.left <> nil) do
			replace := replace^.left;

		// Случай, когда удаленный узел не является корневым узлом
		if (n^.parent <> nil) then
			if (n^.parent^.left = n)  then
				n^.parent^.left := replace
			else
				n^.parent^.right := replace
		// Ситуация с корневым узлом
		else
			root := replace;
		// child - это правильный узел, который заменяет узел и является узлом, который требует последующей корректировки
		// Поскольку замена является преемником, он не может иметь левого дочернего узла
		// Аналогично, у узла-предшественника не может быть правого дочернего узла
		child := replace^.right;
		parent := replace^.parent;
		color := replace^.color;

		// Удаленный узел является родительским узлом замещающего узла (repalce)
		if (parent = n)  then
			parent := replace
		else
    begin
			// Существование дочернего узла
			if (child <> nil) then
				child^.parent := parent;
			parent^.left := child;

			replace^.right := n^.right;
			n^.right^.parent := replace;
    end;
		replace^.parent := n^.parent;
		replace^.color := n^.color;
		replace^.left := n^.left;
		n^.left^.parent := replace;
		if (color = BLACK)  then
			removeFixUp(child, parent);

		Dispose(n);
		exit;
  end;
	// Когда в удаленном узле только левый (правый) узел пуст, найдите дочерний узел удаленного узла
	if (n^.left <> nil)  then
		child := n^.left
	else
		child := n^.right;

	parent := n^.parent;
	color := n^.color;
	if (child <> nil) then
		child^.parent := parent;

	// Удаленный узел не является корневым узлом
	if (parent <> nil)  then
		if (n = parent^.left) then
			parent^.left := child
		else
			parent^.right := child

	// Удаленный узел является корневым узлом
	else
		root := child;

	if (color = BLACK) then
		removeFixUp(child, parent);

	Dispose(n);
end;

procedure removeFixUp(n: Pnode; parent: Pnode);
var
  othernode: Pnode;
begin
	while (n = nil) or ((n^.color = BLACK) and (n <> root)) do
  begin
		if (parent^.left = n)  then
    begin
			othernode := parent^.right;
			if (othernode^.color = RED)  then
			begin
				othernode^.color := BLACK;
				parent^.color := RED;
				rotate_left(parent);
				othernode := parent^.right;
      end;

			if (othernode^.right = nil) or  (othernode^.right^.color = BLACK)
      and (othernode^.left = nil) or (othernode^.left^.color = BLACK) then
      begin
				  othernode^.color := RED;
				  n := parent;
				  parent := n^.parent;
        end

			else
			begin
				if (othernode^.right = nil) or (othernode^.right^.color = BLACK) then
				begin
					othernode^.left^.color := BLACK;
					othernode^.color := RED;
					rotate_right(othernode);
					othernode := parent^.right;
        end;
				othernode^.color := parent^.color;
				parent^.color := BLACK;
				othernode^.right^.color := BLACK;
				rotate_left(parent);
				n := root;
				break;
      end
    end
    else
    begin
			othernode := parent^.left;
			if (othernode^.color = RED)  then
			begin
				othernode^.color := BLACK;
				parent^.color := RED;
				rotate_right(parent);
				othernode := parent^.left;
      end;
			if (othernode^.left = nil) or  (othernode^.left^.color = BLACK)
      and (othernode^.right = nil) or (othernode^.right^.color = BLACK) then
      begin
				  othernode^.color := RED;
				  n := parent;
				  parent := n^.parent;
        end
			else
			begin
				if (othernode^.left = nil) or (othernode^.left^.color = BLACK) then
        begin
          othernode^.right^.color := BLACK;
          othernode^.color := RED;
          rotate_left(othernode);
          othernode := parent^.left;
        end;
				othernode^.color := parent^.color;
				parent^.color := BLACK;
				othernode^.left^.color := BLACK;
				rotate_right(parent);
				n := root;
				break;
      end;
    end;
  end;
	if (n <> nil) then
		n^.color := BLACK;
end;

procedure insert(key: string);   //создание узла по ключу и вставка
var
  z, x, y: Pnode;
begin

  l := LastDelimiter(' ', key);
  Gr := copy(key, l+1, Length(key) - l);
  T := copy(key, 1, l-1);

  new(z);            //запрос динамической памяти для узла
    z^.key := T;     //*****************
    z^.color := RED;
    z^.group := Gr;
    z^.left := nil;
    z^.right := nil;
    z^.parent := nil;
    x := root;
    y := nil;
    while x <> nil do  //ели узел (или root) не nil спускаемся по дереву
      begin            //ищем свободный лист
        y := x;      //спускаясь по дереву запоминаем последний узел
        if z^.key > x^.key then   //*******************
          x := x^.right
        else
          x := x^.left;
      end;
    z^.parent := y;  //нашли лист его папа запомненый узел, присваиваем
    if y = nil then
      root := z
    else if z^.key < y^.key then  //всавляем новый узел в дерево
         y^.left := z            //*************
    else
          y^.right := z;
    InsertFixUp(z);   //идем проверить и переложить дерево
end;

procedure InsertFixUp(n: Pnode);
var
  parent: Pnode;   // parent(n) предок папа
  g: Pnode;        // grahdparent(n)  дед т.е. parent.parent(n)
  u: Pnode;        // uncle(n) дядя - grandparent.left(right), но не parent
begin
  parent := n^.parent;             //запоминаем папу (если есть)
  while(n <> root) and (parent^.color = RED) do
  begin
        g := parent^.parent;       //запоминаем деда  (если есть)
        if g^.left = parent then   //если папа левый сын деда
        begin
            u := g^.right;         //то uncle(n) соотв. правый
            if(u <> nil) and (u^.color = RED) then
             begin
                parent^.color := BLACK;
                u^.color := BLACK;
                g^.color := RED;
                n := g;
                parent := n^.parent;
            end
            else
            begin
                if parent^.right = n  then
                begin
                    rotate_left(parent);
                    swap_t(n, parent);
                end;
                rotate_right(g);
                g^.color := RED;
                parent^.color := BLACK;
                break;
            end;
        end
        else
        begin
            u := g^.left; //uncle(n);
            if(u <> nil) and (u^.color = RED) then
            begin
                g^.color := RED;
                parent^.color := BLACK;
                u^.color := BLACK;

                n := g;
                parent := n^.parent;
            end
            else
            begin
                if parent^.left = n then
                begin
                    rotate_right(parent);
                    swap_t(n, parent);
                end;
                rotate_left(g);
                parent^.color := BLACK;
                g^.color := RED;
                break;
            end;
        end;
  end;
root^.color := BLACK;
end;

procedure swap_t(var x, y: Pnode);
var temp: Pnode;
begin
  temp := x;
  x := y;
  y := temp;
end;


procedure rotate_right(var y: Pnode);
var
	x: Pnode;
begin
   x := y^.left;
	y^.left := x^.right;
	if (x^.right <> nil)  then
		x^.right^.parent := y;

	x^.parent := y^.parent;
	if (y^.parent = nil) then
		root := x
	else
		if  (y = y^.parent^.right)   then
			y^.parent^.right := x
		else
			y^.parent^.left := x;

	x^.right := y;
	y^.parent := x;

end;

procedure rotate_left( var x: Pnode);
var
	y: Pnode;
begin
  y := x^.right;
	x^.right := y^.left;
	if (y^.left <> nil) then
		y^.left^.parent := x;

	y^.parent := x^.parent;
	if (x^.parent = nil)  then
		root := y
	else
    if (x = x^.parent^.left) then
			x^.parent^.left := y
		else
			x^.parent^.right := y;

	y^.left := x;
	x^.parent := y;
end;

function StrComp(S: string; T: string): Integer;
var
  j: integer;
begin
  j := 1;
  while (S[j] <> #0) or (T[j] <> #0) do
  begin
    if S[j] = T[j] then
    begin
      inc(j);
      continue;
    end;
     if S[j] > T[j] then
     begin
      Result := 1;
      break;
     end
     else
     begin
       Result := -1;
       break;
     end;
     inc(j);
  end;
  if S[j] = #0 then
    Result := 0;
end;

procedure RB_Go;
begin
  Pr := 0;
  if FileExists(FileOfBaze) = True then
  begin
       SO_FileName := FileOfBaze;
       AssignFile(H, SO_FileName);
       Reset(H);
       while not Eof(H) do
       begin
       readln(H, S);
       if S = '' then
          continue;
          inc(Pr);
          insert(S);
       end;
    CloseFile(H);
  end
  else
  Pr := -1;
end;

function OpenF_Go(Name_F: string): string;
begin
  Pr := 0;
  AssignFile(H, Name_F);
  Reset(H);
    while not Eof(H) do
    begin
      readln(H, S);
      if S = '' then
        continue;
      inc(Pr);
      insert(S);
    end;
    CloseFile(H);
 
 Result :=  IntToStr(Pr);

end;

function inc_i(var i: integer): integer;
begin
    i := i +1;
    Result := i;
end;


procedure Destroy_node(node: Pnode);
begin
     if (node = nil) then
        Exit;
     Destroy_node(node^.left);
     Destroy_node(node^.right);
     Dispose(node);    //delete node;
     node := nil;      //node = nullptr;
end;


end.


