//
//  WikiArticle+Entity.m
//  NER
//
//  Created by Aleksey Goncharov on 11.05.16.
//  Copyright © 2016 Aleksey Goncharov. All rights reserved.
//

#import "WikiArticle+Entity.h"
#import "WikiEntity.h"

@implementation WikiArticle (Entity)

- (NSAttributedString *)entitiesMarkedString {
  NSArray *entities = [self fetchRelatedEntities];

  NSMutableDictionary *index = [NSMutableDictionary dictionary];
  for (WikiEntity *entity in entities) {
    for (NSString *alias in entity.aliases) {
      index[alias] = entity.wikiLink;
    }
  }

  NSMutableArray *entries = [NSMutableArray array];

  for (NSString *key in index.allKeys) {
    NSRange range = [self.plainText rangeOfString:key options:NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch | NSWidthInsensitiveSearch];
    if (range.location != NSNotFound) {
      [entries addObject:@{ @"range" : [NSValue valueWithRange:range],
                            @"link" : index[key] }];
    }
  }

  NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:self.plainText
                                                                           attributes:@{ NSFontAttributeName : [NSFont fontWithName:@"HelveticaNeue" size:15.0f] }];
  
  for (NSDictionary *entry in entries) {    
    NSRange range = [entry[@"range"] rangeValue];
    [attr addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"HelveticaNeue-Bold" size:15.0f] range:range];
//    [attr addAttribute:NSLinkAttributeName value:entry[@"link"] range:range];
    [attr addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:range];
    [attr addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:range];
  }
  
  for (NSDictionary *marked in self.entities) {
    NSRange range = NSRangeFromString(marked[@"location"]);
    [attr addAttribute:NSForegroundColorAttributeName value:[NSColor redColor] range:range];
  }


  return attr;
}

@end
