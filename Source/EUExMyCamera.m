//
//  EUExCamera.m
//  DOJOSO
//
//  Created by arbullzhang on 1-19-15.
//  Copyright 2011 arbullzhang. All rights reserved.

#import "EUExMyCamera.h"
#import "EUtility.h"
#import "EUExBaseDefine.h"
#import <AssetsLibrary/AssetsLibrary.h>

#define compress  0.3

@implementation EUExMyCamera

#define IsIOS6OrLower ([[[UIDevice currentDevice] systemVersion] floatValue]<7.0)

-(id)initWithBrwView:(EBrowserView *) eInBrwView{
    if (self = [super initWithBrwView:eInBrwView]) {
    }
    return self;
}

#pragma mark -
#pragma mark - dealloc

-(void)dealloc{
    [super dealloc];
}

-(void)clean{
    
}

#pragma mark -
#pragma mark - Plugin Method

-(void)open:(NSMutableArray *)inArguments {
    
    [self selectPhoto];
}

- (void)selectPhoto
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:(id)self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册中选取",@"拍照", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:(UIView *)meBrwView];
    [actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = (id)self;
    
    switch (buttonIndex)
    {
        case 0:
        {
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
            {
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                [EUtility brwView:meBrwView presentModalViewController:picker animated:YES];
            }
        }
            break;
        case 1:
        {
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                [EUtility brwView:meBrwView presentModalViewController:picker animated:YES];
            }
            else
            {
                return;
            }
        }
            break;
        default:
            break;
    }
}

-(void)uexSuccessWithOpId:(int)inOpId dataType:(int)inDataType data:(NSString *)inData {
    if (inData) {
        [self jsSuccessWithName:@"uexMyCamera.returnPhotoPath" opId:inOpId dataType:inDataType strData:inData];
    }
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (image == nil)
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    [self returnPhotoAbsolutePath2JS:image];
}

- (NSString*)pathOfImage:(UIImage *)photoImage{
    NSString *jpgPath =  [NSString stringWithFormat:@"%@/DoJoSo_%f.jpg",NSTemporaryDirectory(),CFAbsoluteTimeGetCurrent()];
    return jpgPath;
}

- (void)returnPhotoAbsolutePath2JS:(UIImage *)photoImage;
{
    NSString *jpgPath = [self pathOfImage:photoImage];
    BOOL succeed = [UIImageJPEGRepresentation(photoImage,compress) writeToFile:jpgPath atomically:YES];
    if(succeed){
        [self uexSuccessWithOpId:0 dataType:UEX_CALLBACK_DATATYPE_TEXT data:jpgPath];
    }else{
        [self uexSuccessWithOpId:0 dataType:UEX_CALLBACK_DATATYPE_TEXT data:nil];
    }
}

@end