.\cc65\bin\ca65 hellones.asm -o .\Rom\hellones.o --debug-info
.\cc65\bin\ld65 .\Rom\hellones.o -o .\Rom\hellones.nes -t nes --dbgfile .\Rom\hellones.dbg
timeout 5
