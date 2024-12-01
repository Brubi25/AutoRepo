@echo off

set localPath="."
set /p localPath="Welchen Ordner / Repo hochlanden > "
set /p dir="In welches Verzeichniss? > "
set /p username="Nutzername > "
set /p server="Server > "
set "port=22"
set /p port="Port (default: 22) > " 

cd %localPath% || goto badLocalPath

if not exist .git (
    git init 
    echo "# git_set_upstream" >> README.md
) 
git add . || goto nogit
git commit -m "first commit"

git remote set-url "origin" ssh://%username%@%server%:%port%%dir% || git remote add "origin" ssh://%username%@%server%:%port%%dir% || goto badServerPath
ssh -p %port% %username%@%server% "mkdir %dir%; cd %dir% && git init && git config receive.denyCurrentBranch ignore && printf '#!/bin/sh\ngit --git-dir=. --work-tree=.. checkout -f' > .git/hooks/post-receive && chmod +x .git/hooks/post-receive" || goto badServerPath

git push --set-upstream origin master
goto end

:nogit
    echo Kein git installiert
    goto error

:badServerPath
    echo Server Path schlecht
    goto error
:badLocalPath
    echo Local Path schlecht
    goto end
:error
    rmdir /q /s .git
    del README.md
:end