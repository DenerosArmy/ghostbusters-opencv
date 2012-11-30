//
//  ViewController.h
//  opencv-ghost
//
//  Created by vaishaal on 11/29/12.
//  Copyright (c) 2012 vaishaal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController {
    
    IBOutlet UIButton *cvfunction;
}
#ifdef __cplusplus
- (cv::Mat)cvMatFromUIImage:(UIImage *)image;
- (cv::Mat)cvMatGrayFromUIImage:(UIImage *)imagel;
-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat;
#endif

-(IBAction)newfunc:(id)sender;
@end
