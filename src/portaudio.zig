const std = @import("std");

// STRUCTS
pub const PaVersionInfo = extern struct {
    versionMajor: i32,
    versionMinor: i32,
    versionSubMinor: i32,
    versionControlRevision: [*:0]const u8,
    versionText: [*:0]const u8,
};
pub const PaHostApiInfo = extern struct {
    structVersion: i32,
    type: PaHostApiTypeId,
    name: [*:0]const u8,
    deviceCount: i32,
    defaultInputDevice: PaDeviceIndex,
    defaultOutputDevice: PaDeviceIndex,
};
pub const PaHostErrorInfo = extern struct {
    hostApiType: PaHostApiTypeId,
    errorCode: i64,
    errorText: [*:0]const u8,
};
pub const PaDeviceInfo = extern struct {
    structVersion: i32,
    name: [*:0]const u8,
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

pub const PaErrorType = i32;
pub const PaDeviceIndex = i32;
pub const PaHostApiIndex = i32;
pub const PaHostApiTypeId = enum(c_int) { _ };
pub const PaTime = f64;
pub const PaSampleFormat = u64;
pub const SampleFormat = enum(PaSampleFormat) {
    float32 = 0x1,
    int32 = 0x2,
    int24 = 0x4,
    int16 = 0x8,
    int8 = 0x10,
    uint8 = 0x20,
    custom = 0x00010000,
    nonInterleaved = 0x80000000,
};
pub const PaStream = anyopaque;
pub const PaStreamFlags = u64;
pub const StreamFlags = packed struct(PaStreamFlags) {
    clipOff: bool = false,
    ditherOff: bool = false,
    neverDropInput: bool = false,
    primeOutputBuffersUsingStreamCallback: bool = false,
    _b: u60 = 0,
};
pub const PaStreamCallbackFlags = u64;
pub const StreamCallbackFlags = packed struct(PaStreamCallbackFlags) {
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
) callconv(.c) i32;
pub const PaStreamFinishedCallback = fn (userData: ?*anyopaque) void;

fn ConvertError(code: PaErrorCode) ?PaError {
    return switch (code) {
        .paNoError => null,
        .paNotInitialized => PaError.notInitialized,
        .paUnanticipatedHostError => PaError.unanticipatedHostError,
        .paInvalidChannelCount => PaError.invalidChannelCount,
        .paInvalidSampleRate => PaError.invalidSampleRate,
        .paInvalidDevice => PaError.invalidDevice,
        .paInvalidFlag => PaError.invalidFlag,
        .paSampleFormatNotSupported => PaError.sampleFormatNotSupported,
        .paBadIODeviceCombination => PaError.badIODeviceCombination,
        .paInsufficientMemory => PaError.insufficientMemory,
        .paBufferTooBig => PaError.bufferTooBig,
        .paBufferTooSmall => PaError.bufferTooSmall,
        .paNullCallback => PaError.nullCallback,
        .paBadStreamPtr => PaError.badStreamPtr,
        .paTimedOut => PaError.timedOut,
        .paInternalError => PaError.internalError,
        .paDeviceUnavailable => PaError.deviceUnavailable,
        .paIncompatibleHostApiSpecificStreamInfo => PaError.incompatibleHostApiSpecificStreamInfo,
        .paStreamIsStopped => PaError.streamIsStopped,
        .paStreamIsNotStopped => PaError.streamIsNotStopped,
        .paInputOverflowed => PaError.inputOverflowed,
        .paOutputUnderflowed => PaError.outputUnderflowed,
        .paHostApiNotFound => PaError.hostApiNotFound,
        .paInvalidHostApi => PaError.invalidHostApi,
        .paCanNotReadFromACallbackStream => PaError.canNotReadFromACallbackStream,
        .paCanNotWriteToACallbackStream => PaError.canNotWriteToACallbackStream,
        .paCanNotReadFromAnOutputOnlyStream => PaError.canNotReadFromAnOutputOnlyStream,
        .paCanNotWriteToAnInputOnlyStream => PaError.canNotWriteToAnInputOnlyStream,
        .paIncompatibleStreamHostApi => PaError.incompatibleStreamHostApi,
        .paBadBufferPtr => PaError.badBufferPtr,
        else => PaError.unknownError,
    };
}
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
    _,
};
pub const PaError = error{
    notInitialized,
    unanticipatedHostError,
    invalidChannelCount,
    invalidSampleRate,
    invalidDevice,
    invalidFlag,
    sampleFormatNotSupported,
    badIODeviceCombination,
    insufficientMemory,
    bufferTooBig,
    bufferTooSmall,
    nullCallback,
    badStreamPtr,
    timedOut,
    internalError,
    deviceUnavailable,
    incompatibleHostApiSpecificStreamInfo,
    streamIsStopped,
    streamIsNotStopped,
    inputOverflowed,
    outputUnderflowed,
    hostApiNotFound,
    invalidHostApi,
    canNotReadFromACallbackStream,
    canNotWriteToACallbackStream,
    canNotReadFromAnOutputOnlyStream,
    canNotWriteToAnInputOnlyStream,
    incompatibleStreamHostApi,
    badBufferPtr,
    unknownError,
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
pub extern fn Pa_GetVersionText() [*:0]const u8;
pub extern fn Pa_GetVersionInfo() *const PaVersionInfo;
pub extern fn Pa_GetErrorText(errorCode: PaErrorType) [*:0]const u8;
pub extern fn Pa_Initialize() PaErrorType;
pub extern fn Pa_Terminate() PaErrorType;
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
) PaErrorType;
extern fn Pa_OpenStream(
    stream: **PaStream,
    inputParameters: *const PaStreamParameters,
    outputParameters: *const PaStreamParameters,
    sampleRate: f64,
    framesPerBuffer: u64,
    streamFlags: PaStreamFlags,
    streamCallback: *const PaStreamCallback,
    userData: ?*anyopaque,
) callconv(.c) PaErrorType;
extern fn Pa_OpenDefaultStream(
    stream: **PaStream,
    numInputChannels: i32,
    numOutputChannels: i32,
    sampleFormat: PaSampleFormat,
    sampleRate: f64,
    framesPerBuffer: u64,
    streamCallback: *const PaStreamCallback,
    userData: ?*anyopaque,
) callconv(.c) PaErrorType;
extern fn Pa_CloseStream(stream: *PaStream) PaErrorType;
extern fn Pa_SetStreamFinishedCallback(
    stream: *PaStream,
    streamFinishedCallback: *PaStreamFinishedCallback,
) PaErrorType;
extern fn Pa_StartStream(stream: *PaStream) PaErrorType;
extern fn Pa_StopStream(stream: *PaStream) PaErrorType;
extern fn Pa_AbortStream(stream: *PaStream) PaErrorType;
extern fn Pa_IsStreamStopped(stream: *PaStream) PaErrorType;
extern fn Pa_IsStreamActive(stream: *PaStream) PaErrorType;
extern fn Pa_GetStreamInfo(stream: *PaStream) *const PaStreamInfo;
extern fn Pa_GetStreamTime(stream: *PaStream) PaTime;
extern fn Pa_GetStreamCpuLoad(stream: *PaStream) f64;
extern fn Pa_ReadStream(stream: *PaStream, buffer: ?*anyopaque, frames: u64) PaErrorType;
extern fn Pa_WriteStream(stream: *PaStream, buffer: ?*const anyopaque, frames: u64) PaErrorType;
extern fn Pa_GetStreamReadAvailable(stream: *PaStream) i64;
extern fn Pa_GetStreamWriteAvailable(stream: *PaStream) i64;
pub extern fn Pa_GetSampleSize(format: PaSampleFormat) PaErrorType;
pub extern fn Pa_Sleep(msec: i64) void;

// wrapper for functions
pub const Stream = struct {
    handle: *PaStream,

    pub fn init(args: struct {
        inputParameters: *const PaStreamParameters,
        outputParameters: *const PaStreamParameters,
        sampleRate: f64,
        framesPerBuffer: u64,
        streamFlags: StreamFlags = .{},
        streamCallback: *const PaStreamCallback,
        userData: ?*anyopaque = null,
    }) !Stream {
        var s = Stream{ .handle = undefined };
        const err = Pa_OpenStream(
            &s.handle,
            args.inputParameters,
            args.outputParameters,
            args.sampleRate,
            args.framesPerBuffer,
            @bitCast(args.streamFlags),
            args.streamCallback,
            args.userData,
        );
        if (ConvertError(@enumFromInt(err))) |e| {
            return e;
        }
        return s;
    }

    pub fn initDefault(args: struct {
        numInputChannels: i32,
        numOutputChannels: i32,
        sampleFormat: SampleFormat,
        sampleRate: f64,
        framesPerBuffer: u64,
        streamFlags: StreamFlags = .{},
        streamCallback: *PaStreamCallback,
        userData: ?*anyopaque = null,
    }) PaError!Stream {
        var s = Stream{ .handle = undefined };
        const err = Pa_OpenDefaultStream(
            &s.handle,
            args.numInputChannels,
            args.numOutputChannels,
            @intFromEnum(args.sampleFormat),
            args.sampleRate,
            args.framesPerBuffer,
            args.streamCallback,
            args.userData,
        );
        if (ConvertError(@enumFromInt(err))) |e| {
            return e;
        }
        return s;
    }

    pub fn deinit(self: Stream) void {
        const err = Pa_CloseStream(self.handle);
        if (ConvertError(@enumFromInt(err))) |e| {
            std.log.err("Failed to close PaStream: {}", .{e});
        }
    }

    pub fn setStreamFinishedCallback(self: Stream, streamFinishedCallback: *PaStreamFinishedCallback) PaError!void {
        const err = Pa_SetStreamFinishedCallback(self.handle, streamFinishedCallback);
        if (ConvertError(@enumFromInt(err))) |e| return e;
    }
    pub fn startStream(self: Stream) PaError!void {
        const err = Pa_StartStream(self.handle);
        if (ConvertError(@enumFromInt(err))) |e| return e;
    }
    pub fn stopStream(self: Stream) PaError!void {
        const err = Pa_StopStream(self.handle);
        if (ConvertError(@enumFromInt(err))) |e| return e;
    }
    pub fn abortStream(self: Stream) PaError!void {
        const err = Pa_AbortStream(self.handle);
        if (ConvertError(@enumFromInt(err))) |e| return e;
    }
    pub fn isStreamStopped(self: Stream) PaError!bool {
        const err = Pa_IsStreamStopped(self.handle);
        if (err == 0) return false;
        if (err == 1) return true;
        if (ConvertError(@enumFromInt(err))) |e| return e;
        return PaError.unknownError;
    }
    pub fn isStreamActive(self: Stream) PaError!bool {
        const err = Pa_IsStreamActive(self.handle);
        if (err == 0) return false;
        if (err == 1) return true;
        if (ConvertError(@enumFromInt(err))) |e| return e;
        return PaError.unknownError;
    }
    pub fn getStreamInfo(self: Stream) *const PaStreamInfo {
        return Pa_GetStreamInfo(self.handle);
    }
    pub fn getStreamTime(self: Stream) PaTime {
        return Pa_GetStreamTime(self.handle);
    }
    pub fn getStreamCpuLoad(self: Stream) f64 {
        return Pa_GetStreamCpuLoad(self.handle);
    }
    pub fn readStream(self: Stream, buffer: ?*anyopaque, frames: u64) PaError!void {
        const err = Pa_ReadStream(self.handle, buffer, frames);
        if (ConvertError(@enumFromInt(err))) |e| return e;
    }
    pub fn writeStream(self: Stream, buffer: ?*const anyopaque, frames: u64) PaError!void {
        const err = Pa_WriteStream(self.handle, buffer, frames);
        if (ConvertError(@enumFromInt(err))) |e| return e;
    }
    pub fn getStreamReadAvailable(self: Stream) i64 {
        return Pa_GetStreamReadAvailable(self.handle);
    }
    pub fn getStreamWriteAvailable(self: Stream) i64 {
        return Pa_GetStreamWriteAvailable(self.handle);
    }
};
