#import <Foundation/Foundation.h>

#include <CoreFoundation/CoreFoundation.h>

#include <IOKit/IOKitLib.h>
#include <IOKit/IOMessage.h>
#include <IOKit/IOCFPlugIn.h>
#include <IOKit/usb/IOUSBLib.h>
#include <iostream>
#include <string.h>
#include <math.h>


#define UVC_INPUT_TERMINAL_ID 0x01
#define UVC_PROCESSING_UNIT_ID 0x02

#define UVC_CONTROL_INTERFACE_CLASS 14
#define UVC_CONTROL_INTERFACE_SUBCLASS 1

#define UVC_SET_CUR    0x01
#define UVC_GET_CUR    0x81
#define UVC_GET_MIN    0x82
#define UVC_GET_MAX    0x83
#define UVC_GET_RES    0x84 //step size
#define UVC_GET_INFO   0x86
#define UVC_GET_DEF    0x87

typedef struct {
    int min, max, stepsize, def;
} uvc_range_t;

typedef struct {
    int pan, tilt;
} uvc_pantilt_t;

typedef struct {
    int panmin, tiltmin, panmax, tiltmax, panstepsize, tiltstepsize, pandef, tiltdef ;
} uvc_ptrange_t;

typedef struct {
	int unit;
	int selector;
	int size;
} uvc_control_info_t;

typedef struct {
    uvc_control_info_t autoExposure;
    uvc_control_info_t exposure;
    uvc_control_info_t absoluteFocus;
    uvc_control_info_t autoFocus;
    uvc_control_info_t focus;
    uvc_control_info_t zoom;
    uvc_control_info_t brightness;
    uvc_control_info_t contrast;
    uvc_control_info_t gain;
    uvc_control_info_t saturation;
    uvc_control_info_t sharpness;
    uvc_control_info_t whiteBalance;
    uvc_control_info_t autoWhiteBalance;
    uvc_control_info_t incremental_exposure;
    uvc_control_info_t backlight;
    uvc_control_info_t gamma;
    uvc_control_info_t lowlight;
    uvc_control_info_t hue;
    uvc_control_info_t autoHue;
    uvc_control_info_t pantilt;
} uvc_controls_t ;

@interface UVCCameraControl : NSObject {
    long dataBuffer;
    IOUSBInterfaceInterface190 **interface;
    //IOUSBInterfaceInterface942 **interface;

    long interfaceNum;
}
@end

void initCameraControl(UInt32 iLocid, long iVid, long iPid);
void getCamRange(int iLocid, std::string iamCamCtrlType, double* outresult);
void getCamValue(int iLocid, std::string iamCamCtrlType, double* outresult);
void setCamValue(int iLocid,std::string iamCamCtrlType,double CamValue,int isAuto);
