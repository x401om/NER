//
//  DBPedia.h
//  NER
//
//  Created by Aleksey Goncharov on 17.01.16.
//  Copyright © 2016 Aleksey Goncharov. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const dbPediaClassOrganization = @"organization";
static NSString *const dbPediaClassPerson = @"person";
static NSString *const dbPediaClassPlace = @"place";

@class BFTask;

@interface DBPedia : NSObject

- (BFTask<NSArray *> *)fetchInfoForQuery:(NSString *)query;

// Classes: http://mappings.dbpedia.org/server/ontology/classes/

- (BFTask<NSArray *> *)fetchInfoForQuery:(NSString *)query queryClass:(NSString *)queryClass maxHits:(NSUInteger)maxHits;

@end
