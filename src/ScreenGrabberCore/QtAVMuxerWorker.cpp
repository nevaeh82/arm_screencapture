#include <QtAV/AVMuxer.h>
#include <QtAV/VideoEncoder.h>
#include <QScreen>
#include <QGuiApplication>
#include <QPixmap>
#include <QCursor>
#include <QPainter>

#include "QtAVMuxerWorker.h"

QtAVMuxerWorker::QtAVMuxerWorker(QObject* parent)
	: QObject(parent)
{
	m_cur.load(":/images/cur.png");
}

QtAVMuxerWorker::~QtAVMuxerWorker()
{
	freeMuxer();
}

void QtAVMuxerWorker::setEncodeParams(const ffmpegTools::QtAVEncodeParams& params)
{
	m_encodeParams = params;
}

void QtAVMuxerWorker::onStarted()
{
	m_muxer = new QtAV::AVMuxer;
	m_encoder = QtAV::VideoEncoder::create("FFmpeg");
	ThreadedQObject::onStarted();

	m_timer = new QTimer(this);
	connect(m_timer, SIGNAL(timeout()), this, SLOT(onCaptureScreen()));
	m_timer->start(40);
	workTime.start();
}

void QtAVMuxerWorker::finishHim()
{
	m_isWaitForFinished = true;
	ThreadedQObject::finishHim();
}

QObject* QtAVMuxerWorker::asThreadedQObject()
{
	return this;
}

void QtAVMuxerWorker::writeImage(const QImage &img)
{
	if (m_isWaitForFinished || img.isNull()) {
		return;
	}

	const auto imageSize = img.size();
	if (!initialize(imageSize)) {
		return;
	}

	//make QtAV video frame from image
	QtAV::VideoFrame frame = QtAV::VideoFrame(img);
	if (frame.pixelFormat() != m_encoder->pixelFormat()) {
		frame = frame.to(m_encoder->pixelFormat());
	}

	//encode video frame and write to file
	if (frame.isValid() && m_encoder->encode(frame)) {
		QtAV::Packet pkt(m_encoder->encoded());
		m_muxer->writeVideo(pkt);
	}
}

bool QtAVMuxerWorker::initialize(const QSize frameSize)
{
	if (m_isInitialized) {
		return true;
	}

	QVariantHash muxopt, avfopt;
	avfopt[QString::fromLatin1("segment_time")] = 4;
	avfopt[QString::fromLatin1("segment_list_size")] = 0;
	avfopt[QString::fromLatin1("segment_format")] = QString::fromLatin1("mpegts");
	muxopt[QString::fromLatin1("avformat")] = avfopt;

	m_encodeParams.dstFileName = QString("ZavScreenVideo.mp4");
	m_muxer->setMedia(m_encodeParams.dstFileName);
	m_encoder->setCodecName(DEFAULT_VIDEO_CODEC);
	m_encoder->setBitRate(m_encodeParams.bitrate);
	m_encoder->setWidth(frameSize.width());
	m_encoder->setHeight(frameSize.height());
	m_encoder->setFrameRate(10);

	if (!m_encoder->open()) {
//		log_error(QString("Failed to open encoder, codec: %1").arg(DEFAULT_VIDEO_CODEC));
		return false;
	}

	if (!m_muxer->isOpen()) {
		m_muxer->copyProperties(m_encoder);
		m_muxer->setOptions(muxopt);

		if (!m_muxer->open()) {
//			log_error("Failed to open muxer");
			return false;
		}
	}

	//QtAV::VideoFormat::PixelFormat tmp = m_encoder->pixelFormat();
	m_isInitialized = true;
	return true;
}

void QtAVMuxerWorker::freeMuxer()
{
	if (m_encoder && m_encoder->isOpen()) {
		m_encoder->close();
	}

	if (m_muxer && m_muxer->isOpen()) {
		m_muxer->close();

	}

	delete m_muxer;
	delete m_encoder;
	m_muxer = nullptr;
	m_encoder = nullptr;
}

void QtAVMuxerWorker::onCaptureScreen()
{
	QScreen *screen = QGuiApplication::primaryScreen();
	QList<QScreen*> lst = QGuiApplication::screens();
	QImage img;

	if(lst.size()>1) {
		int width = 0;
		int height = 0;
		foreach (QScreen* scr, lst) {
			width += scr->size().width();
			height = qMax(height, scr->size().height());
		}

		QImage canvas(width, height, QImage::Format_ARGB32);
		QPainter p(&canvas);
		int wX = 0;
		foreach (QScreen* scr, lst) {
			p.drawPixmap(wX, 0, scr->grabWindow(0));
			wX += scr->size().width();
		}
		p.end();
		img = canvas;
	} else {
		img = screen->grabWindow(0).toImage();
	}

	if(img.isNull()) {
		return;
	}

	QPoint pos = QCursor::pos();

	QPainter p(&img);
	p.drawPixmap(pos, m_cur);
	p.end();

	initialize(img.size());
	writeImage(img);

	if(workTime.elapsed() > 60000*60*3) {
		m_timer->stop();
		freeMuxer();
		emit onTimeout();
	}
}
