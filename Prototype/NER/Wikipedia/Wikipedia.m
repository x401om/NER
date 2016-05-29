//
//  Wikipedia.m
//  NER
//
//  Created by Aleksey Goncharov on 17.01.16.
//  Copyright © 2016 Aleksey Goncharov. All rights reserved.
//

#import "Core.h"
#import "NSString+Parsing.h"
#import "WikiArticle.h"
#import "Wikipedia.h"
#import "XMLDictionary.h"

@implementation Wikipedia

- (BFTask<NSDictionary *> *)parseWikiText:(NSString *)text {
  // remove bold and italics
  text = [text stringByReplacingOccurrencesOfString:@"'''" withString:@""];
  text = [text stringByReplacingOccurrencesOfString:@"''" withString:@""];
  // remove headings
  text = [text stringByReplacingOccurrencesOfString:@"===" withString:@""];
  text = [text stringByReplacingOccurrencesOfString:@"==" withString:@""];
  // remove underlines
  text = [text stringByReplacingOccurrencesOfString:@"<u>" withString:@""];
  text = [text stringByReplacingOccurrencesOfString:@"</u>" withString:@""];

  // searching for <ref> tag
  __block NSString *string = [text copy];
  return [[[[text findAllMatchesOfPattern:@"<ref[^>]*>(.*)</ref>"] continueWithSuccessBlock:^id _Nullable(BFTask<NSArray<NSString *> *> *_Nonnull task) {
    for (NSString *match in task.result) {
      string = [string stringByReplacingOccurrencesOfString:match withString:@""];
    }
    return string;
  }] continueWithSuccessBlock:^id _Nullable(BFTask<NSString *> *_Nonnull task) {
    return [task.result findAllMatchesOfPattern:@"\\[\\[[^\\]\\].]*\\]\\]"];
  }] continueWithSuccessBlock:^id _Nullable(BFTask<NSArray<NSString *> *> *_Nonnull task) {
    NSMutableArray *entities = [NSMutableArray array];
    for (NSString *link in task.result) {
      NSString *originalText = [link plainStingFromWikiLink];
      NSString *linkText = [link fullLinkFromWikiLink];

      string = [string stringByReplacingOccurrencesOfString:link withString:originalText];
      NSRange range = [string rangeOfString:originalText];

      [entities addObject:@{ @"original_text" : originalText,
                             @"link_text" : linkText,
                             @"location" : NSStringFromRange(range) }];
    }
    return @{ @"text" : string,
              @"entities" : entities };
  }];
}

#pragma mark - File

- (BFTask<NSArray<NSDictionary *> *> *)splitArticlesFromXML:(NSString *)xml {

  NSArray *articles = [xml componentsSeparatedByString:@"<page>"];

  return [BFTask taskWithResult:[articles map:^id(NSString *object) {
                   if (object.length) {
                     object = [@"<page>" stringByAppendingString:object];
                     return [[XMLDictionaryParser sharedInstance] dictionaryWithString:object];
                   } else {
                     return nil;
                   }
                 }]];
}

- (BFTask<NSArray<WikiArticle *> *> *)fetchArticlesFromDumpFile:(NSURL *)fileURL {
  NSString *basePath = @"/Users/agoncharov/NER/Articles";
  NSLog(@"Parsing started");

  NSString *xml = [NSString stringWithContentsOfURL:fileURL encoding:NSUTF8StringEncoding error:nil];

  @weakify(self);
  return [[self splitArticlesFromXML:xml] continueWithSuccessBlock:^id _Nullable(BFTask<NSArray<NSDictionary *> *> *_Nonnull task) {
    NSArray *metas = task.result;
    for (NSDictionary *meta in metas) {
//      NSUInteger index = [task.result indexOfObject:meta];
      [BFTask taskFromExecutor:[BFExecutor executorWithDispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)]
                     withBlock:^id _Nonnull {
                       @strongify(self);
                       return [[self fetchArticleFromMeta:meta] continueWithSuccessBlock:^id _Nullable(BFTask<WikiArticle *> *_Nonnull task) {
//                         NSLog(@"Parsed %@/%@ %@", @(index), @(metas.count), task.result.title);
                         WikiArticle *article = task.result;
                         NSString *fileName = [basePath stringByAppendingFormat:@"/%@.json", [article.title stringByReplacingOccurrencesOfString:@" " withString:@"_"]];
                         [article saveToFile:[NSURL fileURLWithPath:fileName]];
                         return task;
                       }];
                     }];
    }
    return nil;
  }];
  return nil;
}

- (BFTask<WikiArticle *> *)fetchArticleFromMeta:(NSDictionary *)meta {
  NSString *wikiText = meta[@"revision"][@"text"][@"__text"];
  return [[self parseWikiText:wikiText] continueWithSuccessBlock:^id _Nullable(BFTask<NSDictionary *> *_Nonnull task) {
    WikiArticle *article = [WikiArticle new];
    article.title = meta[@"title"];
    article.plainText = task.result[@"text"];
    article.entities = task.result[@"entities"];
    return article;
  }];
}

@end
