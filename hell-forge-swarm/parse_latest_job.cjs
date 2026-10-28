const http = require('http');

http.get('http://localhost:3000/api/jobs/job_1783802315651', (res) => {
  let data = '';
  res.on('data', (chunk) => {
    data += chunk;
  });
  res.on('end', () => {
    const job = JSON.parse(data);
    console.log("Status:", job.status);
    console.log("Progress:", job.progress);
    if (job.candidates && job.candidates.length > 0) {
      job.candidates.forEach(c => {
         console.log("Candidate:", c.agentName, c.status, c.score);
         console.log("Logs:", c.testLogs);
      });
    } else {
      console.log("No candidates yet. Logs:");
      console.log(job.logs);
    }
  });
});
