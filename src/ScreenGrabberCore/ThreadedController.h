#pragma once

#include <QThread>
#include "ThreadedQObject.h"

class ThreadedController
{

public:
	static QThread* moveObjectToThread(ThreadedQObject *object, const QString &threadName);

};
