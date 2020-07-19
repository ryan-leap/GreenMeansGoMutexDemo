<#
.SYNOPSIS
    Provides a visual demonstration of a Mutex
.PARAMETER MutexName
    The name of the Mutex to create/reference
.PARAMETER OwnershipTimeout
    The number of seconds to hold the mutex when owned.  For demo purposes the ownership time
    will decrease each pass (wait cycle).
.PARAMETER WaitCycleCount
    The number of passes to take for the demo
.PARAMETER HostColorOwning
    The color the host should be painted to indicate the process owns the Mutex
.PARAMETER HostColorWaiting
    The color the host should be painted to indicate the process is waiting to own the Mutex
.PARAMETER LogPath
    Path to the shared log file
.NOTES
    Author: Ryan Leap
    Email: ryan.leap@gmail.com
#>
[CmdletBinding()]
param (
    [string] $MutexName = 'GreenMeansGoMutexDemo',

    [ValidateRange(1,30)]
    [int] $OwnershipTimeout = 3,

    [ValidateRange(3,50)]
    [int] $WaitCycleCount = 20,

    [ValidateSet('Black', 'DarkBlue', 'DarkGreen', 'DarkCyan','DarkRed', 'DarkMagenta', 'DarkYellow',
    'Gray','DarkGray', 'Blue', 'Green', 'Cyan','Red', 'Magenta', 'Yellow', 'White')]
    [string] $HostColorOwning = 'DarkGreen',

    [ValidateSet('Black', 'DarkBlue', 'DarkGreen', 'DarkCyan','DarkRed', 'DarkMagenta', 'DarkYellow',
    'Gray','DarkGray', 'Blue', 'Green', 'Cyan','Red', 'Magenta', 'Yellow', 'White')]
    [string] $HostColorWaiting = 'DarkRed',

    [string] $LogPath = (Join-Path -Path $PSScriptRoot -ChildPath 'GreenMeansGo.Log')
)

function New-Mutex {
<#
.SYNOPSIS
    Produces an array that when displayed to the console is shaped like a rectangle.
.PARAMETER Name
    Specifies the name of the Mutex to create/reference
.NOTES
    Author: Ryan Leap
    Email: ryan.leap@gmail.com
#>
    param (
        [Parameter(Mandatory)]
        [string] $Name
    )

    [bool] $createdMutex = $false
    $mutex = New-Object System.Threading.Mutex($false, $Name, [ref] $createdMutex)
    Add-Member -InputObject $mutex -NotePropertyName 'Created' -NotePropertyValue $createdMutex
    Add-Member -InputObject $mutex -NotePropertyName 'Name' -NotePropertyValue $Name -PassThru
}

function Update-HostBackgroundColor {
<#
.SYNOPSIS
    "Paints" the host with the color specified
.PARAMETER Color
    Specifies one of the 16 available console colors
.NOTES
    Author: Ryan Leap
    Email: ryan.leap@gmail.com
#>
    param (
            [string] $color
    )

    $host.UI.RawUI.BackgroundColor = $color
    Clear-Host
}

function New-ShapeRectangle {
<#
.SYNOPSIS
    Produces an array that when displayed to the console is shaped like a rectangle.
.DESCRIPTION
    Creates an array whose arrangement of characters resembles a rectangle when displayed to the console.
    Intended to be used for fun or displaying nicely formatted messages to an end user.
.PARAMETER Height
    Specifies the height (array count) of the rectangle.
.PARAMETER Width
    Specifies the width (string length) of the rectangle.
.PARAMETER MarginTop
    Specifies the number of blank lines above the rectangle.
.PARAMETER MarginBottom
    Specifies the number of blank lines below the rectangle.
.PARAMETER MarginLeft
    Specifies the number of blank columns to the left of the rectangle.
.PARAMETER EdgeChar
    Specifies the character to be used to draw the edges of the rectangle.
.PARAMETER FillChar
    Specifies the character to be used to fill the contents of the rectangle.
.PARAMETER TextEmbed
    Specifies a string to place inside the rectangle
.PARAMETER TextAlignHorizontal
    Specifies the horizontal alignment of the text embedded in the rectangle
.PARAMETER TextAlignVertical
    Specifies the vertical alignment of the text embedded in the rectangle
.EXAMPLE
    New-ShapeRectangle -TextEmbed 'Hello World!'
.EXAMPLE
    New-ShapeRectangle -Height 10 -TextEmbed 'Hello World!' -TextAlignHorizontal Left -TextAlignVertical Bottom
.NOTES
    Author: Ryan Leap
    Email: ryan.leap@gmail.com
#>
[CmdletBinding(DefaultParameterSetName='Standard',PositionalBinding=$false)]
    param (
        [ValidateRange(3,5120)]
        [Parameter(Mandatory = $false)]
        [int16] $Height = [math]::Floor($host.UI.RawUI.WindowSize.Height / 5),

        [ValidateRange(3,5120)]
        [Parameter(Mandatory = $false)]
        [int16] $Width = [math]::Floor($host.UI.RawUI.WindowSize.Width - 4),

        [ValidateRange(0,120)]
        [Parameter(Mandatory = $false)]
        [int16] $MarginTop = 1,

        [ValidateRange(0,120)]
        [Parameter(Mandatory = $false)]
        [int16] $MarginBottom = 1,

        [ValidateRange(0,100)]
        [Parameter(Mandatory = $false)]
        [int16] $MarginLeft = 2,

        [ValidateLength(1,1)]
        [Parameter(Mandatory = $false)]
        [string] $EdgeChar = '*',

        [ValidateLength(1,1)]
        [Parameter(Mandatory = $false)]
        [string] $FillChar = ' ',

        [ValidateLength(1,115)]
        [Parameter(ParameterSetName='Embed',Mandatory=$true)]
        [string] $TextEmbed,

        [ValidateSet('Left','Right','Center')]
        [Parameter(ParameterSetName='Embed',Mandatory=$false)]
        [string] $TextAlignHorizontal = 'Center',

        [ValidateSet('Top','Bottom','Middle')]
        [Parameter(ParameterSetName='Embed',Mandatory=$false)]
        [string] $TextAlignVertical = 'Middle'
    )

    if ($TextEmbed) {
        switch ($TextAlignVertical) {
        'Top'    { [int16] $verticalAlignment = 1 }
        'Bottom' { [int16] $verticalAlignment = $Height - 4 }
        'Middle' { [int16] $verticalAlignment = ([math]::Ceiling($Height / 2)) - 2 }
        }
    }
    # Top Margin
    for ($i = 0; $i -lt $MarginTop; $i++) {
        @(' ' * $Width)
    }

    # Draw Shape
    (' ' * $MarginLeft) + $EdgeChar * $Width
    for ($i = 0; $i -lt ($Height-2); $i++) {
        if ($TextEmbed -and ($i -eq $verticalAlignment)) {
            switch ($TextAlignHorizontal) {
                'Left'   { (' ' * $MarginLeft) + $EdgeChar + $FillChar + $TextEmbed + ($FillChar * ($Width - $TextEmbed.Length - 3)) + $EdgeChar }
                'Right'  { (' ' * $MarginLeft) + $EdgeChar + ($FillChar * ($Width - $TextEmbed.Length - 3)) + $TextEmbed + $FillChar + $EdgeChar }
                'Center' {
                    [bool] $oddWidth = $Width % 2
                    [bool] $oddTextLength = $TextEmbed.Length % 2
                    [int16] $insideShapeWidth = $Width - 2
                    $paddingTotal = $insideShapeWidth - $TextEmbed.Length
                    $paddingOnEachSide = [math]::Floor($paddingTotal /2)
                    $paddingLeft = $FillChar * $paddingOnEachSide
                    if ($oddWidth) {
                        if ($oddTextLength) {
                            $paddingRight = $FillChar * $paddingOnEachSide
                        }
                        else {
                            $paddingRight = $FillChar * ($paddingOnEachSide + 1)
                        }
                    }
                    else {
                        if ($oddTextLength) {
                            $paddingRight = $FillChar * ($paddingOnEachSide + 1)
                        }
                        else {
                            $paddingRight = $FillChar * $paddingOnEachSide
                        }
                    }
                    (' ' * $MarginLeft) + $EdgeChar + $paddingLeft + $TextEmbed + $paddingRight + $EdgeChar
                }
            }
        }
        else {
            (' ' * $MarginLeft) + $EdgeChar + ($FillChar * ($Width - 2)) + $EdgeChar
        }
    }
    (' ' * $MarginLeft) + $EdgeChar * $Width

    # Bottom Margin
    for ($i = 0; $i -lt $MarginBottom; $i++) {
        @(' ' * $Width)
    }
}

function Show-MutexOwnership {
<#
.SYNOPSIS
    Helper function that visually represents mutex ownership
.NOTES
    Author: Ryan Leap
    Email: ryan.leap@gmail.com
#>
    param ()

    Update-HostBackgroundColor -color $script:HostColorOwning
    $message = "Process [$([System.Diagnostics.Process]::GetCurrentProcess().Id)] owns Mutex [$($script:mutex.Name)]. Holding for [$($script:ownershipTimeoutMilliseconds)] milliseconds..."
    New-ShapeRectangle -TextEmbed $message -TextAlignHorizontal Left -Height 10
    Add-Content -Path $script:LogPath -Value "[$(Get-Date -Format o)] $message"
    Start-Sleep -Milliseconds $script:ownershipTimeoutMilliseconds
    $script:ownershipTimeoutMilliseconds -= $script:ownershipTimeoutDecrementBy
    $message = "Process [$([System.Diagnostics.Process]::GetCurrentProcess().Id)] releasing mutex [$($script:mutex.Name)]."
    Add-Content -Path $script:LogPath -Value "[$(Get-Date -Format o)] $message"
    $script:mutex.ReleaseMutex()
    $message = "Process [$([System.Diagnostics.Process]::GetCurrentProcess().Id)] released mutex [$($script:mutex.Name)]."
    New-ShapeRectangle -TextEmbed $message -TextAlignHorizontal Left -Height 10
}

function Show-MutexOwnershipInWaiting {
<#
.SYNOPSIS
    Helper function that visually represents waiting for mutex ownership
.NOTES
    Author: Ryan Leap
    Email: ryan.leap@gmail.com
#>
    param ()

    Update-HostBackgroundColor -color $script:HostColorWaiting
    $message = "Process [$([System.Diagnostics.Process]::GetCurrentProcess().Id)] waiting for ownership of Mutex [$($script:mutex.Name)]..."
    New-ShapeRectangle -TextEmbed $message -TextAlignHorizontal Left -Height 10
}

<# 

   Main Script

#>
$hostColor = $host.UI.RawUI.BackgroundColor
$ownershipTimeoutMilliseconds = $OwnershipTimeout * 1000
$ownershipTimeoutDecrementBy = [Math]::Floor($ownershipTimeoutMilliseconds / $WaitCycleCount)
$mutex = New-Mutex -Name $MutexName
if ($mutex.Created) {
    $message = "Process [$([System.Diagnostics.Process]::GetCurrentProcess().Id)] created Mutex [$($mutex.Name)]."
    Set-Content -Path $LogPath -Value "[$(Get-Date -Format o)] $message" -ErrorAction Stop
}

for ($i = 0; $i -lt $WaitCycleCount; $i++) {
    # Calling WaitOne Method with 0 is non-blocking request for ownership
    if ($mutex.WaitOne(0)) {
        Show-MutexOwnership
    }
    else {
        Show-MutexOwnershipInWaiting
        $null = $mutex.WaitOne()
        Show-MutexOwnership
    }
}

Update-HostBackgroundColor -color $hostColor