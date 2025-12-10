# Rideau Canal Skateway Real-time Monitoring System

## Student Information
- **Name**: Kelvin Ngabo
- **Student ID**: 041196196
- **Course**: CST8916 - Remote Data and Real-time Applications
- **Term**: Fall 2025

## Project Links
- **Sensor Simulation Repository**: [Link to rideau-canal-sensor-simulation]
- **Dashboard Repository**: [Link to rideau-canal-dashboard]
- **Live Dashboard**: [Link to Azure App Service deployment]
- **Video Demonstration**: [\[Link to YouTube video\]](https://youtu.be/fdzCLwf7po8)

## Project Overview

The Rideau Canal Skateway is a UNESCO World Heritage Site and the world's largest naturally frozen skating rink. This project implements a real-time monitoring system to ensure skater safety by tracking ice conditions at three key locations:

- **Dow's Lake**: Popular recreational area
- **Fifth Avenue**: Central skating corridor
- **NAC** (National Arts Centre): High-traffic zone

### Problem Statement
The National Capital Commission (NCC) needs constant monitoring of ice conditions to determine when the skateway is safe for public use. Manual monitoring is labor-intensive and cannot provide real-time updates to the public.

### Solution
An IoT-based monitoring system that:
- Collects data from simulated sensors every 10 seconds
- Processes data in 5-minute aggregation windows
- Stores data for real-time and historical analysis
- Displays conditions through a live web dashboard
- Archives data for long-term analysis

## System Architecture

### Architecture Diagram

![alt text](<Architecture Diagram Remote.drawio.png>)

### Data Flow
1. **IoT Sensors** (simulated) measure ice conditions every 10 seconds at three locations
2. **Azure IoT Hub** ingests sensor telemetry data
3. **Azure Stream Analytics** processes data in 5-minute tumbling windows and:
   - Calculates aggregations (avg, min, max)
   - Determines safety status based on business rules
   - Routes data to two outputs
4. **Azure Cosmos DB** stores processed data for dashboard queries
5. **Azure Blob Storage** archives historical data
6. **Web Dashboard** (Azure App Service) displays real-time and historical data

### Azure Services Used
- **Azure IoT Hub**: Message ingestion from 3 IoT devices
- **Azure Stream Analytics**: Real-time stream processing
- **Azure Cosmos DB**: NoSQL database for fast queries
- **Azure Blob Storage**: Long-term data archival
- **Azure App Service**: Web application hosting

## Implementation Details

### 1. IoT Sensor Simulation
**Repository**: [Link to sensor simulation repo]

**Technology**: Python with Azure IoT Device SDK

**Functionality**:
- Simulates 3 sensors (one per location)
- Generates realistic sensor readings:
  - Ice Thickness: 20-40 cm
  - Surface Temperature: -15°C to 5°C
  - Snow Accumulation: 0-10 cm
  - External Temperature: -25°C to 0°C
- Transmits data every 10 seconds
- JSON format with ISO timestamps

**Key Code Components**:
- `generate_sensor_data()`: Creates realistic readings with variation
- `send_telemetry()`: Sends messages to IoT Hub
- Connection management for 3 devices

### 2. Azure IoT Hub
**Configuration**:
- Free tier (F1)
- 3 registered devices with symmetric key authentication
- Messages routed to Stream Analytics

### 3. Azure Stream Analytics

**Query Logic**:
```sql
-- 5-minute tumbling windows
-- Aggregations: AVG, MIN, MAX for ice thickness and temperatures
-- Safety status determination:
--   Safe: Ice ≥ 30cm AND Surface ≤ -2°C
--   Caution: Ice ≥ 25cm AND Surface ≤ 0°C
--   Unsafe: All other conditions
```

**Outputs**:
- Cosmos DB for real-time dashboard queries
- Blob Storage for historical archival (path: `aggregations/{date}/{time}/`)

### 4. Data Storage

**Cosmos DB**:
- Database: `RideauCanalDB`
- Container: `SensorAggregations`
- Partition Key: `/location`
- Serverless capacity mode

**Blob Storage**:
- Container: `historical-data`
- Line-separated JSON format
- Organized by date and time folders

### 5. Web Dashboard
**Repository**: [Link to dashboard repo]

**Technology Stack**:
- Backend: Node.js + Express
- Database Client: @azure/cosmos
- Frontend: HTML5, CSS3, Vanilla JavaScript
- Visualization: Chart.js

**Features**:
- Real-time data display for 3 locations
- Color-coded safety status badges (Safe/Caution/Unsafe)
- Auto-refresh every 30 seconds
- Historical trend charts (last hour):
  - Ice thickness (avg, min, max)
  - Temperature comparison (surface vs external)
- Responsive design for mobile and desktop
- Overall system status indicator

**API Endpoints**:
- `GET /api/latest` - Latest data from all locations
- `GET /api/history/:location` - Historical data (last hour)
- `GET /api/status` - Overall system status
- `GET /api/health` - Health check

### 6. Azure App Service Deployment
- Linux-based App Service
- Node 20 LTS runtime
- Continuous deployment from GitHub
- Environment variables for Cosmos DB connection

## Setup Instructions

### Prerequisites
- Azure subscription (student account recommended)
- Node.js 18+ and npm
- Python 3.8+
- Git and GitHub account
- Code editor (VS Code recommended)

### Quick Start
1. Clone all three repositories
2. Follow setup instructions in each repository's README
3. Configure Azure services as documented
4. Update connection strings in `.env` files
5. Start sensor simulator
6. Verify data flow through Azure Portal
7. Launch dashboard locally or deploy to Azure

**Detailed setup instructions available in each component repository.**

## Results and Analysis

### System Performance
- **Message Processing Rate**: ~0.5 messages/second per sensor (1.5 total)
- **Data Latency**: 5-minute aggregation window + processing time (~30 seconds)
- **Query Response Time**: <500ms for latest data queries
- **Data Retention**: Real-time (7 days in Cosmos DB), historical (unlimited in Blob)

### Sample Outputs
See screenshots folder for examples of:
- IoT Hub receiving messages
- Stream Analytics processing data
- Cosmos DB storing aggregated data
- Blob Storage archived files
- Dashboard displaying real-time and historical data

### Safety Status Distribution
Example from test run (1 hour):
- Safe conditions: 67% of time
- Caution conditions: 25% of time
- Unsafe conditions: 8% of time

### Key Insights
1. **Real-time Monitoring Works**: System successfully processes and displays data with <6 minute latency
2. **Cost-Effective**: Using free/serverless tiers keeps costs minimal (~$5/month estimated)
3. **Scalable Design**: Architecture can easily expand to more sensors or locations
4. **Reliable Safety Detection**: Business rules accurately classify ice conditions

## Challenges and Solutions

### Challenge 1: Stream Analytics Query Complexity
**Problem**: Initial query didn't properly handle safety status logic.

**Solution**: Used Common Table Expressions (CTEs) to separate aggregation from safety status determination, making the query more readable and debuggable.

### Challenge 2: Cosmos DB Connection from Dashboard
**Problem**: Dashboard couldn't connect to Cosmos DB initially.

**Solution**: Verified connection string format and ensured proper environment variables in both local and Azure App Service configurations.

### Challenge 3: Chart.js Not Updating with New Data
**Problem**: Historical charts showed stale data even after API returned new values.

**Solution**: Destroyed existing chart instances before creating new ones to force complete re-render.

### Challenge 4: Time Zone Handling
**Problem**: Timestamps displayed in dashboard didn't match expected local time.

**Solution**: Used JavaScript's `toLocaleTimeString()` to automatically handle time zone conversion for display.

## Future Enhancements
1. **Mobile App**: Native iOS/Android app for skaters on-site
2. **Predictive Analytics**: ML model to predict ice conditions
3. **Alerts**: SMS/email notifications when conditions become unsafe
4. **Weather Integration**: Incorporate external weather API data
5. **Interactive Map**: Visual map showing conditions along entire canal
6. **Historical Comparison**: Year-over-year condition analysis

## AI Tools Disclosure

### Tools Used
- **ChatGPT (GPT-4)**: Used for initial code structure and debugging
- **GitHub Copilot**: Used for code completion and documentation

### Extent of Use
- **Code Generation**: ~30% AI-suggested (sensor data generation logic, chart initialization)
- **Debugging**: Used AI to troubleshoot Stream Analytics query syntax errors
- **Documentation**: Used AI to structure README and improve clarity
- **Personal Work**: Architecture design, Azure configuration, business logic, integration, testing, and final debugging were all done independently

## References

### Azure Documentation
- [Azure IoT Hub Documentation](https://docs.microsoft.com/azure/iot-hub/)
- [Azure Stream Analytics Query Language](https://docs.microsoft.com/stream-analytics-query/stream-analytics-query-language-reference)
- [Azure Cosmos DB for NoSQL](https://docs.microsoft.com/azure/cosmos-db/)

### Libraries and Frameworks
- [Azure IoT Device SDK for Python](https://github.com/Azure/azure-iot-sdk-python)
- [Azure Cosmos DB SDK for JavaScript](https://github.com/Azure/azure-sdk-for-js/tree/main/sdk/cosmosdb)
- [Express.js](https://expressjs.com/)
- [Chart.js](https://www.chartjs.org/)

### Additional Resources
- [National Capital Commission - Skateway Information](https://ncc-ccn.gc.ca/places/rideau-canal-skateway)
- Course materials: CST8916 lecture slides and lab exercises

## License
This project is for educational purposes as part of CST8916 coursework.

---

**Last Updated**: 10/12/2025