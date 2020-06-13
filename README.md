# easydox
Professional specification generation

## For generating documents

***

Please repeat this steps.

### Windows

1. For Download the MSYS2 terminal, click [here](https://github.com/msys2/msys2-installer/releases/download/2020-06-02/msys2-x86_64-20200602.exe).
2. Install it, and run MSYS2.exe file.
3. Type `pacman -S doxygen`, press `Enter`
4. Type `pacman -S make`, press `Enter`
5. For download the TexLive, click [here](http://mirror.ctan.org/systems/texlive/tlnet/install-tl-windows.exe).
6. Run `install-tl-windows.exe` file and do instalation.
7. Go to `easydox` file destination
8. `./generate_dox.sh`
   



### Linux
1. Open terminal
2. `sudo apt-get install doxygen`
3. `sudo apt-get install make`
4. `sudo apt-get install texlive-latex-extra`
5. `sudo apt-get install textlive-fonts-extra`
6. Go to `easydox` file repository.
7. `./generate_dox.sh`


For see the generated pdf

1. Go to `easydox` file directory
2. `cd Dox\output`
3. `evince <fileName>`