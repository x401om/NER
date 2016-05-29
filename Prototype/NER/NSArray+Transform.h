//
//  NSArray+Filtred.h
//  Upmind
//
//  Created by Alexey D Vallianos on 07.07.15.
//  Copyright (c) 2015 Easy Ten LLC. All rights reserved.
//

@import Foundation;

@interface NSArray (Filtered)
- (NSArray *)filteredWithFormat:(NSString *)predicateFormat argumentArray:(NSArray *)arguments;
- (NSArray *)filteredWithFormat:(NSString *)predicateFormat, ...;
- (NSArray *)filteredWithFormat:(NSString *)predicateFormat arguments:(va_list)argList;
- (NSArray *)filtered:(BOOL (^)(id evaluatedObject, NSDictionary *bindings))block;
- (NSArray *)filteredOfType:(Class)type;
- (NSArray *)rejectOfType:(Class)type;
@end

@interface NSArray (Map)
- (NSArray *)mapWithKeyPath:(NSString *)keyPath;
- (NSArray *)map:(id (^)(id object))block;
@end

@interface NSArray (Distinct)
- (NSArray *)distinct;
@end

@interface NSArray (Sorting)
- (NSArray *)shuffle;
- (NSArray *)reverse;
@end

@interface NSArray (Filling)
+ (instancetype)arrayWithObjectsNumber:(NSUInteger)number creatingBlock:(id (^)(NSUInteger index))block;
@end
