# Building Docc for Agora UIKit

First generate the docs with Xcode via Terminal:

```sh
xcodebuild docbuild -scheme AgoraUIKit_iOS-Package \
	-derivedDataPath 'docc' \
	-destination generic/platform=iOS
```

Then turn the doccarchive into static docs:

```sh
$(xcrun --find docc) process-archive \
	transform-for-static-hosting AgoraUIKit_iOS.doccarchive \
	--output-path docs \
	--hosting-base-path iOS-UIKit
```

