# Flytrap Load Testing Overview

Flytrap uses Artillery for basic load testing.

Load testing tools are traditionally used to test API endpoints. However, Flytrap SDKs capture
error data and send them to an AWS API Gateway. Since API Gatway is designed to scale generously,
we utilized Artillery to simulate end-to-end testing of the AWS infrastructure.

Running Artillery load tests allowed us to identify performance bottlenecks and optimize system
performance by simulating bursts of heavy traffic to the application.

## Key Takeaways
-The React-based developer dashboard, hosted on a t3.small AWS EC2 instance, experiences performance
issues beyond 20 requests per second (RPS) due to continuous React component re-rendering, disrupting
developer workflow.

-Backend throughput is constrained at 35 RPS, where webhook requests from the Lambda pipeline exceed
the EC2 instance's capacity, causing degraded performance.

-To protect against interrupted developer workflow, Flytrap's default API Gateway throttling is
configured with a rate limit of 20 RPS and a burst limit of 80 to ensure frontend stability and
manage traffic spikes.

-Users can opt to upgrade EC2 instance size and API Gateway rate limiting (via Terraform or the
AWS console) to handle a greater number of requests per second. This would increase the accuracy of
dashboard insights in areas like error count and affected user count. However, this does not
resolve the React re-rendering issue caused by traffic exceeding 20 RPS. The tradeoff here is
more accurate data collection, but a slow or temporarily unavailable dashboard during high-frequency
bursts of incoming error data.

## Running the Load Test

1. **Install Artillery**:
   ```bash
   npm install -g artillery
   ```

2. **Prepare the Test**:
   Navigate into the `tests` directory in the flytrap_terraform folder.
   The provided test runs against the API Gateway's `/errors` endpoint.
   The test file includes a mock request body formatted and encoded to pass the API Gateway model
   validation for that route.

3. **Update Configuration**:
   - Running an Artillery test requires a deployed Flytrap AWS architecture and a test project.
   - After creating a test project in the Flytrap admin console, update the `tests/load-test-errors.yml`
      file with the project information (available on your project's setup page in the admin console):
      - Replace the value for `target` with your current API Gateway endpoint.
      - Replace the value for `x-api-key` with your project's API key.
      - Replace the value for `project_id` with your project's project ID.
   - Adjust `duration` (test time) and `arrivalRate` (requests/second) as needed. By default, the
     values in the provided test file demonstrate the max load the Flytrap infrastructure can accomodate
     without a negative impact on the system.

4. **Run the Test**:
   ```bash
   artillery run load-test-errors.yml
   ```

