//
//  ViewController.h
//  DorisMobile
//
//  Created by Michael Klein on 14.09.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArcGIS.h"


@interface ViewController : UIViewController <AGSMapViewLayerDelegate>
@property (nonatomic, retain) IBOutlet AGSMapView *mapView;
@property (nonatomic, retain) AGSTiledMapServiceLayer *tiledLayer;
@property (nonatomic, retain) AGSSketchGraphicsLayer *sketchLyr;
@property BOOL locationStatusEnabled;
@property BOOL sketchLayerEnabled;

-(IBAction)changeLayer:(id)sender;
-(IBAction)toggleLocationService:(id)sender;
-(IBAction)toggleSketchLayer:(id)sender;


@end
