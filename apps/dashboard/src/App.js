import React, { useState } from 'react';
import './App.css';

function App() {
  const [activeTab, setActiveTab] = useState('overview');

  const [stats] = useState({
    totalPatients: 1247,
    todayAppointments: 45,
    activeStaff: 12,
    avgWaitTime: '8 min',
  });

  const [recentActivity] = useState([
    { id: 1, type: 'check-in', patient: 'Max Mustermann', time: '09:15', status: 'completed' },
    { id: 2, type: 'appointment', patient: 'Anna Schmidt', time: '09:30', status: 'in-progress' },
    { id: 3, type: 'check-in', patient: 'Tom Weber', time: '09:45', status: 'completed' },
    { id: 4, type: 'appointment', patient: 'Lisa Müller', time: '10:00', status: 'waiting' },
  ]);

  const [staff] = useState([
    { id: 1, name: 'Dr. Schmidt', role: 'Doctor', status: 'active', patients: 5 },
    { id: 2, name: 'Dr. Weber', role: 'Doctor', status: 'active', patients: 3 },
    { id: 3, name: 'Dr. Müller', role: 'Doctor', status: 'break', patients: 0 },
    { id: 4, name: 'Nurse Anna', role: 'Nurse', status: 'active', patients: 2 },
  ]);

  const [devices] = useState([
    { id: 1, name: 'Reception Kiosk 1', type: 'QR Scanner', status: 'online', location: 'Entrance' },
    { id: 2, name: 'Reception Kiosk 2', type: 'NFC Reader', status: 'online', location: 'Lobby' },
    { id: 3, name: 'Doctor Terminal 1', type: 'Tablet', status: 'online', location: 'Room 101' },
    { id: 4, name: 'Doctor Terminal 2', type: 'Tablet', status: 'offline', location: 'Room 102' },
  ]);

  return (
    <div className="App">
      <header className="App-header">
        <h1>⚙️ Sanad Master Dashboard</h1>
        <p className="subtitle">System Management & Analytics</p>
      </header>

      <div className="container">
        <div className="sidebar">
          <button 
            className={`tab-btn ${activeTab === 'overview' ? 'active' : ''}`}
            onClick={() => setActiveTab('overview')}
          >
            📊 Overview
          </button>
          <button 
            className={`tab-btn ${activeTab === 'patients' ? 'active' : ''}`}
            onClick={() => setActiveTab('patients')}
          >
            👥 Patients
          </button>
          <button 
            className={`tab-btn ${activeTab === 'staff' ? 'active' : ''}`}
            onClick={() => setActiveTab('staff')}
          >
            👨‍⚕️ Staff
          </button>
          <button 
            className={`tab-btn ${activeTab === 'devices' ? 'active' : ''}`}
            onClick={() => setActiveTab('devices')}
          >
            📱 Devices
          </button>
          <button 
            className={`tab-btn ${activeTab === 'settings' ? 'active' : ''}`}
            onClick={() => setActiveTab('settings')}
          >
            ⚙️ Settings
          </button>
          <button 
            className={`tab-btn ${activeTab === 'analytics' ? 'active' : ''}`}
            onClick={() => setActiveTab('analytics')}
          >
            📈 Analytics
          </button>
        </div>

        <div className="main-content">
          {activeTab === 'overview' && (
            <div className="overview-section">
              <h2>System Overview</h2>

              <div className="stats-grid">
                <div className="stat-card">
                  <div className="stat-icon">👥</div>
                  <div className="stat-content">
                    <h3>{stats.totalPatients}</h3>
                    <p>Total Patients</p>
                    <span className="stat-change positive">+12% this month</span>
                  </div>
                </div>
                <div className="stat-card">
                  <div className="stat-icon">📅</div>
                  <div className="stat-content">
                    <h3>{stats.todayAppointments}</h3>
                    <p>Today's Appointments</p>
                    <span className="stat-change positive">+5 from yesterday</span>
                  </div>
                </div>
                <div className="stat-card">
                  <div className="stat-icon">👨‍⚕️</div>
                  <div className="stat-content">
                    <h3>{stats.activeStaff}</h3>
                    <p>Active Staff</p>
                    <span className="stat-change neutral">On duty now</span>
                  </div>
                </div>
                <div className="stat-card">
                  <div className="stat-icon">⏱️</div>
                  <div className="stat-content">
                    <h3>{stats.avgWaitTime}</h3>
                    <p>Avg Wait Time</p>
                    <span className="stat-change positive">-2 min improvement</span>
                  </div>
                </div>
              </div>

              <div className="dashboard-grid">
                <div className="activity-panel">
                  <h3>Recent Activity</h3>
                  <div className="activity-list">
                    {recentActivity.map(activity => (
                      <div key={activity.id} className="activity-item">
                        <div className="activity-icon">
                          {activity.type === 'check-in' ? '✅' : '📅'}
                        </div>
                        <div className="activity-content">
                          <p className="activity-text">
                            <strong>{activity.patient}</strong> - {activity.type}
                          </p>
                          <p className="activity-time">{activity.time}</p>
                        </div>
                        <span className={`activity-status ${activity.status}`}>
                          {activity.status}
                        </span>
                      </div>
                    ))}
                  </div>
                </div>

                <div className="quick-actions-panel">
                  <h3>Quick Actions</h3>
                  <div className="actions-grid">
                    <button className="action-card">
                      <div className="action-icon">➕</div>
                      <p>Add Patient</p>
                    </button>
                    <button className="action-card">
                      <div className="action-icon">📅</div>
                      <p>Schedule</p>
                    </button>
                    <button className="action-card">
                      <div className="action-icon">📊</div>
                      <p>Reports</p>
                    </button>
                    <button className="action-card">
                      <div className="action-icon">🔔</div>
                      <p>Notifications</p>
                    </button>
                  </div>
                </div>
              </div>

              <div className="system-status">
                <h3>System Status</h3>
                <div className="status-items">
                  <div className="status-item">
                    <span className="status-indicator online"></span>
                    <span>Reception System</span>
                    <span className="status-text">Online</span>
                  </div>
                  <div className="status-item">
                    <span className="status-indicator online"></span>
                    <span>Doctor Portal</span>
                    <span className="status-text">Online</span>
                  </div>
                  <div className="status-item">
                    <span className="status-indicator online"></span>
                    <span>Patient Portal</span>
                    <span className="status-text">Online</span>
                  </div>
                  <div className="status-item">
                    <span className="status-indicator online"></span>
                    <span>Database</span>
                    <span className="status-text">Online</span>
                  </div>
                </div>
              </div>
            </div>
          )}

          {activeTab === 'staff' && (
            <div className="staff-section">
              <div className="section-header">
                <h2>Staff Management</h2>
                <button className="add-btn">+ Add Staff Member</button>
              </div>

              <div className="staff-grid">
                {staff.map(member => (
                  <div key={member.id} className="staff-card">
                    <div className="staff-avatar">
                      {member.name.split(' ').map(n => n[0]).join('')}
                    </div>
                    <h3>{member.name}</h3>
                    <p className="staff-role">{member.role}</p>
                    <div className="staff-stats">
                      <span className={`status-badge ${member.status}`}>
                        {member.status}
                      </span>
                      <span className="patients-count">
                        {member.patients} patients
                      </span>
                    </div>
                    <div className="staff-actions">
                      <button className="small-btn">View</button>
                      <button className="small-btn">Edit</button>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {activeTab === 'devices' && (
            <div className="devices-section">
              <div className="section-header">
                <h2>Device Management</h2>
                <button className="add-btn">+ Register Device</button>
              </div>

              <div className="devices-list">
                {devices.map(device => (
                  <div key={device.id} className="device-card">
                    <div className="device-icon">📱</div>
                    <div className="device-info">
                      <h3>{device.name}</h3>
                      <p>{device.type} - {device.location}</p>
                    </div>
                    <span className={`status-badge ${device.status}`}>
                      {device.status}
                    </span>
                    <div className="device-actions">
                      <button className="small-btn">Configure</button>
                      <button className="small-btn">Restart</button>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {activeTab === 'analytics' && (
            <div className="analytics-section">
              <h2>Analytics & Reports</h2>
              
              <div className="chart-placeholder">
                <div className="chart-box">
                  <h3>📈 Patient Traffic</h3>
                  <div className="chart-bars">
                    <div className="bar" style={{ height: '60%' }}><span>Mon</span></div>
                    <div className="bar" style={{ height: '75%' }}><span>Tue</span></div>
                    <div className="bar" style={{ height: '85%' }}><span>Wed</span></div>
                    <div className="bar" style={{ height: '70%' }}><span>Thu</span></div>
                    <div className="bar" style={{ height: '90%' }}><span>Fri</span></div>
                    <div className="bar" style={{ height: '40%' }}><span>Sat</span></div>
                    <div className="bar" style={{ height: '20%' }}><span>Sun</span></div>
                  </div>
                </div>

                <div className="chart-box">
                  <h3>⏱️ Average Wait Times</h3>
                  <div className="time-stats">
                    <div className="time-item">
                      <span className="time-label">Morning</span>
                      <span className="time-value">7 min</span>
                    </div>
                    <div className="time-item">
                      <span className="time-label">Afternoon</span>
                      <span className="time-value">12 min</span>
                    </div>
                    <div className="time-item">
                      <span className="time-label">Evening</span>
                      <span className="time-value">5 min</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          )}

          {activeTab === 'settings' && (
            <div className="settings-section">
              <h2>System Settings</h2>
              
              <div className="settings-groups">
                <div className="settings-group">
                  <h3>🔐 Security</h3>
                  <div className="setting-item">
                    <span>Two-Factor Authentication</span>
                    <label className="toggle">
                      <input type="checkbox" defaultChecked />
                      <span className="slider"></span>
                    </label>
                  </div>
                  <div className="setting-item">
                    <span>Session Timeout (minutes)</span>
                    <input type="number" defaultValue="30" className="setting-input" />
                  </div>
                </div>

                <div className="settings-group">
                  <h3>📱 Devices</h3>
                  <div className="setting-item">
                    <span>Enable NFC</span>
                    <label className="toggle">
                      <input type="checkbox" defaultChecked />
                      <span className="slider"></span>
                    </label>
                  </div>
                  <div className="setting-item">
                    <span>Enable QR Code Scanning</span>
                    <label className="toggle">
                      <input type="checkbox" defaultChecked />
                      <span className="slider"></span>
                    </label>
                  </div>
                </div>

                <div className="settings-group">
                  <h3>🔔 Notifications</h3>
                  <div className="setting-item">
                    <span>Email Notifications</span>
                    <label className="toggle">
                      <input type="checkbox" defaultChecked />
                      <span className="slider"></span>
                    </label>
                  </div>
                  <div className="setting-item">
                    <span>SMS Notifications</span>
                    <label className="toggle">
                      <input type="checkbox" />
                      <span className="slider"></span>
                    </label>
                  </div>
                </div>
              </div>

              <button className="save-settings-btn">Save Changes</button>
            </div>
          )}

          {activeTab === 'patients' && (
            <div className="patients-section">
              <div className="section-header">
                <h2>Patient Management</h2>
                <button className="add-btn">+ Add Patient</button>
              </div>
              <div className="no-data">
                <p>Patient management interface</p>
                <p className="small">Search and manage all patients in the system</p>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

export default App;
