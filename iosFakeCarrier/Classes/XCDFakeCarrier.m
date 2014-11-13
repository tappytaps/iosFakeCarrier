//
// Copyright (c) 2012-2013 Cédric Luthi / @0xced. All rights reserved.
//

// Adapted from https://gist.github.com/0xced/3035167 to allow modifying signal strength and other symbols
// Adapted from https://github.com/ksuther/StatusBarCustomization.git


//#warning Fake carrier enabled - disable it from production build!

static const char *fakeCarrier;
static const char *fakeTime;
static int fakeCellSignalStrength = -1;
static int fakeWifiStrength = 3; // default to full strength
static int fakeDataNetwork = 5; // default to Wi-Fi



#import "XCDFakeCarrier.h"
#import <objc/runtime.h>

static NSString* fakeCarrierS;
static NSString* fakeTimeS;


static NSMutableDictionary *fakeItemIsEnabled;


typedef struct {
    char itemIsEnabled[25];
    char timeString[64];
    int gsmSignalStrengthRaw;
    int gsmSignalStrengthBars;
    char serviceString[100];
    BOOL serviceCrossfadeString[100];
    BOOL serviceImages[2][100];
    BOOL operatorDirectory[1024];
    unsigned int serviceContentType;
    int wifiSignalStrengthRaw;
    int wifiSignalStrengthBars;
    unsigned int dataNetworkType;
    int batteryCapacity;
    unsigned int batteryState;
    BOOL batteryDetailString[150];
    // ...
} StatusBarData;

@implementation XCDFakeCarrier


+(void)setLocalizedStatusBarWithTime:(NSDateComponents*)time {
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDate* dateTime = [calendar dateFromComponents:time];
    [self setFakeTime:[NSDateFormatter localizedStringFromDate:dateTime dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle]];
    [self setFakeCarrier:NSLocalizedStringFromTableInBundle(@"fakeCarrier", @"FakeiOSLocalized", [self bundle], @"")];
}

+ (NSBundle *)bundle
{
    NSBundle *bundle;
    
    NSURL *bundleUrl = [[NSBundle mainBundle] URLForResource:@"iosFakeCarrier" withExtension:@"bundle"];
    
    if (bundleUrl) {
        // Should be, when using cocoapods
        bundle = [NSBundle bundleWithURL:bundleUrl];
    } else {
        bundle = [NSBundle mainBundle];
    }
    return bundle;
}


+ (void)setCellStrength:(int)cellStrength
{
    fakeCellSignalStrength = cellStrength;
    [self updateStatusbarView];
}

+ (void)setWiFiStrength:(int)wifiStrength
{
    fakeWifiStrength = wifiStrength;
    [self updateStatusbarView];
}

+ (void)setNetworkType:(int)networkType
{
    fakeDataNetwork = networkType;
    [self updateStatusbarView];
}

+ (void)setEnabled:(BOOL)enabled atIndex:(NSInteger)index
{
    [fakeItemIsEnabled setObject:@(enabled) forKey:@(index)];
    [self updateStatusbarView];
}

+(void)setFakeCarrier:(NSString*) newCarrier {
    fakeCarrierS = newCarrier;
    [self updateStatusbarView];
}

+(void)setFakeTime:(NSString*) newFakeTime {
    fakeTimeS = newFakeTime;
    [self updateStatusbarView];
}

+(void)updateStatusbarView {
    [[UIApplication sharedApplication].keyWindow.rootViewController setNeedsStatusBarAppearanceUpdate];
}

+ (void)load
{
    fakeCarrier = "Carrier";
    fakeTime = "10:21 AM";
    
    fakeItemIsEnabled = [[NSMutableDictionary alloc] init];
    
    BOOL __block success = NO;
    Class UIStatusBarComposedData = objc_getClass("UIStatusBarComposedData");
    SEL selector = NSSelectorFromString(@"rawData");
    Method method = class_getInstanceMethod(UIStatusBarComposedData, selector);
    NSDictionary *statusBarDataInfo = @{ @"^{?=[25c][64c]ii[100c]": @"fake_rawData",
                                         @"^{?=[24c][64c]ii[100c]": @"fake_rawData",
                                         @"^{?=[23c][64c]ii[100c]": @"fake_rawData",
                                         // use B instead of c for 64-bit
                                         @"^{?=[25B][64c]ii[100c]": @"fake_rawData" };
    [statusBarDataInfo enumerateKeysAndObjectsUsingBlock:^(NSString *statusBarDataTypeEncoding, NSString *fakeSelectorString, BOOL *stop) {
        if (method && [@(method_getTypeEncoding(method)) hasPrefix:statusBarDataTypeEncoding])
        {
            SEL fakeSelector = NSSelectorFromString(fakeSelectorString);
            Method fakeMethod = class_getInstanceMethod(self, fakeSelector);
            success = class_addMethod(UIStatusBarComposedData, fakeSelector, method_getImplementation(fakeMethod), method_getTypeEncoding(fakeMethod));
            fakeMethod = class_getInstanceMethod(UIStatusBarComposedData, fakeSelector);
            method_exchangeImplementations(method, fakeMethod);
        }
    }];
    
    if (success)
        NSLog(@"Fake carrier enabled - don't forgot to disable it in production build!");
    else
        NSLog(@"XCDFakeCarrier failed to initialize");
}

- (StatusBarData *)fake_rawData
{
    StatusBarData *rawData = [self fake_rawData];
    fakeCarrier = [fakeCarrierS UTF8String];
    if (fakeCarrier) {
        strlcpy(rawData->serviceString, fakeCarrier, sizeof(rawData->serviceString));
    }
    
    fakeTime = [fakeTimeS UTF8String];
    if (fakeTime) {
        strlcpy(rawData->timeString, fakeTime, sizeof(rawData->timeString));
    }
    
    if (fakeCellSignalStrength > -1) {
        rawData->itemIsEnabled[3] = 1;
        rawData->gsmSignalStrengthBars = fakeCellSignalStrength;
    } else {
        rawData->itemIsEnabled[3] = 0;
    }
    
    for (NSNumber *key in fakeItemIsEnabled) {
        NSNumber *value = [fakeItemIsEnabled objectForKey:key];
        
        rawData->itemIsEnabled[[key integerValue]] = [value boolValue];
    }
    
    rawData->dataNetworkType = fakeDataNetwork;
    
    rawData->wifiSignalStrengthBars = fakeWifiStrength;
    rawData->batteryCapacity = 100; // Full battery
    
    memset(rawData->batteryDetailString, 0, sizeof(rawData->batteryDetailString)); // Hide battery state strings such as "Not Charging"
    
    return rawData;
}

@end
