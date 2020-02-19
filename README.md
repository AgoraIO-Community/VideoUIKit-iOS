# AgoraUIKit

To use this pod, add the following to your Podfile:

`source 'https://github.com/zontan/PodSpecs.git'`

`pod 'AgoraUIKit'`

You can then create an Agora Video View Controller with the following code:

```
let agoraView = AgoraVideoViewController.create(appID: "YOUR_APP_ID", token: "YOUR_TOKEN_OR_NIL", channel: channelName)
                
navigationController?.pushViewController(agoraView, animated: true)
```
