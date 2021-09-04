# JStout's NES Programming Notes

***WIP*** Starting to jump back into this fall of 2021, I'll update this repo as I get a grapple on this again.

Just putting [jstout's notes][1] here, excellent set of notes.  However, wanted to remove the SMB1 graphics
files and use assets generated by [NES Screen Tool][2].

## Building the Demos

I use the assembler/linker provided by the [cc65 compiler][3] and [FCEUX][6] for debugging.  Install both on Debian-based distros (or, on Windows via WSL) by simply executing:

```bash
sudo apt install cc65 fceux
```

Each demo will have to be compiled individually.  Just execute `make` within the directory of the demo's corresponding make file.

## Editing

Not a requirement, but the code editor I use is [Visual Studio Code][4] with the Cole Campbell's [language support extension][5].  To install Visual Studio Code (again, on Debian-based distros or Windows WSL), execute:

```bash
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt update -y && sudo apt upgrade -y
sudo apt install apt-transport-https
sudo apt update -y
sudo apt install code
echo -e "export DOTNET_CLI_TELEMETRY_OPTOUT=1" >> ~/.bashrc
source ~/.bashrc
```

[1]: http://tecmobowl.org/forums/topic/55469-nes-programming-info/
[2]: https://shiru.untergrund.net/software.shtml
[3]: https://cc65.github.io/index.html
[4]: https://code.visualstudio.com
[5]: https://github.com/tlgkccampbell/code-ca65
[6]: https://fceux.com/web/home.html
