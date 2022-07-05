#include "uvcCamCtrl_mac.h"

const uvc_controls_t uvc_controls = {
    .autoExposure = {
        .unit = UVC_INPUT_TERMINAL_ID,
        .selector = 0x02, //CT_AE_MODE_CONTROL
        .size = 1,
    },
    .exposure = {
        .unit = UVC_INPUT_TERMINAL_ID,
        .selector = 0x04, //CT_EXPOSURE_TIME_ABSOLUTE_CONTROL
        .size = 4,
    },

    .incremental_exposure = {
        .unit = UVC_INPUT_TERMINAL_ID,
        .selector = 0x05, //CT_EXPOSURE_TIME_ABSOLUTE_CONTROL
        .size = 1,
    },
    .absoluteFocus = {
        .unit = 0x09,
        .selector = 0x03,
        .size = 8,
    },
    .autoFocus = {
        .unit = UVC_INPUT_TERMINAL_ID,
        .selector = 0x08, //CT_FOCUS_AUTO_CONTROL
        .size = 1,
    },
    .focus = {
        .unit = UVC_INPUT_TERMINAL_ID,
        .selector = 0x06, //CT_FOCUS_ABSOLUTE_CONTROL
        .size = 2,
    },
    .zoom = {
        .unit = UVC_INPUT_TERMINAL_ID,
        .selector = 0x0B, // CT_ZOOM_ABSOLUTE_CONTROL
        .size = 2,
    },
    .brightness = {
        .unit = UVC_PROCESSING_UNIT_ID,
        .selector = 0x02,
        .size = 2,
    },
    .contrast = {
        .unit = UVC_PROCESSING_UNIT_ID,
        .selector = 0x03,
        .size = 2,
    },
    .gain = {
        .unit = UVC_PROCESSING_UNIT_ID,
        .selector = 0x04,
        .size = 2,
    },
    .saturation = {
        .unit = UVC_PROCESSING_UNIT_ID,
        .selector = 0x07,
        .size = 2,
    },
    .sharpness = {
        .unit = UVC_PROCESSING_UNIT_ID,
        .selector = 0x08,
        .size = 2,
    },
    .whiteBalance = {
        .unit = UVC_PROCESSING_UNIT_ID,
        .selector = 0x0A,
        .size = 2,
    },
    .autoWhiteBalance = {
        .unit = UVC_PROCESSING_UNIT_ID,
        .selector = 0x0B,
        .size = 1,
    },
    .backlight = {
        .unit = UVC_PROCESSING_UNIT_ID,
        .selector = 0x01,
        .size = 2,
    },
    .gamma = {
        .unit = UVC_PROCESSING_UNIT_ID,
        .selector = 0x09,
        .size = 2,
    },
    .lowlight = {
        .unit = UVC_INPUT_TERMINAL_ID,
        .selector = 0x03, //CT_AE_PRIORITY_CONTROL
        .size = 1,
    },
    .hue = {
        .unit = UVC_PROCESSING_UNIT_ID,
        .selector = 0x06,
        .size = 2,
    },
    .autoHue = {
        .unit = UVC_PROCESSING_UNIT_ID,
        .selector = 0x10, //PU_HUE_AUTO_CONTROL
        .size = 1,
    },
    .pantilt = {
        .unit = UVC_INPUT_TERMINAL_ID,
        .selector = 0x0D,
        .size = 8,
    },
};


@implementation UVCCameraControl

- (id)initWithLocationID:(UInt32)locationID vendorID:(long)vendorID productID:(long)productID {
    if( self = [super init] ) {
        interface = NULL;

        // Find All USB Devices, get their locationId and check if it matches the requested one
        CFMutableDictionaryRef matchingDict = IOServiceMatching(kIOUSBDeviceClassName);
        io_iterator_t serviceIterator;
        IOServiceGetMatchingServices( kIOMasterPortDefault, matchingDict, &serviceIterator );

        io_service_t camera;
        while( (camera = IOIteratorNext(serviceIterator)) ) {
            // Get DeviceInterface
            IOUSBDeviceInterface **deviceInterface = NULL;
            IOCFPlugInInterface    **plugInInterface = NULL;
            SInt32 score;
            kern_return_t kr = IOCreatePlugInInterfaceForService( camera, kIOUSBDeviceUserClientTypeID, kIOCFPlugInInterfaceID, &plugInInterface, &score );
            if( (kIOReturnSuccess != kr) || !plugInInterface ) {
                //NSLog( @"CameraControl Error: IOCreatePlugInInterfaceForService returned 0x%08x.", kr );
                continue;
            }

            HRESULT res = (*plugInInterface)->QueryInterface(plugInInterface, CFUUIDGetUUIDBytes(kIOUSBDeviceInterfaceID), (LPVOID*) &deviceInterface );
            (*plugInInterface)->Release(plugInInterface);
            if( res || deviceInterface == NULL ) {
                NSLog( @"CameraControl Error: QueryInterface returned %d.\n", (int)res );
                continue;
            }

            UInt32 currentLocationID = 0;
            UInt16 currentVendorID = 0;
            UInt16 currentProductID = 0;
            (*deviceInterface)->GetLocationID(deviceInterface, &currentLocationID);
            (*deviceInterface)->GetDeviceVendor(deviceInterface, &currentVendorID);
            (*deviceInterface)->GetDeviceProduct(deviceInterface, &currentProductID);

            if( currentLocationID == locationID && currentVendorID == vendorID && currentProductID == productID) {
                // Yep, this is the USB Device that was requested!
                interface = [self getControlInferaceWithDeviceInterface:deviceInterface];
                return self;
            }
        } // end while

    }
    return self;
}



- (id)initWithVendorID:(long)vendorID productID:(long)productID interfaceNum:(long)interNum {
    if( self = [super init] ) {
        interface = NULL;

        interfaceNum = interNum;

        // Find USB Device
        CFMutableDictionaryRef matchingDict = IOServiceMatching(kIOUSBDeviceClassName);
        CFNumberRef numberRef;

        numberRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &vendorID);
        CFDictionarySetValue( matchingDict, CFSTR(kUSBVendorID), numberRef );
        CFRelease(numberRef);

        numberRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &productID);
        CFDictionarySetValue( matchingDict, CFSTR(kUSBProductID), numberRef );
        CFRelease(numberRef);
        io_service_t camera = IOServiceGetMatchingService( kIOMasterPortDefault, matchingDict );


        // Get DeviceInterface
        IOUSBDeviceInterface **deviceInterface = NULL;
        IOCFPlugInInterface    **plugInInterface = NULL;
        SInt32 score;
        kern_return_t kr = IOCreatePlugInInterfaceForService( camera, kIOUSBDeviceUserClientTypeID, kIOCFPlugInInterfaceID, &plugInInterface, &score );
        if( (kIOReturnSuccess != kr) || !plugInInterface ) {
            NSLog( @"CameraControl Error: IOCreatePlugInInterfaceForService returned 0x%08x.", kr );
            return self;
        }

        HRESULT res = (*plugInInterface)->QueryInterface(plugInInterface, CFUUIDGetUUIDBytes(kIOUSBDeviceInterfaceID), (LPVOID*) &deviceInterface );
        (*plugInInterface)->Release(plugInInterface);
        if( res || deviceInterface == NULL ) {
            NSLog( @"CameraControl Error: QueryInterface returned %d.\n", (int)res );
            return self;
        }

        interface = [self getControlInferaceWithDeviceInterface:deviceInterface];
    }
    return self;
}


- (id)initWithInterface:(IOUSBDeviceInterface **)deviceInterface {
    if( self = [super init] ) {
        interface = [self getControlInferaceWithDeviceInterface:deviceInterface];
    }
    return self;
}

- (IOUSBInterfaceInterface190 **)getControlInferaceWithDeviceInterface:(IOUSBDeviceInterface **)deviceInterface {
    IOUSBInterfaceInterface190 **controlInterface;

    io_iterator_t interfaceIterator;
    IOUSBFindInterfaceRequest interfaceRequest;
    interfaceRequest.bInterfaceClass = UVC_CONTROL_INTERFACE_CLASS;
    interfaceRequest.bInterfaceSubClass = UVC_CONTROL_INTERFACE_SUBCLASS;
    interfaceRequest.bInterfaceProtocol = kIOUSBFindInterfaceDontCare;
    interfaceRequest.bAlternateSetting = kIOUSBFindInterfaceDontCare;

    IOReturn success = (*deviceInterface)->CreateInterfaceIterator( deviceInterface, &interfaceRequest, &interfaceIterator );
    if( success != kIOReturnSuccess ) {
        return NULL;
    }

    io_service_t usbInterface;
    HRESULT result;


    if( (usbInterface = IOIteratorNext(interfaceIterator)) ) {
        IOCFPlugInInterface **plugInInterface = NULL;

        //Create an intermediate plug-in
        SInt32 score;
        kern_return_t kr = IOCreatePlugInInterfaceForService( usbInterface, kIOUSBInterfaceUserClientTypeID, kIOCFPlugInInterfaceID, &plugInInterface, &score );

        //Release the usbInterface object after getting the plug-in
        kr = IOObjectRelease(usbInterface);
        if( (kr != kIOReturnSuccess) || !plugInInterface ) {
            NSLog( @"CameraControl Error: Unable to create a plug-in (%08x)\n", kr );
            return NULL;
        }

        //Now create the device interface for the interface
        result = (*plugInInterface)->QueryInterface( plugInInterface, CFUUIDGetUUIDBytes(kIOUSBInterfaceInterfaceID), (LPVOID *) &controlInterface );

        //No longer need the intermediate plug-in
        (*plugInInterface)->Release(plugInInterface);

        if( result || !controlInterface ) {
            NSLog( @"CameraControl Error: Couldn’t create a device interface for the interface (%08x)", (int) result );
            return NULL;
        }

        return controlInterface;
    }

    return NULL;
}


- (void)dealloc {
    if( interface ) {
        (*interface)->USBInterfaceClose(interface);
        (*interface)->Release(interface);
    }
    //[super dealloc];
}

- (void)closeInterface {
    if( interface ) {
        (*interface)->USBInterfaceClose(interface);
    }
}


- (BOOL)sendControlRequest:(IOUSBDevRequest)controlRequest {
    if( !interface ){
        NSLog( @"CameraControl Error: No interface to send request" );
        return NO;
    }

    //Now open the interface. This will cause the pipes associated with
    //the endpoints in the interface descriptor to be instantiated
    // vv20211220 macOS 12 will return kIOReturnExclusiveAccess (e00002c5)
    // still working on it...
    NSOperatingSystemVersion version = [[NSProcessInfo processInfo] operatingSystemVersion];
    NSLog([NSString stringWithFormat:@"%ld.%ld.%ld", version.majorVersion, version.minorVersion, version.patchVersion]);
    if(__builtin_available(macOS 12.0, *)){
        kern_return_t kr = (*interface)->ControlRequest( interface, 0, &controlRequest );
        if( kr != kIOReturnSuccess ) {
            //kr = (*interface)->USBInterfaceClose(interface);
            NSLog([NSString stringWithFormat:@"%ld.%ld.%ld", version.majorVersion, version.minorVersion, version.patchVersion]);
            NSLog( @"CameraControl Error: Control request failed: %08x", kr );
            return NO;
        }
    }
    else{
        kern_return_t kr = (*interface)->USBInterfaceOpen(interface);
        if (kr != kIOReturnSuccess)    {
            NSLog([NSString stringWithFormat:@"%ld.%ld.%ld", version.majorVersion, version.minorVersion, version.patchVersion]);
            NSLog( @"CameraControl Error: Unable to open interface (%08x)\n", kr );
            return NO;
        }

        kr = (*interface)->ControlRequest( interface, 0, &controlRequest );
        if( kr != kIOReturnSuccess ) {
            kr = (*interface)->USBInterfaceClose(interface);
            NSLog( @"CameraControl Error: Control request failed: %08x", kr );
            return NO;
        }

        kr = (*interface)->USBInterfaceClose(interface);
    }

    /*kern_return_t kr = (*interface)->USBInterfaceOpen(interface);
    if (kr != kIOReturnSuccess)    {
        //NSLog( @"CameraControl Error: Unable to open interface (%08x)\n", kr );
        NSLog( @"Unable to open interface (%08x)\n", kr );
        kern_return_t kr = (*interface)->ControlRequest( interface, 0, &controlRequest );
        if( kr != kIOReturnSuccess ) {
            //kr = (*interface)->USBInterfaceClose(interface);
            NSLog( @"CameraControl Error: Control request failed: %08x", kr );
            return NO;
        }
    }

    kr = (*interface)->ControlRequest( interface, 0, &controlRequest );
    if( kr != kIOReturnSuccess ) {
        kr = (*interface)->USBInterfaceClose(interface);
        NSLog( @"CameraControl Error: Control request failed: %08x", kr );
        return NO;
    }

    kr = (*interface)->USBInterfaceClose(interface);*/

    return YES;
}


- (long) getInfoForControl:(uvc_control_info_t *)control{
    return [self getDataFor:UVC_GET_INFO withLength:1  fromSelector:control->selector at:control->unit];

}

- (BOOL)setData:(long)value withLength:(int)length forSelector:(int)selector at:(int)unitId {
    IOUSBDevRequest controlRequest;
    controlRequest.bmRequestType = USBmakebmRequestType( kUSBOut, kUSBClass, kUSBInterface );
    controlRequest.bRequest = UVC_SET_CUR;
    controlRequest.wValue = (selector << 8) | interfaceNum;
    controlRequest.wIndex = (unitId << 8) | interfaceNum;
    controlRequest.wLength = length;
    controlRequest.wLenDone = 0;
    controlRequest.pData = &value;
    return [self sendControlRequest:controlRequest];
}

- (BOOL)setData2:(int *)value withLength:(int)length forSelector:(int)selector at:(int)unitId {
    IOUSBDevRequest controlRequest;
    NSLog(@"setData2 unitid %d",unitId);
    NSLog(@"setData2 selector %d",selector);
    NSLog(@"setData2 length %d",length);
    controlRequest.bmRequestType = USBmakebmRequestType( kUSBOut, kUSBClass, kUSBInterface );
    controlRequest.bRequest = UVC_SET_CUR;
    controlRequest.wValue = (selector << 8) | interfaceNum;
    controlRequest.wIndex = (unitId << 8) | interfaceNum;
    controlRequest.wLength = length;
    controlRequest.wLenDone = 0;
    controlRequest.pData = value;
    return [self sendControlRequest:controlRequest];
}

- (short int)getDataFor:(int)type withLength:(int)length fromSelector:(int)selector at:(int)unitId {
    short int value = 0;
    IOUSBDevRequest controlRequest;
    controlRequest.bmRequestType = USBmakebmRequestType( kUSBIn, kUSBClass, kUSBInterface );
    controlRequest.bRequest = type;
    controlRequest.wValue = (selector << 8) | interfaceNum;
    controlRequest.wIndex = (unitId << 8) | interfaceNum;
    controlRequest.wLength = length;
    controlRequest.wLenDone = 0;
    controlRequest.pData = &value;
    BOOL success = [self sendControlRequest:controlRequest];
    return ( success ? value : 0 );
}

- (long)getDatasize4For:(int)type withLength:(int)length fromSelector:(int)selector at:(int)unitId {
    long value = 0;
    IOUSBDevRequest controlRequest;
    controlRequest.bmRequestType = USBmakebmRequestType( kUSBIn, kUSBClass, kUSBInterface );
    controlRequest.bRequest = type;
    controlRequest.wValue = (selector << 8) | interfaceNum;
    controlRequest.wIndex = (unitId << 8) | interfaceNum;
    controlRequest.wLength = length;
    controlRequest.wLenDone = 0;
    controlRequest.pData = &value;
    BOOL success = [self sendControlRequest:controlRequest];
    return ( success ? value : 0 );
}

- (uvc_pantilt_t)getData2For:(int)type withLength:(int)length fromSelector:(int)selector at:(int)unitId {
    uvc_pantilt_t value = {0,0};
    IOUSBDevRequest controlRequest;
    controlRequest.bmRequestType = USBmakebmRequestType( kUSBIn, kUSBClass, kUSBInterface );
    controlRequest.bRequest = type;
    controlRequest.wValue = (selector << 8) | interfaceNum;
    controlRequest.wIndex = (unitId << 8) | interfaceNum;
    controlRequest.wLength = length;
    controlRequest.wLenDone = 0;
    controlRequest.pData = &value;
    BOOL success = [self sendControlRequest:controlRequest];
    if (success) {
        return value;
    }
    else
    {
        value = {0,0};
        return value;
    }
}

// Get Range (min, max)
- (uvc_range_t)getRangeForControl:(const uvc_control_info_t *)control {
    uvc_range_t range = { 0, 0, 0, 0 };
    range.min = (int)[self getDataFor:UVC_GET_MIN withLength:control->size fromSelector:control->selector at:control->unit];
    range.max = (int)[self getDataFor:UVC_GET_MAX withLength:control->size fromSelector:control->selector at:control->unit];
    range.stepsize = (int)[self getDataFor:UVC_GET_RES withLength:control->size fromSelector:control->selector at:control->unit];
    range.def = (int)[self getDataFor:UVC_GET_DEF withLength:control->size fromSelector:control->selector at:control->unit];
    return range;
}

- (uvc_range_t)getRangeForsize4Control:(const uvc_control_info_t *)control {
    uvc_range_t range = { 0, 0, 0, 0 };
    range.min = (int)[self getDatasize4For:UVC_GET_MIN withLength:control->size fromSelector:control->selector at:control->unit];
    range.max = (int)[self getDatasize4For:UVC_GET_MAX withLength:control->size fromSelector:control->selector at:control->unit];
    range.stepsize = (int)[self getDatasize4For:UVC_GET_RES withLength:control->size fromSelector:control->selector at:control->unit];
    range.def = (int)[self getDatasize4For:UVC_GET_DEF withLength:control->size fromSelector:control->selector at:control->unit];
    return range;
}

// Get PTRange (min, max)
- (uvc_ptrange_t)getPTRangeForControl:(const uvc_control_info_t *)control {
    uvc_ptrange_t range = { 0, 0, 0 ,0, 0, 0, 0, 0};
    uvc_pantilt_t ptmin = {0, 0};
    uvc_pantilt_t ptmax = {0, 0};
    uvc_pantilt_t ptstepsize = {0, 0};
    uvc_pantilt_t ptdef = {0, 0};
    ptmin = (uvc_pantilt_t)[self getData2For:UVC_GET_MIN withLength:control->size fromSelector:control->selector at:control->unit];
    ptmax = (uvc_pantilt_t)[self getData2For:UVC_GET_MAX withLength:control->size fromSelector:control->selector at:control->unit];
    ptstepsize = (uvc_pantilt_t)[self getData2For:UVC_GET_RES withLength:control->size fromSelector:control->selector at:control->unit];
    ptdef = (uvc_pantilt_t)[self getData2For:UVC_GET_DEF withLength:control->size fromSelector:control->selector at:control->unit];
    range.panmin = ptmin.pan;
    range.tiltmin = ptmin.tilt;
    range.panmax = ptmax.pan;
    range.tiltmax = ptmax.tilt;
    range.panstepsize = ptstepsize.pan;
    range.tiltstepsize = ptstepsize.tilt;
    range.pandef = ptdef.pan;
    range.tiltdef = ptdef.tilt;
    
    printf("panrangemin:%d\n",range.panmin);
    printf("tiltrangemin:%d\n",range.tiltmin);
    printf("panrangemax:%d\n",range.panmax);
    printf("tiltrangemax:%d\n",range.tiltmax);
    printf("panrangestepsize:%d\n",range.panstepsize);
    printf("tiltrangestepsize:%d\n",range.tiltstepsize);
    printf("panrangedef:%d\n",range.pandef);
    printf("tiltrangedef:%d\n",range.tiltdef);
    return range;
}

// Used to de-/normalize values
- (float)mapValue:(float)value fromMin:(float)fromMin max:(float)fromMax toMin:(float)toMin max:(float)toMax {
    return toMin + (toMax - toMin) * ((value - fromMin) / (fromMax - fromMin));
}


// Get a normalized value
- (float)getValueForControl:(const uvc_control_info_t *)control {
    // TODO: Cache the range somewhere?
    //uvc_range_t range = [self getRangeForControl:control];

    int intval = (int)[self getDataFor:UVC_GET_CUR withLength:control->size fromSelector:control->selector at:control->unit];
    //return [self mapValue:intval fromMin:range.min max:range.max toMin:0 max:1];
    return intval;
}

- (int)getPTValueForControl:(const uvc_control_info_t *)control withValue:(std::string)strvalue {
    // TODO: Cache the range somewhere?
    uvc_ptrange_t range = [self getPTRangeForControl:control];

    uvc_pantilt_t intval = (uvc_pantilt_t)[self getData2For:UVC_GET_CUR withLength:control->size fromSelector:control->selector at:control->unit];
   /* return [self mapValue:intval fromMin:range.min max:range.max toMin:0 max:1];*/
    if(strvalue == "pan")
    {
        printf("pan:%d\n",intval.pan);
        return intval.pan;
    }
    else if(strvalue == "tilt")
    {
        return intval.tilt;
    }
}

// Set a normalized value
- (BOOL)setValue:(float)value forControl:(const uvc_control_info_t *)control {
    // TODO: Cache the range somewhere?
    //uvc_range_t range = [self getRangeForControl:control];

    /*int intval = [self mapValue:value fromMin:0 max:1 toMin:range.min max:range.max];
    return [self setData:intval withLength:control->size forSelector:control->selector at:control->unit];*/
    return [self setData:value withLength:control->size forSelector:control->selector at:control->unit];
}

// ================================================================

// Set/Get the actual values for the camera
//

- (BOOL)setAutoExposure:(BOOL)enabled {
    int intval = (enabled ? 0x08 : 0x01); // "auto exposure modes" ar NOT boolean (on|off) as it seems
    printf("setAutoExposure = %i \n",enabled);
    return [self setData:intval
              withLength:uvc_controls.autoExposure.size
             forSelector:uvc_controls.autoExposure.selector
                      at:uvc_controls.autoExposure.unit];

}

- (BOOL)getAutoExposure {
    int intval = (int)[self getDataFor:UVC_GET_CUR
                       withLength:uvc_controls.autoExposure.size
                     fromSelector:uvc_controls.autoExposure.selector
                               at:uvc_controls.autoExposure.unit];

    return ( intval == 0x08 ? YES : NO );
}

- (BOOL)setExposure:(float)value {
    printf("exposure value %f \n",value);
    //value = 1 - value;
    return [self setValue:value forControl:&uvc_controls.exposure];
}

- (void) incrementExposure {
    [self setData:0x01
       withLength:uvc_controls.exposure.size
      forSelector:uvc_controls.exposure.selector
               at:uvc_controls.exposure.unit];
}

- (void) decrementExposure {
    [self setData:0xFF
       withLength:uvc_controls.exposure.size
      forSelector:uvc_controls.exposure.selector
               at:uvc_controls.exposure.unit];
}

- (void) setDefaultExposure {
    [self setData:0x00
       withLength:uvc_controls.exposure.size
      forSelector:uvc_controls.exposure.selector
               at:uvc_controls.exposure.unit];
}

- (uvc_controls_t *) getControls{
    return (uvc_controls_t *)&uvc_controls;
}

- (float)getExposure {
    float value = [self getValueForControl:&uvc_controls.exposure];
    //return 1 - value;
    return value;
}

//-----focus
- (BOOL)setAutoFocus:(BOOL)enabled {
    //int intval = (enabled ? 0x08 : 0x01); //that's how eposure does it
    int intval = (enabled ? 0x01 : 0x00); //that's how white balance does it
    printf("setAutoFocus = %i \n",enabled);
    return [self setData:intval
              withLength:uvc_controls.autoFocus.size
             forSelector:uvc_controls.autoFocus.selector
                      at:uvc_controls.autoFocus.unit];

}
- (BOOL)getAutoFocus {
    int intval = (int)[self getDataFor:UVC_GET_CUR
                       withLength:uvc_controls.autoFocus.size
                     fromSelector:uvc_controls.autoFocus.selector
                               at:uvc_controls.autoFocus.unit];

    //return ( intval == 0x08 ? YES : NO );
    //return ( intval ? YES : NO );
    return ( intval == 0x01 ? YES : NO );
}
- (BOOL)setAbsoluteFocus:(float)value {
    printf("focus value %f \n",value);
    //value = 1 - value;
    return [self setValue:value forControl:&uvc_controls.focus];

}
- (float)getAbsoluteFocus {
    //float value = [self getValueForControl:&uvc_controls.absoluteFocus];
    //return 1 - value;
    return [self getValueForControl:&uvc_controls.focus];
}

- (BOOL)setZoom:(float)value {
    printf("setZoom value %f \n",value);
    return [self setValue:value forControl:&uvc_controls.zoom];
}

- (float)getZoom {
    return [self getValueForControl:&uvc_controls.zoom];
}

//white balance
- (BOOL)setAutoWhiteBalance:(BOOL)enabled {
    int intval = (enabled ? 0x01 : 0x00);
    printf("setAutoWhiteBalance = %i \n",enabled);
    return [self setData:intval
              withLength:uvc_controls.autoWhiteBalance.size
             forSelector:uvc_controls.autoWhiteBalance.selector
                      at:uvc_controls.autoWhiteBalance.unit];

}

- (BOOL)getAutoWhiteBalance {
    int intval = (int)[self getDataFor:UVC_GET_CUR
                       withLength:uvc_controls.autoWhiteBalance.size
                     fromSelector:uvc_controls.autoWhiteBalance.selector
                               at:uvc_controls.autoWhiteBalance.unit];

    return ( intval ? YES : NO );
}

- (BOOL)setWhiteBalance:(float)value {
    printf("whiteBalance value %f \n",value);
    return [self setValue:value forControl:&uvc_controls.whiteBalance];
}

- (float)getWhiteBalance {
    return [self getValueForControl:&uvc_controls.whiteBalance];
}

//Hue
- (BOOL)setAutoHue:(BOOL)enabled {
    int intval = (enabled ? 0x01 : 0x00);
    printf("setAutoHue = %i \n",enabled);
    return [self setData:intval
              withLength:uvc_controls.autoHue.size
             forSelector:uvc_controls.autoHue.selector
                      at:uvc_controls.autoHue.unit];

}

- (BOOL)getAutoHue {
    int intval = (int)[self getDataFor:UVC_GET_CUR
                       withLength:uvc_controls.autoHue.size
                     fromSelector:uvc_controls.autoHue.selector
                               at:uvc_controls.autoHue.unit];

    return ( intval ? YES : NO );
}

- (BOOL)setHue:(float)value {
    printf("Hue value %f \n",value);
    return [self setValue:value forControl:&uvc_controls.hue];
}

- (float)getHue {
    return [self getValueForControl:&uvc_controls.hue];
}

//---rest---

- (BOOL)setGain:(float)value {
    printf("gain value %f \n",value);

    return [self setValue:value forControl:&uvc_controls.gain];
}

- (float)getGain {
    return [self getValueForControl:&uvc_controls.gain];
}

- (BOOL)setBrightness:(float)value {
    printf("brightness value %f \n",value);
    return [self setValue:value forControl:&uvc_controls.brightness];
}

- (float)getBrightness {
    return [self getValueForControl:&uvc_controls.brightness];
}

- (BOOL)setContrast:(float)value {
    return [self setValue:value forControl:&uvc_controls.contrast];
}

- (float)getContrast {
    return [self getValueForControl:&uvc_controls.contrast];
}

- (BOOL)setSaturation:(float)value {
    return [self setValue:value forControl:&uvc_controls.saturation];
}

- (float)getSaturation {
    return [self getValueForControl:&uvc_controls.saturation];
}

- (BOOL)setSharpness:(float)value {
    return [self setValue:value forControl:&uvc_controls.sharpness];
}

- (float)getSharpness {
    return [self getValueForControl:&uvc_controls.sharpness];
}

- (BOOL)setGamma:(float)value {
    printf("Gamma value %f \n",value);
    return [self setValue:value forControl:&uvc_controls.gamma];
}

- (float)getGamma {
    return [self getValueForControl:&uvc_controls.gamma];
}

- (BOOL)setBacklight:(float)value {
    printf("Backlight value %f \n",value);
    return [self setValue:value forControl:&uvc_controls.backlight];
}

- (float)getBacklight {
    return [self getValueForControl:&uvc_controls.backlight];
}

- (BOOL)setlowlight:(BOOL)enabled {
    //int intval = (enabled ? 0x08 : 0x01); //that's how eposure does it
    int intval = (enabled ? 0x01 : 0x00); //that's how white balance does it
    printf("setlowlight = %i \n",enabled);
    return [self setData:intval
              withLength:uvc_controls.lowlight.size
             forSelector:uvc_controls.lowlight.selector
                      at:uvc_controls.lowlight.unit];

}

- (BOOL)getlowlight {
    int intval = (int)[self getDataFor:UVC_GET_CUR
                       withLength:uvc_controls.lowlight.size
                     fromSelector:uvc_controls.lowlight.selector
                               at:uvc_controls.lowlight.unit];

    //return ( intval == 0x08 ? YES : NO );
    //return ( intval ? YES : NO );
    return ( intval == 0x01 ? YES : NO );
}

- (BOOL)setPanTilt:(int)pan withTilt:(int)tilt {
    //printf("Backlight value %f \n",value);
    int value[2];
    value[0] = pan;
    value[1] = tilt;
    //int value = pan;
    return [self setData2:(int*)&value[0]
               withLength:uvc_controls.pantilt.size
              forSelector:uvc_controls.pantilt.selector
                       at:uvc_controls.pantilt.unit];
}

- (int)getPan {
    return [self getPTValueForControl:&uvc_controls.pantilt withValue:"pan"];
}

- (int)getTilt {
    return [self getPTValueForControl:&uvc_controls.pantilt withValue:"tilt"];
}

@end

UVCCameraControl *cameraControl;

int globalpan = 0, globaltitl = 0;

int iExposurebasis = 0;

int getlog2(int intValue)
{
    double reInt = 0;
    reInt = log2(intValue) + 0.5;
    return reInt;
}

void initCameraControl(UInt32 iLocid, long iVid, long iPid)
{
    cameraControl = [[UVCCameraControl alloc] initWithLocationID:iLocid vendorID:iVid productID:iPid];
}

void getCamRange(int iLocid, std::string iamCamCtrlType, double* outresult)
{
    uvc_range_t getCamRange =  { 0, 0, 0, 0 };
    uvc_ptrange_t getCamPTRange =  { 0, 0, 0, 0, 0, 0, 0, 0 };
    bool bgetAuto;
    //UVCCameraControl *cameraControl = [[UVCCameraControl alloc] initWithLocationID:iLocid];
    std::cout << "out:" << outresult[0]<< "\n";
    if(iamCamCtrlType == "CameraControl_Focus")
    {
        getCamRange = [cameraControl getRangeForControl:&uvc_controls.focus];
        bgetAuto = [cameraControl getAutoFocus];
        if([cameraControl setAutoFocus:YES])
        {
            outresult[4] = 3;
            if(bgetAuto == false)
            {
                [cameraControl setAutoFocus:NO];
            }
        }
        else
        {
            outresult[4] = 0;
        }       
    }
    else if(iamCamCtrlType == "VideoProcAmp_Brightness")
    {
        getCamRange = [cameraControl getRangeForControl:&uvc_controls.brightness];
    }
    else if(iamCamCtrlType == "VideoProcAmp_Contrast")
    {
        getCamRange = [cameraControl getRangeForControl:&uvc_controls.contrast];
    }
    else if(iamCamCtrlType == "VideoProcAmp_Saturation")
    {
        getCamRange = [cameraControl getRangeForControl:&uvc_controls.saturation];
    }
    else if(iamCamCtrlType == "VideoProcAmp_Sharpness")
    {
        getCamRange = [cameraControl getRangeForControl:&uvc_controls.sharpness];
    }
    else if(iamCamCtrlType == "CameraControl_Exposure")
    {
        int imin = 0,imax = 0;
        getCamRange = [cameraControl getRangeForsize4Control:&uvc_controls.exposure];
        imin = getlog2(getCamRange.min + 1);
        imax = getlog2(getCamRange.max + 1);
        iExposurebasis = imin + imax;
        printf("basis:%d\n",imin);
        printf("basis:%d\n",imax);
        getCamRange.min = imin - iExposurebasis;
        getCamRange.max = imax - iExposurebasis;
        getCamRange.stepsize = 1;
        getCamRange.def = getlog2(getCamRange.def + 1) - iExposurebasis;
        bgetAuto = [cameraControl getAutoExposure];
        if([cameraControl setAutoExposure:YES])
        {
            outresult[4] = 3;
            if(bgetAuto == false)
            {
                [cameraControl setAutoExposure:NO];
            }
        }
        else
        {
            outresult[4] = 0;
        }       
    }
    else if(iamCamCtrlType == "VideoProcAmp_WhiteBalance")
    {
        getCamRange = [cameraControl getRangeForControl:&uvc_controls.whiteBalance];
        bgetAuto = [cameraControl getAutoWhiteBalance];
        if([cameraControl setAutoWhiteBalance:YES])
        {
            outresult[4] = 3;
            if(bgetAuto == false)
            {
                [cameraControl setAutoWhiteBalance:NO];
            }
        }
        else
        {
            outresult[4] = 0;
        }       
    }
    else if(iamCamCtrlType == "VideoProcAmp_BacklightCompensation")
    {
        getCamRange = [cameraControl getRangeForControl:&uvc_controls.backlight];
    }
    else if(iamCamCtrlType == "VideoProcAmp_Gamma")
    {
        getCamRange = [cameraControl getRangeForControl:&uvc_controls.gamma];
    }
    else if(iamCamCtrlType == "CameraControl_LowLightCompensation")
    {
        getCamRange = [cameraControl getRangeForControl:&uvc_controls.lowlight];
        outresult[4] = 3;
    }
    else if(iamCamCtrlType == "VideoProcAmp_Hue")
    {
        getCamRange = [cameraControl getRangeForControl:&uvc_controls.hue];
        bgetAuto = [cameraControl getAutoHue];
        if([cameraControl setAutoHue:YES])
        {
            outresult[4] = 3;
            if(bgetAuto == false)
            {
                [cameraControl setAutoHue:NO];
            }
        }
        else
        {
            outresult[4] = 0;
        }       
    }
    else if(iamCamCtrlType == "CameraControl_Zoom")
    {
        getCamRange = [cameraControl getRangeForControl:&uvc_controls.zoom];
    }
    else if(iamCamCtrlType == "CameraControl_Pan")
    {
        globalpan = [cameraControl getPan];
        getCamPTRange = [cameraControl getPTRangeForControl:&uvc_controls.pantilt];
        getCamRange.min = getCamPTRange.panmin;
        getCamRange.max = getCamPTRange.panmax;
        getCamRange.stepsize = getCamPTRange.panstepsize;
        getCamRange.def = getCamPTRange.pandef;
    }
    else if(iamCamCtrlType == "CameraControl_Tilt")
    {
        globaltitl = [cameraControl getTilt];
        getCamPTRange = [cameraControl getPTRangeForControl:&uvc_controls.pantilt];
        getCamRange.min = getCamPTRange.tiltmin;
        getCamRange.max = getCamPTRange.tiltmax;
        getCamRange.stepsize = getCamPTRange.tiltstepsize;
        getCamRange.def = getCamPTRange.tiltdef;
    }

    outresult[0] = getCamRange.min;
    outresult[1] = getCamRange.max;
    outresult[2] = getCamRange.stepsize;
    outresult[3] = getCamRange.def;

    //return outresult;
}

void getCamValue(int iLocid,std::string iamCamCtrlType,double* outresult)
{
    //UVCCameraControl *cameraControl = [[UVCCameraControl alloc] initWithLocationID:iLocid];
    bool bgetAuto;
    double fgetValue;
    if(iamCamCtrlType == "CameraControl_Focus")
    {
        fgetValue = [cameraControl getAbsoluteFocus];
        bgetAuto = [cameraControl getAutoFocus];
        outresult[1] = bgetAuto ? 1 : 2;
    }
    else if(iamCamCtrlType == "VideoProcAmp_Brightness")
    {
        fgetValue = [cameraControl getBrightness];
        outresult[1] = 2;
    }
    else if(iamCamCtrlType == "VideoProcAmp_Contrast")
    {
        fgetValue = [cameraControl getContrast];
        outresult[1] = 2;
    }
    else if(iamCamCtrlType == "VideoProcAmp_Saturation")
    {
        fgetValue = [cameraControl getSaturation];
        outresult[1] = 2;
    }
    else if(iamCamCtrlType == "VideoProcAmp_Sharpness")
    {
        fgetValue = [cameraControl getSharpness];
        outresult[1] = 2;
    }
    else if(iamCamCtrlType == "CameraControl_Exposure")
    {
        double fgetExposure = [cameraControl getExposure];
        if(iExposurebasis == 0)
        {
            uvc_range_t getCamRange = { 0, 0, 0, 0 };
            int imin = 0,imax = 0;
            getCamRange = [cameraControl getRangeForsize4Control:&uvc_controls.exposure];
            imin = getlog2(getCamRange.min + 1);
            imax = getlog2(getCamRange.max + 1);
            iExposurebasis = imin + imax;
        }
        fgetValue = getlog2(fgetExposure + 1) - iExposurebasis;
        bgetAuto = [cameraControl getAutoExposure];
        outresult[1] = bgetAuto ? 1 : 2;
    }
    else if(iamCamCtrlType == "VideoProcAmp_WhiteBalance")
    {
        fgetValue = [cameraControl getWhiteBalance];
        bgetAuto = [cameraControl getAutoWhiteBalance];
        outresult[1] = bgetAuto ? 1 : 2;
    }
    else if(iamCamCtrlType == "VideoProcAmp_BacklightCompensation")
    {
        fgetValue = [cameraControl getBacklight];
        outresult[1] = 2;
    }
    else if(iamCamCtrlType == "VideoProcAmp_Gamma")
    {
        fgetValue = [cameraControl getGamma];
        outresult[1] = 2;
    }
    else if(iamCamCtrlType == "CameraControl_LowLightCompensation")
    {
        fgetValue = [cameraControl getlowlight];
        outresult[1] = 0;
    }
    else if(iamCamCtrlType == "VideoProcAmp_Hue")
    {
        fgetValue = [cameraControl getHue];
        bgetAuto = [cameraControl getAutoHue];
        outresult[1] = bgetAuto ? 1 : 2;
    }
    else if(iamCamCtrlType == "CameraControl_Zoom")
    {
        fgetValue = [cameraControl getZoom];
        outresult[1] = 2;
    }
    else if(iamCamCtrlType == "CameraControl_Pan")
    {
        fgetValue = [cameraControl getPan];
        outresult[1] = 2;
    }
    else if(iamCamCtrlType == "CameraControl_Tilt")
    {
        fgetValue = [cameraControl getTilt];
        outresult[1] = 2;
    }
    else
    {
        fgetValue = 0;
    }
    if(fgetValue != NULL)
    {
        outresult[0] = fgetValue;
    }   

    //return outresult;
}

void setCamValue(int iLocid, std::string iamCamCtrlType,double CamValue,int isAuto)
{
    //UVCCameraControl *cameraControl = [[UVCCameraControl alloc] initWithLocationID:iLocid];
    bool autoFocusType;
    if(iamCamCtrlType == "CameraControl_Focus" && isAuto == 1)
    {
        [cameraControl setAutoFocus:YES];
    }
    else if(iamCamCtrlType == "CameraControl_Focus" && isAuto == 2)
    {
        [cameraControl setAutoFocus:NO];
        [cameraControl setAbsoluteFocus:CamValue];
    }
    else if(iamCamCtrlType == "VideoProcAmp_Brightness")
    {
        [cameraControl setBrightness:CamValue];
    }
    else if(iamCamCtrlType == "VideoProcAmp_Contrast")
    {
        [cameraControl setContrast:CamValue];
    }
    else if(iamCamCtrlType == "VideoProcAmp_Saturation")
    {
        [cameraControl setSaturation:CamValue];
    }
    else if(iamCamCtrlType == "VideoProcAmp_Sharpness")
    {
        [cameraControl setSharpness:CamValue];
    }
    else if(iamCamCtrlType == "CameraControl_Exposure" && isAuto == 1)
    {
        [cameraControl setAutoExposure:YES];
    }
    else if(iamCamCtrlType == "CameraControl_Exposure" && isAuto == 2)
    {
        double itransExposure;
        [cameraControl setAutoExposure:NO];
        if(iExposurebasis == 0)
        {
            uvc_range_t getCamRange = { 0, 0, 0, 0 };
            int imin = 0,imax = 0;
            getCamRange = [cameraControl getRangeForsize4Control:&uvc_controls.exposure];
            imin = getlog2(getCamRange.min + 1);
            imax = getlog2(getCamRange.max + 1);
            iExposurebasis = imin + imax;
        }
        itransExposure = pow(2,(CamValue + iExposurebasis));
        [cameraControl setExposure:(itransExposure - 1)];
    }
    else if(iamCamCtrlType == "VideoProcAmp_WhiteBalance" && isAuto == 1)
    {
        [cameraControl setAutoWhiteBalance:YES];
    }
    else if(iamCamCtrlType == "VideoProcAmp_WhiteBalance" && isAuto == 2)
    {
        [cameraControl setAutoWhiteBalance:NO];
        [cameraControl setWhiteBalance:CamValue];
    }
    else if(iamCamCtrlType == "VideoProcAmp_BacklightCompensation")
    {
        [cameraControl setBacklight:CamValue];
    }
    else if(iamCamCtrlType == "VideoProcAmp_Gamma")
    {
        [cameraControl setGamma:CamValue];
    }
    else if(iamCamCtrlType == "CameraControl_LowLightCompensation" && CamValue == 1)
    {
        [cameraControl setlowlight:YES];
    }
    else if(iamCamCtrlType == "CameraControl_LowLightCompensation" && CamValue == 0)
    {
        [cameraControl setlowlight:NO];
    }
    else if(iamCamCtrlType == "VideoProcAmp_Hue" && isAuto == 1)
    {
        [cameraControl setAutoHue:YES];
    }
    else if(iamCamCtrlType == "VideoProcAmp_Hue" && isAuto == 2)
    {
        [cameraControl setAutoHue:NO];
        [cameraControl setHue:CamValue];
    }
    else if(iamCamCtrlType == "CameraControl_Zoom")
    {
        [cameraControl setZoom:CamValue];
    }
    else if(iamCamCtrlType == "CameraControl_Pan")
    {
        [cameraControl setPanTilt:CamValue withTilt:globaltitl];
        globalpan = [cameraControl getPan];
    }
    else if(iamCamCtrlType == "CameraControl_Tilt")
    {
        [cameraControl setPanTilt:globalpan withTilt:CamValue];
        globaltitl = [cameraControl getTilt];
    }
}
