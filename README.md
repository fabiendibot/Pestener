![Pestener](https://github.com/fabiendibot/Pestener/blob/master/pics/Pestener.png)

# Pestener

[![Build status](https://ci.appveyor.com/api/projects/status/tjpan8uo5jpe61vn?svg=true)](https://ci.appveyor.com/project/fabiendibot/Pestener) <-- Can't test on Appveyor currently building a Jenkins server :)

This version is beta, please do not use it in production right now :)

## What is Pestener ?

Pestener is a new way to factorize the length of your [Pester](https://github.com/Pester) tests.
Indeed, when you have so many [Pester](https://github.com/Pester) tests, it takes quite time for your build to finish.
This module is here to help you reduce this time, thanks to Docker.

It use the [Pester](https://github.com/Pester) file architecture to build some new Pester test file for each describe bloc.
Right now, there are limitations:

1. You must use simple Describe or inmodulescope blocks in order to have the module Workspace.
2. If you want to launch a script before tests, run it in a describe block.

## Need some examples ?
```Powershell
Import-Module Pestener.psm1
Start-Pestener -PesterFile .\Tests\DSC.tests.ps1 -Workspace D:\Git\Pestener `
               -testPath D:\temp -DockerFile D:\Git\Pestener -Maintener "Fabien Dibot" -MaintenerMail "fdibot@pwrshell.net" -NewImage
```

## Notes
Creator: 
* [Fabien Dibot](https://pwrshell.net) 
* [Twitter](https://twitter.com/fdibot)

Licence Model: MIT See licence file [here](https://github.com/fabiendibot/Pestener/LICENCE)

## Links
[Pester](https://github.com/Pester)
[Docker](https://github.com/Docker)
