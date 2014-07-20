def do_goodbye(locoterm)
  locoterm.erase_all
  locoterm.mvaddstr(5, 5, "goodbye!")
  locoterm.getch
  exit
end
