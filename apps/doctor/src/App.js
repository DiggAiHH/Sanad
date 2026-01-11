import React, { useState } from 'react';
import './App.css';

function App() {
  const [activeTab, setActiveTab] = useState('queue');
  const [patients, setPatients] = useState([
    {
      id: 'P001',
      name: 'Max Mustermann',
      appointmentTime: '09:00',
      status: 'waiting',
      reason: 'Routine Check-up',
      priority: 'normal',
    },
    {
      id: 'P002',
      name: 'Anna Schmidt',
      appointmentTime: '09:30',
      status: 'in-progress',
      reason: 'Follow-up',
      priority: 'high',
    },
    {
      id: 'P003',
      name: 'Tom Weber',
      appointmentTime: '10:00',
      status: 'waiting',
      reason: 'Consultation',
      priority: 'normal',
    },
  ]);
  
  const [selectedPatient, setSelectedPatient] = useState(null);

  const handleStatusChange = (patientId, newStatus) => {
    setPatients(prev => prev.map(p => 
      p.id === patientId ? { ...p, status: newStatus } : p
    ));
  };

  const handleCallNext = () => {
    const nextPatient = patients.find(p => p.status === 'waiting');
    if (nextPatient) {
      handleStatusChange(nextPatient.id, 'in-progress');
      setSelectedPatient(nextPatient);
    }
  };

  const getStatusColor = (status) => {
    switch(status) {
      case 'waiting': return '#ffc107';
      case 'in-progress': return '#2196f3';
      case 'completed': return '#4caf50';
      default: return '#999';
    }
  };

  const getPriorityColor = (priority) => {
    switch(priority) {
      case 'high': return '#f44336';
      case 'normal': return '#4caf50';
      case 'low': return '#9e9e9e';
      default: return '#999';
    }
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1>👨‍⚕️ Sanad Doctor Portal</h1>
        <p className="subtitle">Patient Management System</p>
      </header>

      <div className="container">
        <div className="sidebar">
          <button 
            className={`tab-btn ${activeTab === 'queue' ? 'active' : ''}`}
            onClick={() => setActiveTab('queue')}
          >
            📋 Patient Queue
          </button>
          <button 
            className={`tab-btn ${activeTab === 'current' ? 'active' : ''}`}
            onClick={() => setActiveTab('current')}
          >
            👤 Current Patient
          </button>
          <button 
            className={`tab-btn ${activeTab === 'history' ? 'active' : ''}`}
            onClick={() => setActiveTab('history')}
          >
            📚 History
          </button>
        </div>

        <div className="main-content">
          {activeTab === 'queue' && (
            <div className="queue-section">
              <div className="section-header">
                <h2>Patient Queue</h2>
                <button className="call-next-btn" onClick={handleCallNext}>
                  📞 Call Next Patient
                </button>
              </div>

              <div className="patients-grid">
                {patients.map(patient => (
                  <div 
                    key={patient.id} 
                    className="patient-card"
                    style={{ borderLeftColor: getStatusColor(patient.status) }}
                    onClick={() => setSelectedPatient(patient)}
                  >
                    <div className="patient-header">
                      <h3>{patient.name}</h3>
                      <span 
                        className="priority-badge"
                        style={{ background: getPriorityColor(patient.priority) }}
                      >
                        {patient.priority}
                      </span>
                    </div>
                    <div className="patient-details">
                      <p><strong>ID:</strong> {patient.id}</p>
                      <p><strong>Time:</strong> {patient.appointmentTime}</p>
                      <p><strong>Reason:</strong> {patient.reason}</p>
                    </div>
                    <div 
                      className="status-badge"
                      style={{ background: getStatusColor(patient.status) }}
                    >
                      {patient.status}
                    </div>
                    <div className="patient-actions">
                      <button 
                        className="action-btn"
                        onClick={(e) => {
                          e.stopPropagation();
                          handleStatusChange(patient.id, 'in-progress');
                        }}
                        disabled={patient.status === 'in-progress'}
                      >
                        Start
                      </button>
                      <button 
                        className="action-btn complete"
                        onClick={(e) => {
                          e.stopPropagation();
                          handleStatusChange(patient.id, 'completed');
                        }}
                        disabled={patient.status === 'completed'}
                      >
                        Complete
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {activeTab === 'current' && (
            <div className="current-patient-section">
              <h2>Current Patient</h2>
              {selectedPatient ? (
                <div className="patient-detail-card">
                  <h3>{selectedPatient.name}</h3>
                  <div className="detail-grid">
                    <div className="detail-item">
                      <strong>Patient ID:</strong>
                      <span>{selectedPatient.id}</span>
                    </div>
                    <div className="detail-item">
                      <strong>Appointment Time:</strong>
                      <span>{selectedPatient.appointmentTime}</span>
                    </div>
                    <div className="detail-item">
                      <strong>Reason:</strong>
                      <span>{selectedPatient.reason}</span>
                    </div>
                    <div className="detail-item">
                      <strong>Priority:</strong>
                      <span 
                        className="priority-badge"
                        style={{ background: getPriorityColor(selectedPatient.priority) }}
                      >
                        {selectedPatient.priority}
                      </span>
                    </div>
                  </div>
                  <div className="notes-section">
                    <h4>Medical Notes</h4>
                    <textarea 
                      className="notes-textarea"
                      placeholder="Enter medical notes here..."
                      rows="8"
                    />
                  </div>
                  <div className="action-buttons">
                    <button className="btn-primary">Save Notes</button>
                    <button className="btn-secondary">Print</button>
                    <button 
                      className="btn-success"
                      onClick={() => handleStatusChange(selectedPatient.id, 'completed')}
                    >
                      Complete Consultation
                    </button>
                  </div>
                </div>
              ) : (
                <div className="no-data">
                  <p>No patient selected</p>
                  <button className="call-next-btn" onClick={handleCallNext}>
                    📞 Call Next Patient
                  </button>
                </div>
              )}
            </div>
          )}

          {activeTab === 'history' && (
            <div className="history-section">
              <h2>Patient History</h2>
              <div className="no-data">
                <p>Select a patient to view history</p>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

export default App;
