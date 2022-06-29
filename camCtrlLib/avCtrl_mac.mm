#include "avCtrl_mac.h"

//std::string getmacCamList()
int getDeviceList(std::string* outresult)
{
    std::string strUID, strmodID, strLocaName;
    //NSString *strUID, *strmodID, *strLocaName;
    std::string reStr;
    int i = 0;
    NSArray* devs = [AVCaptureDevice devices];
    //NSLog(@"devices: %d\n", (int)[devs count]);
    for(AVCaptureDevice* d in devs) {
        outresult[i] = std::string([d.localizedName UTF8String]);
        outresult[i+1] = std::string([d.uniqueID UTF8String]);
        /*if ( strLocaName == "Kensington W2000 Full HD Auto Focus Webcam #2" )
        {
            //NSLog(@"uniqueID: %@\n", [d uniqueID]);
            //NSLog(@"modelID: %@\n", [d modelID]);
            //NSLog(@"description: %@\n", [d localizedName]);
            //reStr = "get";
            strUID = std::string([d.uniqueID UTF8String]);
            printf("UID:%s\n",strUID.c_str());
            return strUID;
        }
        else
        {
            //printf("No match!\n");
            reStr = "No match!";
        }*/
        //strUID = d.uniqueID;
        i = i + 2;
    }
    return i;
}