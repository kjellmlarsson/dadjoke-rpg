**FREE

//=====================================================================
// Program: DADJOKE
// Library: JOKE
// Purpose: Fetch and display a random dad joke from icanhazdadjoke.com
//=====================================================================

ctl-opt bnddir('LIBHTTP/HTTPAPI');

/include '/QSYS.LIB/LIBHTTP.LIB/QRPGLESRC.FILE/HTTPAPI_H.MBR'

dcl-s url varchar(100) inz('https://icanhazdadjoke.com/');
dcl-s joke varchar(1000);
dcl-s jokeLen int(10);
dcl-s pos int(10);
dcl-s chunk char(51);
dcl-s response char(1);

// Main program logic
http_debug(*on);
http_setCCSIDs(1208: 0); // UTF-8

// Set Accept header to request plain text
http_setOption('accept': 'text/plain');

// Make HTTP GET request
joke = http_string('GET': url);

if joke = '';
  chunk = 'No joke for you';
  dsply chunk '' response;
  *inlr = *on;
  return;
endif;

// Display joke in 51-character chunks
jokeLen = %len(%trim(joke));
pos = 1;

dow pos <= jokeLen;
  if (pos + 50) <= jokeLen;
    chunk = %subst(joke: pos: 51);
  else;
    chunk = %subst(joke: pos);
  endif;
  
  dsply chunk '' response;
  pos += 51;
enddo;

*inlr = *on;
return;