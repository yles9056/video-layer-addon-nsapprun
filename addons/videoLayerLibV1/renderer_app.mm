#define GL_SILENCE_DEPRECATION
#define DEV 1

#if DEV
#define Log(fmt, ...) {NSLog(@"%@", [NSString stringWithUTF8String:fmt]);}
#else
#define Log(format, ...)
#endif


#import "renderer_app.h"

// @interface ClientApplication : NSApplication

// @end

@implementation RendererApp

- (void)initSessionLayer {
    Log("Session and AVCaptureVideoPreviewLayer initialized.");
    self.sess = [[AVCaptureSession alloc] init];
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.sess];
    self.deviceList = [self getAllCameraDevices];
    self.resolution = AVCaptureSessionPreset1280x720;
    self.pos = @[@(0), @(0)];
    self.sz = @[@(400), @(200)];
    self.device = self.deviceList[0];
    self.uniqueId = [self.device uniqueID];
    self.notiCenter = [NSNotificationCenter defaultCenter];
    self.add =[self.notiCenter addObserverForName:AVCaptureDeviceWasConnectedNotification
                                        object:nil
                                         queue:nil
                                    usingBlock:^(NSNotification *note)
                                                {
                                                    NSLog(@"Add!");
                                                    self.deviceList = [self getAllCameraDevices];
                                                }];

    self.remove = [self.notiCenter addObserverForName:AVCaptureDeviceWasDisconnectedNotification
                                                object:nil
                                                queue:nil
                                            usingBlock:^(NSNotification *note)
                                                {
                                                    NSLog(@"Remove!");
                                                    self.deviceList = [self getAllCameraDevices];
                                                }];
}

- (void) configLayer {
    Log("Config the layer to the default setting.");
    // Default setting
    CGFloat x_anchor = 0;
    CGFloat y_anchor = 0;
    CGFloat red = 0;
    CGFloat green = 0;
    CGFloat blue = 0;
    CGFloat alpha = 0;

    [self setLayerResizeMethod];
    [self setLayerBgColor:red green:green blue:blue alpha:alpha];
    [self setLayerAnchorPoint:x_anchor y:y_anchor];
    [self setLayerSize:self.sz];
    [self setLayerPosition:self.pos];

}

- (void) setLayerAnchorPoint:(CGFloat)x_axis
                            y:(CGFloat)y_axis {
    if (DEV) {
        std::string x_str = std::to_string((float)x_axis);
        std::string y_str = std::to_string((float)y_axis);
        Log(("Set the Anchor point of video layer ("+ x_str + "," + y_str + ").").c_str());
    }
    
    [self.previewLayer setAnchorPoint:CGPointMake(0, 0)];
}

- (void) setLayerResizeMethod {
    Log("Set the video layer to the default resize method.");
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
}

- (void) setLayerBgColor:(CGFloat)r 
                    green:(CGFloat)g
                    blue:(CGFloat)b
                    alpha:(CGFloat)a {
    // component value only range (0.0 - 1.0)
    Log("Set the background color of video layer.");
    [self.previewLayer setBackgroundColor:CGColorCreateGenericRGB(r, g, b, a)];
}

- (void) setLayerSize:(NSArray*)sz {
    if (DEV) {
        std::string w_mm = std::to_string([sz[0] floatValue]);
        std::string h_mm = std::to_string([sz[1] floatValue]);
        Log(("Set the size of video layer ("+ w_mm + "," + h_mm + ").").c_str());
    }

    
    [self.previewLayer setBounds:CGRectMake(0, 0, [(NSNumber*)[sz objectAtIndex:0] intValue],
                                            [(NSNumber*)[sz objectAtIndex:1] intValue])];
}

- (void) setLayerPosition:(NSArray*)pos {
    if (DEV) {
        std::string x_mm = std::to_string([pos[0] floatValue]);
        std::string y_mm = std::to_string([pos[1] floatValue]);
        Log(("Set the position of video layer ("+ x_mm + "," + y_mm + ").").c_str());
    }
    
    [self.previewLayer setPosition:CGPointMake([(NSNumber*)[pos objectAtIndex:0] intValue],
                                               [(NSNumber*)[pos objectAtIndex:1] intValue])];
}

- (CAContextID) getLayerId {
    Log("Get the id of video Layer.");
    NSDictionary* dict = [[NSDictionary alloc] init];
    CGSConnectionID connection_id = CGSMainConnectionID();
    CAContext* remoteContext = [CAContext contextWithCGSConnection:connection_id options:dict];
    // Set the CAContext's layer to the CALayer for exporting.
    [remoteContext setLayer:self.previewLayer];
    CAContextID contextId = [remoteContext contextId];
    return contextId;
}

- (void) startSession {
    [self.sess startRunning];
}

- (void) stopSession {
    [self.sess stopRunning];
}

- (void) listAllDevices {
    printf("There are %ld device detected...\n", [self.deviceList count]);
    for (AVCaptureDevice *d in self.deviceList){
        printf("[device] %s\n", [[d localizedName] UTF8String]);
        printf("UniqueID: %s\n", [[d uniqueID] UTF8String]);
        printf("ModelID: %s\n", [[d modelID] UTF8String]);
    }
}

- (NSArray*) getBuildInCameraDevices {
    // AVCaptureDeviceTypeBuiltInWideAngleCamera to get Externel devices
    AVCaptureDeviceDiscoverySession *captureDeviceDiscoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera]
                                          mediaType:AVMediaTypeVideo
                                           position:AVCaptureDevicePositionUnspecified];
    NSArray *devs = [captureDeviceDiscoverySession devices];
    return devs;
}

- (NSArray*) getExternelCameraDevices {
    // AVCaptureDeviceTypeExternalUnknown to get Externel devices
    AVCaptureDeviceDiscoverySession *captureDeviceDiscoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeExternalUnknown]
                                          mediaType:AVMediaTypeVideo
                                           position:AVCaptureDevicePositionUnspecified];
    NSArray *devs = [captureDeviceDiscoverySession devices];
    return devs;
}

- (NSArray*) getAllCameraDevices {

    NSArray* buildInDevices = [self getBuildInCameraDevices];
    NSArray* externelDevices = [self getExternelCameraDevices];
    NSArray *allDevices=buildInDevices?[buildInDevices arrayByAddingObjectsFromArray:externelDevices]:[[NSArray alloc] initWithArray:externelDevices];
    return allDevices;
}

- (AVCaptureDeviceInput*) getDeviceInputByDevice:(AVCaptureDevice*)device {
    NSError* error = nil;
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (error) Log(std::string([[error localizedDescription] UTF8String]).c_str());
    return deviceInput;
}

- (void) setSessionInput:(AVCaptureSession*)sess device:(AVCaptureDevice*)d {
    AVCaptureDeviceInput* input = [self getDeviceInputByDevice: d];
    NSAssert(input != nil, @"Can not get input of device.");
    if ([sess canAddInput:input]) {
        [sess addInput:input];
    }
}

- (AVCaptureDevice*) getCameraDeviceByUniID:(std::string)uniId_string {

    AVCaptureDevice* targetDevice = nil;

    for (AVCaptureDevice *device in self.deviceList)
    {
        if ([[device uniqueID] UTF8String] == uniId_string){
            targetDevice = device;
            break;
        }
    }

    if(targetDevice) {
        Log(("Get the device with uniqueId: "+uniId_string).c_str());
    } else {
        Log("Can not find any device by giving uniqueId.");
    }
    
    return targetDevice;
}

- (bool) setSessionResolution:(NSString*) preset {
    if ([self.device supportsAVCaptureSessionPreset:preset] && [self.sess canSetSessionPreset:preset]) {
        [self.sess beginConfiguration];
        self.sess.sessionPreset = preset;
        [self.sess commitConfiguration];
        Log(("Set resolution to "+std::string([preset UTF8String])).c_str());
        return true;
    } else {
        Log("Can not support this resolution, set to dault 1280x720 one.");
        [self.sess setSessionPreset:AVCaptureSessionPreset1280x720];
        return false;
    }
}

- (void) resetInputSignal {
    NSError* error;
    AVCaptureDeviceInput* input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];
    if ( [self.sess canAddInput:input] ) {
        [self.sess addInput:input];
    }
}

- (void) refreshList {
    self.deviceList = [self getAllCameraDevices];
    std::cout << "Devices:" << [self.deviceList count] << std::endl;
}

@end

// For addon.cpp matching

RendererApp* client_app;
CALayerHost* videoLayer;
NSWindow* winParent;
int contextId = 0;

void initVideoLayerMM(void** handle)
{
    
    NSView *viewParent = static_cast<NSView*>(*reinterpret_cast<void**>(handle));
    winParent = [viewParent window];
    [viewParent setWantsLayer:YES];

    client_app = [[RendererApp alloc] init];
    [client_app initSessionLayer];
    client_app.previewLayer.frame = viewParent.frame;

    [client_app resetInputSignal];
    [[[winParent contentView] layer] addSublayer:client_app.previewLayer];
    [client_app configLayer];
            
}

void destroyVideoLayerMM()
{
    [client_app.previewLayer removeFromSuperlayer];
}

bool getCameraIsOpenMM()
{
    if ([client_app.sess isRunning]) {
        return true;
    } else {
        return false;
    }
}

std::string getCameraLocationIdMM()
{
    std::string deviceLocationId = [[client_app uniqueId] UTF8String];
    return deviceLocationId;
}

bool setCameraLocationIdMM(std::string uniId_string)
{
    NSString* uniId_ns = [NSString stringWithCString:uniId_string.c_str() encoding:[NSString defaultCStringEncoding]];
    AVCaptureDevice* device = [client_app getCameraDeviceByUniID:uniId_string];
    
    if (!(device)) return false;

    bool isRunning = [client_app.sess isRunning];
    if (isRunning) { [client_app stopSession];}

    Log("Remove the old one.");
    for (AVCaptureInput* input in client_app.sess.inputs){
            [client_app.sess removeInput:input];
    }
    [client_app setSessionInput:client_app.sess device:device];
    client_app.device = device;
    client_app.uniqueId = [device uniqueID];
    
    if (isRunning) {Log(("Switch to device "+std::string([uniId_ns UTF8String])+" in objc.").c_str());[client_app startSession];}
    return true;
}

bool openCameraMM()
{
    [client_app startSession];
    return true;
}

bool closeCameraMM()
{
    [client_app stopSession];
    if (NSThread.isMainThread) Log("Main thread...");

    // dispatch_async(dispatch_get_global_queue(0, 0),^{
    [client_app refreshList];
    // });
    
    return true;
}

std::string getCameraResolutionMM()
{
    NSString* resolutionNsstr = client_app.resolution;
    return std::string([resolutionNsstr UTF8String]);
}

bool setCameraResolutionMM(std::string resolutionStr)
{
    NSString* resolutionNsstr = [NSString stringWithCString:resolutionStr.c_str() 
                                   encoding:[NSString defaultCStringEncoding]];
    return [client_app setSessionResolution:resolutionNsstr];
}

std::vector<float> getVideoLayerPositionMM()
{
    CGFloat x = client_app.previewLayer.position.x;
    CGFloat y = client_app.previewLayer.position.y;

    float x_c = (float)x;
    float y_c = (float)y;
    
    std::vector<float> pos = {x_c, y_c};
    return pos;
}

void setVideoLayerPositionMM(std::vector<float> pos)
{
    float x_c = pos.at(0);
    float y_c = pos.at(1);

    CGFloat x = (CGFloat)x_c;
    CGFloat y = (CGFloat)y_c;

    [client_app setLayerPosition:@[@(x), @(y)]];
}


std::vector<float> getVideoLayerSizeMM()
{
    CGFloat w_cg = client_app.previewLayer.frame.size.width;
    CGFloat h_cg = client_app.previewLayer.frame.size.height;

    float w_c = (float)w_cg;
    float h_c = (float)h_cg;
    
    std::vector<float> sz = {w_c, h_c};
    return sz;
}

void setVideoLayerSizeMM(std::vector<float> sz)
{
    float w_c = sz.at(0);
    float h_c = sz.at(1);

    CGFloat w = (CGFloat)w_c;
    CGFloat h = (CGFloat)h_c;

    [client_app setLayerSize:@[@(w), @(h)]];
}
