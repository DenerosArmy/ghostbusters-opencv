//
//  ViewController.m
//  opencv-ghost
//
//  Created by vaishaal on 11/29/12.
//  Copyright (c) 2012 vaishaal. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"test1" ofType:@"jpg"];
    UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:filePath]];
    img.frame = CGRectMake(0, 0, 320, 480);
    [self.view addSubview:img];
    [self.view bringSubviewToFront:cvfunction];
    
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)newfunc:(id)sender {
    NSLog(@"called");
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"test1" ofType:@"jpg"];
    CGSize viewSize = self.view.bounds.size;
    UIImage* input = [self resizeImage:[UIImage imageWithContentsOfFile:filePath] newSize:viewSize];
    NSLog(@"%f",input.size.height);
    UIImageView *img = [[UIImageView alloc] initWithImage:input];
    img.frame = CGRectMake(0, 0, 320, 460);
    
    
    
    //cv function here.
    cv::Mat inputMat = [self cvMatFromUIImage:input];
    cv::Mat greyMat;
    cv::cvtColor(inputMat, greyMat, CV_BGR2GRAY);
    double min = 0;
    double max = 0;
    cv::Point max_loc(1,2);
    cv::Point min_loc(1,2);
    cv::minMaxLoc(greyMat, &min,&max,&min_loc,&max_loc);
    int x_loc = (int)max_loc.x-15;
    int y_loc = (int)max_loc.y-15;
    cv::Mat subImg = greyMat(cv::Rect(x_loc,y_loc,30,30));
    cv::Scalar mean = cv::mean(subImg);
    double mean_val = mean.val[0];
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Hello!" message:[NSString stringWithFormat:@"%1.2f,%d,%d,%1.2f",max,x_loc,y_loc,mean_val] delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
    [alert show];
    UIImage* output = [self UIImageFromCVMat:greyMat];
    
    
    
    UIImageView *img2 = [[UIImageView alloc] initWithImage:output];
    
    
    img2.frame = CGRectMake(0, 0, 320, 460);
    [self.view addSubview:img2];
    [self.view bringSubviewToFront:cvfunction];
    
    UIView *rectangle = [[UIView alloc] initWithFrame:CGRectMake(x_loc, y_loc, 30, 30)]; //A rectangle at point (0, 0) 50x50 in size.
    rectangle.backgroundColor = [UIColor redColor]; //color the rectangle
    [img2 addSubview:rectangle]; //add the rectangle to your image

}
- (UIImage *)resizeImage:(UIImage*)image newSize:(CGSize)newSize {
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGImageRef imageRef = image.CGImage;
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height);
    
    CGContextConcatCTM(context, flipVertical);
    // Draw into the context; this scales the image
    CGContextDrawImage(context, newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(context);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    CGImageRelease(newImageRef);
    UIGraphicsEndImageContext();
    
    return newImage;
}
- (void)drawRect:(CGRect)rect;
{
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(contextRef, 0, 0, 255, 0.1);
    CGContextSetRGBStrokeColor(contextRef, 0, 0, 255, 0.5);
    // Draw a circle (filled)
    CGContextFillEllipseInRect(contextRef, CGRectMake(100, 100, 25, 25));
    // Draw a circle (border only)
    CGContextStrokeEllipseInRect(contextRef, CGRectMake(100, 100, 25, 25));
    // Get the graphics context and clear it
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextClearRect(ctx, rect);
    // Draw a green solid circle
    CGContextSetRGBFillColor(ctx, 0, 255, 0, 1);
    CGContextFillEllipseInRect(ctx, CGRectMake(100, 100, 25, 25));
    // Draw a yellow hollow rectangle
    CGContextSetRGBStrokeColor(ctx, 255, 255, 0, 1);
    CGContextStrokeRect(ctx, CGRectMake(195, 195, 60, 60));
    // Draw a purple triangle with using lines
    CGContextSetRGBStrokeColor(ctx, 255, 0, 255, 1);
    CGPoint points[6] = { CGPointMake(100, 200), CGPointMake(150, 250),
        CGPointMake(150, 250), CGPointMake(50, 250),
        CGPointMake(50, 250), CGPointMake(100, 200) };
    CGContextStrokeLineSegments(ctx, points, 6);
}

- (double)lookForFlash:(cv::Mat)gray_scale
{
    double min = 0;
    double max = 0;
  
    cvMinMaxLoc(&gray_scale,&min,&max);
    return max;
    
    
}

- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    return cvMat;
}

- (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC1); // 8 bits per component, 1 channe       
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    return cvMat;
}

-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
