//
//  WikiEntity.m
//  NER
//
//  Created by Aleksey Goncharov on 10.05.16.
//  Copyright © 2016 Aleksey Goncharov. All rights reserved.
//

#import "WikiEntity.h"

@interface WikiEntity ()


@end

@implementation WikiEntity

- (NSMutableDictionary *)aliases {
  if (!_aliases) {
    _aliases = [NSMutableDictionary dictionary];
  }
  return _aliases;
}

- (NSDictionary *)dictionaryRepresentation {
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];

  if (self.entityName) {
    dict[@"entityName"] = self.entityName;
  }
  if (self.wikiLink) {
    dict[@"wikiLink"] = [self.wikiLink absoluteString];
  }
  if (self.aliases.count) {
    dict[@"aliases"] = self.aliases;
  }

  return dict;
}

+ (instancetype)fetchOrCreateEntityId:(NSString *)entityId {
  WikiEntity *entity = [WikiEntity new];
  NSString *entityPath = [entity entityPathForEntityId:entityId basePath:@"/Users/agoncharov/NER/Entities/"];
  
  if ([[NSFileManager defaultManager] fileExistsAtPath:entityPath]) {
    NSURL *fileUrl = [NSURL fileURLWithPath:entityPath];
    NSData *json = [NSData dataWithContentsOfURL:fileUrl];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:json
                                                         options:kNilOptions
                                                           error:nil];
    
    entity.entityName = dict[@"entityName"];
    entity.wikiLink = dict[@"wikiLink"];
    entity.aliases = [dict[@"aliases"] mutableCopy];
  } else {
    entity.entityName = entityId;
  }

  return entity;
}

- (void)setEntityName:(NSString *)entityName {
  _entityName = entityName;
  NSString *link = [@"https://de.wikipedia.org/wiki/" stringByAppendingString:[entityName stringByReplacingOccurrencesOfString:@" " withString:@"_"]];
  self.wikiLink = [NSURL URLWithString:link];

  [self addEntityAlias:entityName];
}

- (void)addEntityAlias:(NSString *)alias {
  NSUInteger aliasWeight = [self.aliases[alias] unsignedIntegerValue];
  self.aliases[alias] = @(aliasWeight + 1);
}

#pragma mark - Files

- (void)save {
  NSString *entityPath = [self entityPathForEntityId:self.entityName basePath:@"/Users/agoncharov/NER/Entities/"];
  [self saveToFile:entityPath];
}

- (void)saveToFile:(NSString *)filePath {
  NSData *json = [NSJSONSerialization dataWithJSONObject:[self dictionaryRepresentation]
                                                 options:NSJSONWritingPrettyPrinted
                                                   error:nil];
  [json writeToURL:[NSURL fileURLWithPath:filePath] atomically:YES];
}

- (NSString *)entityPathForEntityId:(NSString *)entityId basePath:(NSString *)basePath {
  NSString *prefix = @"!other";
  if (entityId.length >= 2) {
    NSString *pr = [[entityId substringToIndex:2] lowercaseString];

    NSPredicate *myTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"[a-z]*"];
    if ([myTest evaluateWithObject:pr]) {
      prefix = pr;
    }
  }
  NSString *path = [NSString stringWithFormat:@"%@%@/", basePath, prefix];

  if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:NULL]) {
    [[NSFileManager defaultManager] createDirectoryAtPath:path
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
  }

  return [NSString stringWithFormat:@"%@%@.json", path, entityId];
}

- (NSString *)description {
  return [NSString stringWithFormat:@"%@\n%@", self.wikiLink, self.aliases];
}

@end
