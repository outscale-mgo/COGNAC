#-Wincompatible-pointer-types
oapi-cli: main.c osc_sdk.h osc_sdk.c main-helper.h $(JSON_C_RULE)
	gcc -g  main.c osc_sdk.c $(CURL_LD) $(JSON_C_LDFLAGS) $(CURL_CFLAGS) $(JSON_C_CFLAGS) -o oapi-cli -DWITH_DESCRIPTION=1

appimagetool-x86_64.AppImage:
	wget https://github.com/AppImage/AppImageKit/releases/download/12/appimagetool-x86_64.AppImage
	chmod +x appimagetool-x86_64.AppImage

oapi-cli-x86_64.AppImage: oapi-cli oapi-cli-completion.bash appimagetool-x86_64.AppImage
	mkdir -p oapi-cli.AppDir/usr/
	mkdir -p oapi-cli.AppDir/usr/bin/
	mkdir -p oapi-cli.AppDir/usr/lib/
	cp oapi-cli oapi-cli.AppDir/usr/bin/
	cp oapi-cli-completion.bash oapi-cli.AppDir/usr/bin/
	LD_LIBRARY_PATH="$(LD_LIB_PATH)" ./cp-lib.sh oapi-cli ./oapi-cli.AppDir/usr/lib/
	./appimagetool-x86_64.AppImage oapi-cli.AppDir
