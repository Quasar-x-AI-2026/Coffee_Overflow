# 🏥 Dr.dermAI

> AI-powered dermatology assistant built with Flutter for **Quasar x AI 2026 Hackathon**

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat&logo=dart&logoColor=white)](https://dart.dev)
[![AI/ML](https://img.shields.io/badge/AI%2FML-FF6F00?style=flat&logo=tensorflow&logoColor=white)](https://www.tensorflow.org)

## Overview

**Dr.dermAI** is an intelligent mobile application that leverages machine learning to assist with dermatological analysis. The app provides instant skin condition assessments using computer vision, making dermatological consultation more accessible.

## Problem Statement

In rural and remote areas, access to qualified dermatologists is extremely limited, leading to misdiagnosis and improper treatment of skin conditions. Patients rely on local practitioners or self-medication, often worsening their conditions due to lack of proper diagnosis. Poor internet connectivity makes online consultations and cloud-based diagnostic tools unreliable or inaccessible in these regions.

## Solution

Dr.dermAI is a fully offline mobile application that uses a trained machine learning model to analyze skin images captured via smartphone camera. The app identifies likely skin conditions and provides basic medical advice, precautions, and recommendations on when to seek professional care. It serves as a decision-support tool to help users make informed healthcare choices, especially in areas with limited internet connectivity.

## Features

- 📸 Image-based skin analysis using ML models
- 🤖 AI-driven condition detection and classification
- 📱 Cross-platform support (Android, iOS, Web, Desktop)
- 📊 Confidence scores and detailed analysis results
- 💾 History tracking for monitoring changes over time
- 🔒 Privacy-focused with local processing

## Tech Stack

- **Flutter & Dart** - Cross-platform UI framework
- **Python** - ML model training and development
- **TensorFlow/TensorFlow Lite** - Machine learning models
- **Jupyter Notebooks** - Model experimentation and analysis

## Installation

```bash
# Clone the repository
git clone https://github.com/Quasar-x-AI-2026/Coffee_Overflow.git
cd Coffee_Overflow

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Architecture

```
Dr.dermAI/
├── lib/              # Flutter app code
├── assets/           # Images and resources
├── notebooks/        # ML model development
├── android/          # Android build
├── ios/              # iOS build
└── web/              # Web build
```

## Machine Learning

- **Model**: Convolutional Neural Network (CNN) for image classification
- **Dataset**: Dermatological image dataset
- **Framework**: TensorFlow Lite for mobile deployment
- **Performance**: Optimized for on-device inference

## Disclaimer

⚠️ **Important**: Dr.dermAI is designed as a preliminary screening tool and educational resource. It does not replace professional medical diagnosis. Always consult a qualified dermatologist for proper medical advice and treatment.

## Team

**Team Quasar-x-AI-2026** - Hackathon participants, January 2026

## Hackathon

**Event**: Quasar x AI 2026  
**Track**: Healthcare AI  
**Date**: January 2026

---

<div align="center">

**Made with ❤️ for accessible healthcare**

[Report Issues](https://github.com/Quasar-x-AI-2026/Coffee_Overflow/issues)

</div>
