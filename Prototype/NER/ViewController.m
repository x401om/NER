//
//  ViewController.m
//  NER
//
//  Created by Aleksey Goncharov on 17.01.16.
//  Copyright © 2016 Aleksey Goncharov. All rights reserved.
//

#import "Core.h"
#import "DBPedia.h"
#import "ViewController.h"
#import "WikiArticle+Entity.h"
#import "Wikipedia.h"

#import "WikiEntity.h"

#import <Ashton/NSAttributedString+Ashton.h>

@interface ViewController ()

@property (nonatomic) NSMutableDictionary *entities;

@property (weak) IBOutlet NSTextField *textField;
@property (weak) IBOutlet NSButton *button;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (weak) IBOutlet NSTextField *titleLabel;

@property (unsafe_unretained) IBOutlet NSTextView *textView;
@end

@implementation ViewController

- (NSMutableDictionary *)entities {
  if (!_entities) {
    _entities = [NSMutableDictionary dictionary];
  }
  return _entities;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  [self.progressIndicator setDoubleValue:0.0f];
  [self.progressIndicator setMaxValue:1.0f];

  //  [self.textField setStringValue:@"/Users/agoncharov/NER/Articles/"];
}

- (IBAction)buttonPressed:(id)sender {
  self.progressIndicator.doubleValue = 0.0f;
  self.progressIndicator.maxValue = 100.0f;

  [self handleArticleWithPath:self.textField.stringValue];

  //  [self buildEntitiesIndexWithArticlesPath:self.textField.stringValue];
}
- (IBAction)openWikiPressed:(id)sender {
  NSString *path = self.textField.stringValue;
  if (!path.length) {
    return;
  }

  WikiArticle *article = [[WikiArticle alloc] initWithFile:[NSURL fileURLWithPath:path]];
  NSString *link = [@"https://de.wikipedia.org/wiki/" stringByAppendingString:[article.title stringByReplacingOccurrencesOfString:@" " withString:@"_"]];
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:link]];
}

- (void)handleArticleWithPath:(NSString *)path {
  if (!path.length) {
    return;
  }

  WikiArticle *article = [[WikiArticle alloc] initWithFile:[NSURL fileURLWithPath:path]];
  NSString *link = [@"https://de.wikipedia.org/wiki/" stringByAppendingString:[article.title stringByReplacingOccurrencesOfString:@" " withString:@"_"]];
  self.titleLabel.attributedStringValue = [[NSAttributedString alloc] initWithString:article.title
                                                                          attributes:@{ NSLinkAttributeName : link,
                                                                                        NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle) }];
  NSAttributedString *attr = [article entitiesMarkedString];
  [self.textView.textStorage setAttributedString:attr];
  
  NSString *html = [attr mn_HTMLRepresentation];
  NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];
  NSString *htmlPath = [NSString stringWithFormat:@"/Users/agoncharov/NER/Articles_marked/%@.html", article.title];
  [data writeToFile:htmlPath atomically:YES];
}

#pragma mark--

- (void)buildEntitiesIndexWithArticlesPath:(NSString *)path {
  NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
  [self.progressIndicator setMaxValue:files.count];

  NSUInteger progress = 0;
  //  [self.progressIndicator setMaxValue:files.count];

  for (NSString *fileName in files) {
    //    if (progress == 10000) {
    //      break;
    //    }
    double p = (double)(++progress) / files.count;
    if ((NSInteger)(p * 10000) % 100 == 0) {
      NSLog(@"%.2f", p);
    }
    NSString *jsonPath = [path stringByAppendingString:fileName];

    WikiArticle *article = [[WikiArticle alloc] initWithFile:[NSURL fileURLWithPath:jsonPath]];
    [self handleArticle:article];
  }

  progress = 0.0f;
  NSLog(@"Saving");
  for (WikiEntity *entity in [self.entities allValues]) {
    [entity save];
    double p = (double)(++progress) / self.entities.count;
    if ((NSInteger)(p * 1000000) % 10000 == 0) {
      NSLog(@"%.2f", p);
    }
  }
}

- (BFTask *)handleArticle:(WikiArticle *)article {
  for (NSDictionary *entityEntry in article.entities) {

    NSString *title = entityEntry[@"link_text"];
    NSString *alias = entityEntry[@"original_text"];

    WikiEntity *entity = self.entities[title];
    if (!entity) {
      entity = [WikiEntity fetchOrCreateEntityId:title];
      self.entities[title] = entity;
    }
    [entity addEntityAlias:alias];
  }
  return [BFTask taskWithResult:@1];
}

@end
