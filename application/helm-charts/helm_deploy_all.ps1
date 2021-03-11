#!/usr/bin/env pwsh
#Requires -PSEdition Core

param 
(
    [Parameter(Mandatory = $true)]
    [ValidateLength(1,255)]
    [ValidateNotNull()]
    [string]
    $Namespace,

    [Parameter(Mandatory = $true)]
    [ValidateLength(1,255)]
    [ValidateNotNull()]
    [string]
    $Image,

    [Parameter(Mandatory = $true)]
    [ValidateLength(1,255)]
    [ValidateNotNull()]
    [string]
    $Tag,

    [Parameter(Mandatory = $false)]
    [ValidateLength(1,255)]
    [ValidateNotNull()]
    [string]
    $IngressPath = '/'
)

Set-StrictMode -Version latest
$ErrorActionPreference = "Stop"

$Namespace = $Namespace.ToLower()

Write-Host "Namespace:        $Namespace"
Write-Host "Image:            $Image"
Write-Host "Tag:              $Tag"

&helm upgrade bookstore-advanced ./bookstore-advanced --install --namespace $Namespace --set "`"image.repository=$($Image)`"" --set "`"image.tag=$($Tag)`"" --set "`"ingress.path=$($IngressPath)`"" --create-namespace
if ($LastExitCode -gt 0) { throw "helm deploy error" }