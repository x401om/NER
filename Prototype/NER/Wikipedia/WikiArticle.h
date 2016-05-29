//
//  WikiArticle.h
//  NER
//
//  Created by Aleksey Goncharov on 17.01.16.
//  Copyright © 2016 Aleksey Goncharov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WikiEntity;

@interface WikiArticle : NSObject

@property (nonatomic) NSString *title;
@property (nonatomic) NSString *plainText;
@property (nonatomic) NSArray *entities;

- (instancetype)initWithFile:(NSURL *)fileUrl;
- (void)saveToFile:(NSURL *)fileUrl;

- (NSArray<WikiEntity *> *)fetchRelatedEntities;

@end
