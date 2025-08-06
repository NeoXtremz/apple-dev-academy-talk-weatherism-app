- Tech Spec : Wedding Planner
- Author : Lin Dan
- Engineering Lead : Lin Dan
- Product Specs : <Link to product specs, if any>
- Important Documents : <Link to other important documents>
- JIRA Epic : <Link to jira epic ticket>
- Figma : <Link to figma / design file> 
- Figma Prototype : <Or protopie link...>
- BE Tech Specs : <if BE have tech specs...>
- Content Specs : <if need localization...>
- Instrumentation Specs : <if need to track user action / data...>
- QA Test Suite : <link to QA test suite>
- PICs : <name of the PICs of function, ex: PIC BE, PIC PM, PIC Designer, PIC FE, QA, PA, TPM etc>

Project Overview
=================
Sometimes couple that want to host a wedding find it difficult to plan an outdoor wedding. This apps will help the couples to find perfect day and time to host and outdoor wedding.


Requirements
=================
Functional Requirements
- Feature must provide a date picker for selecting wedding date
- Feature must provide a time picker for selecting wedding ceremony time
- Feature must provide a text input field for venue location (city name)
- Feature must validate that all required fields (date, time, location) are filled before proceeding
- Feature must allow users to select future dates only (no past dates)
- Feature must fetch current weather data for the specified location and date


Non Functional Requirements
- <some system requirements, ex: expected max CPU increase, FPS, etc>

Keep the UI FPS around 60 FPS

High-Level Diagram 
- <High level Flow chart>

Low-Level Diagram
- <Flow chart containing the service name etc, or swimlane stuffs>

Code Structure & Implementation Details
========================================
<Some pseudo-code on code-change plan and the logic>

Operational Excellence
=======================
<alert and monitoring link, like datadog dashboard for example>

Backward Compatibility / Rollback Plan
======================================
<outline plan for backward compatibility / rollback plan if needed>

Rollout Plan
============
<how we will roll out, ex: phased rollout according to app version? Or feature control / feature flag change?>

Out of scope
============
<list down things that is out of scope>

Demo
====
<screenshot, screen record>
 
Steps to use this feature
==========================
- Press the "Plan Wedding Weather" button on the home screen
- Insert the location, date, and time for the wedding
- Press the "Check Wedding Weather" button
- The apps show the weeather forecast for the specified date and time and recommend other dates if the weather is not suitable for outdoor wedding

Discussions and Alignments
==========================
Q: 
A: 


