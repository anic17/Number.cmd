@echo off
	:: Fetch and decode parameters:
	setlocal enableDelayedExpansion

	set "_variable=%~1"
	set "_operand1=%~2"
	set "_operator=%~3"
	set "_operand2=%~4"

	set "@return=NaN"

	call :decode _operand1
	call :decode _operand2


	:: Call the operation function:
	if "%_operator%"=="+" goto Addition

	:: if no function was called:
	echo.ERROR. Unknown operator: "%_operator%".
exit /b 1



:Addition

	:: make sure both numbers have the same exponent
	:: by decreasing the higher exponent while increasing its mantissa:
	
	if %_operand1.exponent.integer% GTR %_operand2.exponent.integer% (
		REM difference between both exponents
		set /a delta = _operand1.exponent.integer - _operand2.exponent.integer
		REM multiply with 10^delta
		for /L %%i in (1 1 !delta!) do (
			set "_operand1.mantissa.integer=!_operand1.mantissa.integer!0"
		)
		REM decrease the exponent
		set /a _operand1.exponent.integer -= delta
	)

	if %_operand2.exponent.integer% GTR %_operand1.exponent.integer% (
		REM difference between both exponents
		set /a delta = _operand2.exponent.integer - _operand1.exponent.integer
		REM multiply with 10^delta
		for /L %%i in (1 1 !delta!) do (
			set "_operand2.mantissa.integer=!_operand2.mantissa.integer!0"
		)
		REM decrease the exponent
		set /a _operand2.exponent.integer -= delta
	)

	:: Now both exponents are equal and the addition can be started:
	if %_operand1.exponent.integer% EQU %_operand2.exponent.integer% (
	
		REM ISSUE:INT32 :: highest possible positive number: (2^32/2)-1 = 2147483647
		set /a sum = _operand1.mantissa.integer + _operand2.mantissa.integer
		
		REM save result
		set "@return=!sum!E%_operand1.exponent.integer%"
	)

goto Finish



:: Splits the String representation of a number in its parts
:: @param {String} variable name
:decode <String>%1
	if "!%~1!"=="NaN" exit /b 1
	
	REM check for static constants
	if /i "!%~1:~0,7!"=="Number." (
		REM 2.71828182845904523536028747135266249775724709369995 -> INT32
		if /i "!%~1:~7!"=="e"  set "%~1=+271828182E-8"
		REM 3.141592653589793238462643383279502884197169399375105820974944 -> INT32
		if /i "!%~1:~7!"=="pi" set "%~1=+314159265E-8"
	)
	
	REM if only E^x is given the mantissa is 1; this is needed here so the for is executed in this case, too
	if "!%~1:~0,1!"=="E"  set "%~1=+1!%~1!"
	
	REM splits the number up and sets the variables
	for /F "delims=E tokens=1,2" %%D in ("!%~1!") do (
	
		REM define mantissa
		set "%~1.mantissa.integer=%%D"
		
		REM if only E^x is given the mantissa is 1
		if "!%~1:~0,2!"=="+E" set "%~1.mantissa.integer=+1"
		if "!%~1:~0,2!"=="-E" set "%~1.mantissa.integer=-1"
		
		REM if no sign is given and the number is not zero, it's assumed to be positive
		if "!%~1.mantissa.integer:~0,1!" NEQ "+"  (
		if "!%~1.mantissa.integer:~0,1!" NEQ "-"  (
		if "!%~1.mantissa.integer:0=!" NEQ "" (
			set "%~1.mantissa.integer=+!%~1.mantissa.integer!"
		)))
		
		REM check for only zeros
		if "!%~1.mantissa.integer:0=!"=="" (
			set "%~1.zero=true"
			set "%~1.mantissa.integer=0"
		) else (
			REM remove leading zeros
			for /f "tokens=* delims=0" %%n in ("!%~1.mantissa.integer:~1!") do set "%~1.mantissa.integer=!%~1.mantissa.integer:~0,1!%%n"
		)
		
		
		REM define exponent
		set "%~1.exponent.integer=%%E"
		if "%%E"=="" (
			if "!%~1:~-1!"=="E" (
				set "%~1.exponent.integer=1"
			) else (
				set "%~1.exponent.integer=0"
			)
		)
		
		REM if no sign is given and the number is not zero, it's assumed to be positive
		if "!%~1.exponent.integer:~0,1!" NEQ "+"  (
		if "!%~1.exponent.integer:~0,1!" NEQ "-"  (
		if "!%~1.exponent.integer:0=!" NEQ "" (
			set "%~1.exponent.integer=+!%~1.exponent.integer!"
		)))
		
		REM check for only zeros
		if "!%~1.exponent.integer:0=!"=="" (
			set "%~1.exponent.zero=true"
			set "%~1.exponent.integer=0"
		) else (
			REM remove leading zeros
			for /f "tokens=* delims=0" %%n in ("!%~1.exponent.integer:~1!") do set "%~1.exponent.integer=!%~1.exponent.integer:~0,1!%%n"
		)
	)
exit /b 0