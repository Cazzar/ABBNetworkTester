@echo off
mode con: cols=64 lines=47
title AussieBB Testing Tool
PowerShell.exe -NoExit -NoProfile -NoLogo -ExecutionPolicy Bypass -Command "& { $ErrorActionPreference = 'Stop'; & '%~dp0\lib\ABBNetworkTester.ps1'; exit $lastexitcode }"
