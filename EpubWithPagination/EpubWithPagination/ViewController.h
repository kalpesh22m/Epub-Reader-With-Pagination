//
//  ViewController.h
//  EpubWithPagination
//
//  Created by ganesh kulpe on 28/04/14.
//  Copyright (c) 2014 xyz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZipArchive.h"
#import "XMLHandler.h"
#import "EpubContent.h"
@interface ViewController : UIViewController<XMLHandlerDelegate,UIWebViewDelegate,UIScrollViewDelegate>
{
    __weak IBOutlet UILabel *pageCountlbl;
   __weak  IBOutlet UIWebView *webView;
    __weak IBOutlet UISlider *pageSlider;
    XMLHandler *_xmlHandler;
	EpubContent *_ePubContent;
	NSString *_pagesPath;
	NSString *_rootPath;
	NSString *_strFileName;
	int _pageNumber;
    int  _currentPageIndex;

}
@property (nonatomic, retain)EpubContent *_ePubContent;
@property (nonatomic, retain)NSString *_rootPath;
@property (nonatomic, retain)NSString *_strFileName;


-(IBAction)fontchangeBtnClicked:(id)sender;
-(IBAction)pageSliderValueChanged:(id)sender;
@end
