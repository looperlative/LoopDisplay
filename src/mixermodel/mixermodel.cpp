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

#include "mixermodel.h"

TrackSnapshot::TrackSnapshot(QObject *parent)
    : QObject(parent)
{
}

void TrackSnapshot::setData(int idx, int st, qreal len, qreal pos,
                            int lvl, int pn, int fb, qreal lp,
                            bool hl, bool play, bool sel)
{
    m_index        = idx;
    m_state        = st;
    m_length       = len;
    m_position     = pos;
    m_level        = lvl;
    m_pan          = pn;
    m_feedback     = fb;
    m_loopProgress = lp;
    m_hasLoop      = hl;
    m_isPlaying    = play;
    m_selected     = sel;
    emit dataChanged();
}

MixerModel::MixerModel(QObject *parent)
    : QObject(parent)
{
    for (int i = 0; i < CONTROL_NUM_TRACKS; i++)
        m_tracks[i] = new TrackSnapshot(this);
}

MixerModel::~MixerModel() { }

void MixerModel::updateSnapshot(const ControlCompactStatus &status)
{
    QMutexLocker locker(&m_mutex);

    int newSelected = 0;
    for (int i = 0; i < CONTROL_NUM_TRACKS; i++) {
        int len  = status.length[i];
        int pos  = status.position[i];
        int lvl  = status.level[i];
        int pn   = status.pan[i];
        int fb  = status.feedback[i];
        int st  = status.state[i];
        bool sel = static_cast<bool>(status.selected[i]);

        qreal progress = (len > 0) ? static_cast<qreal>(pos) / static_cast<qreal>(len) : 0.0;

        m_tracks[i]->setData(i, st, static_cast<qreal>(len),
                            static_cast<qreal>(pos), lvl, pn, fb, progress,
                            len > 0, (st == 4 || st == 2), sel);
        emit trackDataChanged(i);

        if (sel) newSelected = i;
    }

    if (m_selectedTrackIndex != newSelected) {
        m_selectedTrackIndex = newSelected;
        emit selectedTrackIndexChanged();
    }
}

TrackSnapshot *MixerModel::track(int index) const
{
    if (index >= 0 && index < CONTROL_NUM_TRACKS)
        return m_tracks[index];
    return nullptr;
}
