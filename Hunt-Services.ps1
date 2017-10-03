FUNCTION Hunt-Services {
<#
.Synopsis 
    Queries SCCM for a given hostname, FQDN, or IP address.

.Description 
    Queries SCCM for a given hostname, FQDN, or IP address.

.Parameter Computer  
    Computer can be a single hostname, FQDN, or IP address.

.Parameter CIM
    Use Get-CIMInstance rather than Get-WMIObject. CIM cmdlets use WSMAN (WinRM)
    to connect to remote machines, and has better standardized output (e.g. 
    datetime format). CIM cmdlets require the querying user to be a member of 
    Administrators or WinRMRemoteWMIUsers_ on the target system. Get-WMIObject 
    is the default due to lower permission requirements, but can be blocked by 
    firewalls in some environments.

.Example 
    Hunt-Services 
    Hunt-Services SomeHostName.domain.com
    Get-Content C:\hosts.csv | Hunt-Services
    Hunt-Services $env:computername
    Get-ADComputer -filter * | Select -ExpandProperty Name | Hunt-Services

.Notes 
    Updated: 2017-10-03
    LEGAL: Copyright (C) 2017  Anthony Phipps
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
    
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#>

    PARAM(
    	[Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        $Computer = $env:COMPUTERNAME
    );

	BEGIN{

        $datetime = Get-Date -Format "yyyy-MM-dd_hh.mm.ss.ff";
        Write-Verbose "Started at $datetime"

        $stopwatch = New-Object System.Diagnostics.Stopwatch;
        $stopwatch.Start();

        $total = 0;

        class Service {
			[String] $Computer
			[Datetime] $DateScanned
            [bool] $AcceptPause
            [bool] $AcceptStop
            [string] $Caption
            [uint32] $CheckPoint
            [bool] $DelayedAutoStart
            [string] $Description
            [bool] $DesktopInteract
            [uint32] $DisconnectedSessions
            [string] $DisplayName
            [string] $ErrorControl
            [uint32] $ExitCode
            [datetime] $InstallDate
            [string] $Name
            [string] $PathName
            [uint32] $ProcessId
            [uint32] $ServiceSpecificExitCode
            [string] $ServiceType
            [bool] $Started
            [string] $StartMode
            [string] $StartName
            [string] $State
            [string] $SystemName
            [uint32] $TagId
            [uint32] $TotalSessions
            [uint32] $WaitHint
		};
	};

    PROCESS{        
                
        $Computer = $Computer.Replace('"', '');

        $Services = Get-CIMinstance -class Win32_Service -Filter "Caption LIKE '%'" -ComputerName $Computer -ErrorAction SilentlyContinue;
        # Odd filter explanation: http://itknowledgeexchange.techtarget.com/powershell/cim-session-oddity/

        if ($Services){
                
            $Services | ForEach-Object {
                
				$output = $null;
				$output = [Service]::new();
				
				$output.Computer = $Computer;
				$output.DateScanned = Get-Date -Format u;
                
				$output.AcceptPause = $_.AcceptPause;
                $output.AcceptStop = $_.AcceptStop;
                $output.Caption = $_.Caption;
                $output.CheckPoint = $_.CheckPoint;
                $output.DelayedAutoStart = $_.DelayedAutoStart;
                $output.Description = $_.Description;
                $output.DesktopInteract = $_.DesktopInteract;
                $output.DisconnectedSessions = $_.DisconnectedSessions;
                $output.DisplayName = $_.DisplayName;
                $output.ErrorControl = $_.ErrorControl;
                $output.ExitCode = $_.ExitCode;
                if ($_.InstallDate) {
                    $output.InstallDate = $_.InstallDate;
                };
                $output.Name = $_.Name;
                $output.PathName = $_.PathName;
                $output.ProcessId = $_.ProcessId;
                $output.ServiceSpecificExitCode = $_.ServiceSpecificExitCode;
                $output.ServiceType = $_.ServiceType;
                $output.Started = $_.Started;
                $output.StartMode = $_.StartMode;
                $output.StartName = $_.StartName;
                $output.State = $_.State;
                $output.SystemName = $_.SystemName;
                $output.TagId = $_.TagId;
                $output.TotalSessions = $_.TotalSessions;
                $output.WaitHint = $_.WaitHint;
                    
                return $output; 
            };
        }
        else {
            
            Write-Verbose "System unreachable.";
            if ($Fails) {
                
                Write-Verbose "-Fails switch activated. Saving system to -Fails filepath.";
                Add-Content -Path $Fails -Value ("$Computer");
            }
            else {
                
                Write-Verbose "Writing failed Computer and DateScanned.";        
                $output = $null;
                $output = [Service]::new();

                $output.Computer = $Computer;
                $output.DateScanned = Get-Date -Format u;

                return $output;
            };
        };
        
        $elapsed = $stopwatch.Elapsed;
        $total = $total + 1;
        
        Write-Verbose "System $total `t $ThisComputer `t Total Time Elapsed: $elapsed";

    };

    END {

        $elapsed = $stopwatch.Elapsed;

        Write-Verbose "Total Systems: $total `t Total time elapsed: $elapsed";
    };
};




