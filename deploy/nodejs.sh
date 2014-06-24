apt-get install libv8-dev -y
echo 'export PATH=$HOME/.npm/bin:$PATH' >> ~/.bashrc
. ~/.bashrc
mkdir ~/.npm
mkdir ~/nodejs
cd ~/nodejs
curl http://nodejs.org/dist/node-latest.tar.gz | tar xz --strip-components=1
./configure --prefix=~/.npm
make install -j8
curl https://www.npmjs.org/install.sh | sh