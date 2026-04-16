# Specification for IBM i RPG Dadjoke program

Create a simple RPG program that retrieves a random dad joke from the Dad Joke API and displays it to the user.

## Functionality

When executing, the program fetches a dad joke from the https://icanhazdadjoke.com/ REST endpoint and stores it in a variable. It then displays the joke to the user with the dsply command and waits for the user to press enter before exiting. Jokes can be longer than the dsply 52 character limit, the program will handle this by looping until all the content of the joke has been displayed to the user.

One program call returns one joke.

## Technical

* Use the LIBHTTP http_string procedure to make the HTTP GET request with text/plain as the content type. 
* Use strict SSL verification.
* The program name is DADJOKE.PGM.RPGLE and it is stored in the JOKE library.

## Building and running

Development happens locally on a developer laptop. Compilation is done on a remote i-series server. 

### Compiling

Create a compile-dadjoke.sh script that runs locally on the developer laptop and uses scp to copy the local program source file to the i environment and then uses ssh to create library, source file and member (if necessary). The script needs to handle that either of library, source file and member alreadu exists or doesnt exist. After this, the script compiles the program and displays the compilation results. 


### Running

Create a run-dadjoke.sh script that runs locally on the developer laptop and uses ssh to execute the program on the i environment. The script creates a temporary SQL file that adds the LIBHTTP and JOKE libraries using QSYS2.QCMDEXC. Then it executes the script using RUNSQLSTM SRCSTMF.

The script fetches output from the system operator message queue and displays it on the developer laptop

### Connectivity

For scp and ssh, use the private key in pem_user_privatekey_download.pem and the ip address 10.0.0.1.