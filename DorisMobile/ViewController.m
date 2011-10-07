//
//  ViewController.m
//  DorisMobile
//
//  Created by Michael Klein on 14.09.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController
@synthesize mapView = _mapView;
@synthesize tiledLayer = _tiledLayer;
@synthesize sketchLyr = _sketchLyr;
@synthesize locationStatusEnabled;
@synthesize sketchLayerEnabled;

-(IBAction)toggleSketchLayer:(id)sender 
{
    if (self.sketchLayerEnabled == YES)
    {
        self.sketchLyr.geometry = nil;
        self.sketchLayerEnabled = NO;
    }
    else
    {
        self.sketchLayerEnabled = YES;
        if ( self.sketchLyr == nil)
        {
            self.sketchLyr = [[AGSSketchGraphicsLayer alloc] initWithGeometry:nil];   
            [self.mapView addMapLayer:self.sketchLyr withName:@"Sketch Layer"];
        }
        
        AGSMutablePolygon *sketchPolygon = [[AGSMutablePolygon alloc] initWithSpatialReference:self.mapView.spatialReference];
        self.sketchLyr.geometry = sketchPolygon;
        self.mapView.touchDelegate = self.sketchLyr;   
    }
    
    
}

-(IBAction)changeLayer:(id)sender 
{
    //just do something
    NSString *theString = [[NSString alloc]initWithFormat:@"This will be implemented later."];
    UIAlertView *alertView = [[UIAlertView alloc]	initWithTitle:@"Important!" 
                                                        message:theString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

-(IBAction)toggleLocationService:(id)sender
{
    if (self.locationStatusEnabled == YES)
    {
        self.locationStatusEnabled = NO ;
        [self.mapView.gps stop]; 
    }
    else
    {
        self.locationStatusEnabled = YES;
        [self.mapView.gps start];
    }
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqual:@"currentPoint"]) {
        NSLog(@"Location updated to %@", self.mapView.gps.currentPoint);
        [self.mapView centerAtPoint:self.mapView.gps.currentPoint animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // to be able to toogle location status
    self.locationStatusEnabled = NO;
    self.sketchLayerEnabled = NO;
    self.tiledLayer = [[AGSTiledMapServiceLayer alloc] initWithURL:[NSURL URLWithString:@"http://server.arcgisonline.com/ArcGIS/rest/services/ESRI_StreetMap_World_2D/MapServer"]];
    [self.mapView addMapLayer:self.tiledLayer withName:@"Tiled Layer"];
    self.mapView.layerDelegate = self;
    [ self.mapView.gps addObserver:self
                        forKeyPath:@"currentPoint"
                           options:(NSKeyValueObservingOptionNew)
                           context:NULL];
}

// method that gets called when the map view has been loaded 
- (void)mapViewDidLoad:(AGSMapView *)mapView {
    //create extent to be used as default
    AGSEnvelope *envelope = [AGSEnvelope envelopeWithXmin:0.0 ymin:0.0 xmax:0.06 ymax:0.06  spatialReference:mapView.spatialReference];
    [self.mapView zoomToEnvelope:envelope animated:NO];
    //center map with linz as centerpoint
    AGSPoint *newPoint = [AGSPoint pointWithX:14.290123 y:48.284792 spatialReference:self.mapView.spatialReference];
    [self.mapView centerAtPoint:newPoint animated:NO];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.mapView = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
