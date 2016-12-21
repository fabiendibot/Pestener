=================
What is Pestener ?
=================

Pestener is the concatenation of Pester & Docker.

Pester is the PowerShell most popular Unit test framework. Open Sourced and community driven, it's now included by default in Windows 10 & Windows Server 2016.
You can use it from PowerShell v2 up to v5 :)

If you don't know what Docker it means you live in another galaxy AHAHAHA :)

So, this PowerShell module is made to make your life easier during very long Pester tests splitting Pester tests files in separate Docker containers running docker on Windows box.

=================
How it works ?
=================

The module will do few things:

* Build a Docker image if needed using nanoserver or windowscore images.
* Split Pester tests files and create a folder with a specific Pester file in it.
* Run docker containers in runspaces in order to use hyperthreading as much as possible

    * The pester directory is mounted 
    * The container will start automatically the pester test
    * Each container will create a Nunit.XML file in order to send it to your CI tools

=================
How the module split Pester files ?
=================

The module uses AST (Abstract Syntax Tree) in order to parse the file.
Each describe block is splitted (except if it's in a inModuleScope block) and a folder with the describe block name trimmed is create with a pester file in it containing the describe block.
This is very important to understand this logic, because it means that if you load some code outside these two blocks, your tests will fail.
You must store all your spefici code in Describe blocks, even if it means repeat it during all along your test script.