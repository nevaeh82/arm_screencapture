#include "ThreadedQObject.h"

ThreadedQObject::ThreadedQObject()
{
	qObject = new ThreadedQObject2();
	qObject->setMainClass(this);
}

ThreadedQObject::~ThreadedQObject()
{
	delete qObject;
}

ThreadedQObject2*ThreadedQObject::getQObject()
{
	return qObject;
}

void ThreadedQObject::onStarted()
{

}

void ThreadedQObject::finishHim()
{
	getQObject()->objectFinish();
}

ThreadedQObject2::ThreadedQObject2(QObject*)
{
	m_mainClass = NULL;
}

void ThreadedQObject2::setMainClass(IThreadedQObject* main)
{
	m_mainClass = main;
}

void ThreadedQObject2::objectFinish()
{
	emit objectFinished();
}

void ThreadedQObject2::onStarted() {
	m_mainClass->onStarted();
}
