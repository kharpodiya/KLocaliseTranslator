//
//  TManager.h
//  Translate
//
//  Created by Mav on 19/05/20.
//  Copyright © 2020 Mav. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TManager : NSObject
+ (id)shared;
-(void)languageDetect:(NSString*)text;
- (void) translateText: (NSString *)text and:(NSString*)language;


@end

NS_ASSUME_NONNULL_END
