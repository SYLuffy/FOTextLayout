# FOTextLayout
实现文字的竖向排列(已区分中英文的竖向方向)。
实现各种文字的排版。
支持 NSAttributedStringKey 大部分的富文本属性，比如：字间距，行间距等。
这个项目本人会长期维护，也欢迎大家积极提issues。

# 动图展示
![image](https://github.com/SYLuffy/FOTextLayout/blob/master/screenCapture.gif)

## 安装

使用cocoapods的方式 

``` pods
 pod 'FOTextLayout', '~> 0.0.1'
 ```

也可以把demo工程里面的 FOText文件夹 拖到你的工程里面。

## 使用方法
你可以直接使用文件夹里的FOTextView这个控件，利用富文本，构造好一个NSAttributedString对象传入进去就行了。

代码如下:

```Objective-C

    self.boundView = [[FOTextView alloc] init];
    
    //直接使用富文本构造你的 文本信息。颜色，字间距，行间距等
    NSAttributedString *string1 = [[NSAttributedString alloc] initWithString:@"asdasqwecx12ok东皋嘉雨新痕涨，沙觜鹭来鸥聚。\n堪爱处最好是、一川夜月光流渚。"];
    NSAttributedString* result = [self buildAttrString:string1.string withFont:@"Copperplate-Light" fontSize:13
                                             lineSpace:2 kern:self.kern fontColor:[UIColor blackColor] delLine:NO];

    [self.boundView setAttString:result];
    [self.view addSubview:self.boundView];
```

设置横竖向排版

``` Objective-C
    //是否竖向排列
    self.boundView.isVertical = NO;
```

设置文字排列方向

``` Objective-C

typedef NS_ENUM(NSInteger,FOTextAlignment) {
    FOTextAlignmentLeft,
    FOTextAlignmentCenter,
    FOTextAlignmentRight
};

[self.boundView setTextAlignment:FOTextAlignmentLeft];
```

在你实际的使用中，你可以对FOTextView进行自定义。

## 参考项目
此文字排版库，参考了YYText里关于文字排版的部分代码，特别感谢YYText的作者 
[YYText](https://github.com/ibireme/YYText)

## License
MIT license. See LICENSE for details.
