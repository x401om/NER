//
//  WikiArticle.m
//  NER
//
//  Created by Aleksey Goncharov on 17.01.16.
//  Copyright © 2016 Aleksey Goncharov. All rights reserved.
//

#import "Core.h"
#import "WikiArticle.h"

#import "WikiEntity.h"

@implementation WikiArticle

- (instancetype)initWithFile:(NSURL *)fileUrl {
  if (self = [super init]) {
    NSData *json = [NSData dataWithContentsOfURL:fileUrl];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:json
                                                         options:kNilOptions
                                                           error:nil];
    self.title = dict[@"title"];
    self.plainText = dict[@"text"];
    self.entities = dict[@"entities"];
  }
  return self;
}

- (void)saveToFile:(NSURL *)fileUrl {
  NSData *json = [NSJSONSerialization dataWithJSONObject:[self dictionaryRepresentation]
                                                 options:NSJSONWritingPrettyPrinted
                                                   error:nil];
  [json writeToURL:fileUrl atomically:YES];
}

- (NSDictionary *)dictionaryRepresentation {
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];

  if (self.title) {
    dict[@"title"] = self.title;
  }
  if (self.plainText) {
    dict[@"text"] = self.plainText;
  }
  if (self.entities) {
    dict[@"entities"] = self.entities;
  }

  return dict;
}

- (NSArray<WikiEntity *> *)fetchRelatedEntities {
  return [self.entities map:^id(NSDictionary *entityInfo) {
    return [WikiEntity fetchOrCreateEntityId:entityInfo[@"link_text"]];
  }];
}

@end
