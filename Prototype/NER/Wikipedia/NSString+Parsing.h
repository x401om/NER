//
//  NSString+Parsing.h
//  NER
//
//  Created by Aleksey Goncharov on 17.01.16.
//  Copyright © 2016 Aleksey Goncharov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BFTask;

@interface NSString (Parsing)

- (BFTask *)findAllMatchesOfPattern:(NSString *)pattern;

- (NSString *)plainStingFromWikiLink;

- (NSString *)fullLinkFromWikiLink;

@end
