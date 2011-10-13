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
@synthesize sketchToolbar;
@synthesize tiptoolbar;
@synthesize toolbartip;
@synthesize undoButton;
@synthesize redoButton;
@synthesize clearButton;
@synthesize tiledLayer = _tiledLayer;
@synthesize sketchLyr = _sketchLyr;
@synthesize locationStatusEnabled;
@synthesize sketchLayerEnabled;

- (IBAction)measureArea:(id)sender {
    if (self.sketchLyr.geometry) {
        AGSGeometry *sketch = self.sketchLyr.geometry;
        AGSGeometryEngine *calculationEngine = [AGSGeometryEngine alloc];
        double area = [calculationEngine areaOfGeometry:sketch];
        // area is negative when sketching counter clockwise
        if (area < 0) {
            area = area * (-1);
        }
        // map unit is in metres, see Rest-Resource -> 'esrimetres'
        toolbartip.text = [NSString stringWithFormat:@"%f Quadratmeter", area];
    }
        

}

- (IBAction)undo:(id)sender {
    if([_sketchLyr.undoManager canUndo]) //extra check, just to be sure
		[_sketchLyr.undoManager undo];
}
- (IBAction)redo:(id)sender {
    if([_sketchLyr.undoManager canRedo]) //extra check, just to be sure
		[_sketchLyr.undoManager redo];
    
}
- (IBAction)clear:(id)sender {
    [_sketchLyr clear];
    
}

-(IBAction)toggleSketchLayer:(id)sender 
{

    if (self.sketchLayerEnabled == YES)
    {   
        // hide toolbar with a fade effect
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut ];
        [sketchToolbar setAlpha:0.0];
        [tiptoolbar setAlpha:0.0];
        [toolbartip setAlpha:0.0];
        [UIView commitAnimations];
        self.sketchLyr.geometry = nil;
        self.sketchLayerEnabled = NO;
        // go back to 'normal' touch behaviour on the map 
        self.mapView.touchDelegate = nil;
    }
    else
    {
        self.sketchLayerEnabled = YES;
        if ( self.sketchLyr == nil)
        {
            self.sketchLyr = [[AGSSketchGraphicsLayer alloc] initWithGeometry:nil]; 
            [self.mapView addMapLayer:self.sketchLyr withName:@"Sketch Layer"];
        }
        // show toolbar with a fade effect
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut ];
        [sketchToolbar setAlpha:1.0];
        [tiptoolbar setAlpha:1.0];
        [toolbartip setAlpha:1.0];
        
        [UIView commitAnimations];
        
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
        self.mapView.gps.autoPan = true;
        [self.mapView.gps start];
    }
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqual:@"currentPoint"]) {
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
    // turn of sketch layer on start
    self.sketchLayerEnabled = NO;
    NSURL *mapUrl = [NSURL URLWithString:@"http://agstest.doris.at/ArcGIS/rest/services/Rasterdaten/Oek/MapServer"];
    AGSTiledMapServiceLayer *tiledLyr = [AGSTiledMapServiceLayer tiledMapServiceLayerWithURL:mapUrl];
    [self.mapView addMapLayer:tiledLyr withName:@"Tiled Layer"];
    // you can get the wkid of a map when looking at the REST-Resource of a map
    AGSSpatialReference *sr = [AGSSpatialReference spatialReferenceWithWKID:31255];
    // you can get xmin to ymax for envelope when looking at REST-Resource of a map
    AGSEnvelope *env = [AGSEnvelope envelopeWithXmin:-66388.1974430619 ymin:270562.472437908 xmax:142103.886207772 ymax:408531.059337051 spatialReference:sr];
    NSLog(@"mapView units: %@", AGSUnitsDisplayString(self.mapView.units));
    [self.mapView zoomToEnvelope:env animated:YES];
    /*
    // add the default map
    NSURL *url = [NSURL URLWithString: @"http://server.arcgisonline.com/ArcGIS/rest/services/ESRI_StreetMap_World_2D/MapServer"]; 
    AGSTiledMapServiceLayer *layer = [AGSTiledMapServiceLayer tiledMapServiceLayerWithURL: url];
    self.tiledLayer = layer;
    
    [self.mapView addMapLayer:self.tiledLayer withName:@"Tiled Layer"];
    self.mapView.layerDelegate = self;
    [ self.mapView.gps addObserver:self
                        forKeyPath:@"currentPoint"
                           options:(NSKeyValueObservingOptionNew)
                           context:NULL];*/
}

// method that gets called when the map view has been loaded 
- (void)mapViewDidLoad:(AGSMapView *)mapView {
    //create extent to be used as default
    /*AGSEnvelope *envelope = [AGSEnvelope envelopeWithXmin:0.0 ymin:0.0 xmax:0.06 ymax:0.06  spatialReference:mapView.spatialReference];
    [self.mapView zoomToEnvelope:envelope animated:NO];*/
    /*//center map with linz as centerpoint
    AGSPoint *newPoint = [AGSPoint pointWithX:14.290123 y:48.284792 spatialReference:self.mapView.spatialReference];
    [self.mapView centerAtPoint:newPoint animated:NO];*/
}

- (void)viewDidUnload
{
    [self setSketchToolbar:nil];
    [self setToolbartip:nil];
    [self setToolbartip:nil];
    [self setTiptoolbar:nil];
    [self setUndoButton:nil];
    [self setUndoButton:nil];
    [self setRedoButton:nil];
    [self setClearButton:nil];
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
