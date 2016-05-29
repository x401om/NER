//
//  WikiEntity.h
//  NER
//
//  Created by Aleksey Goncharov on 10.05.16.
//  Copyright © 2016 Aleksey Goncharov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WikiEntity : NSObject

@property (nonatomic) NSString *entityName;
@property (nonatomic) NSURL *wikiLink;

@property (nonatomic) NSMutableDictionary *aliases;

+ (instancetype)fetchOrCreateEntityId:(NSString *)entityId;

- (void)addEntityAlias:(NSString *)alias;

- (void)save;

@end
