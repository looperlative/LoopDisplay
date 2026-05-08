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
#include <QObject>
#include <QVariantList>
#include <QMutex>

// QObject-based track data so QML can bind to individual properties
class TrackSnapshot : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int        index         READ index            NOTIFY dataChanged)
    Q_PROPERTY(int        state         READ state            NOTIFY dataChanged)
    Q_PROPERTY(qreal      length        READ length           NOTIFY dataChanged)
    Q_PROPERTY(qreal      position      READ position         NOTIFY positionUpdated)
    Q_PROPERTY(int        level         READ level            NOTIFY dataChanged)
    Q_PROPERTY(int        pan           READ pan              NOTIFY dataChanged)
    Q_PROPERTY(int        feedback      READ feedback         NOTIFY dataChanged)
    Q_PROPERTY(qreal      loopProgress  READ loopProgress     NOTIFY positionUpdated)
    Q_PROPERTY(bool       hasLoop       READ hasLoop          NOTIFY dataChanged)
    Q_PROPERTY(bool       isPlaying     READ isPlaying        NOTIFY dataChanged)
    Q_PROPERTY(bool       selected      READ selected         NOTIFY dataChanged)

public:
    explicit TrackSnapshot(QObject *parent = nullptr);

    int     index()        const { return m_index; }
    int     state()        const { return m_state; }
    qreal   length()       const { return m_length; }
    qreal   position()     const { return m_position; }
    int     level()        const { return m_level; }
    int     pan()          const { return m_pan; }
    int     feedback()     const { return m_feedback; }
    qreal   loopProgress() const { return m_loopProgress; }
    bool    hasLoop()      const { return m_hasLoop; }
    bool    isPlaying()    const { return m_isPlaying; }
    bool    selected()     const { return m_selected; }

    Q_SLOT void setData(int idx, int st, qreal len, qreal pos,
                        int lvl, int pn, int fb, qreal lp,
                        bool hl, bool play, bool sel);

signals:
    void dataChanged();
    void positionUpdated();

private:
    int    m_index        { 0 };
    int    m_state        { 0 };
    qreal  m_length       { 0 };
    qreal  m_position     { 0 };
    int    m_level        { 0 };
    int    m_pan          { 0 };
    int    m_feedback     { 0 };
    qreal  m_loopProgress { 0 };
    bool   m_hasLoop      { false };
    bool   m_isPlaying    { false };
    bool   m_selected     { false };
};

class MixerModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int trackCount     READ trackCount        CONSTANT)
    Q_PROPERTY(int selectedTrackIndex READ selectedTrackIndex NOTIFY selectedTrackIndexChanged)

public:
    explicit MixerModel(QObject *parent = nullptr);
    ~MixerModel() override;

    int trackCount() const { return CONTROL_NUM_TRACKS; }
    int selectedTrackIndex() const { return m_selectedTrackIndex; }

    Q_INVOKABLE TrackSnapshot *track(int index) const;

signals:
    void trackDataChanged(int index);
    void selectedTrackIndexChanged();
    void refreshTimer(int counter);

public slots:
    void updateSnapshot(const ControlCompactStatus &status);

private:
    TrackSnapshot *m_tracks[CONTROL_NUM_TRACKS]{ {} };
    int m_selectedTrackIndex{ -1 };
    QMutex m_mutex;
};
