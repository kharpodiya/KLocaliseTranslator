//
//  TManager.m
//  Translate
//
//  Created by Mav on 19/05/20.
//  Copyright © 2020 Mav. All rights reserved.
//

#import "TManager.h"
#import "KSReachability.h"

@implementation TManager


NSString * apiKey = @""; // ADD YOUR API KEY HERE
NSString* sourceLanguage = @"en";
BOOL isReady = true;
enum {
    detectLanguage,
    translate,
    supportedLanguages
}TranslationAPI;


+ (id)shared {
    static TManager *shared = nil;
    @synchronized(self) {
        if (shared == nil)
            shared = [[self alloc] init];
        
    }
    return shared;
}


-(void)languageDetect:(NSString*)text{
    
    NSURLQueryItem* key = [[NSURLQueryItem alloc]initWithName:@"key" value:apiKey];
    NSURLQueryItem* q = [[NSURLQueryItem alloc]initWithName:@"q" value:text];
    NSURLComponents* components = [[NSURLComponents alloc] initWithString:@"https://translation.googleapis.com/language/translate/v2/detect"];
    components.queryItems = @[key, q];
    NSURL *URL = components.URL;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"POST"];
    NSURLSessionDataTask* task = [NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error == nil) {
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:&error];
            if (json[@"data"]){
                NSArray* dataArray = json[@"data"][@"detections"];
                NSDictionary* dataDics = dataArray.firstObject[0];
                NSString* dataString = dataDics[@"language"];
                sourceLanguage = dataString;
                [NSNotificationCenter.defaultCenter postNotificationName:@"detectionDone" object:nil];
            }
            else{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    isReady = YES;
                });
                if (isReady) {
                    isReady = false;
                    [NSNotificationCenter.defaultCenter postNotificationName:@"networkError" object:@"Something went wrong!"];
                }
            }
        }
        else{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                isReady = YES;
            });
            if (isReady) {
                isReady = false;
                [NSNotificationCenter.defaultCenter postNotificationName:@"networkError" object:@"Network connection error!"];
            }
        }
        
    }];
    [task resume];
}

- (void) translateText: (NSString *)text and:(NSString*)language{
    [self apiCalll:text and:language];
}

-(void)apiCalll:(NSString*)text and:(NSString*)language{
    
    TranslationAPI = translate;
    NSURLQueryItem* target = [[NSURLQueryItem alloc]initWithName:@"target" value:language];
    NSURLQueryItem* key = [[NSURLQueryItem alloc]initWithName:@"key" value:apiKey];
    NSURLQueryItem* q = [[NSURLQueryItem alloc]initWithName:@"q" value:text];
    NSURLQueryItem* format = [[NSURLQueryItem alloc]initWithName:@"format" value:@"text"];
    NSURLQueryItem* source = [[NSURLQueryItem alloc]initWithName:@"source" value:sourceLanguage];
    NSURLComponents* components = [[NSURLComponents alloc] initWithString:@"https://translation.googleapis.com/language/translate/v2"];
    components.queryItems = @[target, key, q, format, source];
    NSURL *URL = components.URL;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"POST"];
    NSURLSessionDataTask* task = [NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error == nil) {
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:&error];
            if (json[@"data"]){
                NSURL* url = response.URL;
                NSString* com = url.query;
                NSString* target = [com substringWithRange:NSMakeRange(7, 2)];
                NSString* dataString = json[@"data"][@"translations"][0][@"translatedText"];
                NSDictionary* resultData = @{@"lang": target, @"trans": dataString};
                
                [NSNotificationCenter.defaultCenter postNotificationName:@"TranslationDone" object:resultData];
            }
            else {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    isReady = YES;
                });
                if (error == nil) {
                    NSString* dataString = json[@"error"][@"message"];
                    if (![dataString containsString:@"Bad language pair:"] && isReady){
                        isReady = NO;
                        [NSNotificationCenter.defaultCenter postNotificationName:@"networkError" object:dataString];
                    }
                }
                else {
                    if (isReady){
                        isReady = NO;
                        [NSNotificationCenter.defaultCenter postNotificationName:@"networkError" object:@"Error: File is not translatable. File is too large."];
                    }
                }
                
            }
        }
        else{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                isReady = YES;
            });
            if (isReady) {
                isReady = false;
                [NSNotificationCenter.defaultCenter postNotificationName:@"networkError" object:@"Network connection error!"];
            }
        }
        
    }];
    [task resume];
}


@end
