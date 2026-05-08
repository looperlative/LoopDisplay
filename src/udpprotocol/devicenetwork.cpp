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

#include "devicenetwork.h"
#include <QUdpSocket>
#include <QNetworkDatagram>
#include <QDebug>
#include <arpa/inet.h>

DeviceNetwork::DeviceNetwork()
{
    connect(&m_socket, &QUdpSocket::readyRead,
            this, &DeviceNetwork::onDatagramsReady);
    connect(&m_pollTimer, &QTimer::timeout,
            this, &DeviceNetwork::onPollTimer);
    m_socket.setReadBufferSize(sizeof(ControlCompactStatus) * 8);
}

DeviceNetwork::~DeviceNetwork()
{
    stopPull();
    m_socket.close();
}

void DeviceNetwork::setPollIntervalMs(int ms)
{
    m_pollIntervalMs = ms;
    emit pollIntervalChanged();
}

void DeviceNetwork::setDeviceAddress(const QHostAddress &ip, quint16 port)
{
    m_deviceIp = ip;
    m_devicePort = port;
    emit deviceIpChanged();
    emit deviceConnected(ip, port);
    m_lastStatus = std::make_shared<ControlCompactStatus>();
}

std::shared_ptr<ControlCompactStatus> DeviceNetwork::lastStatus() const
{
    return m_lastStatus;
}

void DeviceNetwork::startPull()
{
    m_pollTimer.start(m_pollIntervalMs);
}

void DeviceNetwork::stopPull()
{
    m_pollTimer.stop();
}

void DeviceNetwork::onPollTimer()
{
    if (m_deviceIp.isNull())
        return;

    doPoll();
}

void DeviceNetwork::doPoll()
{
    QByteArray request("<query>status compact</query>");
    request.append('\0');

    m_socket.writeDatagram(request.data(), request.size(),
                           m_deviceIp, m_devicePort);
}

void DeviceNetwork::onDatagramsReady()
{
    while (m_socket.hasPendingDatagrams()) {
        QNetworkDatagram datagram = m_socket.receiveDatagram(m_socket.pendingDatagramSize());

        // Accept from known device OR the poll port
        if (datagram.senderAddress() != m_deviceIp) {
            continue;
        }

        const QByteArray &payload = datagram.data();
        if (static_cast<size_t>(payload.size()) >= sizeof(ControlCompactStatus)) {
            ControlCompactStatus status;
            memcpy(&status, payload.data(), sizeof(ControlCompactStatus));

            // Convert from network to host byte order
            status.sample_rate = ntohl(status.sample_rate);
            status.num_tracks = ntohl(status.num_tracks);
            for (int i = 0; i < CONTROL_NUM_TRACKS; i++) {
                status.state[i] = ntohl(status.state[i]);
                status.length[i] = ntohl(status.length[i]);
                status.position[i] = ntohl(status.position[i]);
                status.level[i] = ntohl(status.level[i]);
                status.pan[i] = ntohl(status.pan[i]);
                status.feedback[i] = ntohl(status.feedback[i]);
                status.selected[i] = ntohl(status.selected[i]);
            }

            {
                std::lock_guard<std::mutex> lock(m_mutex);
                *m_lastStatus = status;
            }

            emit statusReceived(status);
        }
    }
}
