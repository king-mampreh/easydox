# easydox
Professional specification generation

## Setup
***

Please repeat this steps.

### Windows

1. Download [MSYS2](https://github.com/msys2/msys2-installer/releases/download/2020-06-02/msys2-x86_64-20200602.exe) and install it.
2. Open MSYS2 command shell.
3. Run `pacman -S doxygen` in MSYS command shell to install doxygen.
4. Run `pacman -S make` in MSYS command shell to install make.
5. Download [TexLive](http://mirror.ctan.org/systems/texlive/tlnet/install-tl-windows.exe) and install it.
6. Go to inside the main project directory `easydox` and run `./generate_dox.sh`.
   



### Linux
1. Open a terminal.
2. Run `sudo apt-get install doxygen`, to install doxygen.
3. Run `sudo apt-get install make`, to install make
4. Run `sudo apt-get install texlive-latex-extra`, to install Texlive.
5. Run `sudo apt-get install textlive-fonts-extra`, to install all fonts.
6. Go to inside the main project directory `easydox` and run `./generate_dox.sh`.


To see the generated pdf

1. Go to `easydox` file directory
2. `cd Dox\output`
3. `evince <fileName>`