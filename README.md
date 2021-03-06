# Number.cmd
A new data type for Batch, that can represent large and floating-point numbers and enables calculation with those.

# Syntax
```
command  = "Number ",variable," = ",number," ",operator," ",number;
variable = ("a"|"b"|...|"z"),[variable];
operator = "+"|"-"|"*"|"/";

number   = (integer,["E",[integer]])|"E",[integer]|"NaN";
integer  = [sign],digits;
sign     = "+"|"-";
digits   = ("0"|"1"|...|"9"),[digits];
```

# Examples
```
Number x = 4 + 48
Number x = %x% * -E5
Number y = 50E5 + 2E5
Number result = %x% + %y%
```
Note: In batch files you have to `call Number` to continue execution.

# Exitcodes
```
 0: Success
 1: First operand is not a number (NaN)
 2: Second operand is not a number (NaN)
 3: Unknown operator
 4: Missing parameter(s)
```

# Standard Output
Number.cmd does not write anything to standard output (stdout) by default. If you want the result to be printed, for example when using Number.cmd directly in cmd, you can use `#` instead of a variable-name with an equal-sign.  
The following command for example will output "+8E-1" to the standard output stream:
```
Number # 4 / 5
```
