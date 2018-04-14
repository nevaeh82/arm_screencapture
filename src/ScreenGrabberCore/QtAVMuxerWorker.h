#pragma once

#include <QObject>
#include <QTimer>
#include <QImage>
#include <QPixmap>
#include <QTime>

#include "ThreadedQObject.h"
#include "ThreadSafeBool.h"
#include "ffmpegTools.h"

namespace QtAV {
class AVMuxer;
class VideoEncoder;
}

class QtAVMuxerWorker : public QObject, public ThreadedQObject
{
	Q_OBJECT
public:
	explicit QtAVMuxerWorker(QObject* parent = nullptr);
	~QtAVMuxerWorker();

	void setEncodeParams(const ffmpegTools::QtAVEncodeParams& params);

	/////////////////////////////// IThreadedQObject //////////////////////////
	void onStarted();
	void finishHim();
	QObject* asThreadedQObject();
	///////////////////////////////////////////////////////////////////////////

public slots:
	void writeImage(const QImage& img);

	void onCaptureScreen();

signals:
	void onTimeout();

private:
	bool initialize(const QSize frameSize);
	void freeMuxer();

private:
	QtAV::AVMuxer* m_muxer = nullptr;
	QtAV::VideoEncoder* m_encoder = nullptr;
	ffmpegTools::QtAVEncodeParams m_encodeParams;
	ThreadSafeBool m_isWaitForFinished = false;
	ThreadSafeBool m_isInitialized = false;
	const QString DEFAULT_VIDEO_CODEC = "mpeg4";

	QTimer* m_timer;
	QString m_pathToSave;

	QImage mimg;
	QPixmap m_cur;
	QTime workTime;
};
