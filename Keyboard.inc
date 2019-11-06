procedure FilterKeyboard(Key: Word);
begin
  case Key of
  VK_UP     : Include(ActionKeys,Up);
  VK_DOWN   : Include(ActionKeys,Down);
  VK_LEFT   : Include(ActionKeys,Left);
  VK_RIGHT  : Include(ActionKeys,Right);
  VK_RETURN : Include(ActionKeys,Start);
  Ord('z')  : Include(ActionKeys,BtnA);
  Ord('Z')  : Include(ActionKeys,BtnA);
  Ord('x')  : Include(ActionKeys,BtnB);
  Ord('X')  : Include(ActionKeys,BtnB);
  Ord('c')  : Include(ActionKeys,BtnC);
  Ord('C')  : Include(ActionKeys,BtnC);
  end;
  if Assigned(Rom.OnKeyboard) then
    Rom.OnKeyboard(ActionKeys);
  CleanKeys(ActionKeys);
end;