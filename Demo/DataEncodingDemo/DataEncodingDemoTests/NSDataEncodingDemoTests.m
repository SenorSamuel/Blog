//
//  DataEncodingDemoTests.m
//  DataEncodingDemoTests
//
//  Created by Samuel on 2018/12/1.
//  Copyright © 2018 Samuel. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface NSDataEncodingDemoTests : XCTestCase

@end

@implementation NSDataEncodingDemoTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

#pragma mark - 测试"度"的UTF8编码是 E5 BA A6,且占三个字节
- (void)testDuUTF8Encoding {

    //    "View memory of *_bytes" → E5 BA A6
//    `度` 的 Unicode 编码为`U+5EA6`
//    1. `U+5E96`转换为二进制为:`0101 1110 1010 0110`
//    2. 根据上表得知,`U+5EA6`落在 `0000 0800-0000 FFFF`区间中,UTF-8编码方式为`1110xxxx 10xxxxxx 10xxxxxx`
//    3. 将 `0101 1110 1001 0110` 的低位填到`1110xxxx 10xxxxxx 10xxxxxx`的低位中,不足的补零
//    4. 即`11100101 10111010 10100110` = **E5 BA A6**
    NSData *dataDu = [@"度" dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertTrue(dataDu.length == 3, @"\"度\"的长度不是3");
    Byte byteExpected[] = {0xE5,0xBA,0xA6};
    NSData *dataExpected = [NSData dataWithBytes:byteExpected length:3];
    XCTAssertTrue([dataDu isEqualToData:dataExpected], @"度的 UTF8 编码不是 EABAA6");
}

#pragma mark - 测试"娘"的UTF8编码是 E5 A8 98,且占三个字节
- (void)testNiangUTF8Encoding {
    
//    "View memory of *_bytes" → E5 A8 98
//    1. `U+5A18`转换为二进制为:`0101 1010 0001 1000`
//    2. 根据上表得知,`U+5A18`落在 `0000 0800-0000 FFFF`区间中,UTF-8编码方式为1110xxxx 10xxxxxx 10xxxxxx
//    3. 将 `0101 1010 0001 1000` 的低位填到`1110xxxx 10xxxxxx 10xxxxxx`的低位中,不足的补零
//    4. 即`11100101 10101000 10011000` = **E5 A8 98**
    NSData *dataNiang = [@"娘" dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertTrue(dataNiang.length == 3, @"\"娘\"的长度不是3");
    Byte byteExpected[] = {0xE5,0xA8,0x98};
    NSData *dataExpected = [NSData dataWithBytes:byteExpected length:3];
    XCTAssertTrue([dataNiang isEqualToData:dataExpected], @"娘的 UTF8 编码不是 E5A898");
}

#pragma mark - 测试 UTF16 编码
-(void)testUTF16Encoding{
//    例如:`😍`的 Unicode 编码为 `U+1F60D`,UTF16编码过程如下
    
//    - 0x1F60D 减去 0x10000,结果为 0x0F60D,二进制为0000 1111 0110 0000 1101。
//    - 分割它的上10位值和下10位值（使用二进制）:00001 11101 and 10000 01101。
//    添加0xD800到上值，以形成高位：0xD800 + 0x003D = 0xD83D。
//    添加0xDC00到下值，以形成低位：0xDC00 + 0x020D = 0xDE0D。
//    - 即结果为: `D8 3D DE 0D`
//    - iOS 默认是小端,所以加上 `FFFE`, 然后将 `D8 3D DE 0D` 转换成小端(编码单元为16)形式,即 `FF FE 3D D8 0D DE`
    NSData *dataEmoji = [@"😍" dataUsingEncoding:NSUTF16StringEncoding];
    Byte byteExpected[] = {0xFF,0xFE,0x3D,0xD8,0x0D,0xDE};
    NSData *dataExpected = [NSData dataWithBytes:byteExpected length:6];
    XCTAssertTrue([dataEmoji isEqualToData:dataExpected], @"😍的 UTF8 编码不是 FF FE 3D D8 0D DE");
}

#pragma mark - 测试 iOS 是大端还是小端
-(void) testIOSISLittleEndian {
    
    NSAssert(NSHostByteOrder() == NS_LittleEndian, @"iOS 使用大端");
}

#pragma mark - NSString 与 Unicode
-(void) testNSStringAndUnicode{
    
    NSString *str1 = @"A";
    // => str.length = 1
    XCTAssertTrue(str1.length == 1, @"A的长度不为1个UTF16码元");
    str1 = @"度";
    // => str.length = 1
    XCTAssertTrue(str1.length == 1, @"度的长度不为1个UTF16码元");
    str1 = @"😍";
    // => str.length = 2
    XCTAssertTrue(str1.length == 2, @"😍的长度不为2个UTF16码元");
    str1 = @"A度😍";
    // => str.length = 4
    unichar char2 =[str1 characterAtIndex:2];
    // => char2 U+d83d u
    NSRange range = [str1 rangeOfComposedCharacterSequenceAtIndex:0];
    NSLog(@"%@",NSStringFromRange(range));// {0,1}
    range = [str1 rangeOfComposedCharacterSequenceAtIndex:1];
    NSLog(@"%@",NSStringFromRange(range));//{1,1}
    range = [str1 rangeOfComposedCharacterSequenceAtIndex:2];
    NSLog(@"%@",NSStringFromRange(range));//{2,2}
    
    range = [str1 rangeOfComposedCharacterSequencesForRange:NSMakeRange(2, 1)];
    NSLog(@"%@",NSStringFromRange(range));//{2,2}

    
//    [str1 enumerateSubstringsInRange:range
//                          options:NSStringEnumerationByComposedCharacterSequences
//                       usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop)
//    {
//        NSLog(@"%@ %@", substring, NSStringFromRange(substringRange));
//    }];
}

#pragma mark - 判断字符串等价性
-(void)testNSStringEquivalence{
    
    NSString *s = @"\u00E9"; // é
    NSString *t = @"e\u0301"; // e + ´
    BOOL isEqual = [s isEqualToString:t];
    NSLog(@"%@ is %@ to %@", s, isEqual ? @"equal" : @"not equal", t);
    // => é is not equal to é
    
    // Normalizing to form C
    NSString *sNorm = [s precomposedStringWithCanonicalMapping];
    NSString *tNorm = [t precomposedStringWithCanonicalMapping];
    BOOL isEqualNorm = [sNorm isEqualToString:tNorm];
    NSLog(@"%@ is %@ to %@", sNorm, isEqualNorm ? @"equal" : @"not equal", tNorm);
    // => é is equal to é
    
    //如果只想判断两个字符串是否是"兼容等价",可以使用 localizedCompare:
    s = @"ff"; // ff
    t = @"\uFB00"; // ﬀ ligature
    NSComparisonResult result = [s localizedCompare:t];
    NSLog(@"%@ is %@ to %@", s, result == NSOrderedSame ? @"equal" : @"not equal", t);
    // => ff is equal to ﬀ
}

@end
