git clone --depth 1 https://github.com/savageogre/opengate.git
cd opengate
echo "Test base functionality"
/usr/local/bin/opengate ./beats/meditation_delta.yaml -o meditation_delta.flac
echo "Test TTS functionality"
/usr/local/bin/opengate ./openstates/001_liminal_state.yaml -o liminal_state.flac
echo "Done!"