#import "ReactNativeShareExtension.h"
#import <RCTRootView.h>
#import <MobileCoreServices/MobileCoreServices.h>

#define ITEM_IDENTIFIER @"public.url"

NSExtensionContext* extensionContext;

@implementation ReactNativeShareExtension {
  NSTimer *autoTimer;
  NSString* type;
  NSString* value;
}

- (UIView*) shareView {
  return nil;
}

RCT_EXPORT_MODULE();

- (void)viewDidLoad {
  [super viewDidLoad];
  
  //object variable for extension doesn't work for react-native. It must be assign to gloabl
  //variable extensionContext. in this way, both exported method can touch extensionContext
  extensionContext = self.extensionContext;
  
  UIView *rootView = [self shareView];
  if (rootView.backgroundColor == nil) {
    rootView.backgroundColor = [[UIColor alloc] initWithRed:1 green:1 blue:1 alpha:0.1];
  }
  
  self.view = rootView;
}


RCT_EXPORT_METHOD(close) {
  [extensionContext completeRequestReturningItems:nil
                                completionHandler:nil];
}

RCT_REMAP_METHOD(data,
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
  [self extractUrlFromContext: extensionContext withCallback:^(NSDictionary* result, NSException* err) {
    NSDictionary *inventory = @{
      @"url": result[@"url"],
      @"cookie": result[@"cookie"]
    };
    
    resolve(inventory);
  }];
}

- (void)extractUrlFromContext:(NSExtensionContext *)context withCallback:(void(^)(NSDictionary *result, NSException *exception))callback {
    @try {
        
        for (NSExtensionItem *item in context.inputItems) {
            for (NSItemProvider *itemProvider in item.attachments) {
                if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypePropertyList]) {
                    
                    
                    [itemProvider loadItemForTypeIdentifier: (NSString *) kUTTypePropertyList
                                                    options: 0
                                          completionHandler: ^(id<NSSecureCoding> item, NSError *error) {
                                              
                                              if (item != nil) {
                                                  
                                                  NSDictionary *result = (NSDictionary *) item;
                                                  NSDictionary *resultDict = result[NSExtensionJavaScriptPreprocessingResultsKey];
                                                  
                                                  if(callback) {
                                                      callback(resultDict, nil);
                                                  }
                                              }
                                              
                                          }];
                    
                }
            }
        }
        
        
        
    }
  @catch (NSException *exception) {
    if(callback) {
      callback(nil, exception);
    }
  }
}

@end
