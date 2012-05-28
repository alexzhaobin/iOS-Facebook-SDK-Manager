//
//  MultilineTextView.h
//  LocationTrackingGPS2
//
//  Created by Bin Zhao on 26/02/11.
//  Copyright 2011 DBSys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@interface MultilineTextViewBackgroundLayer : CALayer {
	CGFloat lineHeight;
}

@property (nonatomic) CGFloat lineHeight;

@end

@interface MultilineTextView : UITextView<UIScrollViewDelegate> {
	MultilineTextViewBackgroundLayer *backgroundLayer;
}

@end
