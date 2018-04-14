#include "MainWindow.h"
#include "ui_MainWindow.h"

#include <QFileDialog>

#include "ThreadedController.h"

MainWindow::MainWindow(QWidget *parent) :
	QMainWindow(parent),
	ui(new Ui::MainWindow)
{
	ui->setupUi(this);

	connect(ui->pushButton, SIGNAL(clicked(bool)), this, SLOT(startGrabber()));
	ui->label->hide();
}

MainWindow::~MainWindow()
{
	if(start) {
		startGrabber();
	}
	delete ui;

}

void MainWindow::startTo()
{
	m_muxerWorker = new QtAVMuxerWorker();
	//m_muxerWorker->setEncodeParams(params);
	m_muxerThread = ThreadedController::moveObjectToThread(m_muxerWorker, "qtav_muxer");

	connect(m_muxerWorker, SIGNAL(onTimeout()), this, SLOT(startGrabber()));

	ui->pushButton->setText("Stop");
	ui->label->show();
	start = true;
}

void MainWindow::startGrabber()
{
	if(start) {
		if (m_muxerWorker) {
			m_muxerWorker->finishHim();
			m_muxerThread->wait();
			m_muxerWorker = nullptr;
			m_muxerThread = nullptr;
		}

		ui->pushButton->setText("Start");
		ui->label->hide();
		start = false;
	} else {
		//QString dir = QFileDialog::getExistingDirectory(this, "Choose directory to save res", "");
		m_muxerWorker = new QtAVMuxerWorker();
		//m_muxerWorker->setEncodeParams(params);
		m_muxerThread = ThreadedController::moveObjectToThread(m_muxerWorker, "qtav_muxer");
		connect(m_muxerWorker, SIGNAL(onTimeout()), this, SLOT(startGrabber()));

		ui->pushButton->setText("Stop");
		ui->label->show();

		start = true;
	}
}
