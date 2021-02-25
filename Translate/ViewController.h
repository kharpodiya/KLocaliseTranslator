//
//  ViewController.h
//  Translate
//
//  Created by Mav on 18/05/20.
//  Copyright © 2020 Mav. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>
@interface ViewController : NSViewController
@property (weak) IBOutlet NSTextField *dragLabel;
@property (weak) IBOutlet NSTextField *dragLabel2;
@property (weak) IBOutlet NSButton *chooseFileButton;
@property (weak) IBOutlet NSButton *nextButton;
@property (weak) IBOutlet NSProgressIndicator *indicator;
@property (weak) IBOutlet NSVisualEffectView *blurView;
@property (weak) IBOutlet NSTextField *indicatorLabel;
@property (weak) IBOutlet NSPopUpButton *popUpButton;



@end

