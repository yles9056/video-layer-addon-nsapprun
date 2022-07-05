#include <node.h>
#include <nan.h>
#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <sstream>
//#include <Windows.h>  mac
#ifdef _WIN32
#include <dshow.h>
#include <setupapi.h> 
#include <hidsdi.h>
#include <hidpi.h>
#include <strmif.h>
#else
#include "uvcCamCtrl_mac.h"
#include "avCtrl_mac.h"
#endif
#include "iSerialNum.h"
#include <cstdlib>
#include <string>
#include <vector>

#include <regex>

#define MAX_STRING_SIZE 256

using namespace std;

namespace uvcCamCtrl
{
    static std::string reSortDevPath(std::string inputStr);
}