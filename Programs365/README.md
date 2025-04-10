# Programs365 - Enhanced Training Program Generation

## Overview
Programs365 is a sophisticated training program generation system designed for track and field athletes. The system uses advanced AI to create personalized training programs that consider multiple factors including age, event, gender, training history, and environmental conditions.

## Key Features

### 1. Enhanced Program Generation
- **Periodization Models**: Choose from Linear, Undulating, Block, or Wave periodization
- **Load Management**: Adaptive training load based on athlete profile
- **Environmental Adaptation**: Programs adjust for indoor/outdoor training and weather conditions
- **Facility Considerations**: Customizable based on available equipment and space

### 2. Event-Specific Components
- **Warm-Up Protocols**: Tailored warm-up routines for each event
- **Injury Prevention**: Event-specific prehab exercises
- **Technical Integration**: Balanced technical work with physical development

### 3. Athlete-Centric Features
- **Age-Appropriate Training**: Programs adapted for different age groups
- **Gender-Specific Considerations**: Including menstrual cycle awareness for female athletes
- **Training History**: Load adjustment based on years of experience
- **Previous Injury Consideration**: Modified exercises based on injury history

### 4. Progressive Overload
- Systematic progression across training phases
- Regular deload periods
- Phase-specific intensity and volume adjustments

## System Components

### Models
- `EnhancedProgramModels.swift`: Core data models for program generation
- `Models.swift`: Base models for track and field events

### Services
- `EnhancedProgramService.swift`: Program generation logic
- `ChatGPTService.swift`: AI integration for program customization

### Views
- `EnhancedProgramViews.swift`: User interface for program generation
- `ProgramsView.swift`: Main program management interface

## Usage

1. **Basic Program Generation**
   - Select age group and event
   - Choose training term and period
   - Generate a standard training program

2. **Enhanced Program Generation**
   - Access through the "Enhanced Program Generation" button
   - Configure detailed parameters
   - View event-specific warm-up and injury prevention protocols
   - Generate a highly customized program

3. **Program Management**
   - Save generated programs
   - View and manage saved programs
   - Track progress and make adjustments

## Technical Requirements
- iOS 15.0+
- Swift 5.5+
- Xcode 13.0+

## Contributing
We welcome contributions to improve the program generation system. Please follow these steps:
1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## License
This project is licensed under the MIT License - see the LICENSE file for details. 