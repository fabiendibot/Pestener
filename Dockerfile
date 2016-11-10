FROM microsoft/nanoserver
RUN mkdir C:\Pester
RUN mkdir C:\ThirdPartyTool
RUN mkdir C:\workspace
RUN powershell.exe -ExecutionPolicy Bypass -Command 'Install-Module Pester -Force'
CMD powershell.exe -ExecutionPolicy Bypass -Command cd C:\Pester; Invoke-Pester -OutputFormat LegacyNUnitXml -OutputFile C:\Pester\NUnit.XML -ShouldExit
