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

	MainWindow* view = new MainWindow();
	view->showMaximized();
	view->startTo();

	auto execRv = a.exec();
	delete view;

	QApplication::processEvents(QEventLoop::AllEvents | QEventLoop::WaitForMoreEvents, 1000);
	return execRv;
}
