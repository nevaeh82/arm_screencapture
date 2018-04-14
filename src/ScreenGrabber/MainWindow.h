#pragma once

#include <QMainWindow>
#include <QtAVMuxerWorker.h>
#include "ThreadedQObject.h"

class QBoxLayout;
class QMenu;
class QActionGroup;

namespace Ui {
class MainWindow;
}

class MainWindow : public QMainWindow
{
	Q_OBJECT

private:
	Ui::MainWindow *ui;
	QtAVMuxerWorker* m_muxerWorker = nullptr;
	QThread* m_muxerThread = nullptr;

	bool start = false;

public:
	explicit MainWindow(QWidget *parent = 0);
	~MainWindow();
	void startTo();

public slots:
	void startGrabber();
};
