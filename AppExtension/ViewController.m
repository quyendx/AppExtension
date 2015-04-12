//
//  ViewController.m
//  AppExtension
//
//  Created by Quyen Xuan on 3/27/15.
//  Copyright (c) 2015 Roxwin. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UIDocumentPickerDelegate, UIDocumentMenuDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtPreview;
@property (weak, nonatomic) IBOutlet UISwitch *btnSwitch;
@property (strong, nonatomic) NSURL *url;

@end

@implementation ViewController{
    NSArray *UTITypes;
    UIDocumentPickerMode mode;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UTITypes = [NSArray arrayWithObjects:@"com.adobe.pdf", @"public.text", @"public.image", @"public.spreadsheet", @"public.database", @"public.presentation", @"public.movie", nil];
    _url = [[NSBundle mainBundle] URLForResource:@"temp" withExtension:@"jpg"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - User action
- (IBAction)dismissKeyboard:(id)sender{
    [self.txtPreview resignFirstResponder];
}

- (IBAction)importFile:(id)sender{
    mode = UIDocumentPickerModeImport;
    [self presentDocumentExtensionViewControllerMenu:self.btnSwitch.isOn];
}

- (IBAction)exportFile:(id)sender{
    mode = UIDocumentPickerModeExportToService;
    [self presentDocumentExtensionViewControllerMenu:self.btnSwitch.isOn];
}

- (IBAction)openFile:(id)sender{
    mode = UIDocumentPickerModeOpen;
    [self presentDocumentExtensionViewControllerMenu:self.btnSwitch.isOn];
}

- (IBAction)moveFile:(id)sender{
    mode = UIDocumentPickerModeMoveToService;
    [self presentDocumentExtensionViewControllerMenu:self.btnSwitch.isOn];
}

- (void)presentDocumentExtensionViewControllerMenu:(BOOL)showMenu{
    if (showMenu) {
        [self presentDocumentMenuExtensionViewControllerWithMode:mode];
    }else{
        [self presentDocumentPickerExtensionViewControllerWithMode:mode];
    }
}

- (void)presentDocumentMenuExtensionViewControllerWithMode:(UIDocumentPickerMode)pickerMode{
    UIDocumentMenuViewController *menuVC = nil;
    switch (pickerMode) {
        case UIDocumentPickerModeImport:{ // File from outside
            menuVC = [[UIDocumentMenuViewController alloc] initWithDocumentTypes:UTITypes inMode:mode];
            [menuVC addOptionWithTitle:@"Open image from Photo" image:nil order:UIDocumentMenuOrderFirst handler:^{
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                picker.delegate = self;
                [self presentViewController:picker animated:YES completion:nil];
            }];
        }
            break;
        case UIDocumentPickerModeOpen:
            menuVC = [[UIDocumentMenuViewController alloc] initWithDocumentTypes:UTITypes inMode:mode];
            break;
        case UIDocumentPickerModeMoveToService:{ // File from container sandbox app
            NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *str = @"Content of file";
            NSString *path = [docDir stringByAppendingPathComponent:@"test.txt"];
            [str writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
            NSURL *url = [NSURL fileURLWithPath:path];
            menuVC = [[UIDocumentMenuViewController alloc] initWithURL:url inMode:pickerMode];
        }
            break;
        case UIDocumentPickerModeExportToService:{
            menuVC = [[UIDocumentMenuViewController alloc] initWithURL:_url inMode:pickerMode];
        }
            break;
        default:
            break;
    }
    menuVC.delegate = self;
    [self presentViewController:menuVC animated:YES completion:nil];
}

- (void)presentDocumentPickerExtensionViewControllerWithMode:(UIDocumentPickerMode)pickerMode{
    UIDocumentPickerViewController *docVC = nil;
    switch (pickerMode) {
        case UIDocumentPickerModeImport:
        case UIDocumentPickerModeOpen:
            docVC = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:UTITypes inMode:mode];
            break;
        case UIDocumentPickerModeMoveToService:{
            NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *str = @"Content of file";
            NSString *path = [docDir stringByAppendingPathComponent:@"test.txt"];
            [str writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
            NSURL *url = [NSURL fileURLWithPath:path];
            docVC = [[UIDocumentPickerViewController alloc] initWithURL:url inMode:pickerMode];
        }
            break;
        case UIDocumentPickerModeExportToService:
            docVC = [[UIDocumentPickerViewController alloc] initWithURL:_url inMode:pickerMode];
            break;
        default:
            break;
    }
    docVC.delegate = self;
    [self presentViewController:docVC animated:YES completion:nil];
}

#pragma mark - UIDocumentMenuViewControllerDelegate
- (void)documentMenu:(UIDocumentMenuViewController *)documentMenu didPickDocumentPicker:(UIDocumentPickerViewController *)documentPicker{
    documentPicker.delegate = self;
    [self presentViewController:documentPicker animated:YES completion:nil];
}

- (void)documentMenuWasCancelled:(UIDocumentMenuViewController *)documentMenu{
    NSLog(@"Document menu was cancelled");
}

#pragma mark - UIDocumentPickerViewControllerDelegate
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url{
    UIAlertView *alert = nil;
    if (mode == UIDocumentPickerModeImport || mode == UIDocumentPickerModeExportToService) { // Copy file
        if ([[url lastPathComponent] containsString:@".rtf"] || [[url lastPathComponent] containsString:@".txt"]) {
            NSString *str = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
            alert = [[UIAlertView alloc] initWithTitle:@"Import/Export" message:[NSString stringWithFormat:@"URL %@\nContent %@", [url absoluteString], str] delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
        }else{
            alert = [[UIAlertView alloc] initWithTitle:@"Exported to" message:[url absoluteString] delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
        }
    }else{ // Open file direct
        if ([url startAccessingSecurityScopedResource]) { // Accessed file out of app sandbox
            if ([[url lastPathComponent] containsString:@".rtf"] || [[url lastPathComponent] containsString:@".txt"]) {
                NSString *str = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
                alert = [[UIAlertView alloc] initWithTitle:@"Open/Move" message:[NSString stringWithFormat:@"URL %@\nContent %@", [url absoluteString], str] delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
            }
            [url stopAccessingSecurityScopedResource];
        }
    }
    [alert show];
}

// called if the user dismisses the document picker without selecting a document (using the Cancel button)
- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller{
    NSLog(@"Document picker was cancelled");
}

#pragma mark -
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSURL *url = [info objectForKey:UIImagePickerControllerReferenceURL];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Image URL" message:[url absoluteString] delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"Image picker controller did cancel");
}

@end
