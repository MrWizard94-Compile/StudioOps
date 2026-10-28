const http = require('http');

function checkJob() {
  http.get('http://localhost:3000/api/jobs/job_1783803221097', (res) => {
    let data = '';
    res.on('data', (chunk) => data += chunk);
    res.on('end', () => {
      const job = JSON.parse(data);
      console.log(`Status: ${job.status}, Progress: ${job.progress}`);
      if (job.status === 'completed' || job.status === 'failed') {
         console.log(JSON.stringify(job, null, 2));
      } else {
         setTimeout(checkJob, 2000);
      }
    });
  });
}
checkJob();
