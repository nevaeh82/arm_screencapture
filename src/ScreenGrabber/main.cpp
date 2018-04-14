#include <QApplication>
#include <QTextCodec>
#include <QFile>
#include <QTranslator>

#include "MainWindow.h"

int main(int argc, char *argv[])
{
	QApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
	QApplication a(argc, argv);

	QCoreApplication::setOrganizationName("NTT");
	QCoreApplication::setApplicationName("ZavScreenGrabber");

	QTextCodec::setCodecForLocale(QTextCodec::codecForName("UTF-8"));
	QLocale::setDefault(QLocale("ru_RU"));

	QTranslator translatorScreenGrabber;
	QTranslator translatorScreenGrabberCore;

	// init language files
	QString language = "ru";

	//Q_INIT_RESOURCE(ScreenGrabber_ts);
	//Q_INIT_RESOURCE(ScreenGrabberCore_ts);

	translatorScreenGrabber.load(QString(":/ScreenGrabber_%1.qm").arg(language));
	a.installTranslator(&translatorScreenGrabber);
	translatorScreenGrabberCore.load(QString(":/ScreenGrabberCore_%1.qm").arg(language));
	a.installTranslator(&translatorScreenGrabberCore);

	MainWindow* view = new MainWindow();
	view->showMaximized();
	view->startTo();

	auto execRv = a.exec();
	delete view;

	QApplication::processEvents(QEventLoop::AllEvents | QEventLoop::WaitForMoreEvents, 1000);
	return execRv;
}
