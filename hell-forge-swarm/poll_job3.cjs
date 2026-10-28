const http = require('http');

function checkJob() {
  http.get('http://localhost:3000/api/jobs/job_1783804392944', (res) => {
    let data = '';
    res.on('data', (chunk) => data += chunk);
    res.on('end', () => {
      const job = JSON.parse(data);
      console.log(`Status: ${job.status}, Progress: ${job.progress}`);
    });
  });
}
checkJob();
