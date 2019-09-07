@import UIKit;
#import <math.h>
#import <objc/runtime.h>

@interface AppStoreDynamicTypeLabel : UILabel
@end

@interface AppStoreOfferButton : UIControl
@property (nonatomic, readwrite) AppStoreDynamicTypeLabel *accessibilityOfferLabel;
@property (nonatomic, readwrite) AppStoreDynamicTypeLabel *accessibilityOfferSubtitleLabel;
@property (nonatomic, retain) UILabel *accessibilityOfferIAPLabel;
@property (nonatomic, readwrite) NSString *accessibilityOfferButtonString;
@end

// Define a dictionary of strings (will be used to get the localized "GET" and "Free" strings)
NSDictionary *appStoreStrings;

%hook AppStoreOfferButton
%property (nonatomic, retain) UILabel *accessibilityOfferIAPLabel;

// Here we add additional subviews that we want to see in the button
-(void)showWithText:(NSString*)text subtitleText:(NSString*)subtitleText subtitlePosition:(NSInteger)position theme:(id)theme {
  %orig;

  // Get the button (and implicitly cast it)
  AppStoreOfferButton *btn = self;

  // Remove old IAP Label if it exists
  if (btn.accessibilityOfferIAPLabel && btn.accessibilityOfferIAPLabel.superview) {
    [btn.accessibilityOfferIAPLabel removeFromSuperview];
    btn.accessibilityOfferIAPLabel = nil;
  }

  // Get the "GET" label
  AppStoreDynamicTypeLabel *label = btn.accessibilityOfferLabel;

  // Set a local accent color equal to the iOS color
  UIColor *accent = [UIColor colorWithRed:0 green:0.478 blue:1 alpha:1];

  // Set the label's font to the iOS 7 font
  [label setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:13.0]];

  // Set the rest of the properties: text, text color, background color
  label.text = [text isEqualToString:appStoreStrings[@"OFFER_BUTTON_TITLE_GET"]] ? [appStoreStrings[@"SEARCH_FACET_FREE"] uppercaseString] : text;
  label.textColor = accent;
  label.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];

  // Add the border to the label by editing its layer: color, width and corner radius
  label.layer.borderColor = [accent CGColor];
  label.layer.borderWidth = 1.5;
  label.layer.cornerRadius = 3;

  // If the app contains in-app purchases
  if (
    [subtitleText isEqualToString:appStoreStrings[@"INLINE_IN_APP_PURCHASES"]] // There are in-app purchases
    && ![btn.accessibilityOfferButtonString isEqualToString:appStoreStrings[@"ACCESSIBILITY_REDOWNLOAD_BUTTON"]] // The button is not the cloud with the arrow (currently broken)
    && ![text isEqualToString:[appStoreStrings[@"SEARCH_FACET_FREE"] uppercaseString]] // The text hasn't already been covered (the button has been processed)
    ) {
    // Hide the "In-app purchases" text
    btn.accessibilityOfferSubtitleLabel.hidden = YES;
    btn.accessibilityOfferSubtitleLabel.text = nil;

    // Define a distance from the border's upper left corner
    CGFloat cornerSpace = 4;

    // Define a new label and place it
    UILabel *inAppPurchaseLabel = [[UILabel alloc]initWithFrame:CGRectMake(cornerSpace, 0, 15, 15)];

    // Set the label's font to the iOS 7 font
    [inAppPurchaseLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:13.0]];

    // Set the rest of the properties: text, text color
    inAppPurchaseLabel.text = @"+";
    inAppPurchaseLabel.textColor = accent;

    // Add the IAP label to the offer label
    [label addSubview:inAppPurchaseLabel];

    // Store a reference to the label in the OfferButton (so that we can do btn.accessibilityOfferIAPLabel)
    btn.accessibilityOfferIAPLabel = inAppPurchaseLabel;
  }
}

-(void)showWithText:(NSString*)text theme:(id)theme {
  %orig;

  // Get the button (and implicitly cast it)
  AppStoreOfferButton *btn = self;

  // Remove old IAP Label if it exists
  if (btn.accessibilityOfferIAPLabel && btn.accessibilityOfferIAPLabel.superview) {
    [btn.accessibilityOfferIAPLabel removeFromSuperview];
    btn.accessibilityOfferIAPLabel = nil;
  }

  // Get the "GET" label
  AppStoreDynamicTypeLabel *label = btn.accessibilityOfferLabel;

  // Set a local accent color equal to the iOS color
  UIColor *accent = [UIColor colorWithRed:0 green:0.478 blue:1 alpha:1];

  // Set the label's font to the iOS 7 font
  [label setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:13.0]];

  // Set the rest of the properties: text, text color, background color
  label.text = [text isEqualToString:appStoreStrings[@"OFFER_BUTTON_TITLE_GET"]] ? [appStoreStrings[@"SEARCH_FACET_FREE"] uppercaseString] : text;
  label.textColor = accent;
  label.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];

  // Add the border to the label by editing its layer: color, width and corner radius
  label.layer.borderColor = [accent CGColor];
  label.layer.borderWidth = 1.5;
  label.layer.cornerRadius = 3;
}

%end

%ctor {
  // Get the current user language (the top one in settings)
  NSString *locale = [[NSLocale preferredLanguages] firstObject];
  // Set our dictionary to contain the strings included in AppStoreKit.framework (which is in App Store's sandbox by the way)
  appStoreStrings = [[NSDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"/Applications/AppStore.app/Frameworks/AppStoreKit.framework/%@.lproj/Localizable.strings", [locale componentsSeparatedByString:@"-"][0]]];
  // Set the pseudo-classes to be an alias to the actual ones
  %init(AppStoreOfferButton = objc_getClass("AppStore.OfferButton"));
}