//
//  ViewController.m
//  Translate
//
//  Created by Mav on 18/05/20.
//  Copyright © 2020 Mav. All rights reserved.
//

#import "ViewController.h"
#import "TManager.h"

#include <unistd.h>
#include <sys/types.h>
#include <pwd.h>
#include <assert.h>

@implementation ViewController


NSString* filePAth = @"";
NSMutableArray* keys;
NSMutableArray* values;
NSArray * languages;
NSString *texts = @"";
NSString * directoryPath;
NSString * fileContent = @"";
int writeCount = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dragNotification:)
                                                 name:@"dragNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(translationDone:)
                                                 name:@"TranslationDone"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(detectionDone)
                                                 name:@"detectionDone"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkError:)
                                                 name:@"networkError"
                                               object:nil];
    [self setProgress:NO];
    [self.popUpButton setMenu:[self getmenu]];
    languages = [self getList].allValues;
    directoryPath = [[self RealHomeDirectory] stringByAppendingPathComponent:@"Downloads/Translation/"];
    // Do any additional setup after loading the view.
}

-(NSMenu*)getmenu{
    NSMenu* menu = [[NSMenu alloc] init];
    NSDictionary * lang = [self getList];
    NSArray *keys = [lang allKeys];
    NSArray *sortedKeys = [keys sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *first = [lang objectForKey:a];
        NSString *second = [lang objectForKey:b];
        return [first compare:second];
    }];
    for (int i = 0; i <= lang.count; i++) {
        if (i == 0) {
            NSMenuItem * item = [[NSMenuItem alloc]initWithTitle:@"All" action:@selector(didselectItem:) keyEquivalent:@"All"];
            [menu addItem:item];
        }else {
            NSString* name = [sortedKeys objectAtIndex:i-1];
            NSMenuItem * item = [[NSMenuItem alloc]initWithTitle:name action:@selector(didselectItem:) keyEquivalent:name];
            [menu addItem:item];
        }
    }
    return menu;
}
-(void)didselectItem:(NSMenuItem*)key{
    NSDictionary * dic = [self getList];
    if ([key.title isEqualToString:@"All"]){
        languages = dic.allValues;
    }
    else{
        languages = @[dic[key.title]];
    }
    
}
-(void)setProgress:(BOOL)isProgress{
    
    if (isProgress) {
        self.indicator.alphaValue = 1.0;
        self.blurView.hidden = NO;
        [self.indicator startAnimation:nil];
        self.indicatorLabel.hidden = NO;
    }
    else{
        self.indicator.alphaValue = 0.0;
        self.blurView.hidden = YES;
        [self.indicator stopAnimation:nil];
        self.indicatorLabel.hidden = YES;
    }
    
}


-(NSDictionary*)getList {
    
    NSDictionary* dics = @{@"Afrikaans" : @"af", @"Albanian" : @"sq", @"Amharic" : @"am", @"Arabic" : @"ar", @"Armenian" : @"hy", @"Azerbaijani" : @"az",
                           @"Basque" : @"eu", @"Belarusian" : @"be", @"Bengali" : @"bn", @"Bosnian" : @"bs", @"Bulgarian" : @"bg",
                           @"Catalan" : @"ca", @"Cebuano" : @"ceb", @"Chinese (Simplified)" : @"zh-CN", @"Chinese (Traditional)" : @"zh-TW", @"Corsican" : @"co",
                           @"Croatian" : @"hr", @"Czech" : @"cs", @"Danish" : @"da", @"Dutch" : @"nl", @"English" : @"en", @"Esperanto" : @"eo",
                           @"Estonian" : @"et", @"Finnish" : @"fi", @"French" : @"fr", @"Frisian" : @"fy", @"Galician" : @"gl", @"Georgian" : @"ka",
                           @"German" : @"de", @"Greek" : @"el", @"Gujarati" : @"gu", @"Haitian Creole" : @"ht", @"Hausa" : @"ha", @"Hawaiian" : @"haw",
                           @"Hebrew" : @"he", @"Hindi" : @"hi", @"Hmong" : @"hmn", @"Hungarian" : @"hu", @"Icelandic" : @"is", @"Igbo" : @"ig", @"Indonesian" : @"id",
                           @"Irish" : @"ga", @"Italian" : @"it", @"Japanese" : @"ja", @"Javanese" : @"jv", @"Kannada" : @"kn", @"Kazakh" : @"kk", @"Khmer" : @"km",
                           @"Kinyarwanda" : @"rw", @"Korean" : @"ko", @"Kurdish" : @"ku", @"Kyrgyz" : @"ky", @"Lao" : @"lo", @"Latin" : @"la", @"Latvian" : @"lv",
                           @"Lithuanian" : @"lt", @"Luxembourgish" : @"lb", @"Macedonian" : @"mk", @"Malagasy" : @"mg", @"Malay" : @"ms", @"Malayalam" : @"ml",
                           @"Maltese" : @"mt", @"Maori" : @"mi", @"Marathi" : @"mr", @"Mongolian" : @"mn", @"Myanmar (Burmese)" : @"my", @"Nepali" : @"ne",
                           @"Norwegian" : @"no", @"Nyanja (Chichewa)" : @"ny", @"Odia (Oriya)" : @"or", @"Pashto" : @"ps", @"Persian" : @"fa", @"Polish" : @"pl",
                           @"Portuguese (Portugal, Brazil)" : @"pt", @"Punjabi" : @"pa", @"Romanian" : @"ro", @"Russian" : @"ru", @"Samoan" : @"sm", @"Scots Gaelic" : @"gd",
                           @"Serbian" : @"sr", @"Sesotho" : @"st", @"Shona" : @"sn", @"Sindhi" : @"sd", @"Sinhala (Sinhalese)" : @"si", @"Slovak" : @"sk", @"Slovenian" : @"sl",
                           @"Somali" : @"so", @"Spanish" : @"es", @"Sundanese" : @"su", @"Swahili" : @"sw", @"Swedish" : @"sv", @"Tagalog (Filipino)" : @"tl", @"Tajik" : @"tg",
                           @"Tamil" : @"ta", @"Tatar" : @"tt", @"Telugu" : @"te", @"Thai" : @"th", @"Turkish" : @"tr", @"Turkmen" : @"tk", @"Ukrainian" : @"uk", @"Urdu" : @"ur",
                           @"Uyghur" : @"ug", @"Uzbek" : @"uz", @"Vietnamese" : @"vi", @"Welsh" : @"cy", @"Xhosa" : @"xh", @"Yiddish" : @"yi", @"Yoruba" : @"yo", @"Zulu" : @"zu"};
    return dics;
}

-(NSString *)RealHomeDirectory {
    struct passwd *pw = getpwuid(getuid());
    assert(pw);
    return [NSString stringWithUTF8String:pw->pw_dir];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}
- (IBAction)chooseFileAction:(id)sender {
    
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:YES];
    [openDlg setCanChooseDirectories:NO];
    [openDlg setPrompt:@"Select"];
    [openDlg beginWithCompletionHandler:^(NSInteger result){
        filePAth = [openDlg URL].path;
        if([[filePAth pathExtension] isEqual:@"strings"]){
            self.dragLabel.stringValue = @"File Selected";
            self.dragLabel2.stringValue = @"Press Next button to continue.";
            self.nextButton.enabled = YES;
        }
        else{
            self.dragLabel.stringValue = @"File not supported";
            self.dragLabel2.stringValue = @"Please select correct file.";
            self.nextButton.enabled = NO;
        }
    }];
}


- (IBAction)nextAction:(id)sender {
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:NO];
    [openDlg setCanChooseDirectories:YES];
    [openDlg setCanCreateDirectories:YES];
    [openDlg setPrompt:@"Choose folder to save files"];
    [openDlg beginWithCompletionHandler:^(NSInteger result){
        directoryPath = [openDlg directoryURL].path;
        
        [self processToReadFile];
    }];
}

-(void)resetAll {
    
    writeCount = 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.dragLabel.stringValue = @"Drag Files Here";
        self.dragLabel2.stringValue = @"You can drag&drop only single file.";
        self.nextButton.enabled = NO;
        [self setProgress:NO];
    });
    
    
    
}
- (void) dragNotification:(NSNotification *) notification{
    filePAth = notification.object;
    _dragLabel.stringValue = @"File Selected";
    _dragLabel2.stringValue = @"Press Next button to continue.";
    self.nextButton.enabled = YES;
    
}
-(void) processToReadFile {
    
    
    fileContent = [NSString stringWithContentsOfFile:filePAth encoding:NSUTF8StringEncoding error:nil];
    NSRange range = [fileContent rangeOfString:@"\n\"" ];
    NSString *file = [fileContent substringFromIndex:range.location];
    file = [file stringByReplacingOccurrencesOfString:@"\n" withString:@"" ];
    
    NSArray * sepratedStrings = [file componentsSeparatedByString:@";"];
    keys = [[NSMutableArray alloc] init];
    values = [[NSMutableArray alloc] init];
    for (NSString* text in sepratedStrings) {
        if (![text  isEqual: @""]){
            NSArray * temp = [text componentsSeparatedByString:@"="];
            
            NSArray * preKey = [temp[0] componentsSeparatedByString:@"\""];
            if(preKey.count > 1) {
                [keys addObject:preKey[preKey.count-2]];
            }
            else{
                [keys addObject:temp[0]];
            }
            if (temp.count > 1) {
                [values addObject:[temp[1] stringByReplacingOccurrencesOfString:@"\"" withString:@"" ]];
            }
            
        }
    }
    [self setProgress:YES];
    [TManager.shared languageDetect: values[0]];
    
}
-(void)networkError:(NSNotification *) notification {
    NSString* message = notification.object;
    [self resetAll];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Message"];
        [alert setInformativeText:message];
        [alert addButtonWithTitle:@"OK"];
        [alert setAlertStyle:NSAlertStyleInformational];
        
        [alert beginSheetModalForWindow:[[self view] window] completionHandler:^(NSModalResponse returnCode) {
            
        }];
    });
}

-(void) detectionDone {
    for (NSString* language in languages) {
        [TManager.shared translateText:[values componentsJoinedByString:@"\n"] and:language]; //
    }
}

-(void) translationDone:(NSNotification *) notification {
    NSDictionary* data = notification.object;
    NSString* translation = data[@"trans"];
    NSString* target = data[@"lang"];
    NSArray* str = [translation componentsSeparatedByString:@"\n"];
    NSMutableArray *mainFile = (NSMutableArray*)[fileContent componentsSeparatedByString:@";"];
    for (int i = 0; i < str.count; i++) {
        NSString *y = mainFile[i];
        NSRange range = [y rangeOfString:@"=" options:NSBackwardsSearch];
        NSString *set = [str[i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        y = [y stringByReplacingCharactersInRange:NSMakeRange(range.location+2, y.length-range.location-2) withString:[NSString stringWithFormat:@"\"%@\";",set]];
        if ([y containsString:@"\"\""] && ![y containsString:@"\"\";"]){
            y = [y stringByReplacingOccurrencesOfString:@"\"\"" withString:@"\""];
        }
        [mainFile replaceObjectAtIndex:i withObject:y];
    }
    NSString *finalString = [mainFile componentsJoinedByString:@"\n"];
    [self writeTofile:finalString and:target];
}

-(void)writeTofile:(NSString*)text and :(NSString*)lang {
    writeCount++;
    NSString* path = [directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_LocalStrg.strings",lang]];
    BOOL isDir = NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]){
        if(![NSFileManager.defaultManager createFileAtPath:path contents:[text dataUsingEncoding:NSUTF8StringEncoding] attributes:nil])
            NSLog(@"Error: write file failed %@", path);
    }
    else{
        
    }
    
    if (writeCount == languages.count || writeCount == languages.count - 1){
        [self resetAll];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:@"Translated successfuly!"];
            [alert setInformativeText:[NSString stringWithFormat:@"Check your transleted file in \"%@\" folder.",directoryPath]];
            [alert addButtonWithTitle:@"OK"];
            [alert setAlertStyle:NSAlertStyleInformational];
            
            [alert beginSheetModalForWindow:[[self view] window] completionHandler:^(NSModalResponse returnCode) {
                
            }];
        });
    }
}

@end

