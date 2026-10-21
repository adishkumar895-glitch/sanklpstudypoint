@echo off
title Sanklap Study Point - Localhost Server
echo ====================================================
echo Starting Sanklap Study Point on Localhost...
echo Opening in your browser: http://localhost:8080
echo ====================================================
powershell -ExecutionPolicy Bypass -File "%~dp0server.ps1" -Port 8080
pause
