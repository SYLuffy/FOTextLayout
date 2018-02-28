# FOTextLayout
直接使用coreText框架，绘制文字，可以用来替代UILabel，实现文字的各种复杂排版。
这个项目本人会长期维护，也欢迎大家积极提issues。

# 动图展示


## 安装
暂时没有放到pods上面，所以只需要把工程里面的 FOText文件夹 拖到你的工程里面就行了。

## 使用方法
你可以直接使用文件夹里的FOTextView这个控件，使用方法如下:

```Objective-C

    self.boundView = [[FOTextView alloc] init];
    
    //直接使用富文本构造你的 文本信息
    
    NSAttributedString *string1 = [[NSAttributedString alloc] initWithString:@"asdasqwecx12ok东皋嘉雨新痕涨，沙觜鹭来鸥聚。\n堪爱处最好是、一川夜月光流渚。"];
    NSAttributedString* result = [self buildAttrString:string1.string withFont:@"Copperplate-Light" fontSize:13
                                             lineSpace:2 kern:self.kern fontColor:[UIColor blackColor] delLine:NO];
    //设置文本
    [self.boundView setAttString:result];
    [self.view addSubview:self.boundView];
```
在你实际的使用中，你可以对FOTextView进行各种改造，或者完全抛开不用，直接重新封装一个控件也可以的。

## 参考项目
此文字排版库，参考了YYText里关于文字排版的部分代码，也做了一些代码引用，特别感谢YYText的作者 
[YYText](https://github.com/ibireme/YYText)

## License
MIT license. See LICENSE for details.
