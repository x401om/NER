//
//  WikiArticle+Entity.h
//  NER
//
//  Created by Aleksey Goncharov on 11.05.16.
//  Copyright © 2016 Aleksey Goncharov. All rights reserved.
//

#import "Core.h"
#import "WikiArticle.h"

#import <Cocoa/Cocoa.h>

@interface WikiArticle (Entity)

- (NSAttributedString *)entitiesMarkedString;

@end
