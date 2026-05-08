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

#include "devicefinder.h"
#include "protocol.h"
#include <Qt>
#include <QDebug>
#include <QNetworkInterface>
#include <QUdpSocket>

DeviceFinder::DeviceFinder()
{
    connect(&m_socket, &QUdpSocket::readyRead,
            this, &DeviceFinder::processDatagrams);
    m_timer.setInterval(500);
    m_timer.setSingleShot(false);
    connect(&m_timer, &QTimer::timeout,
            this, &DeviceFinder::sendBroadcast);
}

DeviceFinder::~DeviceFinder()
{
    m_searching = false;
    m_socket.close();
    m_timer.stop();
}

void DeviceFinder::startSearch()
{
    if (m_searching)
        return;
    m_searching = true;
    m_found = false;
    m_deviceVersion.clear();
    emit deviceFoundChanged();
    emit deviceVersionChanged();

    if (!m_socket.bind(0, QUdpSocket::ShareAddress | QUdpSocket::ReuseAddressHint)) {
        qWarning() << "Failed to bind UDP socket for discovery";
        m_searching = false;
        return;
    }

    sendBroadcast();
    m_timer.start();
}

void DeviceFinder::stopSearch()
{
    m_searching = false;
    m_timer.stop();
    m_socket.close();
}

void DeviceFinder::sendBroadcast()
{
    const QList<QNetworkInterface> interfaces = QNetworkInterface::allInterfaces();
    for (const QNetworkInterface &iface : interfaces) {
        if (!(iface.flags() & QNetworkInterface::IsUp) ||
            !(iface.flags() & QNetworkInterface::IsRunning) ||
             (iface.flags() & QNetworkInterface::IsLoopBack))
            continue;

        for (const QNetworkAddressEntry &entry : iface.addressEntries()) {
            if (entry.ip().protocol() != QAbstractSocket::IPv4Protocol)
                continue;

            QHostAddress bcast;
            uint32_t ip   = entry.ip().toIPv4Address();
            uint32_t mask = entry.netmask().toIPv4Address();
            bcast.setAddress(ip | (~mask));

            if (!bcast.isNull()) {
                QByteArray request("<query>id</query>\0", 18);
                m_socket.writeDatagram(request.data(), request.size(),
                                       bcast, DEVICE_UDP_PORT);
            }
        }
    }
}

void DeviceFinder::processDatagrams()
{
    while (m_socket.hasPendingDatagrams()) {
        QNetworkDatagram datagram = m_socket.receiveDatagram();

        QString response(datagram.data());
        if (response.contains("<id>") && response.contains("</id>")) {
            int start = response.indexOf("<id>") + 4;
            int end   = response.indexOf("</id>");
            if (end > start) {
                QString version = response.mid(start, end - start);
                m_deviceAddress = datagram.senderAddress();
                m_deviceVersion = version;
                m_found = true;
                emit deviceFound(datagram.senderAddress(), version);
                emit deviceVersionChanged();
                emit deviceFoundChanged();
                m_searching = false;
                m_timer.stop();
            }
        }
    }
}
