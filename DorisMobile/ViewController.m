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
@synthesize changeLayerButton;
@synthesize tiledLayer = _tiledLayer;
@synthesize sketchLyr = _sketchLyr;
@synthesize locationStatusEnabled;
@synthesize sketchLayerEnabled;
@synthesize popoverController;
@synthesize layerOptionController;

- (IBAction)togglePopoverController:(id)sender {
    if ([popoverController isPopoverVisible]) {
        
        [popoverController dismissPopoverAnimated:YES];
        
    } else {
        
        [popoverController presentPopoverFromBarButtonItem:changeLayerButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
    }
}


- (IBAction)measureSketch:(id)sender {
    // map unit is in metres, see Rest-Resource -> 'esrimetres'
    if (self.sketchLyr.geometry) {
        AGSGeometry *sketch = self.sketchLyr.geometry;
        double result = 0;
        NSString *unit = @"";
        AGSGeometryEngine *calculationEngine = [AGSGeometryEngine alloc];
        if ([sketch isKindOfClass:[AGSMutablePolygon class]]) {
            unit = @"Quadratmeter";
            result = [calculationEngine areaOfGeometry:sketch];
            // area is negative when sketching counter clockwise
            if (result < 0) {
                result = result * (-1);
            
            }
        }
        else {
            unit = @"Meter";
            result = [calculationEngine  lengthOfGeometry:sketch];
        }
        toolbartip.text = [NSString stringWithFormat:@"%f %@", result, unit];
    }
        

}
- (IBAction)togglePolylineSketch:(id)sender {
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
        [self clearSketch];
        self.sketchLayerEnabled = NO;
        // go back to 'normal' touch behaviour on the map 
        self.mapView.touchDelegate = self;
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
        
        AGSMutablePolyline *sketchPolyline = [[AGSMutablePolyline alloc] initWithSpatialReference:self.mapView.spatialReference];
        self.sketchLyr.geometry = sketchPolyline;
        self.mapView.touchDelegate = self.sketchLyr;   
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
    [self clearSketch];
}
- (void)clearSketch {
    [self.sketchLyr clear];
    toolbartip.text = @"Bitte auf die Karte tippen, um einen Punkt hinzuzufügen";
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
        [self clearSketch];
        self.sketchLayerEnabled = NO;
        // go back to 'normal' touch behaviour on the map 
        self.mapView.touchDelegate = self;
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

-(void)changeLayer:(NSString *)mapName  
{   
    NSString *mapUrlString = [[NSString alloc] initWithFormat:@"http://agstest.doris.at/ArcGIS/rest/services/Rasterdaten/%@/MapServer", mapName];
    NSURL *mapUrl = [NSURL URLWithString:mapUrlString];
    AGSTiledMapServiceLayer *tiledLyr = [AGSTiledMapServiceLayer tiledMapServiceLayerWithURL:mapUrl];
    [self.mapView addMapLayer:tiledLyr withName:mapName];
}

// implemented for popover
-(void)didTap:(NSString *)string {
    [popoverController dismissPopoverAnimated:YES];
    [self changeLayer:string];
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
    // to be able to react to touch events on the map
    self.mapView.touchDelegate = self;
    
    // popover controller
    layerOptionController = [LayerOptionController alloc];
    layerOptionController.delegate = self;
    
    popoverController = [[UIPopoverController alloc] initWithContentViewController:layerOptionController];
    
    popoverController.popoverContentSize = CGSizeMake(250, 300);

}

- (void)mapView:(AGSMapView *)mapView didTapAndHoldAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint graphics:(NSDictionary *)graphics 
{   
    NSString *coordsString = [[NSString alloc] initWithFormat:@"X: %f Y: %f", mappoint.x, mappoint.y];
    mapView.callout.title = @"Koordinaten für diesen Punkt";
    mapView.callout.detail = coordsString; 
    mapView.callout.image = [UIImage imageNamed:@"icon_small.png"];
    mapView.callout.accessoryButtonHidden = YES;
    
    //Display the callout
    [mapView showCalloutAtPoint: mappoint];
}

// method that gets called when the map view has been loaded 
- (void)mapViewDidLoad:(AGSMapView *)mapView {
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
    [self setChangeLayerButton:nil];
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
