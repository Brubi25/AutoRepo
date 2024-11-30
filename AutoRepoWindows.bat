@echo off

set /p dir="In welches Verzeichniss? > "
set /p username="Nutzername > "
set /p server="Server > "
set "port=22"
set /p port="Port (default: 22) > " 
set /p name="Repositiory Name > "

rename .git .git_old
cd ..
rename AutoRepo %name%
cd %name%

if not exist .git git init
git add . || goto nogit
git commit -m "first commit"
git remote add "origin" ssh://%username%@%server%:%port%%dir%
ssh -p %port% %username%@%server% "mkdir %dir% && cd %dir% && git init && git config receive.denyCurrentBranch ignore && printf '#!/bin/sh\ngit --git-dir=. --work-tree=.. checkout -f' > .git/hooks/post-receive && chmod +x .git/hooks/post-receive" || goto badServerPath
git push --set-upstream origin master
goto end

:nogit
    echo Kein git installiert
    goto end

:badServerPath
    rmdir /q /s .git
    rename .git_old .git
    goto end
:end
    del AutoRepoWindows.bat
    rmdir /q /s .git_old