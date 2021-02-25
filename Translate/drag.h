//
//  drag.h
//  Translate
//
//  Created by Mav on 18/05/20.
//  Copyright © 2020 Mav. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface drag : NSView<NSDraggingSource, NSDraggingDestination, NSPasteboardItemDataProvider>{
    
    BOOL highlight;
}

@end

NS_ASSUME_NONNULL_END
