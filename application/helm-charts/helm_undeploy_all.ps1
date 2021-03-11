#!/usr/bin/env pwsh
#Requires -PSEdition Core

param 
(
    [Parameter(Mandatory = $true)]
    [ValidateLength(1,255)]
    [ValidateNotNull()]
    [string]
    $Namespace
)

$Namespace = $Namespace.ToLower()

Write-Host "Namespace:        $Namespace"

helm delete bookstore-advanced --namespace $Namespace
if ($LastExitCode -gt 0) { throw "helm delete error" }