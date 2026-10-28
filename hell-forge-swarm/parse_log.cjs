fetch('http://localhost:3000/api/jobs/job_1783802269898').then(r=>r.json()).then(data => {
  data.logs.forEach(l => {
    if(l.message.includes('generation failed')) {
      console.log(l.message);
    }
  })
});
