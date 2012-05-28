//
//  CustomTableViewCell.h
//  HummbeeHunt
//
//  Created by Alex Zhao Bin on 16/01/12.
//  Copyright (c) 2012 Roadhouse Digital. All rights reserved.
//

#define kCellAccessoryViewSpace (36.0)

typedef enum 
{
	CustomTableViewCellBackgroundViewPositionSingle = 0,
	CustomTableViewCellBackgroundViewPositionTop = 1, 
	CustomTableViewCellBackgroundViewPositionBottom = 2,
	CustomTableViewCellBackgroundViewPositionMiddle = 3
} CustomTableViewCellBackgroundViewPosition;


@interface CustomTableViewCell : UITableViewCell {
    UIButton *detailButton;
}

@property (nonatomic, readonly) UIButton *detailButton;
@property (nonatomic, assign) CustomTableViewCellBackgroundViewPosition position;

@end
