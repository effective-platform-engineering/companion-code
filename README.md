# Companion Code for *Effective Platform Engineering*

This repository contains companion materials for the book, including runnable exercise solutions and a minimal template platform repository.

## Quick links
- 📄 **Appendix A – Combined Solutions (Chapters 2–8)**  
  [Download the PDF](./Appx-A_chankramath_effective_platform_engineering.pdf)
- 🧩 **Exercise solutions:** [`exercise_solutions/`](./exercise_solutions/)
- 🏗️ **Template platform repository:** [`template_platform_repository/`](./template_platform_repository/)

## How to use this repo
- Each chapter below lists one or more exercises. Start in `exercise_solutions/chapter-X/` and open the folder matching the exercise.
- The PDF above provides a **narrative walkthrough** of the solutions (the repo folders focus on the final code).
- We’ll update the PDF when fixes or enhancements land in the repo.

---

## Chapter 2

[Exercise 2.1](exercise_solutions/chapter-2/Exercise-2.1_Stakeholder_Map.md) Stakeholder Map  
[Exercise 2.2](exercise_solutions/chapter-2/Exercise-2.2_Feature_set_of_an_MVP_engineering_platform.md) Feature set of an MVP engineering platform  
[Exercise 2.3](exercise_solutions/chapter-2/Exercise-2.3_Observability_Driven_Design_Requirements.md) Observability Driven Design Requirements  
[Exercise 2.4](exercise_solutions/chapter-2/Exercise-2.4_Model_a_feature_request.md) Model a feature request  
[Exercise 2.5](exercise_solutions/chapter-2/Exercise-2.5_Fitness_Functions.md) Fitness Functions  
[Exercise 2.6](exercise_solutions/chapter-2/Exercise-2.6_Writing_a_Domain_specific_ADR.md) Writing a Domain-Specific ADR  

## Chapter 3

[Exercise 3.1](exercise_solutions/chapter-3/) Develop a Platform Value Model  
[Exercise 3.2](exercise_solutions/chapter-3/) Identify and setup measurement techniques for reducing cognitive load  
[Exercise 3.3](exercise_solutions/chapter-3/) Case Study Scaling Platform Team  
[Exercise 3.4](exercise_solutions/chapter-3/) Establish a set of KPIs and measure for success  

## Chapter 4

[Exercise 4.1](exercise_solutions/chapter-4/Exercise-4.1_Create_policies_to_require_that_deployments_include_availability_and_resource_management_requirements.md) Create policies to require that deployments include availability and resource management requirements  
[Exercise 4.2](exercise_solutions/chapter-4/Exercise-4.2_Create_a_bash_script_that_will_sign_a_docker_image_and_then_verify_the_results.md) Create a bash script that will sign a docker image and then verify the results  
[Exercise 4.3](exercise_solutions/chapter-4/Exercise-4.3_Create_an_admission_controller_policy_to_allow_only_images_from_our_registry_and_organization.md) Create an admission controller policy to allow only images from our registry and organization  

## Chapter 5

[Exercise 5.1](exercise_solutions/chapter-5/Exercise-5.1_Set_up_an_observability_system_for_infrastructure_monitoring.md) Set up an observability system for infrastructure monitoring  
[Exercise 5.2](exercise_solutions/chapter-5/Exercise-5.2_Correlating_data_with_a_demo_application.md) Correlating data with a demo application  
[Exercise 5.3](exercise_solutions/chapter-5/Exercise-5.3_Case_Study_Evaluate_the_TCO_of_continuing_to_support_your_observability_system_locally.md) Case Study Evaluate the TCO of continuing to support your observability system locally  
[Exercise 5.4](exercise_solutions/chapter-5/Exercise-5.4_Use_Prometheus_data_to_create_SLOs.md) Use Prometheus data to create SLOs  

## Chapter 6

[Configuring GitHub for signed commits](exercise_solutions/chapter-6/configuring_github_for_signed_commits.md)  
[Exercise 6.1](exercise_solutions/chapter-6/6.1_developer_tools_selection_criteria) Developer Tool Selection Criteria  
[Exercise 6.2](exercise_solutions/chapter-6/6.2_test_driven_development_of_infrastructure_code) Test-Driven Development of Infrastructure Code  
[Exercise 6.3](exercise_solutions/chapter-6/6.3_static_code_analysis) Static Code Analysis  
[Exercise 6.4](exercise_solutions/chapter-6/6.4_pre_commit_hooks) Pre-commit Hooks  
[Exercise 6.5](exercise_solutions/chapter-6/6.5_experiment_with_self_hosted_runners) Experiment with Self-Hosted Runners  
[Exercises 6.6 – 6.9](exercise_solutions/chapter-6/6.6-9_aws_iam_profiles) AWS IAM Profiles pipeline  

## Chapter 7

[Exercise 7.1](exercise_solutions/chapter-7/7.1_aws_platform_hosted_zones) AWS Platform Hosted Zones  
[Exercise 7.2](exercise_solutions/chapter-7/7.2_aws_platform_vpc) AWS Platform VPC  
[Exercise 7.3](exercise_solutions/chapter-7/7.3_aws_control_plane_base) AWS Control Plane Base  
[Project 7.1](exercise_solutions/chapter-7/project-7.1_configure_idp) Auth0.com Identity Provider Configuration  
[Project 7.2](exercise_solutions/chapter-7/project-7.2_create_cli) epectl control plane CLI initial setup  

## Chapter 8

[Exercise 8.2](exercise_solutions/chapter-8/Exercise-8.2_Run_Trivy_scan_on_metrics_server_chart.md) Run Trivy scan on metrics-server chart and create a values.yaml to correct the findings  
[Exercise 8.3 – 8.5](exercise_solutions/chapter-8/8.3-5_aws_control_plane_services) AWS Control Plane Services  
[Exercise 8.6 – 8.12](exercise_solutions/chapter-8/8.6-12_aws_control_plane_extensions) AWS Control Plane Extensions  

---

## Contributing
Spotted an issue or improvement? Open an issue or a PR. Please keep filenames and chapter/exercise numbers consistent.

## License
See [`LICENSE`](./LICENSE).
