## reservations
| vpc                     | region          | az                | az                | az                | total IPs |
|-------------------------|:---------------:|:-----------------:|:-----------------:|:-----------------:|:---------:|
|                         |                 |                   |                   |                   |           |
| dps-2                   | us-east-1       | us-east-1a        |   us-east-1b      |  us-east-1c       |           |
| sbx-i01-aws-us-east-1   | 10.90.0.0/16    |                   |                   |                   |           |
| private  (nodes)        |                 | 10.80.0.0/18      | 10.80.64.0/18     | 10.80.128.0/18    | 49,146    |
| intra<sup>*</sup>       |                 | 10.80.192.0/20    | 10.80.208.0/20    | 10.80.224.0/20    | 12,282    |
| database                |                 | 10.80.240.0/23    | 10.80.242.0/23    | 10.80.244.0/23    | 1,530     |
| public   (ingress)      |                 | 10.80.246.0/23    | 10.80.248.0/23    | 10.80.250.0/23    | 1,530     |
|                         |                 |                   |                   | unallocated addr  | 1047      |
|                         |                 |                   |                   |                   |           |
| dps-1                   | us-east-2       | us-east-2a        |   us-east-2b      |  us-east-2c       |           |
| prod-i01-aws-us-east-1  | 10.90.0.0/16    |                   |                   |                   |           |
| private (nodes)         |                 | 10.90.0.0/18      | 10.90.64.0/18     | 10.90.128.0/18    | 49,146    |
| intra<sup>*</sup>       |                 | 10.90.192.0/20    | 10.90.208.0/20    | 10.90.224.0/20    | 12,282    |
| database                |                 | 10.90.240.0/23    | 10.90.242.0/23    | 10.90.244.0/23    | 1,530     |
| public   (ingress)      |                 | 10.90.246.0/23    | 10.90.248.0/23    | 10.90.250.0/23    | 1,530     |
|                         |                 |                   |                   | unallocated addr  | 1047      |

<sup>*</sup>private subnet with no internet routing (in the sense of RFC1918 Category 1), commonly used for Lambda functions ENI allocations.
