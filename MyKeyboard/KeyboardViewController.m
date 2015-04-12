//
//  KeyboardViewController.m
//  MyKeyboard
//
//  Created by Quyen Xuan on 4/1/15.
//  Copyright (c) 2015 Roxwin. All rights reserved.
//

#import "KeyboardViewController.h"

@interface KeyboardViewController ()
@property (nonatomic, strong) NSArray *keyboardButtonTitles;
@property (nonatomic, strong) NSMutableArray *keyboardButtons;
@property (nonatomic, assign) BOOL isLowerKey;
@end

@implementation KeyboardViewController

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    // Add custom view sizing constraints here
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Perform custom UI setup here
    [self.view setBackgroundColor:[UIColor clearColor]];
    self.keyboardButtons = [NSMutableArray arrayWithCapacity:20];
    self.isLowerKey = NO;
    
    NSArray *firstRow = [NSArray arrayWithObjects:@"Q", @"W", @"E", @"R", @"T", @"Y", @"U", @"I", @"O", @"P", nil];
    NSArray *secRow = [NSArray arrayWithObjects:@"A", @"S", @"D", @"F", @"G", @"H", @"J", @"K", @"L", nil];
    NSArray *thirdRow = [NSArray arrayWithObjects:@"CP", @"Z", @"X", @"C", @"V", @"B", @"N", @"M", @"DEL", nil];
    NSArray *fourRow = [NSArray arrayWithObjects:@"CHG", @"SPACE", @"RETURN", nil];
    self.keyboardButtonTitles = [NSArray arrayWithObjects:firstRow, secRow, thirdRow, fourRow, nil];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    UIView *keyboard = [self createKeyboardWithFrame:CGRectMake(0, 0, screenBounds.size.width, 216) buttonTitles:self.keyboardButtonTitles];
    if (![self.view.subviews containsObject:keyboard]) {
        [self.view addSubview:keyboard];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated
}

- (void)textWillChange:(id<UITextInput>)textInput {
    // The app is about to change the document's contents. Perform any preparation here.
}

- (void)textDidChange:(id<UITextInput>)textInput {
    // The app has just changed the document's contents, the document context has been updated.
    
    UIColor *textColor = nil;
    if (self.textDocumentProxy.keyboardAppearance == UIKeyboardAppearanceDark) {
        textColor = [UIColor whiteColor];
    } else {
        textColor = [UIColor blackColor];
    }
}

- (UIButton *)createKeyboardButtonWithTitle:(NSString *)title width:(CGFloat)width height:(CGFloat)height atIndex:(NSInteger)index{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(index * width, 0, width, height)];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor colorWithRed:1.0 green:250/255.0f blue:205/255.0f alpha:0.1f]];
    [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(didTapButton:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (UIView *)createKeyboardWithFrame:(CGRect)frame buttonTitles:(NSArray *)buttonTitles{
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    UIView *keyboardView = [[UIView alloc] initWithFrame:frame];
    CGFloat rowHeight = frame.size.height/buttonTitles.count;
    for (NSArray *arr in buttonTitles) {
        NSInteger index = [buttonTitles indexOfObject:arr];
        UIView *row = [self createKeyboardRowViewWithSize:CGSizeMake(screenWidth, rowHeight) atIndex:index rowTitles:arr];
        [keyboardView addSubview:row];
    }
    return keyboardView;
}

- (UIView *)createKeyboardRowViewWithSize:(CGSize)size atIndex:(NSInteger)index rowTitles:(NSArray *)rowTitles{
    UIView *row = [[UIView alloc] initWithFrame:CGRectMake(0, size.height * index, size.width, size.height)];
    CGFloat btnWidth = size.width / rowTitles.count;
    for (NSString *title in rowTitles) {
        UIButton *btn = [self createKeyboardButtonWithTitle:title width:btnWidth height:size.height atIndex:[rowTitles indexOfObject:title]];
        [self.keyboardButtons addObject:btn];
        [row addSubview:btn];
    }
    return row;
}

- (void)didTapButton:(UIButton *)button{
    if ([button.titleLabel.text isEqualToString:@"CP"] || [button.titleLabel.text isEqualToString:@"cp"]) {
        [self changeToLowerKey:!self.isLowerKey];
        return;
    }
    if ([button.titleLabel.text isEqualToString:@"DEL"] || [button.titleLabel.text isEqualToString:@"del"]) {
        [self.textDocumentProxy deleteBackward];
        return;
    }
    if ([button.titleLabel.text isEqualToString:@"SPACE"] || [button.titleLabel.text isEqualToString:@"space"]) {
        [self.textDocumentProxy insertText:@" "];
        return;
    }
    if ([button.titleLabel.text isEqualToString:@"RETURN"] || [button.titleLabel.text isEqualToString:@"return"]) {
        [self dismissKeyboard];
        return;
    }
    
    if ([button.titleLabel.text isEqualToString:@"CHG"] || [button.titleLabel.text isEqualToString:@"chg"]) {
        [self advanceToNextInputMode];
        return;
    }
    
    [self.textDocumentProxy insertText:button.titleLabel.text];
}

- (void)changeToLowerKey:(BOOL)lowerKey{
    for (UIButton *btn in self.keyboardButtons) {
        if ([btn.titleLabel.text isEqualToString:@"CP"] || [btn.titleLabel.text isEqualToString:@"DEL"] || [btn.titleLabel.text isEqualToString:@"CHG"] || [btn.titleLabel.text isEqualToString:@"SPACE"] || [btn.titleLabel.text isEqualToString:@"RETURN"]) {
            continue;
        }
        if (lowerKey) {
            [btn setTitle:[btn.titleLabel.text lowercaseString] forState:UIControlStateNormal];
        }else{
            [btn setTitle:[btn.titleLabel.text uppercaseString] forState:UIControlStateNormal];
        }
    }
    self.isLowerKey = lowerKey;
}

@end
