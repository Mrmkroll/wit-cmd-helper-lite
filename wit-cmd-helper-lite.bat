@echo off
chcp 437 > nul

:top
title Wit-Cmd-Helper-Lite - Main menu
cls
echo -- Main Menu --
echo:
echo - For the disk image -
echo 1. Convert     --- Convert image file formats, such as WBFS to ISO and vice versa.
echo 2. Extract     --- Extract all files in the image file while maintaining the directory tree.
echo 3. Create      --- Create image files such as ISO and WBFS.
echo:
echo - Other -
echo 4. Change Game ID      --- Change the Game ID of the image file.
echo 5. Change Save Data    --- Change the save data when using the image file.
echo:
echo 0. Exit

choice /C 123450 /N > nul

if errorlevel 6 goto :exit
if errorlevel 5 goto :save_section
if errorlevel 4 goto :game_id_section
if errorlevel 3 goto :create_section
if errorlevel 2 goto :extract_section
if errorlevel 1 goto :convert_section

::-----------------------------------------------------------------------------

:convert_section
title Wit-Cmd-Helper-Lite - Convert image file formats
call :get_f_path
call :convert

goto :pause

::-----------------------------------------------------------------------------

:extract_section
title Wit-Cmd-Helper-Lite - Extract all files in the image file
call :get_f_path
cls
call :d_name
cls
echo Set your own folder names: %ANS%
call :extract

goto :pause

::-----------------------------------------------------------------------------

:create_section
title Wit-Cmd-Helper-Lite - Create image file
call :get_d_path
cls
call :extension
cls
echo Set extension: %EX% & echo :
call :f_name
cls
echo Set extension: %EX% & echo Set image file name: %ANS%
call :create

goto :pause

::-----------------------------------------------------------------------------

:game_id_section
title Wit-Cmd-Helper-Lite - Change Game ID
call :get_f_path
cls
call :game_id
cls
echo Set Game ID: %id%
@wit edit "%GOT_FL_PATH%" --disc-id %id%

goto :pause

::-----------------------------------------------------------------------------

:save_section
title Wit-Cmd-Helper-Lite - Change Save Data
call :get_f_path
cls
call :save
cls
echo Set Save Data ID: %sd%
@wit edit "%GOT_FL_PATH%" --ticket-id %sd% --tmd-id %sd% --tt-id %sd%

goto :pause

::-----------------------------------------------------------------------------

:exit
title Wit-Cmd-Helper-Lite - Shutting down
cls
echo See you. & timeout /t 1 /nobreak > nul & cls & echo See you.. & timeout /t 1 /nobreak > nul & cls & echo See you... & timeout /t 1 /nobreak > nul
exit


::-----------------------------------------------------------------------------

:pause
echo: & pause
goto :top

::-----------------------------------------------------------------------------

:get_f_path
cls
set TRUE_FALSE=FALSE
set GOT_FL_PATH=NULL & set GOT_EXT=NULL & set GOT_F_PATH=NULL & set GOT_PATH=NULL
echo Please drag and drop the disk image. & set /P GOT_FL_PATH=""
if not %GOT_FL_PATH%==NULL (
    call :get_ext %GOT_FL_PATH%
    call :get_path %GOT_FL_PATH%
)
if %GOT_EXT%==.wbfs set TRUE_FALSE=TRUE
if %GOT_EXT%==.iso set TRUE_FALSE=TRUE
if %TRUE_FALSE%==FALSE  goto :get_f_path
exit /b

::-----------------------------------------------------------------------------

:get_d_path
cls
set TRUE_FALSE=FALSE
set GOT_D_PATH=NULL & set GOT_EXT=NULL & set GOT_F_PATH=NULL & set GOT_PATH=NULL
echo Please drag and drop the disk image folder. & set /P GOT_D_PATH=""
if %GOT_D_PATH%==NULL goto :get_d_path
call :get_ext %GOT_D_PATH%
call :get_path %GOT_D_PATH%
if %GOT_EXT%==NONE set TRUE_FALSE=TRUE
if %GOT_EXT%==.tmp set TRUE_FALSE=TRUE
if %TRUE_FALSE%==FALSE goto :get_d_path
exit /b

::-----------------------------------------------------------------------------

:get_ext
set GOT_EXT=%~x1
if "%GOT_EXT%"=="" ( set GOT_EXT=NONE ) else ( call :to_lower %GOT_EXT% )
exit /b

:get_path
set GOT_F_PATH=%~dpn1 & set GOT_PATH=%~dp1 & set GOT_FL_PATH=%~1
exit /b

::-----------------------------------------------------------------------------
:to_lower
set GOT_EXT=%1
for %%i in (a b c d e f g h i j k l m n o p q r s t u v w x y z) do call set GOT_EXT=%%GOT_EXT:%%i=%%i%%
exit /b

::-----------------------------------------------------------------------------

:d_name
set ANS=
set /P D_NAME="Do you want to set a folder name?(y/N): "
if /i {%D_NAME%}=={y} goto :ans_y
set ANS=No & exit /b

:f_name
set ANS=
set /P F_NAME="Do you want to set a image file name?(y/N): "
if /i {%F_NAME%}=={y} goto :ans_y
set ANS=No & exit /b

:ans_y
set ANS=Yes & exit /b

::-----------------------------------------------------------------------------

:extension
set EXT=w
set /P EXT="Set the image file extension to be WBFS(W)/ISO(i): "
if /i {%EXT%}=={w} set EX=wbfs & exit /b
if /i {%EXT%}=={i} set EX=iso & exit /b
goto :extension

::-----------------------------------------------------------------------------

:convert
if %GOT_EXT%==.wbfs (
    @wit copy "%GOT_FL_PATH%" -P -d "%GOT_F_PATH%.iso" & exit /b
) else (
    @wit copy "%GOT_FL_PATH%" -P -d "%GOT_F_PATH%.wbfs" & exit /b
)

::-----------------------------------------------------------------------------

:extract
if %ANS%==Yes (
    set DIR_NAME=
    :loop
    if "%DIR_NAME%"=="" (
        echo Please enter folder name. & set /P DIR_NAME=""
        goto :loop
    )
    @wit extract "%GOT_FL_PATH%" -P -d "%GOT_PATH%%DIR_NAME%" & exit /b
) else (
    @wit extract "%GOT_FL_PATH%" -P -d "%GOT_F_PATH%.tmp" & exit /b
)

::-----------------------------------------------------------------------------

:create
if %ANS%==Yes (
    set FILE_NAME=
    :redo
    if "%FILE_NAME%"=="" (
        echo Please enter image file name. & set /P FILE_NAME=""
        goto :redo
    )
    echo %GOT_FL_PATH%
    @wit copy "%GOT_FL_PATH%" -P -d "%GOT_PATH%%FILE_NAME%.%EX%" & exit /b
) else (
    if %GOT_EXT%==tmp @wit copy "%GOT_FL_PATH%" -d "%GOT_F_PATH%.%EX%" & exit /b
    @wit copy "%GOT_FL_PATH%" -P -d "%GOT_FL_PATH%.%EX%" & exit /b
)

::-----------------------------------------------------------------------------

:game_id
echo Please enter Game ID. (length: 6) & echo ex: RMCJ01
set id= & set /P id=""
call :check %id%
if not %len%==6 goto :game_id
exit /b

::-----------------------------------------------------------------------------

:save
echo Please enter Save Data ID. (length: 4) & echo ex: RMCJ
set sd= & set /P sd=""
call :check %sd%
if not %len%==4 goto :save
exit /b

::-----------------------------------------------------------------------------

:check
set str=%1
set len=0

:for
if not "%str%"=="" (
    set str=%str:~1%
    set /a len=%len%+1
    goto :for
)
exit /b