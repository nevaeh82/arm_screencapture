#include <QMetaProperty>
#include <QtAV/VideoDecoder.h>
#include <iostream>

#include "ffmpegTools.h"

AVHWAccel* ffmpegTools::findHwAccel(AVCodecID codec_id, AVPixelFormat pix_fmt)
{
	AVHWAccel* hwaccel = nullptr;

	while ((hwaccel= av_hwaccel_next(hwaccel))) {
		if (hwaccel->id == codec_id	&& hwaccel->pix_fmt == pix_fmt) {
			return hwaccel;
		}
	}

	return nullptr;
}

void ffmpegTools::freeFrameDeep(AVFrame* pFrame)
{
	if (pFrame != nullptr) {
		av_freep(&pFrame->data[0]);
		freeFrame(pFrame);
	}
}

void ffmpegTools::freeFrame(AVFrame* pFrame)
{
	if (pFrame != nullptr) {
		av_frame_unref(pFrame);
		av_frame_free(&pFrame);
		pFrame = nullptr;
	}
}

AVPixelFormat ffmpegTools::find_fmt_by_hw_type(const AVHWDeviceType type)
{
	AVPixelFormat fmt;

	switch (type) {
		case AV_HWDEVICE_TYPE_VAAPI:
			fmt = AV_PIX_FMT_VAAPI;
			break;
		case AV_HWDEVICE_TYPE_DXVA2:
			fmt = AV_PIX_FMT_DXVA2_VLD;
			break;
		case AV_HWDEVICE_TYPE_VDPAU:
			fmt = AV_PIX_FMT_VDPAU;
			break;
		case AV_HWDEVICE_TYPE_CUDA:
			fmt = AV_PIX_FMT_CUDA;
			break;
		default:
			fmt = AV_PIX_FMT_NONE;
			break;
	}

	return fmt;
}

AVHWDeviceType ffmpegTools::find_hw_type_by_fmt(const AVPixelFormat fmt)
{
	AVHWDeviceType hw_type;

	switch (fmt) {
		case AV_PIX_FMT_VAAPI:
			hw_type = AV_HWDEVICE_TYPE_VAAPI;
			break;
		case AV_PIX_FMT_DXVA2_VLD:
			hw_type = AV_HWDEVICE_TYPE_DXVA2;
			break;
		case AV_PIX_FMT_VDPAU:
			hw_type = AV_HWDEVICE_TYPE_VDPAU;
			break;
		case AV_PIX_FMT_CUDA:
			hw_type = AV_HWDEVICE_TYPE_CUDA;
			break;
		default:
			hw_type = AV_HWDEVICE_TYPE_DXVA2;
			break;
	}

	return hw_type;
}

AVPixelFormat ffmpegTools::find_sw_fmt_by_hw_type(const AVHWDeviceType type)
{
	AVPixelFormat fmt;

	switch (type)
	{
		case AV_HWDEVICE_TYPE_DXVA2:
			fmt = AV_PIX_FMT_NV12;
			break;
		case AV_HWDEVICE_TYPE_VDPAU:
			fmt = AV_PIX_FMT_NV12;
			break;
		default:
			fmt = AV_PIX_FMT_NONE;
			break;
	}

	return fmt;
}

bool ffmpegTools::find_sps_pps(const QByteArray& frame)
{
	if (frame.isEmpty()) {
		return false;
	}

	//[NOTE]: part of this code was copied from vlc
	const int START_CODE_SIZE = 4;
	const int SPS_CODE = 7;
	const int PPS_CODE = 8;
	const uint8_t* p_buffer = reinterpret_cast<const uint8_t*>(frame.data());
	int i_buffer = frame.size();
	bool spsFound = false;
	bool ppsFound = false;

	while (i_buffer > START_CODE_SIZE && !(spsFound && ppsFound)) {

		int i_offset = 0;
		int i_size   = 0;

		while (p_buffer[0] != 0 || p_buffer[1] != 0 || p_buffer[2] != 1) {
			++p_buffer;
			--i_buffer;
			if (i_buffer == 0) {
				break;
			}
		}

		if (i_buffer < START_CODE_SIZE || memcmp(p_buffer, "\x00\x00\x01", 3) != 0)	{
			/* No startcode found.. */
			break;
		}

		p_buffer += 3;
		i_buffer -= 3;

		const int i_nal_type = p_buffer[0] & 0x1f;
		i_size = i_buffer;
		for (i_offset = 0; i_offset + 2 < i_buffer; ++i_offset) {
			if (!memcmp(p_buffer + i_offset, "\x00\x00\x01", 3)) {
				/* we found another startcode */
				while (i_offset > 0 && 0 == p_buffer[i_offset - 1]) {
					i_offset--;
				}
				i_size = i_offset;
				break;
			}
		}

		if (i_size == 0) {
			/* No-info found in nal */
			continue;
		}

		if (i_nal_type == SPS_CODE) {
			spsFound = true;
		}
		else if (i_nal_type == PPS_CODE) {
			ppsFound = true;
		}
		i_buffer -= i_size;
		p_buffer += i_size;
	}

	return spsFound && ppsFound;
}

QString ffmpegTools::getDecoderName(const VideoDecoder& dType)
{
	auto decoders = availableDecoders();
	for (const auto& settings: decoders) {
		if (settings.decoderId == dType) {
//			log_info(QString("Video decoder name: %1").arg(settings.decoderName));
			return settings.decoderName;
		}
	}

	auto recommended = getOptimizeDecoder();
	//log_warning(QString("Invalid video decoder name: %1").arg(static_cast<int>(dType)));
	//log_warning(QString("Reset video decoder name to default: %1").arg(recommended.decoderName));

	return recommended.decoderName;
}

QMap<VideoDecoder, QString> ffmpegTools::allDecoders()
{
	static const QMap<VideoDecoder, QString> ALL_DECODERS = {{VideoDecoder::FFmpeg_default, DEFAULT_DECODER_FFMPEG},
															 {VideoDecoder::QtAV_FFmpeg, QTAV_DECODER_FFMPEG},
															 {VideoDecoder::QtAV_DXVA, QTAV_DECODER_DXVA},
															 {VideoDecoder::QtAV_CUDA, QTAV_DECODER_CUDA},
															 {VideoDecoder::QtAV_VDA, QTAV_DECODER_VDA},
															 {VideoDecoder::QtAV_VAAPI, QTAV_DECODER_VAAPI},
															 {VideoDecoder::QtAV_Cedarv, QTAV_DECODER_CEDARV}};
	return ALL_DECODERS;
}

QList<ffmpegTools::DecoderSettings> ffmpegTools::availableDecoders()
{
	static QList<DecoderSettings> AVAILABLE_DECODERS;
	if (!AVAILABLE_DECODERS.isEmpty()) {
		return AVAILABLE_DECODERS;
	}

	auto decoders = allDecoders();
	for (auto it = decoders.begin(); it != decoders.end(); ++it) {
		DecoderSettings settings;
		settings.decoderId = it.key();
		settings.decoderName = it.value();
		if (it.key() == VideoDecoder::FFmpeg_default) {
			settings.options.insert("tooltip", QObject::tr("Default ffmpeg decoder"));
			AVAILABLE_DECODERS.push_back(settings);
			continue;
		}
		auto decoder = QtAV::VideoDecoder::create(it.value().toLatin1().constData());
		if (decoder && decoder->isAvailable()) {
			const QMetaObject* mo = decoder->metaObject();
			for (int i = 0; i < mo->propertyCount(); ++i) {
				QMetaProperty mp = mo->property(i);
				QVariant v(mp.read(decoder));
				if (mp.isEnumType()) {
					settings.options.insert(QString::fromLatin1(mp.name()), v.toInt());
				} else {
					settings.options.insert(QString::fromLatin1(mp.name()), v);
				}
			}
			settings.options.remove("objectName");
			settings.options.insert("tooltip", decoder->description());
			AVAILABLE_DECODERS.push_back(settings);
			delete decoder;
		}
	}

	return AVAILABLE_DECODERS;
}

QString ffmpegTools::defaultDecoder()
{
	auto decoders = availableDecoders();
	auto recommended = getOptimizeDecoder();
	for (const auto& settings: decoders) {
		if (settings.decoderId == recommended.decoderId) {
			return settings.decoderName;
		}
	}

	return QTAV_DECODER_FFMPEG;
}

QList<VideoDecoder> ffmpegTools::recommendedDecoder()
{
	QList<VideoDecoder> outList;
	auto decoders = availableDecoders();
	for (auto it = decoders.cbegin(); it != decoders.cend(); ++it) {
		if (it->decoderId != VideoDecoder::QtAV_FFmpeg && it->decoderId != VideoDecoder::FFmpeg_default) {
			outList << it->decoderId;
		}
	}

	if (!outList.isEmpty()) {
		return outList;
	}

	return {VideoDecoder::QtAV_FFmpeg};
}

QVariantHash ffmpegTools::getAllDecoderOptions(const VideoDecoder& decoderID)
{
	auto decoders = availableDecoders();
	for (const auto& settings: decoders) {
		if (settings.decoderId == decoderID) {
			return settings.options;
		}
	}

	return QVariantHash();
}

ffmpegTools::DecoderSettings ffmpegTools::getOptimizeDecoder()
{
	static QList<VideoDecoder> priorityDecoders = {VideoDecoder::QtAV_CUDA,
												   VideoDecoder::QtAV_DXVA,
												   VideoDecoder::QtAV_VDA,
												   VideoDecoder::QtAV_VAAPI,
												   VideoDecoder::QtAV_Cedarv,
												   VideoDecoder::QtAV_FFmpeg,
												   VideoDecoder::FFmpeg_default };

	DecoderSettings outSettings;
	auto decoders = availableDecoders();
	for (auto decoderId: priorityDecoders) {

		bool isFound = false;
		for (const auto& settings: decoders) {
			if (settings.decoderId == decoderId) {
				outSettings = settings;
				outSettings.options.remove("tooltip");
				isFound = true;
				break;
			}
		}

		if (isFound) {
			break;
		}
	}

	return outSettings;
}

//-----------------------------------------------------------------------------//
//--------------------this code was copied from ffmpeg ------------------------//
//-----------------------------------------------------------------------------//
static int compare_codec_desc(const void *a, const void *b)
{
	auto da = (const AVCodecDescriptor * const *)a;
	auto db = (const AVCodecDescriptor * const *)b;

	return (*da)->type != (*db)->type ? FFDIFFSIGN((*da)->type, (*db)->type) :
		   strcmp((*da)->name, (*db)->name);
}

static unsigned get_codecs_sorted(const AVCodecDescriptor ***rcodecs)
{
	const AVCodecDescriptor *desc = NULL;
	const AVCodecDescriptor **codecs;
	unsigned nb_codecs = 0, i = 0;

	while ((desc = avcodec_descriptor_next(desc)))
		nb_codecs++;
	if (!(codecs = (const AVCodecDescriptor **)av_calloc(nb_codecs, sizeof(*codecs)))) {
		//av_log(NULL, AV_LOG_ERROR, "Out of memory\n");
		return 0;
	}
	desc = NULL;
	while ((desc = avcodec_descriptor_next(desc))) {
		codecs[i++] = desc;
	}
	//av_assert0(i == nb_codecs);
	qsort(codecs, nb_codecs, sizeof(*codecs), compare_codec_desc);
	*rcodecs = codecs;
	return nb_codecs;
}

static const AVCodec *next_codec_for_id(enum AVCodecID id, const AVCodec *prev,
										int encoder)
{
	while ((prev = av_codec_next(prev))) {
		if (prev->id == id &&
			(encoder ? av_codec_is_encoder(prev) : av_codec_is_decoder(prev)))
			return prev;
	}
	return NULL;
}

static void print_codecs_for_id(enum AVCodecID id, int encoder)
{
	const AVCodec *codec = NULL;

	printf(" (%s: ", encoder ? "encoders" : "decoders");

	while ((codec = next_codec_for_id(id, codec, encoder))) {
		printf("%s ", codec->name);
	}

	printf(")");
}

static char get_media_type_char(enum AVMediaType type)
{
	switch (type) {
		case AVMEDIA_TYPE_VIDEO:    return 'V';
		case AVMEDIA_TYPE_AUDIO:    return 'A';
		case AVMEDIA_TYPE_DATA:     return 'D';
		case AVMEDIA_TYPE_SUBTITLE: return 'S';
		case AVMEDIA_TYPE_ATTACHMENT:return 'T';
		default:                    return '?';
	}
}

int ffmpegTools::showAvailablecodecs()
{
	const AVCodecDescriptor **codecs;
	unsigned i, nb_codecs = get_codecs_sorted(&codecs);

	printf("Codecs:\n"
		   " D..... = Decoding supported\n"
		   " .E.... = Encoding supported\n"
		   " ..V... = Video codec\n"
		   " ..A... = Audio codec\n"
		   " ..S... = Subtitle codec\n"
		   " ...I.. = Intra frame-only codec\n"
		   " ....L. = Lossy compression\n"
		   " .....S = Lossless compression\n"
		   " -------\n");
	for (i = 0; i < nb_codecs; i++) {
		const AVCodecDescriptor *desc = codecs[i];
		const AVCodec *codec = NULL;

		if (strstr(desc->name, "_deprecated"))
			continue;

		printf(" ");
		printf(avcodec_find_decoder(desc->id) ? "D" : ".");
		printf(avcodec_find_encoder(desc->id) ? "E" : ".");

		printf("%c", get_media_type_char(desc->type));
		printf((desc->props & AV_CODEC_PROP_INTRA_ONLY) ? "I" : ".");
		printf((desc->props & AV_CODEC_PROP_LOSSY)      ? "L" : ".");
		printf((desc->props & AV_CODEC_PROP_LOSSLESS)   ? "S" : ".");

		printf(" %-20s %s", desc->name, desc->long_name ? desc->long_name : "");

		/* print decoders/encoders when there's more than one or their
		 * names are different from codec name */
		while ((codec = next_codec_for_id(desc->id, codec, 0))) {
			if (strcmp(codec->name, desc->name)) {
				print_codecs_for_id(desc->id, 0);
				break;
			}
		}
		codec = NULL;
		while ((codec = next_codec_for_id(desc->id, codec, 1))) {
			if (strcmp(codec->name, desc->name)) {
				print_codecs_for_id(desc->id, 1);
				break;
			}
		}

		printf("\n");
	}
	av_free(codecs);
	return 0;
}
//-----------------------------------------------------------------------------//
//-----------------------------------------------------------------------------//
