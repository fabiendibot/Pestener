# Pestener

[![Build status](https://ci.appveyor.com/api/projects/status/x3er7r2p0n96wggd?svg=true)](https://ci.appveyor.com/project/fabiendibot/Pestener)

This version is beta, please do not use it right now :)

## What is Pestener ?

Pestener is a new way to factorize the length of your [Pester](https://github.com/Pester) tests.
Indeed, when you have so many [Pester](https://github.com/Pester) tests, it takes quite time for your build to finish.
This module is here to help you reduce this time, thanks to Docker.

It use the [Pester](https://github.com/Pester) file architecture to build some new Pester test file for each describe bloc.
Right now, there are limitations.
1. You must use simple Describe block in order to have the module Workspace
2. You can't use Inscope functions in your Pester script
3. If you want to launch a script before tests, run it in a describe block.

## Need some examples ?
``Import-Module Pestener``

``Start-Pestener -PesterFile D:\git\Pestener\Tests\DSC.tests.ps1 -OutputXML -ShouldExit -Workspace D:\Git\Pestener -PesterTests D:\temp -DockerFile D:\Git\Pestener -Maintener "Fabien Dibot" -MaintenerMail "fdibot@pwrshell.net"``

## Notes
Creator: [Fabien Dibot](https://pwrshell.net) - [Twitter](https://twitter.com/fdibot)
Licence Model: MIT See licence file [here](https://github.com/fabiendibot/Pestener/LICENCE)

## Links
[Pester](https://github.com/Pester)
[Docker](https://github.com/Pester)
