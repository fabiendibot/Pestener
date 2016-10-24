## Pestener

[![Build status](https://ci.appveyor.com/api/projects/status/x3er7r2p0n96wggd?svg=true)](https://ci.appveyor.com/project/fabiendibot/Pestener)

# What is Pestener ?

Pestener is a new way to fatorize the length of your [Pester](https://github.com/Pester) tests.
Indeed, when you have so many [Pester](https://github.com/Pester) tests, it takes quite time for your build to finish.
This module is here to help you reduce this time, thanks to Docker.

It use the [Pester](https://github.com/Pester) file architecture to build some new Pester test file for each describe bloc

# Need some examples ?
Start-Pestener -TestPath C:\temp\Pestertests -OutPutXML -Workspace C:\Jenkins -CleanWorkspace -DockerFilePath C:\Jenkins\Dockerfile -Maintener 'Fabien Dibot' -MaintenerMail fdibot@pwrshell.net

# Notes
Creator: [Fabien Dibot](https://pwrshell.net) - [Twitter](https://twitter.com/fdibot)
Licence Model: <to_be_done>

# Links
Pester
Docker


## TO BE DONE 

1. Corriger les problèmes de syntaxe dans le module
2. Ajouter la possibilité de ne pas avoir à recréer le container si il existe (ça permettra de gagner du temps sur l'exécution du script)
3. Mettre en place un build automatique
     * Push automatique si succès dans PSGallery ?
4. Add every single Pester possibility to be add to each new Pester File

