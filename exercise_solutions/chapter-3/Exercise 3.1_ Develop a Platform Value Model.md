## ***Exercise 3.1: Develop a Platform Value Model***

Develop a platform value model for PETech that can help communicate the value of your intended platform capability to decision-makers. There are no right or wrong answers for this exercise, as the outcome you seek is a value-driven response to whether or not you should invest in building a particular platform capability.

To complete this exercise, you should answer the following questions.

1. Describe your business context and why this platform strategy will be critical  
2. Identify the specific platform product capability you want to build  
3. List out the assumptions and exceptions  
4. Identify the measures of success  
5. Identify all the costs of building the platform  
6. Obtain data from the path-to-production analysis (conduct one if you have not previously done a path-to-production analysis as described in section 2.5.2) to determine the savings goals  
7. Identify a clear timeline  
8. Identify the metrics you want to track against and clarify the formulas you want to use to compute these metrics  
9. Compute the savings for these capabilities you are building based on the savings goals from step 6\. Also, compute the costs of building these capabilities from step 5   
10. Report the target metrics (from step 8\) for the period you have identified (from step 7\)

**Solution**   

While there are no right or wrong answers for this exercise, you can use the following responses as a guideline to compare against what you generated.

1. **Business Context:** PETech is building financial service products on the public cloud for business-to-consumer clients. The consumers log into the PETech portal and integrate their technology systems to generate appropriate invoices and other payment workflows. A loosely coupled architecture is used for the overall software system and implemented using primarily containerized microservices. PEech wants to improve the effectiveness of its engineering team in developing and delivering these containerized microservices faster, in better quality, and with minimal additional training for its financial software developers.  
2. **Platform Capability:** Using the Kubernetes-based container orchestration is the industry standard recommended approach for every developer and the development team. However, the learning curve to install, operate, troubleshoot, and optimize the clusters for the k8s applications is very high. The capability that we need to build is a layer that resides between Kubernetes and the developers, helping them focus on their applications by having knowledge of the concepts and the approach of containerizing the applications and orchestrating them, but abstracts out the repeatable set of steps associated with it.  
3. **Assumptions and Exceptions:** PETech’s platform engineering team has decided that there will only be one option to build this technical capability. An architectural decision tree is in place to recommend the appropriate implementation for a given microservice across the spectrum of choices, such as Kubernetes, Serverless, Virtual machines, and others.  
4. **Measures of Success:** This effort’s success is measured by the number of workloads deployed across the organization and the number of teams adopting the platform for their container orchestration.  
5. **Costs of building the platform**: The cost of building the platform includes three distinct components: Developer costs, infrastructure costs, and any related support and onboarding costs  
6. **Savings goals**: This initiative will have clear savings goals. These include eliminating the costs of building the capabilities by individual teams, replicated and infrastructure costs, downtime as the teams repeatedly wait for the availability of capabilities and opportunity costs.  
7. **Identify a clear timeline:** The organization would like to understand the return on investment for the platform capabilities within the first year, twelve months from the start of the effort.  
8. **Metrics to track:** We would like to follow the value-to-cost ratio (VCR) as it becomes the driving factor for investing in capability building.  
   *Value-to-cost ratio \= value generated \*100 / cost of generating the value*  
9. **Computations:**  
   Before you start your build costs and savings calculation, establish specific baseline numbers, as shown below.

##### 

|  | Business Domain Product |
| :---- | :---- |
| **Fully loaded developer cost/hour** | $100 |
| **Average hours worked / month** | 160 |
| **Number of months to develop the capability** | 3 |
| **Adoption period to measure value** | 9 |
| **Average number of developers/application** | 6 |

##### **Table 3.12 Baseline Numbers for computing the costs involved**

Calculate each of the three components to compute the build costs, as shown in step 5 above. The assumption is that it takes three months for a team of four developers to build this capability.

##### 

|  |  | Total Costs |
| ----- | :---- | :---- |
| **Developer Costs** |  |  |
| Number of developer**s** | 4 | $192,000 |
| **Infrastructure Costs** |  |  |
| Average cloud costs/month | $1000 | $3000 |
| **Support & Onboarding** |  |  |
| Number of support engineers | 4 | $576,000 |
| Average cloud costs/month | $1000 | $9000 |
| **Total Build Costs**   |  | $780,000 |

##### **Table 3.13 Computing build costs**

To compute the savings, we have to consider the adoption of the capability by a certain number of applications every month from month four to month twelve based on the assumptions made in step seven.

##### 

|  |  | Total Costs |
| ----- | :---- | :---- |
| **Adoption starting month 4** |  |  |
| Average applications adopted/month | 10 |  |
| Hours saved/developer/week | 5 |  |
| **Total Savings**   |  | $1,080,000 |

##### **Table 3.14 Savings calculations**

10. **Metrics calculation:** Now that we have the cost of building the platform capability and the potential value generated by this capability, you can calculate the value-to-cost ratio.

    *Value-to-cost ratio \= $1,080,000 \*100 / $780,00 \= 1.38*

The solution provided above is a simplified version of calculating the value of a platform product. Depending on other costs and savings goals, your answer can be as detailed as your decision-makers require.