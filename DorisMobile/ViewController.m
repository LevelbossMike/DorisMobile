//
//  ViewController.m
//  DorisMobile
//
//  Created by Michael Klein on 14.09.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController
//The geocode service
static NSString *kGeoLocatorURL = @"http://agstest.doris.at/ArcGIS/rest/services/Basisdaten/GeoSuche/MapServer";

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
@synthesize searchBar = _searchBar;
@synthesize popoverController;
@synthesize layerOptionController;

@synthesize graphicsLayer = _graphicsLayer;
@synthesize locator = _locator;
@synthesize calloutTemplate = _calloutTemplate;

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
    //create the graphics layer that the geocoding result
    //will be stored in and add it to the map
    self.graphicsLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:self.graphicsLayer withName:@"Graphics Layer"];

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
    [self setSearchBar:nil];
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

- (void)startGeocoding {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tut mir leid!"
                                                    message:@"Das funktioniert leider noch nicht."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    
    [alert show];
    /*
    //clear out previous results
    [self.graphicsLayer removeAllGraphics];
    
    //create the AGSLocator with the geo locator URL
    //and set the delegate to self, so we get AGSLocatorDelegate notifications
    self.locator = [AGSLocator locatorWithURL:[NSURL URLWithString:kGeoLocatorURL]];
    self.locator.delegate = self;
    
    //we want all out fields
    //Note that the "*" for out fields is supported for geocode services of
    //ArcGIS Server 10 and above
    //NSArray *outFields = [NSArray arrayWithObject:@"*"];
    
    //for pre-10 ArcGIS Servers, you need to specify all the out fields:
    NSArray *outFields = [NSArray arrayWithObjects:@"Loc_name",
                          @"Shape",
                          @"Score",
                          @"Name",
                          @"Rank",
                          @"Match_addr",
                          @"Descr",
                          @"Latitude",
                          @"Longitude",
                          @"City",
                          @"County",
                          @"State",
                          @"State_Abbr",
                          @"Country",
                          @"Cntry_Abbr",
                          @"Type",
                          @"North_Lat",
                          @"South_Lat",
                          @"West_Lon",
                          @"East_Lon",
                          nil];
    
    //Create the address dictionary with the contents of the search bar
    NSDictionary *addresses = [NSDictionary dictionaryWithObjectsAndKeys:self.searchBar.text, @"PlaceName", nil];
    
    //now request the location from the locator for our address
    [self.locator locationsForAddress:addresses returnFields:outFields];*/
}
#pragma mark _
#pragma mark UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	
	//hide the callout
	self.mapView.callout.hidden = YES;
	
    //First, hide the keyboard, then starGeocoding
    [searchBar resignFirstResponder];
    [self startGeocoding];
}


- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    //hide the keyboard
    [searchBar resignFirstResponder];
}

//geocoding
- (void)locator:(AGSLocator *)locator operation:(NSOperation *)op didFindLocationsForAddress:(NSArray *)candidates
{
    //check and see if we didn't get any results
	if (candidates == nil || [candidates count] == 0)
	{
        //show alert if we didn't get results
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Results"
                                                        message:@"No Results Found By Locator"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        
        [alert show];
	}
	else
	{
        //use these to calculate extent of results
        double xmin = DBL_MAX;
        double ymin = DBL_MAX;
        double xmax = -DBL_MAX;
        double ymax = -DBL_MAX;
		
		//create the callout template, used when the user displays the callout
		//self.calloutTemplate = [[[AGSCalloutTemplate alloc]init] autorelease];
        
        //loop through all candidates/results and add to graphics layer
		for (int i=0; i<[candidates count]; i++)
		{            
			AGSAddressCandidate *addressCandidate = (AGSAddressCandidate *)[candidates objectAtIndex:i];
            
            //get the location from the candidate
            AGSPoint *pt = addressCandidate.location;
            
            //accumulate the min/max
            if (pt.x  < xmin)
                xmin = pt.x;
            
            if (pt.x > xmax)
                xmax = pt.x;
            
            if (pt.y < ymin)
                ymin = pt.y;
            
            if (pt.y > ymax)
                ymax = pt.y;
            
			//create a marker symbol to use in our graphic
            AGSPictureMarkerSymbol *marker = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"BluePushpin.png"];
            marker.xoffset = 9;
            marker.yoffset = -16;
            marker.hotspot = CGPointMake(-9, -11);
            
            //set the text and detail text based on 'Name' and 'Descr' fields in the attributes
            self.calloutTemplate.titleTemplate = @"${Name}";
            self.calloutTemplate.detailTemplate = @"${Descr}";
			
            //create the graphic
			AGSGraphic *graphic = [[AGSGraphic alloc] initWithGeometry: pt
																symbol:marker 
															attributes:[addressCandidate.attributes mutableCopy]
                                                  infoTemplateDelegate:self.calloutTemplate];
            
            
            //add the graphic to the graphics layer
			[self.graphicsLayer addGraphic:graphic];
            
            if ([candidates count] == 1)
            {
                //we have one result, center at that point
                [self.mapView centerAtPoint:pt animated:NO];
                
				// set the width of the callout
				self.mapView.callout.width = 250;
                
                //show the callout
                [self.mapView showCalloutAtPoint:(AGSPoint *)graphic.geometry forGraphic:graphic animated:YES];
            }
			      
		}
        
        //if we have more than one result, zoom to the extent of all results
        int nCount = [candidates count];
        if (nCount > 1)
        {            
            AGSMutableEnvelope *extent = [AGSMutableEnvelope envelopeWithXmin:xmin ymin:ymin xmax:xmax ymax:ymax spatialReference:self.mapView.spatialReference];
            [extent expandByFactor:1.5];
			[self.mapView zoomToEnvelope:extent animated:YES];
        }
	}
    
    //since we've added graphics, make sure to redraw
    [self.graphicsLayer dataChanged];
    
}

- (void)locator:(AGSLocator *)locator operation:(NSOperation *)op didFailLocationsForAddress:(NSError *)error
{
    //The location operation failed, display the error
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Locator Failed"
                                                    message:[NSString stringWithFormat:@"Error: %@", error.description]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"                                          
                                          otherButtonTitles:nil];
    
    [alert show];
}

@end
