//
//  DBPedia.m
//  NER
//
//  Created by Aleksey Goncharov on 17.01.16.
//  Copyright © 2016 Aleksey Goncharov. All rights reserved.
//

#import "AFNetworking.h"
#import "Core.h"
#import "DBPedia.h"

static NSString *const dbPediaBaseUrl = @"http://lookup.dbpedia.org/api/";

@interface DBPedia ()

@property (nonatomic) AFHTTPRequestOperationManager *requestManager;

@end

@implementation DBPedia

- (AFHTTPRequestOperationManager *)requestManager {
  if (!_requestManager) {
    NSURL *baseURL = [NSURL URLWithString:dbPediaBaseUrl];
    _requestManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
    _requestManager.securityPolicy.allowInvalidCertificates = YES;
    _requestManager.requestSerializer.timeoutInterval = 60;
  }
  return _requestManager;
}

- (BFTask<NSArray *> *)fetchInfoForQuery:(NSString *)query {
  return [self fetchInfoForQuery:query queryClass:nil maxHits:5];
}

- (BFTask<NSArray *> *)fetchInfoForQuery:(NSString *)query queryClass:(NSString *)queryClass maxHits:(NSUInteger)maxHits {
  if (!query) {
    return [BFTask taskWithError:[NSError errorWithDomain:@"com.ner.dbpedia" code:0 userInfo:nil]];
  }

  BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];

  NSString *path = nil;
  if (queryClass) {
    path = [NSString stringWithFormat:@"%@search/KeywordSearch?MaxHits=%@&QueryClass=%@&QueryString=%@", dbPediaBaseUrl, @(maxHits),
                                      [queryClass stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]],
                                      [query stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
  } else {
    path = [NSString stringWithFormat:@"%@search/KeywordSearch?MaxHits=%@QueryString=%@", dbPediaBaseUrl, @(maxHits),
                                      [query stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
  }

  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]
                                                         cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                     timeoutInterval:10];

  [request setHTTPMethod:@"GET"];
  [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];

  [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
    if (error) {
      [source trySetError:error];
    } else {
      NSError *encodingError = nil;
      NSDictionary *info = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&encodingError];
      if (encodingError) {
        [source trySetError:encodingError];
      } else {
        [source trySetResult:info[@"results"]];
      }
    }
  }] resume];

  return source.task;
}

#pragma mark - Helpers

@end
