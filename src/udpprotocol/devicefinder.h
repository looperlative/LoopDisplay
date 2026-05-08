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

#include <cstdint>
#include <QNetworkDatagram>
#include <QHostAddress>
#include <QTimer>
#include <QUdpSocket>

class DeviceFinder : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString deviceVersion READ deviceVersion NOTIFY deviceVersionChanged)
    Q_PROPERTY(bool found READ found NOTIFY deviceFoundChanged)

public:
    explicit DeviceFinder();
    ~DeviceFinder();

    QString deviceVersion() const { return m_deviceVersion; }
    bool found() const { return m_found; }

public slots:
    void startSearch();
    void stopSearch();

signals:
    void deviceFound(const QHostAddress &address, const QString &version);
    void deviceVersionChanged();
    void deviceFoundChanged();

private:
    void processDatagrams();
    void sendBroadcast();

    QUdpSocket m_socket;
    QTimer m_timer;
    bool m_found{false};
    QString m_deviceVersion;
    QHostAddress m_deviceAddress;
    bool m_searching{false};
};
