//
//  Demo1ViewController.m
//  CMPopTipView
//
//  Created by Chris Miles on 13/11/10.
//  Copyright (c) Chris Miles 2010.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "Demo1ViewController.h"

#define foo4random() (1.0 * (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX)

#pragma mark -
#pragma mark Private interface

@interface Demo1ViewController ()
@property (nonatomic, strong)	NSArray			*colorSchemes;
@property (nonatomic, strong)	NSDictionary	*contents;
@property (nonatomic, strong)	id				currentPopTipViewTarget;
@property (nonatomic, strong)	NSMutableArray	*visiblePopTipViews;
@end


#pragma mark -
#pragma mark Implementation

@implementation Demo1ViewController

@synthesize colorSchemes;
@synthesize contents=_contents;
@synthesize currentPopTipViewTarget;
@synthesize visiblePopTipViews;

- (void)dismissAllPopTipViews {
	while ([visiblePopTipViews count] > 0) {
		CMPopTipView *popTipView = visiblePopTipViews[0];
		[popTipView dismissAnimated:YES];
		[visiblePopTipViews removeObjectAtIndex:0];
	}
}

- (IBAction)buttonAction:(id)sender {
	[self dismissAllPopTipViews];
	
	if (sender == currentPopTipViewTarget) {
		// Dismiss the popTipView and that is all
		self.currentPopTipViewTarget = nil;
	}
	else {
		NSString *contentMessage = nil;
		UIView *contentView = nil;
		id content = (self.contents)[@([(UIView *)sender tag])];
		if ([content isKindOfClass:[UIView class]]) {
			contentView = content;
		}
		else if ([content isKindOfClass:[NSString class]]) {
			contentMessage = content;
		}
		else {
			contentMessage = @"A CMPopTipView can automatically point to any view or bar button item.";
		}
		NSArray *colorScheme = colorSchemes[(NSInteger)(foo4random()*[colorSchemes count])];
		UIColor *backgroundColor = colorScheme[0];
		UIColor *textColor = colorScheme[1];
		
		CMPopTipView *popTipView;
		if (contentView) {
			popTipView = [[CMPopTipView alloc] initWithCustomView:contentView];
		}
		else {
			popTipView = [[CMPopTipView alloc] initWithMessage:contentMessage];
		}
		popTipView.delegate = self;
		//popTipView.disableTapToDismiss = YES;
		if (backgroundColor && ![backgroundColor isEqual:[NSNull null]]) {
			popTipView.backgroundColor = backgroundColor;
		}
		if (textColor && ![textColor isEqual:[NSNull null]]) {
			popTipView.textColor = textColor;
		}
        
        popTipView.animation = arc4random() % 2;
		
		popTipView.dismissTapAnywhere = YES;
        [popTipView autoDismissAnimated:YES atTimeInterval:3.0];

		if ([sender isKindOfClass:[UIButton class]]) {
			UIButton *button = (UIButton *)sender;
			[popTipView presentPointingAtView:button inView:self.view animated:YES];
		}
		else {
			UIBarButtonItem *barButtonItem = (UIBarButtonItem *)sender;
			[popTipView presentPointingAtBarButtonItem:barButtonItem animated:YES];
		}
		
		[visiblePopTipViews addObject:popTipView];
		self.currentPopTipViewTarget = sender;
	}
}


#pragma mark -
#pragma mark CMPopTipViewDelegate methods

- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView {
	[visiblePopTipViews removeObject:popTipView];
	self.currentPopTipViewTarget = nil;
}


#pragma mark -
#pragma mark UIViewController methods

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	for (CMPopTipView *popTipView in visiblePopTipViews) {
		id targetObject = popTipView.targetObject;
		[popTipView dismissAnimated:NO];
		
		if ([targetObject isKindOfClass:[UIButton class]]) {
			UIButton *button = (UIButton *)targetObject;
			[popTipView presentPointingAtView:button inView:self.view animated:NO];
		}
		else {
			UIBarButtonItem *barButtonItem = (UIBarButtonItem *)targetObject;
			[popTipView presentPointingAtBarButtonItem:barButtonItem animated:NO];
		}
	}
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.visiblePopTipViews = [NSMutableArray array];
	
	self.contents = @{@11: @"A CMPopTipView will automatically position itself within the container view.",
					 @12: @"A CMPopTipView will automatically orient itself above or below the target view based on the available space.",
					 @13: @"A CMPopTipView always tries to point at the center of the target view.",
					 @14: @"A CMPopTipView can point to any UIView subclass.",
					 @15: @"A CMPopTipView will automatically size itself to fit the text message.",
					 @16: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"appicon57.png"]],	// content can be a UIView
					 // Nav bar buttons
					 @21: @"This CMPopTipView is pointing at a leftBarButtonItem of a navigationItem.",
					 @22: @"Two popup animations are provided: slide and pop. Tap other buttons to see them both.",
					 // Toolbar buttons
					 @31: @"CMPopTipView will automatically point at buttons either above or below the containing view.",
					 @32: @"The arrow is automatically positioned to point to the center of the target button.",
					 @33: @"CMPopTipView knows how to point automatically to UIBarButtonItems in both nav bars and tool bars."};
	
	// Array of (backgroundColor, textColor) pairs.
	// NSNull for either means leave as default.
	// A color scheme will be picked randomly per CMPopTipView.
	self.colorSchemes = @[@[[NSNull null], [NSNull null]],
						 @[[UIColor colorWithRed:134.0/255.0 green:74.0/255.0 blue:110.0/255.0 alpha:1.0], [NSNull null]],
						 @[[UIColor darkGrayColor], [NSNull null]],
						 @[[UIColor lightGrayColor], [UIColor darkTextColor]],
						 @[[UIColor orangeColor], [UIColor blueColor]],
						 @[[UIColor colorWithRed:220.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0], [NSNull null]]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
	return YES;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
	
	self.contents = nil;
	self.visiblePopTipViews = nil;
}



@end
