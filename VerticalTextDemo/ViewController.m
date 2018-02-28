//
//  ViewController.m
//  VerticalTextDemo
//
//  Created by shenyi on 29/08/2017.
//  Copyright © 2017 everImageing. All rights reserved.
//

#import "ViewController.h"
#import "FOTextView.h"
#import <CoreText/CoreText.h>

@interface ViewController ()


@property (nonatomic, strong) UIButton *btnAlignment;

@property (nonatomic, strong) UIButton *btnLayout;

@property (nonatomic, strong) UIButton *btnSpacingAdd;

@property (nonatomic, strong) UIButton *btnKernAdd;

@property (nonatomic, strong) FOTextView *boundView;

@property (nonatomic, assign) CGFloat spacing;

@property (nonatomic, assign) CGFloat kern;


@property (nonatomic, strong) NSAttributedString *testText;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.spacing = 2;
    
    self.kern = 0;
    
    //直接使用FOTextView
    self.boundView = [[FOTextView alloc] init];
    NSAttributedString *string1 = [[NSAttributedString alloc] initWithString:@"asdasqwecx12ok东皋嘉雨新痕涨，沙觜鹭来鸥聚。\n堪爱处最好是、一川夜月光流渚。\n无人独舞。\n任翠幄张天，柔茵藉地，酒尽未能去。\n青绫被，莫忆金闺故步。\n儒冠曾把身误。\n弓刀千骑成何事，荒了邵平瓜圃。\n君试觑。\n满青镜、星星鬓影今如许。\n功名浪语。fgff便似得班超，封侯万里，dadaaf归计恐迟暮。"];
    self.testText = string1;
    //构造富文本信息
    NSAttributedString* result = [self buildAttrString:string1.string withFont:@"Copperplate-Light" fontSize:13
                                             lineSpace:2 kern:self.kern fontColor:[UIColor blackColor] delLine:NO];
    self.boundView.isVertical = NO;
    [self.boundView setAttString:result];
    
    [self.view addSubview:self.boundView];
    
    self.boundView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    
    //alignment
    self.btnAlignment = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 100, 60, 40)];
    
    [self.btnAlignment setTitle:@"Alignment" forState:UIControlStateNormal];
    
    [self.btnAlignment addTarget:self action:@selector(onAlignmentTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.btnAlignment setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [self.btnAlignment setBackgroundColor:[UIColor redColor]];
    
    //layout
    [self.view addSubview:self.btnAlignment];
    
    self.btnLayout = [[UIButton alloc] initWithFrame:CGRectMake(self.btnAlignment.frame.origin.x + self.btnAlignment.frame.size.width + 10, self.btnAlignment.frame.origin.y, 60, 40)];
    [self.btnLayout setTitle:@"Layout" forState:UIControlStateNormal];
    [self.btnLayout setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.btnLayout setBackgroundColor:[UIColor redColor]];
    
    [self.view addSubview:self.btnLayout];
    
    [self.btnLayout addTarget:self action:@selector(onLayoutTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    // space
    self.btnSpacingAdd = [[UIButton alloc] initWithFrame:CGRectMake(self.btnLayout.frame.origin.x + self.btnLayout.frame.size.width + 10, self.btnAlignment.frame.origin.y, 60, 40)];
    [self.btnSpacingAdd setTitle:@"Spacing" forState:UIControlStateNormal];
    [self.btnSpacingAdd setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.btnSpacingAdd setBackgroundColor:[UIColor redColor]];
    
    [self.view addSubview:self.btnSpacingAdd];
    
    [self.btnSpacingAdd addTarget:self action:@selector(onSpacingTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    //kern
    self.btnKernAdd = [[UIButton alloc] initWithFrame:CGRectMake(self.btnSpacingAdd.frame.origin.x + self.btnSpacingAdd.frame.size.width + 10, self.btnAlignment.frame.origin.y, 60, 40)];
    [self.btnKernAdd setTitle:@"Kern" forState:UIControlStateNormal];
    [self.btnKernAdd setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.btnKernAdd setBackgroundColor:[UIColor redColor]];
    
    [self.view addSubview:self.btnKernAdd];
    
    [self.btnKernAdd addTarget:self action:@selector(onKernTapped:) forControlEvents:UIControlEventTouchUpInside];
    
}


- (void)onSpacingTapped:(UIButton*)sender{
    
    self.spacing += sender.selected? -2: 2;
    
    if(self.spacing > 10){
        sender.selected = YES;
    } else if(self.spacing < 0) {
        sender.selected  = NO;
    }
    
    NSAttributedString* string =  [self buildAttrString:self.testText.string withFont:@"Copperplate-Light" fontSize:13 lineSpace:self.spacing kern:self.kern fontColor:[UIColor blackColor] delLine:NO];
    
    [self.boundView setAttString:string];
    
    self.boundView.isVertical = self.btnAlignment.selected;
    
    [self.boundView setTextAlignment:(int)self.btnAlignment.tag];
    
}

- (void)onKernTapped:(UIButton*)sender{
    
    self.kern += sender.selected? -2: 2;
    
    if(self.kern > 10){
        sender.selected = YES;
    } else if(self.kern < 0) {
        sender.selected  = NO;
    }
    
    NSAttributedString* string =  [self buildAttrString:self.testText.string withFont:@"Copperplate-Light" fontSize:13 lineSpace:self.spacing kern:self.kern fontColor:[UIColor blackColor] delLine:NO];
    
    [self.boundView setAttString:string];
    
    self.boundView.isVertical = self.btnAlignment.selected;
    
    [self.boundView setTextAlignment:(int)self.btnAlignment.tag];
    
}


- (void)onLayoutTapped:(UIButton*)sender{
    
    self.boundView.isVertical = !sender.selected;
    
    [self.boundView setTextAlignment:(int)self.btnAlignment.tag];
    
    sender.selected = self.boundView.isVertical;
    
}

- (void)onAlignmentTapped:(UIButton*)sender{
    NSInteger tag =  sender.tag;
    
    if(tag < 2){
        tag++;
    } else {
        tag = 0;
    }
    
    sender.tag = tag;
    
    [self.boundView setTextAlignment:(int)tag];
    
}

//下面我使用了 coretext里面的富文本属性
//使用NSDictionary<NSAttributedStringKey, id> *)attrs 也可以
- (NSMutableAttributedString *)buildAttrString:(NSString *)content
                                      withFont:(NSString *)fontName
                                      fontSize:(CGFloat)fontSize
                                     lineSpace:(CGFloat)lineSpace
                                          kern:(CGFloat)kernValue
                                     fontColor:(UIColor *)textColor
                                       delLine:(BOOL)delLine
{
    
    
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)fontName, fontSize, NULL);
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc]
                                            initWithString:content
                                            attributes:
                                            @{
                                              (NSString *)kCTFontAttributeName : (__bridge id)fontRef,
                                              (NSString *)kCTForegroundColorAttributeName :(id)textColor.CGColor
                                              }];

    
    
    //line break
    CTParagraphStyleSetting lineBreakMode;
    CTLineBreakMode lineBreak = kCTLineBreakByWordWrapping; //换行模式
    lineBreakMode.spec = kCTParagraphStyleSpecifierLineBreakMode;
    lineBreakMode.value = &lineBreak;
    lineBreakMode.valueSize = sizeof(CTLineBreakMode);
    //行间距
    CTParagraphStyleSetting LineSpacing;
    CGFloat spacing = lineSpace;  //指定间距
    LineSpacing.spec = kCTParagraphStyleSpecifierLineSpacingAdjustment;
    LineSpacing.value = &spacing;
    LineSpacing.valueSize = sizeof(CGFloat);

    CTParagraphStyleSetting settings[] = {lineBreakMode,LineSpacing};
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, 2);   //第二个参数为settings的长度
    [attString addAttribute:(NSString *)kCTParagraphStyleAttributeName
                      value:(__bridge id)paragraphStyle
                      range:NSMakeRange(0, attString.length)];
    
    if(kernValue != 0){
        [attString addAttribute:NSKernAttributeName
                                 value:[NSNumber numberWithFloat:kernValue]
                                 range:NSMakeRange(0, [attString length])];
    }
    if (delLine){
        NSNumber *underline = [NSNumber numberWithInt:kCTTextAlignmentCenter];
        [attString addAttribute:(id)kCTUnderlineStyleAttributeName value:underline range:NSMakeRange(0, attString.length) ];
    }
    return attString;
}

@end
