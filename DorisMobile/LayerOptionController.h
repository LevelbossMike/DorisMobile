//
//  LayerOptionController.h
//  DorisMobile
//
//  Created by Michael Klein on 13.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LayerOptionControllerDelegate <NSObject>
-(void) didTap: (NSString *)string;
@end

@interface LayerOptionController : UITableViewController

@property(nonatomic, retain) NSMutableArray *arrayOfStrings;
@property (nonatomic, assign) id<LayerOptionControllerDelegate> delegate;


@end
