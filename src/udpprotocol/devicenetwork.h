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

#pragma once

#include "protocol.h"
#include <QUdpSocket>
#include <QNetworkDatagram>
#include <QTimer>
#include <QObject>
#include <memory>
#include <mutex>

class DeviceNetwork : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int pollIntervalMs READ pollIntervalMs WRITE setPollIntervalMs NOTIFY pollIntervalChanged)
    Q_PROPERTY(QHostAddress deviceIp READ deviceIp NOTIFY deviceIpChanged)

public:
    explicit DeviceNetwork();
    ~DeviceNetwork();

    int pollIntervalMs() const { return m_pollIntervalMs; }
    Q_INVOKABLE void setPollIntervalMs(int ms);
    QHostAddress deviceIp() const { return m_deviceIp; }

    void setDeviceAddress(const QHostAddress &ip, quint16 port = DEVICE_UDP_PORT);
    std::shared_ptr<ControlCompactStatus> lastStatus() const;

signals:
    void pollIntervalChanged();
    void deviceIpChanged();
    void statusReceived(const ControlCompactStatus &status);
    void deviceLost();
    void deviceConnected(const QHostAddress &ip, quint16 port);

public slots:
    Q_INVOKABLE void startPull();
    Q_INVOKABLE void stopPull();

private slots:
    void onPollTimer();
    void onDatagramsReady();

private:
    void doPoll();

    QUdpSocket m_socket;
    QTimer m_pollTimer;
    int m_pollIntervalMs{100};
    QHostAddress m_deviceIp;
    quint16 m_devicePort{DEVICE_UDP_PORT};
    std::shared_ptr<ControlCompactStatus> m_lastStatus;
    std::mutex m_mutex;
    QByteArray m_receiveBuffer;
};
