function DlgAbout(Dlg, iMsg, wParam, lParam: LongWord): LResult; stdcall;
begin
  Result := LResult(True);
  case iMsg of
  WM_CLOSE: EndDialog(Dlg,0);
  WM_LBUTTONDOWN: SendMessage(Dlg,WM_CLOSE,0,0);
  end;
  Result := LResult(False);
end;

function DlgKeyboard(Dlg, iMsg, wParam, lParam: LongWord): LResult; stdcall;
begin
  Result := LResult(True);
  case iMsg of
  WM_CLOSE: EndDialog(Dlg,0);
  end;
  Result := LResult(False);
end;