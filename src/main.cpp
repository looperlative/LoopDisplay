// Copyright (C) 2026 Robert Amstadt
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <qqmlcontext.h>
#include "mixermodel/mixermodel.h"
#include "udpprotocol/devicefinder.h"
#include "udpprotocol/devicenetwork.h"
#include <Qt>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName("LoopDisplay");
    app.setOrganizationName("Loop");

    QQmlApplicationEngine engine;

    auto mixerModel = new MixerModel;
    auto deviceFinder = new DeviceFinder;
    auto deviceNetwork = new DeviceNetwork;

    QObject::connect(deviceFinder, &DeviceFinder::deviceFound,
        deviceNetwork, [deviceNetwork](const QHostAddress &ip, const QString &version) {
            deviceNetwork->setDeviceAddress(ip);
        });
    QObject::connect(deviceNetwork, &DeviceNetwork::statusReceived,
        mixerModel, &MixerModel::updateSnapshot);

    QQmlEngine::setObjectOwnership(deviceFinder, QQmlEngine::CppOwnership);
    QQmlEngine::setObjectOwnership(deviceNetwork, QQmlEngine::CppOwnership);
    QQmlEngine::setObjectOwnership(mixerModel, QQmlEngine::CppOwnership);

    engine.rootContext()->setContextProperty("mixerModel", mixerModel);
    engine.rootContext()->setContextProperty("deviceFinder", deviceFinder);
    engine.rootContext()->setContextProperty("deviceNetwork", deviceNetwork);

    engine.load(QUrl(QStringLiteral("qrc:///main.qml")));

    return app.exec();
}
