set SSL_VERIFY_SERVER=NO

FOR /F "tokens=*" %%A IN (files.txt) DO q %%A -s 4 > nul < nul
