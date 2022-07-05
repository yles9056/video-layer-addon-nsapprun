﻿#include "iSerialNum.h"

#ifdef _WIN32
static char* GuidToString(const GUID& guid)
{
	int buf_len = 64;
	char* buf = (char*)malloc(buf_len);
	_snprintf(
		buf,
		buf_len,
		"{%08X-%04X-%04X-%02X%02X-%02X%02X%02X%02X%02X%02X}",
		guid.Data1, guid.Data2, guid.Data3,
		guid.Data4[0], guid.Data4[1],
		guid.Data4[2], guid.Data4[3],
		guid.Data4[4], guid.Data4[5],
		guid.Data4[6], guid.Data4[7]);
	//printf("%s\n",buf);
	return buf;
}

static BOOL GetParentDeviceInstanceId(_Out_ PWCHAR pszParentDeviceInstanceId, _Out_ PDEVINST phParentDeviceInstanceId, _In_ DEVINST hCurrentDeviceInstanceId) {

	// Handle to parent Device Instance ID
	BOOL result = CM_Get_Parent(phParentDeviceInstanceId, hCurrentDeviceInstanceId, 0);
	if (result == CR_SUCCESS) {

		// Device ID as String
		memset(pszParentDeviceInstanceId, 0, MAX_DEVICE_ID_LEN);
		result = CM_Get_Device_IDW(*phParentDeviceInstanceId, pszParentDeviceInstanceId, MAX_DEVICE_ID_LEN, 0);
		if (result == CR_SUCCESS) {
			return TRUE;
		}
	}

	return FALSE;
}

static std::string parseSerialNumber(std::string serialNumber)
{
	int k = (int)serialNumber.length() - 1;
	while (serialNumber[k] != '\\') k--;

	//std::string strTmp = serialNumber.substr((int)serialNumber.length() - k, (int)serialNumber.length());
	std::string strTmp = serialNumber.substr(k + 1, (int)serialNumber.length());
	//std::cout << "      Serial number is: " << strTmp << "\r\n";
	return strTmp;
}

static int CheckSerialNumber(std::string serialNumber)
{
	int result = 1;
	int k = (int)serialNumber.length() - 1;
	while (serialNumber[k] != '\\') k--;

	//std::string strTmp = serialNumber.substr((int)serialNumber.length() - k, (int)serialNumber.length());
	std::string strTmp = serialNumber.substr(k + 1, (int)serialNumber.length());
	std::cout << "      Serial number is: " << strTmp << "\r\n";

#if 0 // it's not Kensington webcam's parse rule
	if (serialNumber[k + 1] == 'C' && (serialNumber[k + 2] >= '0' && serialNumber[k + 2] <= '9') && (serialNumber[k + 3] == 'L' || serialNumber[k + 3] == 'R'))
	{
		int id = (serialNumber[k + 4] - '0') * 10 + (serialNumber[k + 5] - '0') * 2;
		if (serialNumber[k + 3] == 'R') id++;
		return id;
	}
	else
		return -1;//illegal
#endif
	return result;
}

//static int getSerialNumber(std::string childDistanceId)
int getSerialNumber(std::string childDistanceId)
{
	std::cout << "getSerialNumber(): The input id is: " << childDistanceId;
	USES_CONVERSION;
	// GUID to match devices by class
	GUID guid;
	CLSIDFromString(GUID_CAMERA_STRING, &guid);

	// Get matching devices info
	HDEVINFO devInfo = SetupDiGetClassDevs(&guid, NULL, NULL, DIGCF_PRESENT | DIGCF_DEVICEINTERFACE);// DIGCF_ALLCLASSES);

	// Device Instance ID as string
	WCHAR szDeviceInstanceId[MAX_DEVICE_ID_LEN];

	if (devInfo != INVALID_HANDLE_VALUE) {

		DWORD devIndex = 0;
		SP_DEVINFO_DATA devInfoData;
		devInfoData.cbSize = sizeof(SP_DEVINFO_DATA);

		// Loop over devices found in SetupDiGetClassDevs
		while (SetupDiEnumDeviceInfo(devInfo, devIndex, &devInfoData))
		{
			// Read Device Instance ID of current device
			memset(szDeviceInstanceId, 0, MAX_DEVICE_ID_LEN);
			SetupDiGetDeviceInstanceIdW(devInfo, &devInfoData, szDeviceInstanceId, MAX_PATH, 0);

			//compare the device's instanceId
			char* szDeviceInstId = W2A(szDeviceInstanceId);
			transform(childDistanceId.begin(), childDistanceId.end(), childDistanceId.begin(), ::toupper);

			std::string strDevID(szDeviceInstId);

			// 原作者使用的方式看起來不像USB的camera, 是以內建的camera為主的樣子，所以我們在解析字串的時候不能用UIDxxx來分析...
			//if (childDistanceId.compare(szDeviceInstId) == 0)
			if(strDevID.find(childDistanceId) != std::string::npos) // vv20210907
			{
				// Handle of current defice instance id
				DEVINST hCurrentDeviceInstanceId = devInfoData.DevInst;

				// Handle of parent Device Instance ID
				DEVINST hParentDeviceInstanceId;

				// Parent Device Instance ID as string
				WCHAR pszParentDeviceInstanceId[MAX_DEVICE_ID_LEN];

				// Initialize / clean variables
				memset(szDeviceInstanceId, 0, MAX_DEVICE_ID_LEN);
				hParentDeviceInstanceId = NULL;

				if (GetParentDeviceInstanceId(pszParentDeviceInstanceId, &hParentDeviceInstanceId, hCurrentDeviceInstanceId))
				{
					std::string parentDeviceInstanceId = W2A(pszParentDeviceInstanceId);

					return (CheckSerialNumber(parentDeviceInstanceId));

					//if (DeviceIdMatchesPattern(pszParentDeviceInstanceId, pszParentDeviceInstanceIdPattern)) {

					//	// Parent Device Instance ID matches given regexp - print it out and exit
					//	wprintf(L"%s\n", pszParentDeviceInstanceId);
					//	getchar();
					//	return 0;
					//}

					// Parent Device Instance ID does not match the pattern - check parent's parent
					//hCurrentDeviceInstanceId = hParentDeviceInstanceId;
					break;

				}
				else {
					// There is no parent. Stop the loop.
					break;
				}
			}
			devIndex++;
		}

	}

	return 0;
}
#else
std::string find_serial(int idLocation,int idVendor, int idProduct)
{
    std::string strSerial;
    char cSerial[256];
    CFMutableDictionaryRef matchingDictionary = IOServiceMatching(kIOUSBDeviceClassName);
    
    // Find All USB Devices, get their locationId and check if it matches the requested one
    CFMutableDictionaryRef matchingDict = IOServiceMatching(kIOUSBDeviceClassName);
    io_iterator_t serviceIterator;
    IOServiceGetMatchingServices( kIOMasterPortDefault, matchingDict, &serviceIterator );

    io_service_t camera;
    while( (camera = IOIteratorNext(serviceIterator)) )
    {
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
        if( currentLocationID == idLocation && currentVendorID == idVendor && currentProductID == idProduct)
        {
            //std::cout<<currentLocationID<<std::endl;
            std::cout<<"Math"<<std::endl;
                    
            if (IOServiceGetMatchingServices(kIOMasterPortDefault, matchingDictionary, &serviceIterator) == KERN_SUCCESS)
            {
                CFMutableDictionaryRef dict = NULL;
                if (IORegistryEntryCreateCFProperties(camera, &dict, kCFAllocatorDefault, kNilOptions) == KERN_SUCCESS )
                {
                    CFTypeRef obj = CFDictionaryGetValue(dict, CFSTR(kIOHIDSerialNumberKey));
                    if (!obj)
                    {
                        obj = CFDictionaryGetValue(dict, CFSTR(kUSBSerialNumberString));
                    }
                    if (obj)
                    {
                        //return CFStringCreateCopy(kCFAllocatorDefault, (CFStringRef)obj);
                        if(CFStringGetCString(CFStringCreateCopy(kCFAllocatorDefault, (CFStringRef)obj), cSerial, 256, CFStringGetSystemEncoding()))
                        {
                            strSerial = cSerial;
                            return strSerial;
                        }
                    }
                }
            }
        }
    } // end while
    strSerial = "No matching";
    return strSerial;
}
#endif

std::string getSNByPIDVID(std::string childDistanceId, std::string _PID, std::string _VID)
{
	//int iTmp;
	std::string retStr;
#ifdef _WIN32
	//std::cout << "getSNByPIDVID(): The input pid and vid is: " << _PID << ", " << _VID << "\r\n";
	USES_CONVERSION;	
	// GUID to match devices by class
	GUID guid;
	CLSIDFromString(GUID_CAMERA_STRING, &guid);

	// Get matching devices info
	HDEVINFO devInfo = SetupDiGetClassDevs(&guid, NULL, NULL, DIGCF_PRESENT | DIGCF_DEVICEINTERFACE);// DIGCF_ALLCLASSES);

	// Device Instance ID as string
	WCHAR szDeviceInstanceId[MAX_DEVICE_ID_LEN];

	if (devInfo != INVALID_HANDLE_VALUE) {

		DWORD devIndex = 0;
		SP_DEVINFO_DATA devInfoData;
		devInfoData.cbSize = sizeof(SP_DEVINFO_DATA);

		// Loop over devices found in SetupDiGetClassDevs
		while (SetupDiEnumDeviceInfo(devInfo, devIndex, &devInfoData))
		{
			// Read Device Instance ID of current device
			memset(szDeviceInstanceId, 0, MAX_DEVICE_ID_LEN);
			SetupDiGetDeviceInstanceIdW(devInfo, &devInfoData, szDeviceInstanceId, MAX_PATH, 0);

			//compare the device's instanceId
			char* szDeviceInstId = W2A(szDeviceInstanceId);
			transform(childDistanceId.begin(), childDistanceId.end(), childDistanceId.begin(), ::toupper);
			int k = 0;
			while (childDistanceId[k] != '{')
			{
				if (childDistanceId[k] == '#')
				{
					childDistanceId.erase(k, 1);
					childDistanceId.insert(k, "\\");
				}
				k++;
			}
			childDistanceId.erase(k - 1);	//remove all char in id > k
			//std::cout << "getSNByPIDVID() - the After replacement the childDistanceId: " << childDistanceId << "\r\n";

			std::string strDevID(szDeviceInstId);
			//std::cout << "getSNByPIDVID() - the strDevID: " << strDevID << "\r\n";

			// 原作者使用的方式看起來不像USB的camera, 是以內建的camera為主的樣子，所以我們在解析字串的時候不能用UIDxxx來分析...
			//if (childDistanceId.compare(szDeviceInstId) == 0)
			//if(strDevID.find(childDistanceId) != std::string::npos) // vv20210907
			if(childDistanceId.find(strDevID) != std::string::npos) // vv20210907
			//transform(_PID.begin(), _PID.end(), _PID.begin(), ::toupper);
			//transform(_VID.begin(), _VID.end(), _VID.begin(), ::toupper);
			//std::cout << "getSNByPIDVID(): Now the pid and vid became: " << _PID << ", " << _VID << "\r\n";
			//if(strDevID.find(_PID) != std::string::npos && 
			//   strDevID.find(_VID) != std::string::npos	) // vv20210907
			{
				// Handle of current defice instance id
				DEVINST hCurrentDeviceInstanceId = devInfoData.DevInst;

				// Handle of parent Device Instance ID
				DEVINST hParentDeviceInstanceId;

				// Parent Device Instance ID as string
				WCHAR pszParentDeviceInstanceId[MAX_DEVICE_ID_LEN];

				// Initialize / clean variables
				memset(szDeviceInstanceId, 0, MAX_DEVICE_ID_LEN);
				hParentDeviceInstanceId = NULL;

				if (GetParentDeviceInstanceId(pszParentDeviceInstanceId, &hParentDeviceInstanceId, hCurrentDeviceInstanceId))
				{
					std::string parentDeviceInstanceId = W2A(pszParentDeviceInstanceId);

					//return (CheckSerialNumber(parentDeviceInstanceId));
					//iTmp = CheckSerialNumber(parentDeviceInstanceId);
					retStr = parseSerialNumber(parentDeviceInstanceId);
					break;

				}
				else {
					// There is no parent. Stop the loop.
					break;
				}
			}
			devIndex++;
		}
	}
#else
	int iLocid = std::strtol(childDistanceId.c_str() , NULL, 16);
	int iVid = std::strtol(_VID.c_str() , NULL, 16);
	int iPid = std::strtol(_PID.c_str() , NULL, 16);
	retStr = find_serial(iLocid, iVid, iPid);
#endif
	return retStr;
}

#ifdef _WIN32
bool getCameraOrderBySerialNumber(std::vector<int>* order, int numOfCamera)
{
	int numOfFoundedCamera = 0;
	USES_CONVERSION;
	// Init COM
	HRESULT hr = NULL;
	hr = CoInitialize(NULL);
	if (FAILED(hr)) {
		printf("Error, Can not init COM.");
		return false;
	}
	//	printf("===============Directshow Filters ===============\n");
	ICreateDevEnum* pSysDevEnum = NULL;
	hr = CoCreateInstance(CLSID_SystemDeviceEnum, NULL, CLSCTX_INPROC_SERVER, IID_ICreateDevEnum, (void**)&pSysDevEnum);
	if (FAILED(hr)) {
		return hr;
	}

	IEnumMoniker* pEnumCat = NULL;
	//Category	
	/************************************************************************
	Friendly Name	                      CLSID
	-------------------------------------------------------------------------
	Audio Capture Sources	              CLSID_AudioInputDeviceCategory
	Audio Compressors	                  CLSID_AudioCompressorCategory
	Audio Renderers	                      CLSID_AudioRendererCategory
	Device Control Filters	              CLSID_DeviceControlCategory
	DirectShow Filters	                  CLSID_LegacyAmFilterCategory
	External Renderers	                  CLSID_TransmitCategory
	Midi Renderers	                      CLSID_MidiRendererCategory
	Video Capture Sources	              CLSID_VideoInputDeviceCategory
	Video Compressors	                  CLSID_VideoCompressorCategory
	WDM Stream Decompression Devices	  CLSID_DVDHWDecodersCategory
	WDM Streaming Capture Devices	      AM_KSCATEGORY_CAPTURE
	WDM Streaming Crossbar Devices	      AM_KSCATEGORY_CROSSBAR
	WDM Streaming Rendering Devices	      AM_KSCATEGORY_RENDER
	WDM Streaming Tee/Splitter Devices	  AM_KSCATEGORY_SPLITTER
	WDM Streaming TV Audio Devices	      AM_KSCATEGORY_TVAUDIO
	WDM Streaming TV Tuner Devices	      AM_KSCATEGORY_TVTUNER
	WDM Streaming VBI Codecs	          AM_KSCATEGORY_VBICODEC
	************************************************************************/
	//hr = pSysDevEnum->CreateClassEnumerator(CLSID_VideoCompressorCategory, &pEnumCat, 0);
	hr = pSysDevEnum->CreateClassEnumerator(CLSID_VideoInputDeviceCategory, &pEnumCat, 0);
	//hr = pSysDevEnum->CreateClassEnumerator(CLSID_AudioCompressorCategory, &pEnumCat, 0);
	//hr = pSysDevEnum->CreateClassEnumerator(CLSID_AudioInputDeviceCategory, &pEnumCat, 0);
	//hr = pSysDevEnum->CreateClassEnumerator(CLSID_MediaMultiplexerCategory, &pEnumCat, 0);
	//hr = pSysDevEnum->CreateClassEnumerator(CLSID_LegacyAmFilterCategory, &pEnumCat, 0);

	if (hr != S_OK) {
		pSysDevEnum->Release();
		return false;
	}

	// Obtain a class enumerator for the video input category.
	IMoniker* pMoniker = NULL;
	ULONG monikerFetched;
	int deviceCounter = 0;
	//Filter
	while (pEnumCat->Next(1, &pMoniker, &monikerFetched) == S_OK)
	{
		IPropertyBag* pPropBag;
		VARIANT varName;
		IBaseFilter* pFilter = NULL;
		hr = pMoniker->BindToStorage(0, 0, IID_IPropertyBag, (void**)&pPropBag);
		if (FAILED(hr))
		{
			pMoniker->Release();
			continue;
		}
		VariantInit(&varName);
		//		hr = pPropBag->Read(L"FriendlyName", &varName, 0);
		hr = pPropBag->Read(L"DevicePath", &varName, 0);

		//"FriendlyName": The name of the device.
		//"Description": A description of the device.
		//Filter Info================
		//修改格式使其和com產生的串格式對應
		bool kgt_cam_found = false;
		if (varName.bstrVal == NULL) { // Found nothing
			//std::cout << "Not get any string!!! Next one please!! \r\n";
			VariantClear(&varName);
			continue;
		}
		std::string varNameBak = W2A(varName.bstrVal);
#if 1
		if (varNameBak.find("vid_047d") != std::string::npos) {
			if (varNameBak.find("pid_80b3") != std::string::npos || // W2000
				(varNameBak.find("pid_80b4") != std::string::npos)   // W2050
				)
				std::cout << "Kensington cam: " << varNameBak << "\r\n";
				kgt_cam_found = true;
		}
		if (!kgt_cam_found) continue;
#endif
#if 1 // we're usb camera
		while (varNameBak[0] != 'u')
			varNameBak.erase(0, 1);//remove one char
		int k = 0;
		while (varNameBak[k] != '{')
		{
			if (varNameBak[k] == '#')
			{
				varNameBak.erase(k, 1);
				varNameBak.insert(k, "\\");
			}
			k++;
		}
		varNameBak.erase(k - 1);	//remove all char in id > k
#endif
		//printf("[%s]\n", W2A(varName.bstrVal));
		//cout << varNameBak << endl;

		int index = getSerialNumber(varNameBak);
		if (index != -1)
		{
			order->at(index) = deviceCounter;
			numOfFoundedCamera++;
		}

		VariantClear(&varName);

		pPropBag->Release();
		pMoniker->Release();
		deviceCounter++;
	}
	pEnumCat->Release();
	pSysDevEnum->Release();
	//printf("=================================================\n");
	CoUninitialize();

	//檢測所有攝像頭是否合法
	//ID連續且以組劃分
	if (numOfFoundedCamera == numOfCamera)
	{
		for (int i = 0; i < numOfCamera; i++)
			if (order->at(i) == -1) return false;
		return true;
	}
	else
	{
		return false;
	}
}
#endif
