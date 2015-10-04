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

#import "PanelsViewController.h"

@implementation UIScrollViewExt

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	if (_isEditing) return self;
	else return [super hitTest:point withEvent:event];
}
@end


@interface PanelsViewController()
- (void)tilePages;
- (void)configurePage:(PanelView*)page forIndex:(int)index;
- (BOOL)isDisplayingPageForIndex:(int)index;
- (PanelView *)panelForPage:(NSInteger)page;
@end

@implementation PanelsViewController

- (void)loadView
{
	[super loadView];
	[self.view setBackgroundColor:[UIColor blackColor]];
	
	CGRect frame = [self scrollViewFrame];
	self.scrollViewExt = [[UIScrollViewExt alloc] initWithFrame:CGRectMake(-1.0f * GAP, 0.0f, frame.size.width + 2.0f * GAP, frame.size.height)];
	[_scrollViewExt setScrollsToTop:NO];
	[_scrollViewExt setDelegate:self];
	[_scrollViewExt setShowsHorizontalScrollIndicator:NO];
	[_scrollViewExt setPagingEnabled:YES];
	[_scrollViewExt setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
	[self.view addSubview:_scrollViewExt];
	[_scrollViewExt setContentSize:CGSizeMake(([self panelViewSize].width + 2.0f * GAP) * [self numberOfPanels], frame.size.height - self.navigationController.navigationBar.frame.size.height - [UIApplication sharedApplication].statusBarFrame.size.height)];
	self.recycledPages = [NSMutableSet set];
	self.visiblePages = [NSMutableSet set];
	
	[self tilePages];
}

-(void)viewDidLayoutSubviews
{
  [super viewDidLayoutSubviews];

  if(!isViewDidLayoutSubviews)
  {
    [self addPage];
    isViewDidLayoutSubviews = YES;
  }
}

//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//}

//- (void)viewDidUnload
//{
//    [super viewDidUnload];
//}

-(void)viewDidLoad
{
  [super viewDidLoad];
  isViewDidLayoutSubviews = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
	PanelView *panelView = [self panelViewAtPage:_currentPage];
	[panelView pageDidAppear];
}

- (void)viewWillAppear:(BOOL)animated
{
	PanelView *panelView = [self panelViewAtPage:_currentPage];
	[panelView pageWillAppear];
}

- (void)viewWillDisappear:(BOOL)animated
{
	PanelView *panelView = [self panelViewAtPage:_currentPage];
	[panelView pageWillDisappear];
}

#pragma mark editing

- (void)shouldWiggle:(BOOL)wiggle
{
	for (int i=0; i<[self numberOfPanels]; i++) {
		PanelView *panelView = (PanelView *)[_scrollViewExt viewWithTag:TAG_PAGE+i];
		[panelView shouldWiggle:wiggle];
		
	}
}

- (void)setEditing:(BOOL)isEditing
{
	self.isEditing = isEditing;
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.2];
	[_scrollViewExt setIsEditing:isEditing];
	[self shouldWiggle:isEditing];
	if (isEditing) {
		[_scrollViewExt setTransform:CGAffineTransformMakeScale(0.5, 0.5)];
		[_scrollViewExt setClipsToBounds:NO];
	} else {
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(onEditingAnimationStopped)];
		[_scrollViewExt setTransform:CGAffineTransformMakeScale(1, 1)];
		
	}

	[UIView commitAnimations];
}

- (void)onEditingAnimationStopped
{
	[_scrollViewExt setClipsToBounds:YES];
}

#pragma mark frame and sizes

/*
 Overwrite this to change size of scroll view.
 Default implementation fills the screen
 */
- (CGRect)scrollViewFrame
{
	return CGRectMake(0.0f, 0.0f, [self.view bounds].size.width, [self.view bounds].size.height);
}

- (CGSize)panelViewSize
{
	float width = [self scrollViewFrame].size.width;
	if ([self numberOfVisiblePanels] > 1) {
		width = ([self scrollViewFrame].size.width - 2.0f * GAP * ([self numberOfVisiblePanels] - 1)) / [self numberOfVisiblePanels];
	}
	
	return CGSizeMake(width, [self scrollViewFrame].size.height);
}

/*
 Overwrite this to change number of visible panel views
 */
- (int)numberOfVisiblePanels
{
	return 1;
}

#pragma mark adding and removing panels

- (void)addPage
{
	//numberOfPages += 1;
	[_scrollViewExt setContentSize:CGSizeMake(([self panelViewSize].width + 2.0f * GAP) * [self numberOfPanels], _scrollViewExt.frame.size.width)];
}

- (void)removeCurrentPage
{	
	if (_currentPage == [self numberOfPanels] && _currentPage != 0) {
		// this is the last page
		//numberOfPages -= 1;
		
		PanelView *panelView = (PanelView*)[_scrollViewExt viewWithTag:TAG_PAGE + _currentPage];
		[panelView showPanel:NO animated:YES];
		[self removeContentOfPage:_currentPage];
		
		[panelView performSelector:@selector(showPreviousPanel) withObject:nil afterDelay:0.4];
		[self performSelector:@selector(jumpToPreviousPage) withObject:nil afterDelay:0.6];
	} else if ([self numberOfPanels] == 0) {
		PanelView *panelView = (PanelView *)[_scrollViewExt viewWithTag:TAG_PAGE + _currentPage];
		[panelView showPanel:NO animated:YES];
		[self removeContentOfPage:_currentPage];
	} else {
		PanelView *panelView = (PanelView *)[_scrollViewExt viewWithTag:TAG_PAGE + _currentPage];
		[panelView showPanel:NO animated:YES];
		[self removeContentOfPage:_currentPage];
		[self performSelector:@selector(pushNextPage) withObject:nil afterDelay:0.4];
	}
}

- (void)jumpToPreviousPage
{
	[_scrollViewExt setContentSize:CGSizeMake(([self panelViewSize].width + 2.0f * GAP) * [self numberOfPanels], _scrollViewExt.frame.size.width)];
}

- (void)pushNextPage
{
	[_scrollViewExt setContentSize:CGSizeMake(([self panelViewSize].width + 2.0f * GAP) * [self numberOfPanels], _scrollViewExt.frame.size.width)];
	
	for (int i = _currentPage; i < [self numberOfVisiblePanels]; i++) {
		if (_currentPage < [self numberOfPanels]) {
			PanelView *panelView = (PanelView *)[_scrollViewExt viewWithTag:TAG_PAGE + i];
			[panelView showNextPanel];
			[panelView pageWillAppear];
		}
	}
}

- (void)removeContentOfPage:(int)page
{
	
}

#pragma mark scroll view delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	PanelView *panelView = (PanelView*)[_scrollViewExt viewWithTag:TAG_PAGE + _currentPage];
	[panelView pageWillDisappear];
}

- (void)scrollViewDidScroll:(UIScrollView*)scrollView
{
	//NSLog(@"%@", scrollView_);
	[self tilePages];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	
	if (_currentPage != _lastDisplayedPage)
	{
		PanelView *panelView = (PanelView*)[_scrollViewExt viewWithTag:TAG_PAGE + _currentPage];
		[panelView pageDidAppear];
	}
	
	self.lastDisplayedPage = _currentPage;
}

#pragma mark reuse table views

- (void)tilePages
{
	CGRect visibleBounds = [_scrollViewExt bounds];
	int firstNeededPageIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds)) * [self numberOfVisiblePanels];
	int lastNeededPageIndex = floorf((CGRectGetMaxX(visibleBounds) - 1) / CGRectGetWidth(visibleBounds)) * [self numberOfVisiblePanels];

	firstNeededPageIndex = MAX(firstNeededPageIndex,0);
	lastNeededPageIndex = MIN(lastNeededPageIndex, [self numberOfPanels] - 1) + [self numberOfVisiblePanels];
	
	if (_isEditing) firstNeededPageIndex -= 1;
	
	if (firstNeededPageIndex < 0) firstNeededPageIndex = 0;
	if (lastNeededPageIndex >= [self numberOfPanels]) lastNeededPageIndex = [self numberOfPanels] - 1;
	
	self.currentPage = firstNeededPageIndex;
	
	for (PanelView *panel in _visiblePages)
	{
		if (panel.pageNumber < firstNeededPageIndex || panel.pageNumber > lastNeededPageIndex)
		{
			[_recycledPages addObject:panel];
			[panel removeFromSuperview];
			[panel shouldWiggle:NO];
		}
	}
	[_visiblePages minusSet:_recycledPages];
	
	for (int index=firstNeededPageIndex; index<=lastNeededPageIndex; index++)
	{
		if (![self isDisplayingPageForIndex:index])
		{
			PanelView *panel = [self panelForPage:index];
			int x = ([self panelViewSize].width + 2.0f * GAP) * index + GAP;
			CGRect panelFrame = CGRectMake(x, 0.0f, [self panelViewSize].width, [self scrollViewFrame].size.height);
			
			[panel setFrame:panelFrame];
			[panel setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
			[panel setDelegate:self];
			[panel setTag:TAG_PAGE + index];
			[panel setPageNumber:index];
			[panel pageWillAppear];

			[_scrollViewExt addSubview:panel];
			[_visiblePages addObject:panel];
			[panel shouldWiggle:_isEditing];
		}
	}
}

- (BOOL)isDisplayingPageForIndex:(int)index
{
	for (PanelView *page in _visiblePages)
	{
		if (page.pageNumber==index) return YES;
	}
	return NO;
}

- (void)configurePage:(PanelView*)page forIndex:(int)index
{
	int x = ([self.view bounds].size.width + 2.0f * GAP) * index + GAP;
	CGRect pageFrame = CGRectMake(x, 0.0f, [self.view bounds].size.width, [self.view bounds].size.height);
	[page setFrame:pageFrame];
	[page setPageNumber:index];
	[page pageWillAppear];
}

- (PanelView*)dequeueReusablePageWithIdentifier:(NSString*)identifier
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.identifier == %@", identifier];
	NSSet *filteredSet =[_recycledPages filteredSetUsingPredicate:predicate];
	PanelView *page = [filteredSet anyObject];
	if (page) {
		[_recycledPages removeObject:page];
	}
	return page;
}

#pragma mark panel views

- (PanelView *)panelViewAtPage:(NSInteger)page
{
	PanelView *panelView = (PanelView*)[_scrollViewExt viewWithTag:TAG_PAGE + page];
	return panelView;
}

- (PanelView *)panelForPage:(NSInteger)page
{
	static NSString *identifier = @"PanelTableView";
	PanelView *panelView = (PanelView *)[self dequeueReusablePageWithIdentifier:identifier];
	if (panelView == nil) {
		panelView = [[PanelView alloc] initWithIdentifier:identifier];
	}
	return panelView;
}

- (NSInteger)numberOfPanels
{
	return 0;
}

- (CGFloat)panelView:(PanelView *)panelView heightForRowAtIndexPath:(PanelIndexPath *)indexPath
{
	return 50;
}

- (UITableViewCell *)panelView:(PanelView *)panelView cellForRowAtIndexPath:(PanelIndexPath *)indexPath
{
	static NSString *identity = @"UITableViewCell";
	UITableViewCell *cell = (UITableViewCell*)[panelView.tableView dequeueReusableCellWithIdentifier:identity];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identity];
	}
	return cell;
}

- (NSInteger)panelView:(PanelView *)panelView numberOfRowsInPage:(NSInteger)page section:(NSInteger)section
{
	return 0;
}

- (void)panelView:(PanelView *)panelView didSelectRowAtIndexPath:(PanelIndexPath *)indexPath
{
	
}

- (NSInteger)panelView:(id)panelView numberOfSectionsInPage:(NSInteger)pageNumber
{
	return 2;
}

- (NSString*)panelView:(id)panelView titleForHeaderInPage:(NSInteger)pageNumber section:(NSInteger)section
{
	return [NSString stringWithFormat:@"Page %i Section %i", pageNumber, section];
}

- (void)goToPanel:(NSInteger)index
{
    _scrollViewExt.bounds = CGRectMake(index * _scrollViewExt.bounds.size.width, _scrollViewExt.bounds.origin.y, _scrollViewExt.bounds.size.width, _scrollViewExt.bounds.size.height);
    
    [self tilePages];
}

@end
