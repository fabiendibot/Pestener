FROM microsoft/nanoserver
RUN mkdir C:\Pester
RUN mkdir C:\ThirdPartyTool
RUN mkdir C:\Workspace
RUN powershell.exe -ExecutionPolicy Bypass -Command 'Install-Module Pester -Force'
CMD powershell.exe -ExecutionPolicy Bypass -Command cd C:\Pester; Invoke-Pester -OutputFormat LegacyNUnitXml -OutputFile C:\Workspace\Nunit.XML
