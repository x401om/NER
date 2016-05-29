//
//  NSArray+Filtred.m
//  Upmind
//
//  Created by Alexey D Vallianos on 07.07.15.
//  Copyright (c) 2015 Easy Ten LLC. All rights reserved.
//

#import "NSArray+Transform.h"

@implementation NSArray (Filtered)
- (NSArray *)filteredWithFormat:(NSString *)predicateFormat argumentArray:(NSArray *)arguments {
  NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat argumentArray:arguments];
  return [self filteredArrayUsingPredicate:predicate];
}
- (NSArray *)filteredWithFormat:(NSString *)predicateFormat, ... {
  va_list args;
  va_start(args, predicateFormat);
  NSArray *result = [self filteredWithFormat:predicateFormat arguments:args];
  va_end(args);
  return result;
}
- (NSArray *)filteredWithFormat:(NSString *)predicateFormat arguments:(va_list)argList {
  NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat arguments:argList];
  return [self filteredArrayUsingPredicate:predicate];
}
- (NSArray *)filtered:(BOOL (^)(id evaluatedObject, NSDictionary *bindings))block {
  NSPredicate *predicate = [NSPredicate predicateWithBlock:block];
  return [self filteredArrayUsingPredicate:predicate];
}
- (NSArray *)filteredOfType:(Class)type {
  return [self filtered:^BOOL(id item, NSDictionary *bindings) {
    return [[item class] isSubclassOfClass:type];
  }];
}
- (NSArray *)rejectOfType:(Class)type {
  return [self filtered:^BOOL(id item, NSDictionary *bindings) {
    return ![[item class] isSubclassOfClass:type];
  }];
}
@end

@implementation NSArray (Map)
- (NSArray *)mapWithKeyPath:(NSString *)keyPath {
  return [[self valueForKeyPath:keyPath] rejectOfType:[NSNull class]];
}

- (NSArray *)map:(id (^)(id object))block {
  if (!self.count)
    return nil;
  NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count];
  for (id obj in self) {
    id mapped = block(obj);
    
    if (mapped) {
      [result addObject:mapped];
    } 
  }
  return result;
}
@end

@implementation NSArray (Distinct)
- (NSArray *)distinct {
  if (!self.count)
    return nil;
  NSMutableArray *distinctSet = [[NSMutableArray alloc] init];
  for (id item in self) {
    if (![distinctSet containsObject:item]) {
      [distinctSet addObject:item];
    }
  }
  return distinctSet;
}
@end

@implementation NSArray (Sorting)

- (NSArray *)shuffle {
  NSMutableArray *mutableArray;
  if ([self isKindOfClass:[NSMutableArray class]]) {
    mutableArray = (NSMutableArray *)self;
  } else {
    mutableArray = [NSMutableArray arrayWithArray:self];
  }
  NSUInteger count = mutableArray.count;
  for (NSUInteger i = 0; i < count; i++) {
    NSUInteger j = i + arc4random_uniform((u_int32_t )(count - i));
    [mutableArray exchangeObjectAtIndex:i withObjectAtIndex:j];
  }
  
  return mutableArray;
}

- (NSArray *)reverse {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];
    NSEnumerator *enumerator = [self reverseObjectEnumerator];
    for (id element in enumerator) {
        [array addObject:element];
    }
    return array;
}

@end

@implementation NSArray (Filling)

+ (instancetype)arrayWithObjectsNumber:(NSUInteger)number creatingBlock:(id (^)(NSUInteger index))block {
  NSMutableArray *array = [NSMutableArray arrayWithCapacity:number];
  for (NSUInteger i = 0; i < number; ++i) {
    id obj = block(i);
    [array addObject:obj?:[NSNull null]];
  }
  return array;
}

@end