// STRUCTS
pub const PaVersionInfo = extern struct {
    versionMajor: i32,
    versionMinor: i32,
    versionSubMinor: i32,
    versionControlRevision: *const c_char,
    versionText: *const c_char,
};
pub const PaHostApiInfo = extern struct {
    structVersion: i32,
    type: PaHostApiTypeId,
    name: *const c_char,
    deviceCount: i32,
    defaultInputDevice: PaDeviceIndex,
    defaultOutputDevice: PaDeviceIndex,
};
pub const PaHostErrorInfo = extern struct {
    hostApiType: PaHostApiTypeId,
    errorCode: i64,
    errorText: *const c_char,
};
pub const PaDeviceInfo = extern struct {
    structVersion: i32,
    name: *const c_char,
    hostApi: PaHostApiIndex,
    maxInputChannels: i32,
    maxOutputChannels: i32,
    defaultLowInputLatency: PaTime,
    defaultLowOutputLatency: PaTime,
    defaultHighInputLatency: PaTime,
    defaultHighOutputLatency: PaTime,
    defaultSampleRate: f64,
};
pub const PaStreamParameters = extern struct {
    device: PaDeviceIndex,
    channelCount: i32,
    sampleFormat: PaSampleFormat,
    suggestedLatency: PaTime,
    hostApiSpecificStreamInfo: ?*anyopaque,
};
pub const PaStreamCallbackTimeInfo = extern struct {
    inputBufferAdcTime: PaTime,
    currentTime: PaTime,
    outputBufferDacTime: PaTime,
};
pub const PaStreamInfo = extern struct {
    structVersion: i32,
    inputLatency: PaTime,
    outputLatency: PaTime,
    sampleRate: f64,
};

pub const PaError = i32;
pub const PaDeviceIndex = i32;
pub const PaDeviceIndexE = enum(i32) {
    float32 = 0x1,
    int32 = 0x2,
    int24 = 0x4,
    int16 = 0x8,
    int8 = 0x10,
    uint8 = 0x20,
    custom = 0x00010000,
    nonInterleaved = 0x80000000,
};
pub const PaHostApiIndex = i32;
pub const PaHostApiTypeId = enum(c_int) {};
pub const PaTime = f64;
pub const PaSampleFormat = u64;
pub const PaStream = anyopaque;
pub const PaStreamFlags = u64;
pub const PaStreamFlagsE = packed struct(PaStreamFlags) {
    clipOff: bool = false,
    ditherOff: bool = false,
    neverDropInput: bool = false,
    primeOutputBuffersUsingStreamCallback: bool = false,
    _b: u60 = 0,
};
pub const PaStreamCallbackFlags = u64;
pub const PaStreamCallbackFlagsE = packed struct(PaStreamCallbackFlags) {
    inputUnderflow: bool = false,
    inputOverflow: bool = false,
    outputUnderflow: bool = false,
    outputOverflow: bool = false,
    primingOutput: bool = false,
    _b: u59 = 0,
};
pub const PaStreamCallback = fn (
    input: ?*const anyopaque,
    output: ?*anyopaque,
    frameCount: u64,
    timeInfo: *const PaStreamCallbackTimeInfo,
    statusFlags: PaStreamCallbackFlags,
    userData: ?*anyopaque,
) i32;
pub const PaStreamFinishedCallback = fn (userData: ?*anyopaque) void;

pub const PaErrorCode = enum(c_int) {
    paNoError = 0,
    paNotInitialized = -10000,
    paUnanticipatedHostError,
    paInvalidChannelCount,
    paInvalidSampleRate,
    paInvalidDevice,
    paInvalidFlag,
    paSampleFormatNotSupported,
    paBadIODeviceCombination,
    paInsufficientMemory,
    paBufferTooBig,
    paBufferTooSmall,
    paNullCallback,
    paBadStreamPtr,
    paTimedOut,
    paInternalError,
    paDeviceUnavailable,
    paIncompatibleHostApiSpecificStreamInfo,
    paStreamIsStopped,
    paStreamIsNotStopped,
    paInputOverflowed,
    paOutputUnderflowed,
    paHostApiNotFound,
    paInvalidHostApi,
    paCanNotReadFromACallbackStream,
    paCanNotWriteToACallbackStream,
    paCanNotReadFromAnOutputOnlyStream,
    paCanNotWriteToAnInputOnlyStream,
    paIncompatibleStreamHostApi,
    paBadBufferPtr,
};

pub const paHostApiTypeId = enum(c_int) {
    paInDevelopment = 0,
    paDirectSound = 1,
    paMME = 2,
    paASIO = 3,
    paSoundManager = 4,
    paCoreAudio = 5,
    paOSS = 7,
    paALSA = 8,
    paAL = 9,
    paBeOS = 10,
    paWDMKS = 11,
    paJACK = 12,
    paWASAPI = 13,
    paAudioScienceHPI = 14,
};

pub const PaStreamCallbackResult = enum(c_int) {
    paContinue = 0,
    paComplete = 1,
    paAbort = 2,
};

pub extern fn Pa_GetVersion() i32;
pub extern fn Pa_GetVersionText() *const c_char;
pub extern fn Pa_GetVersionInfo() *const PaVersionInfo;
pub extern fn Pa_GetErrorText(errorCode: PaError) *const c_char;
pub extern fn Pa_Initialize() PaError;
pub extern fn Pa_Terminate() PaError;
pub extern fn Pa_GetHostApiCount() PaHostApiIndex;
pub extern fn Pa_GetDefaultHostApi() PaHostApiIndex;
pub extern fn Pa_GetHostApiInfo(hostApi: PaHostApiIndex) *const PaHostApiInfo;
pub extern fn Pa_HostApiTypeIdToHostApiIndex(type: PaHostApiTypeId) PaHostApiIndex;
pub extern fn Pa_HostApiDeviceIndexToDeviceIndex(
    hostApi: PaHostApiIndex,
    hostApiDeviceIndex: i32,
) PaDeviceIndex;
pub extern fn Pa_GetLastHostErrorInfo() *const PaHostErrorInfo;
pub extern fn Pa_GetDeviceCount() PaDeviceIndex;
pub extern fn Pa_GetDefaultInputDevice() PaDeviceIndex;
pub extern fn Pa_GetDefaultOutputDevice() PaDeviceIndex;
pub extern fn Pa_GetDeviceInfo(device: PaDeviceIndex) *const PaDeviceInfo;
pub extern fn Pa_IsFormatSupported(
    inputParameters: *const PaStreamParameters,
    outputParameters: *const PaStreamParameters,
    sampleRate: f64,
) PaError;
pub extern fn Pa_OpenStream(
    stream: **PaStream,
    inputParameters: *const PaStreamParameters,
    outputParameters: *const PaStreamParameters,
    sampleRate: f64,
    framesPerBuffer: u64,
    streamFlags: PaStreamFlags,
    streamCallback: *PaStreamCallback,
    userData: ?*anyopaque,
) PaError;
pub extern fn Pa_OpenDefaultStream(
    stream: **PaStream,
    numInputChannels: i32,
    numOutputChannels: i32,
    sampleFormat: PaSampleFormat,
    sampleRate: f64,
    framesPerBuffer: u64,
    streamCallback: *PaStreamCallback,
    userData: ?*anyopaque,
) PaError;
pub extern fn Pa_CloseStream(stream: *PaStream) PaError;
pub extern fn Pa_SetStreamFinishedCallback(
    stream: *PaStream,
    streamFinishedCallback: *PaStreamFinishedCallback,
) PaError;
pub extern fn Pa_StartStream(stream: *PaStream) PaError;
pub extern fn Pa_StopStream(stream: *PaStream) PaError;
pub extern fn Pa_AbortStream(stream: *PaStream) PaError;
pub extern fn Pa_IsStreamStopped(stream: *PaStream) PaError;
pub extern fn Pa_IsStreamActive(stream: *PaStream) PaError;
pub extern fn Pa_GetStreamInfo(stream: *PaStream) *const PaStreamInfo;
pub extern fn Pa_GetStreamTime(stream: *PaStream) PaTime;
pub extern fn Pa_GetStreamCpuLoad(stream: *PaStream) f64;
pub extern fn Pa_ReadStream(stream: *PaStream, buffer: ?*anyopaque, frames: u64) PaError;
pub extern fn Pa_WriteStream(stream: *PaStream, buffer: ?*const anyopaque, frames: u64) PaError;
pub extern fn Pa_GetStreamReadAvailable(stream: *PaStream) i64;
pub extern fn Pa_GetStreamWriteAvailable(stream: *PaStream) i64;
pub extern fn Pa_GetSampleSize(format: PaSampleFormat) PaError;
pub extern fn Pa_Sleep(msec: i64) void;
