import React, { useState } from 'react';
import './App.css';

function App() {
  const [scanMode, setScanMode] = useState('qr'); // 'qr' or 'nfc'
  const [checkInStatus, setCheckInStatus] = useState('');
  const [patients, setPatients] = useState([]);

  // Simulate NFC scanning
  const handleNFCScan = () => {
    // In a real implementation, this would use Web NFC API
    const mockData = {
      patientId: 'P' + Math.floor(Math.random() * 1000),
      appointmentId: 'A' + Math.floor(Math.random() * 1000),
      timestamp: Date.now(),
    };
    processCheckIn(mockData);
  };

  // Simulate QR code scanning
  const handleQRScan = () => {
    // In a real implementation, this would use a QR scanner library
    const mockData = {
      patientId: 'P' + Math.floor(Math.random() * 1000),
      appointmentId: 'A' + Math.floor(Math.random() * 1000),
      timestamp: Date.now(),
    };
    processCheckIn(mockData);
  };

  const processCheckIn = (data) => {
    setCheckInStatus('processing');
    
    // Simulate API call
    setTimeout(() => {
      const newPatient = {
        id: data.patientId,
        appointmentId: data.appointmentId,
        checkedInAt: new Date().toLocaleString('de-DE'),
        status: 'Checked In',
      };
      
      setPatients(prev => [newPatient, ...prev]);
      setCheckInStatus('success');
      
      setTimeout(() => {
        setCheckInStatus('');
      }, 3000);
    }, 1500);
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1>🏥 Sanad Reception System</h1>
        <p className="subtitle">Automated Patient Check-In</p>
      </header>

      <div className="container">
        <div className="scan-section">
          <div className="mode-selector">
            <button 
              className={`mode-btn ${scanMode === 'qr' ? 'active' : ''}`}
              onClick={() => setScanMode('qr')}
            >
              📱 QR Code
            </button>
            <button 
              className={`mode-btn ${scanMode === 'nfc' ? 'active' : ''}`}
              onClick={() => setScanMode('nfc')}
            >
              📡 NFC
            </button>
          </div>

          <div className="scanner-area">
            {scanMode === 'qr' ? (
              <div className="scanner-box">
                <div className="qr-frame">
                  <div className="corner top-left"></div>
                  <div className="corner top-right"></div>
                  <div className="corner bottom-left"></div>
                  <div className="corner bottom-right"></div>
                  <div className="scan-line"></div>
                </div>
                <p>Scan QR Code Here</p>
                <button className="scan-btn" onClick={handleQRScan}>
                  Simulate QR Scan
                </button>
              </div>
            ) : (
              <div className="scanner-box">
                <div className="nfc-icon">📡</div>
                <p>Hold NFC Card Near Reader</p>
                <button className="scan-btn" onClick={handleNFCScan}>
                  Simulate NFC Scan
                </button>
              </div>
            )}
          </div>

          {checkInStatus === 'processing' && (
            <div className="status-message processing">
              ⏳ Processing check-in...
            </div>
          )}

          {checkInStatus === 'success' && (
            <div className="status-message success">
              ✅ Check-in successful!
            </div>
          )}
        </div>

        <div className="patients-section">
          <h2>Recent Check-Ins</h2>
          <div className="patients-list">
            {patients.length === 0 ? (
              <p className="no-data">No check-ins yet today</p>
            ) : (
              patients.map((patient, index) => (
                <div key={index} className="patient-card">
                  <div className="patient-info">
                    <strong>Patient ID:</strong> {patient.id}
                  </div>
                  <div className="patient-info">
                    <strong>Appointment:</strong> {patient.appointmentId}
                  </div>
                  <div className="patient-info">
                    <strong>Time:</strong> {patient.checkedInAt}
                  </div>
                  <div className="patient-status">{patient.status}</div>
                </div>
              ))
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

export default App;
