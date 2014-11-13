# iOS Fake Carrier
The purpose of this small class is to make pefrect status bar for your App Store screenshots. 


![example](webimages/statusbars.png?raw=true)

## How to use - quick start
The easies way is to use CocoaPods - simply install *iOSFakeCarrier* pod into your project. Then in `applicationDidFinishLaunching` add this sniplet:

```objective-c

    NSDateComponents* dateCom = [[NSDateComponents alloc] init];
    dateCom.hour = 13;
    dateCom.minute = 22;
    [XCDFakeCarrier setLocalizedStatusBarWithTime:dateCom];

```

This will set time in status bar to 13:22 (or 1:22 pm if you are in US). The time is localized - based on your language settings.
This `setLocalizedStatusBarWithTime` also automtically adds carrier name based on language settings - for example in USA it is AT&T, in 
Germany T-Mobile DE and so on. Feel free to create pull request with carrier info for other countries / languages, there is only few 
of them now.

## Additinal methods
You can use additional methods to fine tune your status bar. There are methods like:

```objective-c

	// status bar customizations
	/* 0 to 5 */
	+ (void)setCellStrength:(int)cellStrength;

	/* 0 to 3 */
	+ (void)setWiFiStrength:(int)wifiStrength;
	/*
	 dataNetworkType:
	 0 - GPRS
	 1 - E (EDGE)
	 2 - 3G
	 3 - 4G
	 4 - LTE
	 5 - Wi-Fi
	 6 - Personal Hotspot
	 7 - 1x
	 8 - Blank
	 */
	+ (void)setNetworkType:(int)networkType;

	/*
	 itemIsEnabled:
	 
	 1 - do not disturb
	 2 - airplane mode
	 3 - cell signal strength indicator
	 6 - show time on right side
	 10 - strange battery symbol
	 11 - Bluetooth
	 12 - strange telephone symbol
	 13 - alarm clock
	 13 - slanted plus sign
	 16 - location services
	 17 - orientation lock
	 19 - AirPlay
	 20 - microphone
	 21 - VPN
	 22 - forwarded call?
	 23 - spinning activity indicator	+(void)setFakeCarrier:(NSString*) newCarrier;

	 24 - square
	 */
	+ (void)setEnabled:(BOOL)enabled atIndex:(NSInteger)index;

	/*
	 Sets carrier to specific string 
	 */

	/*
	 Sets time info to specific string
	 */
	+(void)setFakeTime:(NSString*) newFakeTime;


```

## Don't forgot...
To remove this module from production build. Not only your customers will not be happy with status bar with strange carrier info and
"frozen" wrong time, but it will also hardly goes through App Store review. We added compilation warning, when this class is used. Ideally, 
create different target sdasdfor screenshot creation or at least `IFDEF` this class.

## Carrier info for my country is not included?
Feel free to add new language to the project and then add fakeCarrier key to FakeiOSLocalized.strings. Then send me pull request new country
will be supported in the new release.

## Credits
The core of the status bar code was used from https://gist.github.com/0xced/3035167 Copyright (c) 2012-2013 Cédric Luthi / @0xced. I also 
used mofied version with additional methods from https://github.com/ksuther/StatusBarCustomization.git and fixed it to work with latest iOS.

More info also on my blog post: http://www.tappytaps.com/blog/developer/nice-status-bar-for-app-store-screenshots/