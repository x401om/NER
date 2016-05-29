//
//  Wikipedia.h
//  NER
//
//  Created by Aleksey Goncharov on 17.01.16.
//  Copyright © 2016 Aleksey Goncharov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BFTask;
@class WikiArticle;
@class WikiEntity;

@interface Wikipedia : NSObject

- (BFTask<NSArray<WikiArticle *> *> *)fetchArticlesFromDumpFile:(NSURL *)fileURL;

@end
