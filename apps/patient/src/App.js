import React, { useState } from 'react';
import './App.css';

function App() {
  const [activeTab, setActiveTab] = useState('dashboard');
  const [patient] = useState({
    id: 'P12345',
    name: 'Max Mustermann',
    dateOfBirth: '01.01.1990',
    bloodType: 'A+',
  });

  const [appointments] = useState([
    {
      id: 'A001',
      date: '15.01.2026',
      time: '09:00',
      doctor: 'Dr. Schmidt',
      type: 'Check-up',
      status: 'upcoming',
    },
    {
      id: 'A002',
      date: '20.01.2026',
      time: '14:30',
      doctor: 'Dr. Weber',
      type: 'Follow-up',
      status: 'upcoming',
    },
    {
      id: 'A003',
      date: '05.01.2026',
      time: '10:00',
      doctor: 'Dr. Müller',
      type: 'Consultation',
      status: 'completed',
    },
  ]);

  const generateQRCode = (appointmentId) => {
    const qrData = JSON.stringify({
      patientId: patient.id,
      appointmentId: appointmentId,
      timestamp: Date.now(),
    });
    return qrData;
  };

  // Simple QR code visualization (in production, use a library like qrcode.react)
  const QRCodeDisplay = ({ data }) => (
    <div className="qr-display">
      <div className="qr-grid">
        {Array.from({ length: 256 }).map((_, i) => (
          <div 
            key={i} 
            className="qr-pixel"
            style={{
              background: Math.random() > 0.5 ? '#000' : '#fff'
            }}
          />
        ))}
      </div>
      <p className="qr-info">Scan this code at reception</p>
    </div>
  );

  return (
    <div className="App">
      <header className="App-header">
        <h1>👤 Sanad Patient Portal</h1>
        <p className="subtitle">Your Health, Your Control</p>
      </header>

      <div className="container">
        <div className="sidebar">
          <div className="patient-info-card">
            <div className="avatar">
              {patient.name.split(' ').map(n => n[0]).join('')}
            </div>
            <h3>{patient.name}</h3>
            <p>ID: {patient.id}</p>
          </div>
          
          <button 
            className={`tab-btn ${activeTab === 'dashboard' ? 'active' : ''}`}
            onClick={() => setActiveTab('dashboard')}
          >
            🏠 Dashboard
          </button>
          <button 
            className={`tab-btn ${activeTab === 'appointments' ? 'active' : ''}`}
            onClick={() => setActiveTab('appointments')}
          >
            📅 Appointments
          </button>
          <button 
            className={`tab-btn ${activeTab === 'qrcode' ? 'active' : ''}`}
            onClick={() => setActiveTab('qrcode')}
          >
            📱 My QR Code
          </button>
          <button 
            className={`tab-btn ${activeTab === 'records' ? 'active' : ''}`}
            onClick={() => setActiveTab('records')}
          >
            📋 Medical Records
          </button>
        </div>

        <div className="main-content">
          {activeTab === 'dashboard' && (
            <div className="dashboard-section">
              <h2>Welcome back, {patient.name.split(' ')[0]}!</h2>
              
              <div className="stats-grid">
                <div className="stat-card">
                  <div className="stat-icon">📅</div>
                  <div className="stat-content">
                    <h3>2</h3>
                    <p>Upcoming Appointments</p>
                  </div>
                </div>
                <div className="stat-card">
                  <div className="stat-icon">🩺</div>
                  <div className="stat-content">
                    <h3>{patient.bloodType}</h3>
                    <p>Blood Type</p>
                  </div>
                </div>
                <div className="stat-card">
                  <div className="stat-icon">📝</div>
                  <div className="stat-content">
                    <h3>5</h3>
                    <p>Medical Records</p>
                  </div>
                </div>
              </div>

              <div className="next-appointment">
                <h3>Next Appointment</h3>
                <div className="appointment-detail">
                  <div className="appointment-info">
                    <p className="appointment-date">
                      📅 {appointments[0].date} at {appointments[0].time}
                    </p>
                    <p className="appointment-doctor">
                      👨‍⚕️ {appointments[0].doctor}
                    </p>
                    <p className="appointment-type">
                      {appointments[0].type}
                    </p>
                  </div>
                  <button className="view-qr-btn" onClick={() => setActiveTab('qrcode')}>
                    View QR Code
                  </button>
                </div>
              </div>
            </div>
          )}

          {activeTab === 'appointments' && (
            <div className="appointments-section">
              <div className="section-header">
                <h2>My Appointments</h2>
                <button className="book-btn">+ Book New Appointment</button>
              </div>

              <div className="appointments-list">
                {appointments.map(appointment => (
                  <div key={appointment.id} className="appointment-card">
                    <div className="appointment-left">
                      <div className="appointment-date-box">
                        <div className="date-day">
                          {appointment.date.split('.')[0]}
                        </div>
                        <div className="date-month">
                          {appointment.date.split('.')[1]}/{appointment.date.split('.')[2]}
                        </div>
                      </div>
                    </div>
                    <div className="appointment-middle">
                      <h3>{appointment.type}</h3>
                      <p>🕐 {appointment.time}</p>
                      <p>👨‍⚕️ {appointment.doctor}</p>
                    </div>
                    <div className="appointment-right">
                      <span className={`status-badge ${appointment.status}`}>
                        {appointment.status}
                      </span>
                      {appointment.status === 'upcoming' && (
                        <button 
                          className="small-btn"
                          onClick={() => setActiveTab('qrcode')}
                        >
                          QR Code
                        </button>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {activeTab === 'qrcode' && (
            <div className="qrcode-section">
              <h2>Your Check-In QR Code</h2>
              <p className="instruction">
                Show this QR code at the reception for quick check-in
              </p>
              
              <div className="qr-container">
                <QRCodeDisplay data={generateQRCode(appointments[0].id)} />
                
                <div className="qr-details">
                  <p><strong>Patient ID:</strong> {patient.id}</p>
                  <p><strong>Appointment:</strong> {appointments[0].id}</p>
                  <p><strong>Date:</strong> {appointments[0].date}</p>
                  <p><strong>Time:</strong> {appointments[0].time}</p>
                </div>
              </div>

              <div className="qr-actions">
                <button className="btn-primary">Download QR Code</button>
                <button className="btn-secondary">Share</button>
              </div>

              <div className="info-box">
                <h4>📱 How to use:</h4>
                <ul>
                  <li>Scan this QR code at the reception kiosk</li>
                  <li>Or hold your NFC-enabled device near the reader</li>
                  <li>Check-in will be completed automatically</li>
                  <li>No human interaction required</li>
                </ul>
              </div>
            </div>
          )}

          {activeTab === 'records' && (
            <div className="records-section">
              <h2>Medical Records</h2>
              <div className="records-list">
                <div className="record-card">
                  <div className="record-icon">📄</div>
                  <div className="record-info">
                    <h4>Blood Test Results</h4>
                    <p>05.01.2026</p>
                  </div>
                  <button className="view-btn">View</button>
                </div>
                <div className="record-card">
                  <div className="record-icon">💊</div>
                  <div className="record-info">
                    <h4>Prescription</h4>
                    <p>28.12.2025</p>
                  </div>
                  <button className="view-btn">View</button>
                </div>
                <div className="record-card">
                  <div className="record-icon">🩺</div>
                  <div className="record-info">
                    <h4>Check-up Report</h4>
                    <p>15.12.2025</p>
                  </div>
                  <button className="view-btn">View</button>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

export default App;
