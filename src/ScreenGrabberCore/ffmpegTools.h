#pragma once
#include <QObject>
#include <QMap>
#include <QVariantHash>

extern "C" {

#define __STDC_CONSTANT_MACROS

#ifndef INT64_C
#define INT64_C(c) (c ## LL)
#define UINT64_C(c) (c ## ULL)
#endif

#include "libavcodec/avcodec.h"
#include "libavutil/channel_layout.h"
#include "libavutil/common.h"
#include "libavutil/imgutils.h"
#include "libavutil/mathematics.h"
#include "libavutil/samplefmt.h"
#include "libavformat/avformat.h"
#include "libavformat/avio.h"
#include "libswscale/swscale.h"
#include "libavutil/pixfmt.h"
#include "libavutil/opt.h"
#include "libavutil/hwcontext.h"
}

const QString DEFAULT_DECODER_FFMPEG = "FFmpeg";
const QString QTAV_DECODER_FFMPEG = "FFmpeg";
const QString QTAV_DECODER_DXVA = "DXVA";
const QString QTAV_DECODER_CUDA = "CUDA";
const QString QTAV_DECODER_VDA = "VDA";
const QString QTAV_DECODER_VAAPI = "VAAPI";
const QString QTAV_DECODER_CEDARV = "Cedarv";


enum class VideoDecoder {
	Undefined = -1,
	FFmpeg_default = 0,
	QtAV_FFmpeg,
	QtAV_DXVA,
	QtAV_CUDA,
	QtAV_VDA,
	QtAV_VAAPI,
	QtAV_Cedarv
};

struct ffmpegTools
{

enum VideoSpeed {
	x14,
	x12,
	autoVal,
	x2,
	x4
};

struct DecoderSettings
{
	VideoDecoder decoderId = VideoDecoder::FFmpeg_default;
	QString decoderName;
	QVariantHash options;
};

struct QtAVEncodeParams
{
	QStringList srcFiles;
	QString dstFileName;
	int bitrate = 8 * 1024 * 1024;	//8Mbps
};

static AVHWAccel* findHwAccel(AVCodecID codec_id, AVPixelFormat pix_fmt);
static void freeFrameDeep(AVFrame* pFrame);
static void freeFrame(AVFrame* pFrame);
static AVPixelFormat find_fmt_by_hw_type(const AVHWDeviceType type);
static AVHWDeviceType find_hw_type_by_fmt(const AVPixelFormat fmt);
static AVPixelFormat find_sw_fmt_by_hw_type(const AVHWDeviceType type);
static bool find_sps_pps(const QByteArray& frame);

static QMap<VideoDecoder, QString> allDecoders();
static QList<DecoderSettings> availableDecoders();
static QString defaultDecoder();
static QString getDecoderName(const VideoDecoder& dType);
static QList<VideoDecoder> recommendedDecoder();
static QVariantHash getAllDecoderOptions(const VideoDecoder& decoderID);

static DecoderSettings getOptimizeDecoder();
static int showAvailablecodecs();
};
