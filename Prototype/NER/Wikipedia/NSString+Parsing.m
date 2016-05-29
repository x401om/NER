//
//  NSString+Parsing.m
//  NER
//
//  Created by Aleksey Goncharov on 17.01.16.
//  Copyright © 2016 Aleksey Goncharov. All rights reserved.
//

#import "NSString+Parsing.h"
#import <Bolts/Bolts.h>

@implementation NSString (Parsing)

- (BFTask<NSArray<NSString *> *> *)findAllMatchesOfPattern:(NSString *)pattern {
  NSMutableArray *matches = [NSMutableArray array];

  NSError *error;
  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                         options:NSRegularExpressionCaseInsensitive
                                                                           error:&error];
  if (error) {
    return [BFTask taskWithError:error];
  }

  for (NSTextCheckingResult *match in [regex matchesInString:self options:0 range:NSMakeRange(0, self.length)]) {
    [matches addObject:[self substringWithRange:match.range]];
  }
  return [BFTask taskWithResult:matches];
}

- (NSString *)plainStingFromWikiLink {
  NSString *clearLink = [self stringByReplacingOccurrencesOfString:@"[[" withString:@""];
  clearLink = [clearLink stringByReplacingOccurrencesOfString:@"]]" withString:@""];

  NSArray *components = [clearLink componentsSeparatedByString:@"|"];
  return [components lastObject];
}

- (NSString *)fullLinkFromWikiLink {
  NSString *clearLink = [self stringByReplacingOccurrencesOfString:@"[[" withString:@""];
  clearLink = [clearLink stringByReplacingOccurrencesOfString:@"]]" withString:@""];

  NSArray *components = [clearLink componentsSeparatedByString:@"|"];
  return [components firstObject];
}

@end
