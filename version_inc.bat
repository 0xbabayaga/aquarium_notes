set /p var= <..\Anotes\version_cnt.txt 
set /a var= %var%+1 
echo %var% >..\Anotes\version_cnt.txt
echo #define APP_VERSION "0.0.0.%var%" >..\Anotes\c++\version.h
echo %var%