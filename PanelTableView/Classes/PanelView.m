/**
 * Copyright (c) 2009 Muh Hon Cheng
 * Created by honcheng on 11/27/10.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining 
 * a copy of this software and associated documentation files (the 
 * "Software"), to deal in the Software without restriction, including 
 * without limitation the rights to use, copy, modify, merge, publish, 
 * distribute, sublicense, and/or sell copies of the Software, and to 
 * permit persons to whom the Software is furnished to do so, subject 
 * to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be 
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT 
 * WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR 
 * PURPOSE AND NONINFRINGEMENT. IN NO EVENT 
 * SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE 
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR 
 * IN CONNECTION WITH THE SOFTWARE OR 
 * THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 * 
 * @author 		Muh Hon Cheng <honcheng@gmail.com>
 * @copyright	2010	Muh Hon Cheng
 * @version
 * 
 */

#import "PanelView.h"

@interface PanelView()
- (void)show:(BOOL)show;
@end

@implementation PanelView

- (id)initWithFrame:(CGRect)frame 
{
    if (self = [super initWithFrame:frame]) 
	{
		[self setBackgroundColor:[UIColor whiteColor]];
		
		self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
		[self addSubview:_tableView];
		[_tableView setDelegate:self];
		[_tableView setDataSource:self];
		[_tableView setScrollsToTop:NO];
    }
    return self;
}

- (id)initWithIdentifier:(NSString*)identifier
{
	if (self = [super init])
	{
		self.identifier = identifier;
	}
	return self;
}

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
	
	CGRect tableViewFrame = _tableView.frame;
	tableViewFrame.size.width = self.frame.size.width;
	tableViewFrame.size.height = self.frame.size.height;
	[_tableView setFrame:tableViewFrame];
}

- (void)reset
{

}

- (void)pageWillAppear
{
	[_tableView reloadData];
	[self restoreTableviewOffset];
}

- (void)pageDidAppear
{
	//NSLog(@"page did appear %i", pageNumber);
	//[self showPanel:YES animated:YES];
	[_tableView setScrollsToTop:YES];

}

- (void)pageWillDisappear
{
	[_tableView setScrollsToTop:NO];
	[self saveTableviewOffset];
}

#pragma mark offset save/restore

#define kTableOffset @"kTableOffset"

- (void)saveTableviewOffset
{
	CGPoint contentOffset = [_tableView contentOffset];
	float y = contentOffset.y;
	
	NSMutableArray *offsetArray = [[[NSUserDefaults standardUserDefaults] objectForKey:kTableOffset] mutableCopy];
	if (!offsetArray)
	{
		offsetArray = [NSMutableArray array];
	}
	
	if ([offsetArray count] < _pageNumber + 1)
	{
		[offsetArray addObject:@(y)];
	}
	else
	{
		[offsetArray replaceObjectAtIndex:_pageNumber withObject:[NSNumber numberWithInt:y]];
	}
	
	[[NSUserDefaults standardUserDefaults] setObject:offsetArray forKey:kTableOffset];
	//[offsetArray release];
	
}

- (void)restoreTableviewOffset
{
	NSMutableArray *offsetArray = [[NSUserDefaults standardUserDefaults] objectForKey:kTableOffset];
	if (offsetArray)
	{
		if ([offsetArray count] > _pageNumber)
		{
			float y = [[offsetArray objectAtIndex:_pageNumber] floatValue];
			CGPoint contentOffset = CGPointMake(0.0f, y);
			[_tableView setContentOffset:contentOffset animated:NO];
		}
	}
}

- (void)removeTableviewOffset
{
	NSMutableArray *offsetArray = [[[NSUserDefaults standardUserDefaults] objectForKey:kTableOffset] mutableCopy];
	if (offsetArray) {
		if ([offsetArray count] > _pageNumber) {
			[offsetArray removeObjectAtIndex:_pageNumber];
			[[NSUserDefaults standardUserDefaults] setObject:offsetArray forKey:kTableOffset];
		}
	}
}

#pragma mark add and remove panels

- (void)addPanelWithAnimation:(BOOL)animate
{
	if (animate) {
		[self showPanel:YES animated:YES];
	}
}

- (void)removePanelWithAnimation:(BOOL)animate
{
	if (animate) {
		[self showPanel:NO animated:YES];
		[self performSelector:@selector(showNextPanel) withObject:nil afterDelay:0.9f];
	}
}

#pragma mark animation

- (void)shouldWiggle:(BOOL)wiggle
{
	if (wiggle) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.1f];
		[UIView setAnimationRepeatAutoreverses:YES];
		[UIView setAnimationRepeatCount:10000];
		[self setTransform:CGAffineTransformMakeRotation(1.0f * M_PI / 180.0f)];
		[self setTransform:CGAffineTransformMakeRotation(-1.0f * M_PI / 180.0f)];
		[UIView commitAnimations];
	} else {
		[self setTransform:CGAffineTransformMakeRotation(0.0f)];
		[self.layer removeAllAnimations];
	}
}

#define kTransitionDuration	0.4

- (void)showNextPanel
{
	CGAffineTransform scaleTransform = CGAffineTransformScale([self transformForOrientation], 1.0f, 1.0f);
	[self setTransform:scaleTransform];
	CGAffineTransform translateTransform = CGAffineTransformTranslate([self transformForOrientation], self.frame.size.width, 0.0f);
	[self setTransform:translateTransform];
	//[self setTransform:CGAffineTransformConcat(translateTransform, scaleTransform)];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.2];
	
	//scaleTransform = CGAffineTransformScale([self transformForOrientation], 1, 1);
	translateTransform = CGAffineTransformMakeTranslation(0.0f, 0.0f);
	//[self setTransform:CGAffineTransformConcat(scaleTransform, translateTransform)];
	[self setTransform:translateTransform];
	
	[UIView commitAnimations];
	
}

- (void)showPreviousPanel
{
	CGAffineTransform scaleTransform = CGAffineTransformScale([self transformForOrientation], 1.0f, 1.0f);
	[self setTransform:scaleTransform];
	CGAffineTransform translateTransform = CGAffineTransformTranslate([self transformForOrientation], -1.0f * self.frame.size.width, 0.0f);
	[self setTransform:translateTransform];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.2];
	
	translateTransform = CGAffineTransformMakeTranslation(0.0f, 0.0f);
	[self setTransform:translateTransform];
	
	[UIView commitAnimations];
	
}

- (void)showPanel:(BOOL)show animated:(BOOL)animated
{
	if (animated) {
		[self show:show];
	} else {
		[self setHidden:!show];
		if (show) {
			self.transform = CGAffineTransformScale([self transformForOrientation], 1, 1);
		} else {
			//
		}
	}
}

- (void)show:(BOOL)show 
{
	if (show) {
		self.transform = CGAffineTransformScale([self transformForOrientation], 0.001, 0.001);
	} else {
		[self removeTableviewOffset];
		self.transform = CGAffineTransformScale([self transformForOrientation], 1, 1);
	}
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.2];
	[UIView setAnimationDelegate:self];
	if (show) {
		[UIView setAnimationDidStopSelector:@selector(bounce1AnimationStopped)];
		self.transform = CGAffineTransformScale([self transformForOrientation], 1.05, 1.05);
	} else {
		[UIView setAnimationDidStopSelector:@selector(bounce4AnimationStopped)];
		self.transform = CGAffineTransformScale([self transformForOrientation], 1.05, 1.05);
	}
	[UIView commitAnimations];
}

- (void)bounce1AnimationStopped
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:kTransitionDuration/3];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(bounce2AnimationStopped)];
	self.transform = CGAffineTransformScale([self transformForOrientation], 0.9, 0.9);
	[UIView commitAnimations];
}

- (void)bounce2AnimationStopped
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:kTransitionDuration/4];
	self.transform = [self transformForOrientation];
	[UIView commitAnimations];
}

- (void)bounce3AnimationStopped
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:kTransitionDuration/4];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(bounce4AnimationStopped)];
	self.transform = CGAffineTransformScale([self transformForOrientation], 1.1, 1.1);
	[UIView commitAnimations];
}

- (void)bounce4AnimationStopped
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:kTransitionDuration/1.5];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(completedHidingAnimation)];
	self.transform = CGAffineTransformScale([self transformForOrientation], 0.001, 0.001);
	[UIView commitAnimations];
}

- (void)completedHidingAnimation
{
}

- (CGAffineTransform)transformForOrientation 
{
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	if (orientation == UIInterfaceOrientationLandscapeLeft) {
		return CGAffineTransformMakeRotation(M_PI * 1.5f);
	} else if (orientation == UIInterfaceOrientationLandscapeRight) {
		return CGAffineTransformMakeRotation(M_PI / 2.0f);
	} else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
		return CGAffineTransformMakeRotation(-M_PI);
	} else {
		return CGAffineTransformIdentity;
	}
}

#pragma mark table

- (CGFloat)tableView:(UITableView *)tableView_ heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([self.delegate respondsToSelector:@selector(panelView:heightForRowAtIndexPath:)]) {
		return [self.delegate panelView:self heightForRowAtIndexPath:[PanelIndexPath panelIndexPathForPage:self.pageNumber indexPath:indexPath]];
	} else return 0;
}

- (void)tableView:(UITableView *)tableView_ didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([self.delegate respondsToSelector:@selector(panelView:didSelectRowAtIndexPath:)]) {
		return [self.delegate panelView:self didSelectRowAtIndexPath:[PanelIndexPath panelIndexPathForPage:self.pageNumber indexPath:indexPath]];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([self.delegate respondsToSelector:@selector(panelView:cellForRowAtIndexPath:)]) {
		return [self.delegate panelView:self cellForRowAtIndexPath:[PanelIndexPath panelIndexPathForPage:self.pageNumber indexPath:indexPath]];
	}
	return nil;
}

- (NSInteger)tableView:(UITableView *)tableView_ numberOfRowsInSection:(NSInteger)section
{
	if ([self.delegate respondsToSelector:@selector(panelView:numberOfRowsInPage:section:)]) {
		return [self.delegate panelView:self numberOfRowsInPage:self.pageNumber section:section];
	}
	return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if ([self.delegate respondsToSelector:@selector(panelView:numberOfSectionsInPage:)]) {
		return [self.delegate panelView:self numberOfSectionsInPage:self.pageNumber];
	}
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if ([self.delegate respondsToSelector:@selector(panelView:titleForHeaderInPage:section:)]) {
		return [self.delegate panelView:self titleForHeaderInPage:self.pageNumber section:section];
	}
	return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([self.delegate respondsToSelector:@selector(panelView:viewForHeaderInPage:section:)]) {
        return [self.delegate panelView:self viewForHeaderInPage:self.pageNumber section:section];
    }
    return nil;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(panelView:didScroll:)]) {
        return [self.delegate panelView:self didScroll:scrollView];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([self.delegate respondsToSelector:@selector(panelView:heightForHeaderInSection:)]) {
        return [self.delegate panelView:self heightForHeaderInSection:section];
    } else {
        return 0;
    }
}

@end
