//
//  ViewController.m
//  EpubWithPagination
//
//  Created by ganesh kulpe on 28/04/14.
//  Copyright (c) 2014 xyz. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    NSUInteger textFontSize;
    BOOL isFromFontChange;

}
@property (assign, nonatomic) CGPoint touchBeginPoint;

@property (nonatomic, readonly) int pageCount;

@property (nonatomic) NSUInteger spineIndex;


@end

@implementation ViewController
@synthesize _ePubContent;
@synthesize _rootPath;
@synthesize _strFileName;
- (void)viewDidLoad
{
    [super viewDidLoad];
    textFontSize=100;
	// Do any additional setup after loading the view, typically from a nib.
    _strFileName=@"tolstoy-war-and-peace";
    webView.paginationMode = UIWebPaginationModeLeftToRight;
    webView.paginationBreakingMode = UIWebPaginationBreakingModePage;
    webView.scrollView.pagingEnabled = YES;
    webView.scrollView.delegate = self;
    webView.scrollView.pagingEnabled = YES;
    webView.scrollView.alwaysBounceHorizontal = YES;
    webView.scrollView.alwaysBounceVertical = NO;
    webView.scrollView.bounces = YES;
    webView.scrollView.showsVerticalScrollIndicator = NO;
    webView.scrollView.showsHorizontalScrollIndicator = NO;
    
    //First unzip the epub file to documents directory
	[self unzipAndSaveFile];
	_xmlHandler=[[XMLHandler alloc] init];
	_xmlHandler.delegate=self;
	[_xmlHandler parseXMLFileAt:[self getRootFilePath]];
    


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark Font Change Action
-(IBAction)fontchangeBtnClicked:(id)sender;
{
    switch ([sender tag]) {
        case 1: // A-
            textFontSize = (textFontSize > 100) ? textFontSize -5 : textFontSize;
            break;
        case 2: // A+
            textFontSize = (textFontSize < 250) ? textFontSize +5 : textFontSize;
            break;
    }
    isFromFontChange=YES;
    int    page = webView.scrollView.contentOffset.x / webView.scrollView.frame.size.width;
    
    NSString *jsString = [[NSString alloc] initWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%d%%'",
                          textFontSize];
    [webView stringByEvaluatingJavaScriptFromString:jsString];
    [webView reload];
    float pageOffset = page * webView.bounds.size.width;
    [webView.scrollView setContentOffset:CGPointMake(pageOffset, 0) animated:NO];;
    pageCountlbl.text=[NSString stringWithFormat:@"Page %d/%d",page+1,_pageCount];
    [pageSlider setValue:page+1];
}

#pragma mark Page Slider Value Changed
-(IBAction)pageNoChange:(id)sender
{
    int page=pageSlider.value;
    pageCountlbl.text=[NSString stringWithFormat:@"Page %d/%d",page,_pageCount];

}
-(IBAction)pageSliderValueChanged:(id)sender
{
    int page=pageSlider.value;
    pageCountlbl.text=[NSString stringWithFormat:@"Page %d/%d",page,_pageCount];

    page=page-1;

    [webView.scrollView setContentOffset:CGPointMake(page*webView.bounds.size.width, 0) animated:NO];;

}

#pragma mark UIWebview Delgate
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"%@",error.localizedDescription);
}
- (void)webViewDidFinishLoad:(UIWebView *)theWebView{
    NSString *jsString = [[NSString alloc] initWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%d%%'",
                          textFontSize];
    [webView stringByEvaluatingJavaScriptFromString:jsString];
    _pageCount =  webView.pageCount;
  
    _currentPageIndex=0;
    if (!isFromFontChange) {
        if (_pageCount==1) {
            pageSlider.hidden=YES;
        }
        else
        {
            pageSlider.hidden=NO;

        }
        pageCountlbl.text=[NSString stringWithFormat:@"Page %d/%d",_currentPageIndex+1,_pageCount];
        pageSlider.minimumValue=1;
        pageSlider.maximumValue=_pageCount;
        [pageSlider setValue:1];

    }
    
}
    
#pragma mark - ScrollView Delegate Method
- (void)gotoPage:(int)pageIndex
{
        _currentPageIndex = pageIndex;
        float pageOffset = pageIndex * webView.bounds.size.width;
        [webView.scrollView setContentOffset:CGPointMake(pageOffset, 0) animated:NO];;
        pageCountlbl.text=[NSString stringWithFormat:@"Page %d/%d",_currentPageIndex+1,_pageCount];
        
}
    
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
        self.touchBeginPoint = scrollView.contentOffset;
}
    
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
        CGFloat   pageWidth   = scrollView.frame.size.width;
        _currentPageIndex = ceil(scrollView.contentOffset.x / pageWidth);
    [pageSlider setValue:_currentPageIndex+1];
        CGPoint touchEndPoint = scrollView.contentOffset;
        BOOL  _next = self.touchBeginPoint.x > touchEndPoint.x + 5;
        
        if (!_next)
        {
            if (_currentPageIndex == 0)
            {
                if (_pageNumber>0) {
                    
                    _pageNumber--;
                    [self loadPage];
                    
                }
                
                
            }
        }
        else
        {
            if(_currentPageIndex + 1 == _pageCount)
            {
                
                if ([self._ePubContent._spine count]-1>_pageNumber) {
                    
                    _pageNumber++;
                    [self loadPage];
                }
                
            }
        }
        pageCountlbl.text=[NSString stringWithFormat:@"Page %d/%d",_currentPageIndex+1,_pageCount];
    }
    

#pragma mark Epub Contents
/*Function Name : unzipAndSaveFile
 *Return Type   : void
 *Parameters    : nil
 *Purpose       : To unzip the epub file to documents directory
 */

- (void)unzipAndSaveFile{
	
	ZipArchive* za = [[ZipArchive alloc] init];
	if( [za UnzipOpenFile:[[NSBundle mainBundle] pathForResource:_strFileName ofType:@"epub"]] ){
		
		NSString *strPath=[NSString stringWithFormat:@"%@/UnzippedEpub",[self applicationDocumentsDirectory]];
		//Delete all the previous files
		NSFileManager *filemanager=[[NSFileManager alloc] init];
		if ([filemanager fileExistsAtPath:strPath]) {
			
			NSError *error;
			[filemanager removeItemAtPath:strPath error:&error];
		}
		filemanager=nil;
		//start unzip
		BOOL ret = [za UnzipFileTo:[NSString stringWithFormat:@"%@/",strPath] overWrite:YES];
		if( NO==ret ){
			// error handler here
			UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error"
														  message:@"An unknown error occured"
														 delegate:self
												cancelButtonTitle:@"OK"
												otherButtonTitles:nil];
			[alert show];
			alert=nil;
		}
		[za UnzipCloseFile];
	}
}

/*Function Name : applicationDocumentsDirectory
 *Return Type   : NSString - Returns the path to documents directory
 *Parameters    : nil
 *Purpose       : To find the path to documents directory
 */

- (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

/*Function Name : getRootFilePath
 *Return Type   : NSString - Returns the path to container.xml
 *Parameters    : nil
 *Purpose       : To find the path to container.xml.This file contains the file name which holds the epub informations
 */

- (NSString*)getRootFilePath{
	
	//check whether root file path exists
	NSFileManager *filemanager=[[NSFileManager alloc] init];
	NSString *strFilePath=[NSString stringWithFormat:@"%@/UnzippedEpub/META-INF/container.xml",[self applicationDocumentsDirectory]];
	if ([filemanager fileExistsAtPath:strFilePath]) {
		
		//valid ePub
		NSLog(@"Parse now");
		
		filemanager=nil;
		
		return strFilePath;
	}
	else {
		
		//Invalid ePub file
		UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error"
													  message:@"Root File not Valid"
													 delegate:self
											cancelButtonTitle:@"OK"
											otherButtonTitles:nil];
		[alert show];
		alert=nil;
		
	}
	filemanager=nil;
	return @"";
}


#pragma mark XMLHandler Delegate Methods

- (void)foundRootPath:(NSString*)rootPath{
	
	//Found the path of *.opf file
	
	//get the full path of opf file
	NSString *strOpfFilePath=[NSString stringWithFormat:@"%@/UnzippedEpub/%@",[self applicationDocumentsDirectory],rootPath];
	NSFileManager *filemanager=[[NSFileManager alloc] init];
	
	self._rootPath=[strOpfFilePath stringByReplacingOccurrencesOfString:[strOpfFilePath lastPathComponent] withString:@""];
	
	if ([filemanager fileExistsAtPath:strOpfFilePath]) {
		
		//Now start parse this file
		[_xmlHandler parseXMLFileAt:strOpfFilePath];
	}
	else {
		
		UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error"
													  message:@"OPF File not found"
													 delegate:self
											cancelButtonTitle:@"OK"
											otherButtonTitles:nil];
		[alert show];
		alert=nil;
	}
	filemanager=nil;
	
}


- (void)finishedParsing:(EpubContent*)ePubContents{
    
	_pagesPath=[NSString stringWithFormat:@"%@/%@",self._rootPath,[ePubContents._manifest valueForKey:[ePubContents._spine objectAtIndex:0]]];
	self._ePubContent=ePubContents;
	_pageNumber=0;
	[self loadPage];
}




/*Function Name : loadPage
 *Return Type   : void
 *Parameters    : nil
 *Purpose       : To load actual pages to webview
 */

- (void)loadPage{
	
    isFromFontChange=NO;
	_pagesPath=[NSString stringWithFormat:@"%@/%@",self._rootPath,[self._ePubContent._manifest valueForKey:[self._ePubContent._spine objectAtIndex:_pageNumber]]];
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:_pagesPath]]];
	//set page number
    
    
    // Instantiate UITextView object
    
    
    
   	pageCountlbl.text=[NSString stringWithFormat:@"%d",_pageNumber+1];
}


@end
