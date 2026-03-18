

winget install JanDeDobbeleer.OhMyPosh --source winget

winget upgrade JanDeDobbeleer.OhMyPosh --source winget

$themesPath = "$HOME\OhMyPoshThemes"

if (-not (Test-Path $themesPath)) {
    New-Item -ItemType directory -Path $themesPath -Force
}

$env:POSH_THEMES_PATH = $themesPath

$psrlInstalled = Get-Module -ListAvailable -Name PSReadLine | Sort-Object Version -Descending | Select-Object -First 1

if ($psrlInstalled) {
    $latestVersion = (Find-Module -Name PSReadLine -ErrorAction SilentlyContinue).Version
    if ($latestVersion -and $psrlInstalled.Version -lt $latestVersion) {
        Write-Host "PSReadLine installed (v$($psrlInstalled.Version)), but a newer version is available (v$latestVersion). Updating..." -ForegroundColor Yellow
        $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        if ($isAdmin) {
            Update-Module PSReadLine -Force
            Write-Host "PSReadLine updated to v$latestVersion." -ForegroundColor Green
        }
        else {
            Write-Host "Administrator permissions required to update PSReadLine. Run PowerShell as administrator." -ForegroundColor Red
        }
    }
    else {
        Write-Host "PSReadLine is already installed and up to date (v$($psrlInstalled.Version))." -ForegroundColor Green
    }
}
else {
    Write-Host "PSReadLine is not installed. Checking permissions..." -ForegroundColor Yellow
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if ($isAdmin) {
        Install-Module PSReadLine -Force -SkipPublisherCheck
        Write-Host "PSReadLine installed successfully." -ForegroundColor Green
    }
    else {
        Write-Host "Administrator permissions required to install PSReadLine. Run PowerShell as administrator." -ForegroundColor Red
    }
}

Invoke-WebRequest https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/paradox.omp.json -OutFile "$env:POSH_THEMES_PATH\paradox.omp.json"
Set-Content "$HOME\OhMyPoshThemes\.current_theme" "$env:POSH_THEMES_PATH\paradox.omp.json"
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\paradox.omp.json" | Invoke-Expression

$profilePath = $PROFILE

$gitAliases = @'
CLS
$themeConfigFile = "$HOME\OhMyPoshThemes\.current_theme"
if (Test-Path $themeConfigFile) {
    $savedTheme = Get-Content $themeConfigFile -Raw
    $savedTheme = $savedTheme.Trim()
    if (Test-Path $savedTheme) {
        oh-my-posh init pwsh --config $savedTheme | Invoke-Expression
    } else {
        Write-Host "Saved theme not found: $savedTheme. Using default theme." -ForegroundColor Yellow
        oh-my-posh init pwsh --config "$HOME\OhMyPoshThemes\paradox.omp.json" | Invoke-Expression
    }
} else {
    New-Item -ItemType file -Path $themeConfigFile -Force
    Write-Host "Config file created" -ForegroundColor Cyan
    oh-my-posh init pwsh --config "$HOME\OhMyPoshThemes\paradox.omp.json" | Invoke-Expression
}

# ---------- Helpers -----------------------------------------
function Get-CurrentBranch { git rev-parse --abbrev-ref HEAD }
function Get-MainBranch {
    $branches = git branch --format '%(refname:short)' 2>$null
    if ($branches -match '^main$')   { return 'main' }
    if ($branches -match '^master$') { return 'master' }
    return 'main'
}
function Get-DevBranch {
    $branches = git branch --format '%(refname:short)' 2>$null
    if ($branches -match '^develop$')     { return 'develop' }
    if ($branches -match '^development$') { return 'development' }
    return 'develop'
}

# ---------- Basic / Status ----------------------------------
function g       { git @args }
function gst     { git status }
function gss     { git status --short }
function gsb     { git status --short -b }
function gco     { git checkout @args }
function gcor    { git checkout --recurse-submodules @args }
function grs     { git restore @args }
function grss    { git restore --source @args }
function grst    { git restore --staged @args }
function gcl     { git clone --recurse-submodules @args }
function gclean  { git clean --interactive -d }
function gpristine { git reset --hard; git clean -dffx }

# Reset
function grh     { git reset @args }
function grhh    { git reset --hard @args }
function grhk    { git reset --keep @args }
function grhs    { git reset --soft @args }
function gru     { git reset -- @args }

# Misc
function ghh     { git help @args }
function gignore   { git update-index --assume-unchanged @args }
function gunignore { git update-index --no-assume-unchanged @args }
function gignored  { git ls-files -v | Select-String '^[a-z]' }
function gfg       { param($pattern) git ls-files | Select-String $pattern }
function gcount    { git shortlog --summary -n }

# Submodules
function gsi     { git submodule init }
function gsu     { git submodule update }

# Bisect
function gbs     { git bisect @args }
function gbsb    { git bisect bad }
function gbsg    { git bisect good }
function gbsn    { git bisect new }
function gbso    { git bisect old }
function gbsr    { git bisect reset }
function gbss    { git bisect start }

# ---------- Add ---------------------------------------------
function ga      { git add @args }
function gaa     { git add --all }
function gapa    { git add --patch }
function gau     { git add --update }
function gav     { git add --verbose }

# ---------- Branch ------------------------------------------
function gb      { git branch @args }
function gba     { git branch -a }
function gbd     { git branch -d @args }
function gbD     { git branch -D @args }
function gbm     { git branch --move @args }
function gbnm    { git branch --no-merged }
function gbr     { git branch --remote }
function ggsup   { git branch --set-upstream-to=origin/$(Get-CurrentBranch) }

# Switch
function gsw     { git switch @args }
function gswc    { git switch --create @args }
function gswm    { git switch $(Get-MainBranch) }
function gswd    { git switch $(Get-DevBranch) }

# Merge
function gmrg    { git merge @args }
function gma     { git merge --abort }
function gms     { git merge --squash @args }
function gmtl    { git mergetool --no-prompt }
function gmtlvim { git mergetool --no-prompt --tool=vimdiff }

# ---------- Commit ------------------------------------------
function gcom    { git commit --verbose @args }
function gc!     { git commit --verbose --amend }
function gcn!    { git commit --verbose --no-edit --amend }
function gca     { git commit --verbose --all @args }
function gca!    { git commit --verbose --all --amend }
function gcan!   { git commit --verbose --all --no-edit --amend }
function gcam    { git commit --all --message @args }
function gcas    { git commit --all --signoff }
function gcasm   { git commit --all --signoff --message @args }
function gcsm    { git commit --signoff --message @args }
function gcmsg   { git commit --message @args }
function gcs     { git commit -S @args }
function gcss    { git commit -S -s @args }
function gcssm   { git commit -S -s -m @args }

# Cherry-pick
function gcp     { git cherry-pick @args }
function gcpa    { git cherry-pick --abort }
function gcpc    { git cherry-pick --continue }

# Tag
function gts     { git tag -s @args }
function gtv     { git tag | Sort-Object { [version]($_ -replace '[^0-9.]','') } }
function gtl     { param($prefix='') git tag --sort=-v:refname -n -l "${prefix}*" }

# WIP
function gwip    { git add -A; git commit -m '--wip-- [skip ci]' }
function gunwip  {
    $last = git log -n 1 --pretty=%s
    if ($last -match '--wip--') { git reset HEAD~1 }
}

# ---------- Log ---------------------------------------------
function glog    { git log --oneline --decorate --graph }
function gloga   { git log --oneline --decorate --graph --all }
function glo     { git log --oneline --decorate }
function glol    { git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' }
function glola   { git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --all }
function glols   { git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --stat }
function glod    { git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset' }
function glods   { git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset' --date=short }
function glp     { git log --pretty=@args }
function gcount  { git shortlog --summary -n }
function gk      { Start-Process gitk -ArgumentList '--all --branches' }

# ---------- Fetch -------------------------------------------
function gf      { git fetch @args }
function gfa     { git fetch --all --prune --jobs=10 }
function gfo     { git fetch origin }

# ---------- Pull --------------------------------------------
# gl removed (conflicts with Get-Location) - use gpl instead
function gpl     { git pull }
function gpr     { git pull --rebase }
function ggpull  { git pull origin $(Get-CurrentBranch) }
function ggl     { git pull origin $(Get-CurrentBranch) }
function ggu     { git pull --rebase origin $(Get-CurrentBranch) }

# ---------- Push --------------------------------------------
function gpsh    { git push @args }
function gpd     { git push --dry-run }
function gpf     { git push --force-with-lease --force-if-includes }
function gpf!    { git push --force }
function gpoat   { git push origin --all; git push origin --tags }
function gpu     { git push upstream @args }
function gpshv   { git push --verbose }
function ggpush  { git push origin $(Get-CurrentBranch) }
function ggp     { git push origin $(Get-CurrentBranch) }

# Remote
function grv     { git remote --verbose }
function gra     { git remote add @args }
function grmv    { git remote rename @args }
function grrm    { git remote remove @args }
function grset   { git remote set-url @args }
function grup    { git remote update }

# ---------- Diff --------------------------------------------
function gd      { git diff @args }
function gdiff   { git diff @args }
function gdca    { git diff --cached }
function gdcw    { git diff --cached --word-diff }
function gds     { git diff --staged }
function gdw     { git diff --word-diff }
function gdup    { git diff '@{upstream}' }

# ---------- Stash -------------------------------------------
function gsta    { git stash push @args }
function gstaa   { git stash apply @args }
function gstc    { git stash clear }
function gstd    { git stash drop @args }
function gstl    { git stash list }
function gstp    { git stash pop }
function gsts    { git stash show --patch }
function gstu    { git stash --include-untracked }
function gstall  { git stash --all }

# ---------- Rebase ------------------------------------------
function grb     { git rebase @args }
function grba    { git rebase --abort }
function grbc    { git rebase --continue }
function grbi    { git rebase --interactive @args }
function grbs    { git rebase --skip }
function grbo    { git rebase --onto @args }
function grbd    { git rebase develop }
function grbm    { git rebase $(Get-MainBranch) }

# ---------- Worktree ----------------------------------------
function gwt     { git worktree @args }
function gwta    { git worktree add @args }
function gwtls   { git worktree list }
function gwtmv   { git worktree move @args }
function gwtrm   { git worktree remove @args }


function ghep {
    param(
        [string]$Category = "",
        [string]$Search   = ""
    )

    $aliases = @(
        # basic
        [pscustomobject]@{ Alias='g';          Command='git';                                        Cat='basic'    }
        [pscustomobject]@{ Alias='gst';         Command='git status';                                 Cat='basic'    }
        [pscustomobject]@{ Alias='gss';         Command='git status --short';                         Cat='basic'    }
        [pscustomobject]@{ Alias='gsb';         Command='git status --short -b';                      Cat='basic'    }
        [pscustomobject]@{ Alias='gco';         Command='git checkout [ref]';                         Cat='basic'    }
        [pscustomobject]@{ Alias='gcor';        Command='git checkout --recurse-submodules [ref]';    Cat='basic'    }
        [pscustomobject]@{ Alias='grs';         Command='git restore [file]';                         Cat='basic'    }
        [pscustomobject]@{ Alias='grss';        Command='git restore --source [src] [file]';          Cat='basic'    }
        [pscustomobject]@{ Alias='grst';        Command='git restore --staged [file]';                Cat='basic'    }
        [pscustomobject]@{ Alias='gcl';         Command='git clone --recurse-submodules [url]';       Cat='basic'    }
        [pscustomobject]@{ Alias='gclean';      Command='git clean --interactive -d';                 Cat='basic'    }
        [pscustomobject]@{ Alias='gpristine';   Command='git reset --hard + git clean -dffx';         Cat='basic'    }
        [pscustomobject]@{ Alias='grh';         Command='git reset [ref]';                            Cat='basic'    }
        [pscustomobject]@{ Alias='grhh';        Command='git reset --hard [ref]';                     Cat='basic'    }
        [pscustomobject]@{ Alias='grhk';        Command='git reset --keep [ref]';                     Cat='basic'    }
        [pscustomobject]@{ Alias='grhs';        Command='git reset --soft [ref]';                     Cat='basic'    }
        [pscustomobject]@{ Alias='gru';         Command='git reset -- [file]';                        Cat='basic'    }
        [pscustomobject]@{ Alias='ghh';         Command='git help [cmd]';                             Cat='basic'    }
        [pscustomobject]@{ Alias='gignore';     Command='git update-index --assume-unchanged [file]'; Cat='basic'    }
        [pscustomobject]@{ Alias='gunignore';   Command='git update-index --no-assume-unchanged';     Cat='basic'    }
        [pscustomobject]@{ Alias='gignored';    Command='list assume-unchanged files';                Cat='basic'    }
        [pscustomobject]@{ Alias='gfg';         Command='git ls-files | grep [pattern]';              Cat='basic'    }
        [pscustomobject]@{ Alias='gcount';      Command='git shortlog --summary -n';                  Cat='basic'    }
        [pscustomobject]@{ Alias='gsi';         Command='git submodule init';                         Cat='basic'    }
        [pscustomobject]@{ Alias='gsu';         Command='git submodule update';                       Cat='basic'    }
        # bisect
        [pscustomobject]@{ Alias='gbs';         Command='git bisect [args]';                          Cat='bisect'   }
        [pscustomobject]@{ Alias='gbsb';        Command='git bisect bad';                             Cat='bisect'   }
        [pscustomobject]@{ Alias='gbsg';        Command='git bisect good';                            Cat='bisect'   }
        [pscustomobject]@{ Alias='gbsn';        Command='git bisect new';                             Cat='bisect'   }
        [pscustomobject]@{ Alias='gbso';        Command='git bisect old';                             Cat='bisect'   }
        [pscustomobject]@{ Alias='gbsr';        Command='git bisect reset';                           Cat='bisect'   }
        [pscustomobject]@{ Alias='gbss';        Command='git bisect start';                           Cat='bisect'   }
        # add
        [pscustomobject]@{ Alias='ga';          Command='git add [file]';                             Cat='add'      }
        [pscustomobject]@{ Alias='gaa';         Command='git add --all';                              Cat='add'      }
        [pscustomobject]@{ Alias='gapa';        Command='git add --patch';                            Cat='add'      }
        [pscustomobject]@{ Alias='gau';         Command='git add --update';                           Cat='add'      }
        [pscustomobject]@{ Alias='gav';         Command='git add --verbose';                          Cat='add'      }
        # branch
        [pscustomobject]@{ Alias='gb';          Command='git branch';                                 Cat='branch'   }
        [pscustomobject]@{ Alias='gba';         Command='git branch -a  (all including remotes)';     Cat='branch'   }
        [pscustomobject]@{ Alias='gbd';         Command='git branch -d [branch]  (safe delete)';      Cat='branch'   }
        [pscustomobject]@{ Alias='gbD';         Command='git branch -D [branch]  (force delete)';     Cat='branch'   }
        [pscustomobject]@{ Alias='gbm';         Command='git branch --move [old] [new]';              Cat='branch'   }
        [pscustomobject]@{ Alias='gbnm';        Command='git branch --no-merged';                     Cat='branch'   }
        [pscustomobject]@{ Alias='gbr';         Command='git branch --remote';                        Cat='branch'   }
        [pscustomobject]@{ Alias='ggsup';       Command='set upstream to origin/[current branch]';    Cat='branch'   }
        [pscustomobject]@{ Alias='gsw';         Command='git switch [branch]';                        Cat='branch'   }
        [pscustomobject]@{ Alias='gswc';        Command='git switch --create [branch]';               Cat='branch'   }
        [pscustomobject]@{ Alias='gswm';        Command='git switch main/master (auto-detect)';       Cat='branch'   }
        [pscustomobject]@{ Alias='gswd';        Command='git switch develop (auto-detect)';           Cat='branch'   }
        [pscustomobject]@{ Alias='gmrg';        Command='git merge [branch]';                         Cat='branch'   }
        [pscustomobject]@{ Alias='gma';         Command='git merge --abort';                          Cat='branch'   }
        [pscustomobject]@{ Alias='gms';         Command='git merge --squash [branch]';                Cat='branch'   }
        [pscustomobject]@{ Alias='gmtl';        Command='git mergetool --no-prompt';                  Cat='branch'   }
        [pscustomobject]@{ Alias='gmtlvim';     Command='git mergetool --no-prompt --tool=vimdiff';   Cat='branch'   }
        # commit
        [pscustomobject]@{ Alias='gcom';        Command='git commit --verbose';                       Cat='commit'   }
        [pscustomobject]@{ Alias='gc!';         Command='git commit --verbose --amend';               Cat='commit'   }
        [pscustomobject]@{ Alias='gcn!';        Command='git commit --amend --no-edit';               Cat='commit'   }
        [pscustomobject]@{ Alias='gca';         Command='git commit --verbose --all';                 Cat='commit'   }
        [pscustomobject]@{ Alias='gca!';        Command='git commit --verbose --all --amend';         Cat='commit'   }
        [pscustomobject]@{ Alias='gcan!';       Command='git commit --all --amend --no-edit';         Cat='commit'   }
        [pscustomobject]@{ Alias='gcam';        Command='git commit --all --message [msg]';           Cat='commit'   }
        [pscustomobject]@{ Alias='gcas';        Command='git commit --all --signoff';                 Cat='commit'   }
        [pscustomobject]@{ Alias='gcasm';       Command='git commit --all --signoff --message [msg]'; Cat='commit'   }
        [pscustomobject]@{ Alias='gcsm';        Command='git commit --signoff --message [msg]';       Cat='commit'   }
        [pscustomobject]@{ Alias='gcmsg';       Command='git commit --message [msg]';                 Cat='commit'   }
        [pscustomobject]@{ Alias='gcs';         Command='git commit -S  (GPG signed)';                Cat='commit'   }
        [pscustomobject]@{ Alias='gcss';        Command='git commit -S -s  (signed + signoff)';       Cat='commit'   }
        [pscustomobject]@{ Alias='gcssm';       Command='git commit -S -s -m [msg]';                  Cat='commit'   }
        [pscustomobject]@{ Alias='gcp';         Command='git cherry-pick [hash]';                     Cat='commit'   }
        [pscustomobject]@{ Alias='gcpa';        Command='git cherry-pick --abort';                    Cat='commit'   }
        [pscustomobject]@{ Alias='gcpc';        Command='git cherry-pick --continue';                 Cat='commit'   }
        [pscustomobject]@{ Alias='gts';         Command='git tag -s [name]  (signed tag)';            Cat='commit'   }
        [pscustomobject]@{ Alias='gtv';         Command='git tag sorted by version';                  Cat='commit'   }
        [pscustomobject]@{ Alias='gtl';         Command='git tag list with prefix filter';            Cat='commit'   }
        [pscustomobject]@{ Alias='gwip';        Command='stage all + commit --wip--';                 Cat='commit'   }
        [pscustomobject]@{ Alias='gunwip';      Command='undo last commit if it was a wip';           Cat='commit'   }
        # log
        [pscustomobject]@{ Alias='glog';        Command='git log --oneline --decorate --graph';       Cat='log'      }
        [pscustomobject]@{ Alias='gloga';       Command='git log --oneline --graph --all';            Cat='log'      }
        [pscustomobject]@{ Alias='glo';         Command='git log --oneline --decorate';               Cat='log'      }
        [pscustomobject]@{ Alias='glol';        Command='git log --graph (pretty format)';            Cat='log'      }
        [pscustomobject]@{ Alias='glola';       Command='git log --graph --all (pretty format)';      Cat='log'      }
        [pscustomobject]@{ Alias='glols';       Command='git log --graph --stat (pretty format)';     Cat='log'      }
        [pscustomobject]@{ Alias='glod';        Command='git log --graph with date';                  Cat='log'      }
        [pscustomobject]@{ Alias='glods';       Command='git log --graph --date=short';               Cat='log'      }
        [pscustomobject]@{ Alias='glp';         Command='git log --pretty=[format]';                  Cat='log'      }
        [pscustomobject]@{ Alias='gk';          Command='open gitk --all --branches';                 Cat='log'      }
        # fetch
        [pscustomobject]@{ Alias='gf';          Command='git fetch';                                  Cat='remote'   }
        [pscustomobject]@{ Alias='gfa';         Command='git fetch --all --prune --jobs=10';          Cat='remote'   }
        [pscustomobject]@{ Alias='gfo';         Command='git fetch origin';                           Cat='remote'   }
        # pull
        # gl removed (conflicts with Get-Location) - use gpl instead
        [pscustomobject]@{ Alias='gpl';         Command='git pull';                                   Cat='remote'   }
        [pscustomobject]@{ Alias='gpr';         Command='git pull --rebase';                          Cat='remote'   }
        [pscustomobject]@{ Alias='ggpull';      Command='git pull origin [current branch]';           Cat='remote'   }
        [pscustomobject]@{ Alias='ggl';         Command='git pull origin [current branch]';           Cat='remote'   }
        [pscustomobject]@{ Alias='ggu';         Command='git pull --rebase origin [current branch]';  Cat='remote'   }
        # push
        [pscustomobject]@{ Alias='gpsh';        Command='git push';                                   Cat='remote'   }
        # gps removed (conflicts with Get-Process) - use gpsh instead
        [pscustomobject]@{ Alias='gpd';         Command='git push --dry-run';                         Cat='remote'   }
        [pscustomobject]@{ Alias='gpf';         Command='git push --force-with-lease (safe force)';   Cat='remote'   }
        [pscustomobject]@{ Alias='gpf!';        Command='git push --force';                           Cat='remote'   }
        [pscustomobject]@{ Alias='gpoat';       Command='git push origin --all + --tags';             Cat='remote'   }
        [pscustomobject]@{ Alias='gpu';         Command='git push upstream';                          Cat='remote'   }
        [pscustomobject]@{ Alias='gpshv';       Command='git push --verbose';                         Cat='remote'   }
        [pscustomobject]@{ Alias='ggpush';      Command='git push origin [current branch]';           Cat='remote'   }
        [pscustomobject]@{ Alias='ggp';         Command='git push origin [current branch]';           Cat='remote'   }
        [pscustomobject]@{ Alias='grv';         Command='git remote --verbose';                       Cat='remote'   }
        [pscustomobject]@{ Alias='gra';         Command='git remote add [name] [url]';                Cat='remote'   }
        [pscustomobject]@{ Alias='grmv';        Command='git remote rename [old] [new]';              Cat='remote'   }
        [pscustomobject]@{ Alias='grrm';        Command='git remote remove [name]';                   Cat='remote'   }
        [pscustomobject]@{ Alias='grset';       Command='git remote set-url [name] [url]';            Cat='remote'   }
        [pscustomobject]@{ Alias='grup';        Command='git remote update';                          Cat='remote'   }
        # diff
        [pscustomobject]@{ Alias='gd';          Command='git diff';                                   Cat='diff'     }
        [pscustomobject]@{ Alias='gdiff';       Command='git diff';                                   Cat='diff'     }
        [pscustomobject]@{ Alias='gdca';        Command='git diff --cached';                          Cat='diff'     }
        [pscustomobject]@{ Alias='gdcw';        Command='git diff --cached --word-diff';              Cat='diff'     }
        [pscustomobject]@{ Alias='gds';         Command='git diff --staged';                          Cat='diff'     }
        [pscustomobject]@{ Alias='gdw';         Command='git diff --word-diff';                       Cat='diff'     }
        [pscustomobject]@{ Alias='gdup';        Command='git diff @{upstream}';                       Cat='diff'     }
        # stash
        [pscustomobject]@{ Alias='gsta';        Command='git stash push';                             Cat='stash'    }
        [pscustomobject]@{ Alias='gstaa';       Command='git stash apply';                            Cat='stash'    }
        [pscustomobject]@{ Alias='gstc';        Command='git stash clear';                            Cat='stash'    }
        [pscustomobject]@{ Alias='gstd';        Command='git stash drop';                             Cat='stash'    }
        [pscustomobject]@{ Alias='gstl';        Command='git stash list';                             Cat='stash'    }
        [pscustomobject]@{ Alias='gstp';        Command='git stash pop';                              Cat='stash'    }
        [pscustomobject]@{ Alias='gsts';        Command='git stash show --patch';                     Cat='stash'    }
        [pscustomobject]@{ Alias='gstu';        Command='git stash --include-untracked';              Cat='stash'    }
        [pscustomobject]@{ Alias='gstall';      Command='git stash --all';                            Cat='stash'    }
        # rebase
        [pscustomobject]@{ Alias='grb';         Command='git rebase [branch]';                        Cat='rebase'   }
        [pscustomobject]@{ Alias='grba';        Command='git rebase --abort';                         Cat='rebase'   }
        [pscustomobject]@{ Alias='grbc';        Command='git rebase --continue';                      Cat='rebase'   }
        [pscustomobject]@{ Alias='grbi';        Command='git rebase --interactive [ref]';             Cat='rebase'   }
        [pscustomobject]@{ Alias='grbs';        Command='git rebase --skip';                          Cat='rebase'   }
        [pscustomobject]@{ Alias='grbo';        Command='git rebase --onto [target]';                 Cat='rebase'   }
        [pscustomobject]@{ Alias='grbd';        Command='git rebase develop';                         Cat='rebase'   }
        [pscustomobject]@{ Alias='grbm';        Command='git rebase main/master (auto-detect)';       Cat='rebase'   }
        # worktree
        [pscustomobject]@{ Alias='gwt';         Command='git worktree [args]';                        Cat='worktree' }
        [pscustomobject]@{ Alias='gwta';        Command='git worktree add [path] [branch]';           Cat='worktree' }
        [pscustomobject]@{ Alias='gwtls';       Command='git worktree list';                          Cat='worktree' }
        [pscustomobject]@{ Alias='gwtmv';       Command='git worktree move [src] [dst]';              Cat='worktree' }
        [pscustomobject]@{ Alias='gwtrm';       Command='git worktree remove [path]';                 Cat='worktree' }
    )

    # Category map: short name -> display label
    $catLabels = [ordered]@{
        basic    = "Basic / Status / Reset"
        bisect   = "Bisect"
        add      = "Add"
        branch   = "Branch / Switch / Merge"
        commit   = "Commit / Cherry-pick / Tag / WIP"
        log      = "Log"
        remote   = "Fetch / Pull / Push / Remote"
        diff     = "Diff"
        stash    = "Stash"
        rebase   = "Rebase"
        worktree = "Worktree"
    }

    # Filter by -Search
    if ($Search) {
        $aliases = $aliases | Where-Object {
            $_.Alias   -like "*$Search*" -or
            $_.Command -like "*$Search*"
        }
    }

    # Filter by positional category
    if ($Category -and $Category -ne "") {
        $cat = $Category.ToLower()
        if (-not $catLabels.Contains($cat)) {
            Write-Host ""
            Write-Host " Unknown category '$Category'. Available categories:" -ForegroundColor Yellow
            $catLabels.Keys | ForEach-Object { Write-Host "   $_" -ForegroundColor DarkCyan }
            Write-Host ""
            return
        }
        $aliases = $aliases | Where-Object { $_.Cat -eq $cat }
    }

    # ---- Render ------------------------------------------------
    $colAlias = 13
    $colCmd   = 54

    function Write-Header {
        param([string]$label)
        $line = "-" * ($colAlias + $colCmd + 5)
        Write-Host ""
        Write-Host $line -ForegroundColor DarkGray
        Write-Host "  $label" -ForegroundColor Cyan
        Write-Host $line -ForegroundColor DarkGray
    }

    function Write-Row {
        param([string]$alias, [string]$command)
        Write-Host "  " -NoNewline
        Write-Host ($alias.PadRight($colAlias)) -NoNewline -ForegroundColor Yellow
        Write-Host "  " -NoNewline
        Write-Host $command -ForegroundColor White
    }

    Write-Host ""
    Write-Host '  Git aliases - PowerShell (Oh My Zsh style)' -ForegroundColor Cyan
    if ($Search)   { Write-Host "  Filter: '$Search'" -ForegroundColor DarkGray }
    if ($Category) { Write-Host "  Category: $Category" -ForegroundColor DarkGray }

    if ($Search -or $Category) {
        # Flat list when filtered
        Write-Header "Results"
        foreach ($row in $aliases) {
            Write-Row $row.Alias $row.Command
        }
        Write-Host ""
        Write-Host "  $($aliases.Count) alias(es) found" -ForegroundColor DarkGray
    } else {
        # Group by category
        foreach ($cat in $catLabels.Keys) {
            $rows = $aliases | Where-Object { $_.Cat -eq $cat }
            if ($rows.Count -eq 0) { continue }
            Write-Header $catLabels[$cat]
            foreach ($row in $rows) {
                Write-Row $row.Alias $row.Command
            }
        }
        Write-Host ""
        Write-Host "  $($aliases.Count) aliases total" -ForegroundColor DarkGray
        Write-Host '  Usage: ghep [category]   |   ghep -Search [term]' -ForegroundColor DarkGray
    }

    Write-Host ""
}


function gthemes {
    $themes = @(Get-ChildItem "$HOME\OhMyPoshThemes\" -Filter *.omp.json | Select-Object -ExpandProperty Name)
    $themes += "Open themes folder"
    if ($themes.Count -eq 1) { Write-Host "No themes installed." -ForegroundColor Yellow; return }

    $index = 0
    while ($true) {
        Clear-Host
        Write-Host "Theme Selector (Up/Down + Enter, ESC to cancel):" -ForegroundColor Cyan
        for ($i = 0; $i -lt $themes.Count; $i++) {
            if ($i -eq $index) { Write-Host ("> " + $themes[$i]) -ForegroundColor Green }
            else { Write-Host ("  " + $themes[$i]) }
        }

        $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").VirtualKeyCode
        if ($key -eq 38) { if ($index -gt 0) { $index-- } }
        elseif ($key -eq 40) { if ($index -lt ($themes.Count - 1)) { $index++ } }
        elseif ($key -eq 13) { break }
        elseif ($key -eq 27) { return }
    }

    $sel = $themes[$index]
    if ($sel -eq "Open themes folder") {
        explorer "$HOME\OhMyPoshThemes\"
        return
    }

    $tp = Join-Path "$HOME\OhMyPoshThemes\" $sel
    $tp | Set-Content "$HOME\OhMyPoshThemes\.current_theme"
    oh-my-posh init pwsh --config $tp | Invoke-Expression
    Write-Host ('Switched to: ' + $sel + ' - saved as default theme') -ForegroundColor Green
}
'@


if (-not (Test-Path $profilePath)) {
    New-Item -ItemType File -Path $profilePath -Force
}

Set-Content -Path $profilePath -Value $gitAliases -Encoding UTF8

. $PROFILE
