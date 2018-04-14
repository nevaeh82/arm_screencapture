#pragma once

#include <QObject>

class IThreadedQObject {

public:
	virtual ~IThreadedQObject() { }
	virtual void onStarted() = 0;
};

class ThreadedQObject2: public QObject
{
	Q_OBJECT

	IThreadedQObject* m_mainClass;

public:
	explicit ThreadedQObject2(QObject *parent = 0);
	virtual ~ThreadedQObject2() { }

	void setMainClass(IThreadedQObject*);

	void objectFinish();

public slots:
	virtual void onStarted();

signals:
	void objectFinished();
};

class ThreadedQObject : public IThreadedQObject
{

	ThreadedQObject2* qObject;

public:
	explicit ThreadedQObject();
	virtual ~ThreadedQObject();

	ThreadedQObject2* getQObject();

	virtual void onStarted();
	virtual void finishHim();

	virtual QObject* asThreadedQObject() = 0;
};

