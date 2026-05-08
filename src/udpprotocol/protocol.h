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
#include <array>

// UDP port on the device
constexpr uint16_t DEVICE_UDP_PORT = 5667;

constexpr int CONTROL_NUM_TRACKS = 8;
constexpr int MAX_STATUS_MSG = 2000;

// Track state values
enum class TrackState : int32_t {
    Empty = 0,
    Recording = 1,
    Overdubbing = 2,
    Stopped = 3,
    Playing = 4,
    Replacing = 5
};

// Compact binary status structure (network byte order from device)
#pragma pack(push, 1)
struct ControlCompactStatus {
    int32_t sample_rate;
    int32_t num_tracks;
    int32_t state[CONTROL_NUM_TRACKS];
    int32_t length[CONTROL_NUM_TRACKS];
    int32_t position[CONTROL_NUM_TRACKS];
    int32_t level[CONTROL_NUM_TRACKS];
    int32_t pan[CONTROL_NUM_TRACKS];
    int32_t feedback[CONTROL_NUM_TRACKS];
    int32_t selected[CONTROL_NUM_TRACKS];
};
#pragma pack(pop)

static_assert(sizeof(ControlCompactStatus) == (4 + 4 + 8*7*4), "ControlCompactStatus size mismatch");

// Human-readable label for track state
const char* trackStateLabel(TrackState state);
