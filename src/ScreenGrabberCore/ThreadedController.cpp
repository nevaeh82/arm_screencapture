#include "ThreadedController.h"

QThread* ThreadedController::moveObjectToThread(ThreadedQObject* object, const QString& threadName)
{
	QThread* thread = new QThread;

	QObject::connect(thread, SIGNAL(started()), object->getQObject(), SLOT(onStarted()));

	QObject::connect(object->getQObject(), SIGNAL(objectFinished()), thread, SLOT(quit()));
	QObject::connect(thread, SIGNAL(finished()), object->asThreadedQObject(), SLOT(deleteLater()));
	QObject::connect(thread, SIGNAL(finished()), thread, SLOT(deleteLater()));

	object->asThreadedQObject()->moveToThread(thread);
	object->getQObject()->moveToThread(thread);
	thread->setObjectName(threadName);
	thread->start();

	return thread;
}

