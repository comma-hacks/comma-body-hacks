pushd ~
test -d comma-body-hacks || git clone git@github.com:kfatehi/comma-body-hacks
PROFILE=$(case "$SHELL" in 
*/bash) echo "$HOME/.bashrc" ;;
*/zsh) echo "$HOME/.zprofile" ;;
esac)
source $PROFILE
which cbh > /dev/null || echo "export PATH="\$HOME/comma-body-hacks/bin:\$PATH" >> $PROFILE
source $PROFILE
popd