@call %~dp0\printc info "Restoring the original PATH so that it does not keep growing on many runs."
@if  DEFINED OLDPATH ( @set PATH=%OLDPATH%) else call %~dp0\printc error "Cannot restore PATH, OLDPATH not found."
@set OLDPATH=
@set msgCounter=
