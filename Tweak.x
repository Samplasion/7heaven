#import <UIKit/UIFont.h>

@interface AppStoreDynamicTypeLabel : UILabel
@property (nonatomic, copy, readwrite) NSString *text;
@end

@interface AppStoreOfferButton : UIControl
@property (nonatomic, readwrite) AppStoreDynamicTypeLabel *accessibilityOfferLabel;
@property (nonatomic, readwrite) AppStoreDynamicTypeLabel *accessibilityOfferSubtitleLabel;
@property (nonatomic, readwrite) UILabel *accessibilityOfferIAPLabel;
@property (nonatomic, readwrite) NSString *accessibilityOfferButtonString;
@end

@interface AppStoreGenericPageViewController : UIViewController
@end

// Define a dictionary of strings (will be used to get the "GET" and "Free" strings)
NSDictionary *appStoreStrings;

%hook AppStoreOfferButton
%property (nonatomic, assign) UILabel *accessibilityOfferIAPLabel;

// Here we add additional subviews that we want to see in the button
-(void)layoutSubviews {
  %orig;

  // Get the button (and implicitly cast it)
  AppStoreOfferButton *btn = self;
  // Get the "GET" label
  AppStoreDynamicTypeLabel *label = btn.accessibilityOfferLabel;

  // Set a local sccent color equal to the iOS color
  UIColor *accent = [UIColor colorWithRed:0 green:0.478 blue:1 alpha:1];

  // Set the label's font to the iOS 7 font
  [label setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:13.0]];

  // Set the rest of the properties: text, text color, background color
  label.text = [label.text isEqualToString:appStoreStrings[@"OFFER_BUTTON_TITLE_GET"]] ? [appStoreStrings[@"SEARCH_FACET_FREE"] uppercaseString] : label.text;
  label.textColor = accent;
  label.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];

  // Add the border to the label by editing its layer: color, width and corner radius
  label.layer.borderColor = [accent CGColor];
  label.layer.borderWidth = 1.5;
  label.layer.cornerRadius = 3;

  // If the app contains in-app purchases
  if (!btn.accessibilityOfferSubtitleLabel.hidden && ![btn.accessibilityOfferButtonString isEqualToString:appStoreStrings[@"ACCESSIBILITY_REDOWNLOAD_BUTTON"]]) {
    // Hide the "In-app purchases" text
    btn.accessibilityOfferSubtitleLabel.hidden = true;
    btn.accessibilityOfferSubtitleLabel.text = @"";

    // Define a distance from the border's upper left corner
    CGFloat cornerSpace = 4;

    // Define a new label and place it
    UILabel *inAppPurchaseLabel = [[UILabel alloc]initWithFrame:CGRectMake(btn.accessibilityOfferLabel.frame.origin.x + cornerSpace, cornerSpace + 10, 15, 15)];

    // Set the label's font to the iOS 7 font
    [inAppPurchaseLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:13.0]];

    // Set the rest of the properties: text, text color
    inAppPurchaseLabel.text = @"+";
    inAppPurchaseLabel.textColor = accent;

    // Link the label to the OfferButton (so that we can do btn.accessibilityOfferIAPLabel)
    btn.accessibilityOfferIAPLabel = inAppPurchaseLabel;

    // Actually add the label to the OfferButton
    [self addSubview:inAppPurchaseLabel];
  }
}
%end

%ctor {
  // Set the pseudo-classes to be an alias to the actual ones
  %init(_ungrouped, AppStoreOfferButton = NSClassFromString(@"AppStore.OfferButton"), AppStoreGenericPageViewController = NSClassFromString(@"AppStore.GenericPageViewController"));

  // Get the current user language (the top one in settings)
  NSString *locale = [[NSLocale preferredLanguages] firstObject];
  // Set our dictionary to contain the strings included in AppStoreKit.framework (which is in App Store's sandbox by the way)
  appStoreStrings = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"/Applications/AppStore.app/Frameworks/AppStoreKit.framework/%@.lproj/Localizable.strings", [locale componentsSeparatedByString:@"-"][0]]];
}