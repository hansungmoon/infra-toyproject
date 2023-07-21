import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  vus: 100,
  duration: '60s',
};

export default function () {
  const url = 'www.marketboro.click/items/1';
  const payload = {
    name: 'Updated K6'
  };

  const headers = { 'Content-Type': 'application/json' };

  const response = http.put(url, JSON.stringify(payload), { headers });

  check(response, {
    'Status is 200': (r) => r.status === 200,
  });

  sleep(1); // Adjust the sleep time between iterations if needed
}