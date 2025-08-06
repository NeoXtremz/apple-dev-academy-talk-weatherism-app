# Weatherism - Technical Specification

- **Tech Spec**: Outfit Recommendation Feature
- **Author**: Regina Celine Adiwinata
- **Engineering Lead**: 
- **Product Specs**: 
- **Important Documents**: 
- **JIRA Epic**: 
- **Figma**: 
- **Figma Prototype**: 
- **BE Tech Specs**: 
- **Content Specs**: 
- **Instrumentation Specs**: 
- **QA Test Suite**: 
- **PICs**: 
  - PIC FE: Regina Celine Adiwinata
  - PIC PM: 
  - PIC Designer: 
  - PIC BE: 
  - PIC QA: 
  - PIC PA: 
  - PIC TPM: 

---

## Project Overview
Penambahan fitur **Outfit Recommendation** pada aplikasi Weatherism untuk menampilkan saran pakaian yang sesuai dengan kondisi cuaca saat ini.  
Data gambar diambil dari **Unsplash API** berdasarkan kondisi cuaca (cerah, hujan, berawan, salju, dsb).

---

## Requirements

### Functional Requirements
- Mendapatkan kondisi cuaca saat ini dari `WeatherViewModel`.
- Memetakan kondisi cuaca ke kata kunci pencarian yang sesuai.
- Mengambil gambar dari **Unsplash API** berdasarkan kata kunci.
- Menampilkan gambar outfit secara horizontal scroll di bawah informasi cuaca.

### Non-Functional Requirements
- Waktu load gambar outfit < 2 detik pada jaringan stabil.
- Smooth scrolling pada list gambar.
- Handling error API jika koneksi gagal atau data kosong.

---

## High-Level Diagram

Low-Level Diagram
- <Flow chart containing the service name etc, or swimlane stuffs>

Code Structure & Implementation Details
========================================
MVVM
- **View**:  
  - `OutfitListView` → Menampilkan list gambar outfit secara horizontal.  
- **ViewModel**:  
  - `OutfitViewModel` → Mengatur pemanggilan API Unsplash & mapping kondisi cuaca.  
- **Service**:  
  - `UnsplashService` → Menghandle request API Unsplash dan parsing JSON.  

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
![Unknown](https://github.com/user-attachments/assets/6f98218c-8880-44f5-8445-7d38d47e296d)

 

Steps to use this feature
==========================
1. Open app.
2. Enter a city name in the search bar.
3. Tap "Search".
4. View weather data & outfit recommendations.

Discussions and Alignments
==========================
Q: 
A: 


