# Automation of Stopping/Starting EC2 Instances on a Schedule

https://www.joe-edwards.co.uk/#portfolio/portfolio-2

Breif - To implement an automated solution for starting and stopping EC2 instances on a defined schedule. The automation will help optimize costs and resource utilization by ensuring that instances are active only when needed. 

Lambda Functions
-Two Lambda functions are defined - one for starting instances and one for stopping instances.
-Each Lambda function is associated with a specific IAM role, defining its permissions and actions.
-Python 3.10 is chosen as the runtime environment for these functions.
-The Lambda functions are triggered by EventBridge to execute specific actions at scheduled times.

IAM Role and Policies
-An IAM role is defined for Lambda execution, allowing Lambda functions to describe, start, and stop EC2 instances.
-An IAM policy is attached to the role to grant the necessary permissions.

EventBridge
-EventBridge rules are created to define the schedule for starting and stopping instances using cron expressions.
-Targets are defined, linking the EventBridge rules to their corresponding Lambda functions.
-Permissions are granted to EventBridge to invoke the Lambda functions when event conditions are met.

Python Code
-Python code is provided for both Lambda functions.
-The "start_instances" function identifies and starts EC2 instances with a specific tag that are in a "stopped" state.
-The "stop_instances" function identifies and stops EC2 instances with a specific tag that are in a "running" state.
