//
//  NSDataBase64EncodingDemo.m
//  DataEncodingDemoTests
//
//  Created by 1 on 2019/1/7.
//  Copyright © 2019 Samuel. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface NSDataBase64EncodingDemo : XCTestCase

@end

@implementation NSDataBase64EncodingDemo

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

-(void)testBase64Api{
    
    NSString *base64Str = @"MIIEogIBAAKCAQBjYkZvNeIa+1shtXTSzOPmKbgnsaJDq0twWVwwvLLPDpm8dEv7\r\nUgsZpnnXmxvG3phQkoGX1kiP1wvE9r5z6wmX7vlP55ogEshoN48nFnuvm6y+Ntik\r\nE9EHg/ulnaNAUPxkkjbGWlWs4adCdiLBz790YsoU5xN3tJm080riONs2qvdh0k+O\r\ne7gWLGV3xS/G1Ji9bc/9QilwRugRk9NNmt+GQHE0xTWFUSOHRuSe62Sgcp4eebCx\r\nIZlQQ5TiZVFYa8iSjexPA2D9DssdBee/FpkFhaK87Zi5WtjjyxnHeZW37OTGQtN1\r\nLDDXkiY6h8X5WcmZpHVe+KO80l+Lkdp727q/AgMBAAECggEAXwe3pdt2Kqqyh1cF\r\nMBRuzsSRrJL0P5RpfDJWLtwgdlDVvBfQF65postGsl1EgDKUnmaYuGFT3QaZ4Gq3\r\nzguujrMZfchN3eFX9B88KPocptxKn0++c5XnSDJxy/kiAvvtexU8fwod5kOXNbvU\r\nnFJUFavo43fZa5srZpVEw2/uXSSBbhpibEL5+Mc3gg8CfS23CJnKbjHTnAD+PgB8\r\nvoCLICPVvpsRZ+XFTKlVqHuA1/Xe9tiaNvR32h2C8thDRB10BzOVaimb1e5zzF01\r\ntdKYFQ8cU4238N91ezkqrEwNOPPwX+Au8Wi6BD5EW9HD700Jm8hzBqB6eclHfcTc\r\nqEyhgQKBgQDFwZNl2GIFYtJst2Hq2dMQPzVsxFvvUBu5MJUN/pTD7d9GEz79nBtI\r\n6QkAZt2JKFN080UtrSBhE/+/Nfh8wcw2b9TRo87j31hMTAjsZrpZOcpSuMwzPioI\r\nFxLGzfiBKCpk89cmZY0p4tOa0MXFFW4iASbe5eXRBwJTgyHrDT273wKBgQCAp5/R\r\nlwf73/LBT5H11A+s0zh/bRtC4omjkjsD9nHC3OypFR5TJ6z42LKaWAcm+SC5yc8K\r\nXdvi4tXh8aF6uMGCeon94K8Cs8zTbs01s45VYhfPoBW/ZJgWNjZX3u5zLX2mo8pZ\r\noKllyvwY35KyzWphZrmclo3Si7Q2t+8QOyndIQKBgAU2D6tMY3De5Mqmnnbw3IX+\r\nFGtUVVPeGYzswdDHl6X+G7ceBLfsKC/orCsNiuL1ZBWd34HPoR3NyByC0JSBCt+Y\r\nXNRVa7tHhG0mR8nq/xgg1LsPUZo8FiF2cjE49kZ5B3z3jADgBjNHXeojfEKwSOGu\r\nhBa1mjPC6oXG29r0016jAoGAcETWvGlVuEC3cGXlc2Y4v5IazWgC0B0sCyeChHS8\r\n1VVA2FPrgJkw4n8HbJTAuQvRuQ8Ys20wgw97oY3gYl1z0E7quDcnwe3xIdihDum/\r\nnVbafH6wO7Km3Us1pPyPjMb3zUFFRW1kJcY6s+H1/D4xRQoFk1X2MPNkshNUdQ+L\r\n+sECgYEAhdFYcmSrlDlk6O8tuVIed24UYHq+GymBCXq7TcF3u2AklAqq//5BSbgB\r\nLYb5OL7rrO8iSNObOvEHffiGNlb5HcuT731u2NDJ0Fyu799n8JENKH4q/2Er5D1m\r\n0faQeiBhRE7pcdNigkAx+mt+xhDuUK2WVomgC0ESWKbj6bzc6Rs=";
    
    //1.调用 initWithBase64EncodedString 获得 rawData
    NSData *originalData = [[NSData alloc]initWithBase64EncodedString:base64Str options:NSDataBase64DecodingIgnoreUnknownCharacters];
    //2.调用 base64EncodedStringWithOptions 获得 base64字符串
    NSString *base64EncodedString = [originalData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength|NSDataBase64EncodingEndLineWithCarriageReturn|NSDataBase64EncodingEndLineWithLineFeed];
    XCTAssertTrue([base64Str isEqualToString:base64EncodedString],@"base64Str与base64EncodedString相等");
    
    //3.initWithBase64EncodedData: utfData/originalData的区别:两者对应的编码表不同
    NSData *utfData = [base64Str dataUsingEncoding:NSUTF8StringEncoding];
    NSData *recoverDataFromUTFData = [[NSData alloc]initWithBase64EncodedData:utfData options:NSDataBase64DecodingIgnoreUnknownCharacters];
    XCTAssertTrue([originalData isEqualToData:recoverDataFromUTFData],@"originalData与recoverDataFromUTFData相等");
    
    //4.base64EncodedDataWithOptions:从 base64 rawdata中创建 utf8Data
    NSData *base64EncodedData = [originalData base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength|NSDataBase64EncodingEndLineWithCarriageReturn|NSDataBase64EncodingEndLineWithLineFeed];
    if ([base64EncodedData isEqualToData:utfData]) NSLog(@"相等");
    XCTAssertTrue([base64EncodedData isEqualToData:utfData],@"base64EncodedData与utfData相等");
}



@end
