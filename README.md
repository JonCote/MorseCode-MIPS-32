# MorseCode
CS230 Computer Architecture and Assembly Language UVic, Assignment

Develop from scratch a morse code program using MIPS-32 assembly language

Functions:
  Morse_flash: send binary string morse code data to digital lab sim to flash on screen where 0 is a dot (short flash) and 1 is a dash (long flash)
  Flash_message: store one-byte binary data into memory then sending the data to Morse_flash to be displayed on screen
  Letter_to_code: convert letter into its one-byte equivalent and store into memory
  Encode_message: use Letter_to_code to convert a whole string into binary code
  
With all four functions we are able to convert each letter of a string input into its respective one-byte equivalent binary code and them display the string on screen as morse code
  
  
  
