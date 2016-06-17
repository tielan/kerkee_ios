//
//  KCFile.m
//  kerkee
//
//  Created by zihong on 16/6/17.
//  Copyright © 2016年 zihong. All rights reserved.
//

#import "KCFile.h"
#import "string.h"
#import "KCFileManager.h"

#define kSeparatorChar '/'

@interface KCFile ()
{
    NSString* m_path;
}

@end


// Removes duplicate adjacent slashes and any trailing slash.
static NSString* fixSlashes(NSString* origPath)
{
    if (!origPath) return nil;
    // Remove duplicate adjacent slashes.
    bool lastWasSlash = false;
    const char* newOrigPath = origPath.UTF8String;
//    const char* newOrigPath = [origPath cStringUsingEncoding:NSUTF8StringEncoding];//0x80000632
    if (!newOrigPath) return nil;
    
    int length = (int)strlen(newOrigPath);
    char* newPath = malloc((length+1)*sizeof(char));
    memset(newPath, 0, (length+1)*sizeof(char));
    int newLength = 0;
    for (int i = 0; i < length; ++i)
    {
        char ch = newOrigPath[i];
        if (ch == '/')
        {
            if (!lastWasSlash)
            {
                newPath[newLength++] = kSeparatorChar;
                lastWasSlash = true;
            }
        }
        else
        {
            newPath[newLength++] = ch;
            lastWasSlash = false;
        }
    }
    // Remove any trailing slash (unless this is the root of the file system).
    if (lastWasSlash && newLength > 1)
    {
        newLength--;
    }
    
    NSString *newPathString = [NSString stringWithCString:newPath encoding:NSUTF8StringEncoding];
    
    if (newPath)
    {
        free(newPath);
        newPath = NULL;
    }
    
    // Reuse the original string if possible.
    return (newLength != length) ? newPathString : origPath;
}


// Joins two path components, adding a separator only if necessary.
static NSString* join(NSString* prefix, NSString* suffix)
{
//    if (!prefix) prefix = @"";
//    if (!suffix) suffix = @"";
    int prefixLength = (int)prefix.length;
    bool haveSlash = (prefixLength > 0 && [prefix characterAtIndex:prefixLength - 1] == kSeparatorChar);
    if (!haveSlash)
    {
        haveSlash = (suffix.length > 0 && [suffix characterAtIndex:0] == kSeparatorChar);
    }
    return haveSlash ? [NSString stringWithFormat:@"%@%@", prefix, suffix] : [NSString stringWithFormat:@"%@%c%@", prefix, kSeparatorChar,suffix];
}

@implementation KCFile

- (id)init
{
    if (self = [super init])
    {
    }
    return self;
}

- (id)initWithPath:(NSString*)aPath
{
    if (self = [super init])
    {
        m_path = fixSlashes(aPath);
    }
    return self;
}

- (id)initWithPath:(NSString*)aDirPath name:(NSString*)aName
{
    if (self = [super init])
    {
        if (aDirPath == NULL || aDirPath.length == 0)
        {
            m_path = fixSlashes(aName);
        }
        else if (aName.length == 0)
        {
            m_path = fixSlashes(aDirPath);
        }
        else
        {
            m_path = fixSlashes(join(aDirPath, aName));
        }
    }
    return self;
}

- (id)initWithFile:(KCFile*)aDirFile name:(NSString*)aName
{
    self = [self initWithPath:(aDirFile ? aDirFile.getPath : nil) name:aName];
    
    return self;
}

- (NSString*)getPath
{
    return m_path;
}

- (BOOL)canExecute
{
    if (!m_path) return false;
    return [KCFileManager isExecutable:m_path];
}

- (BOOL)canRead
{
    if (!m_path) return false;
    return [KCFileManager isReadable:m_path];
}

- (BOOL)canWrite
{
    if (!m_path) return false;
    return [KCFileManager isWritable:m_path];
}


@end
