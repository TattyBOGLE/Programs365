# Programs365

A SwiftUI-based iOS application for generating and managing track and field training programs using OpenAI's ChatGPT API.

## Features

- Age group-specific training programs
- Event-specific workout plans
- Multiple training terms (Short, Medium, Long)
- Training period management
- Weekly program generation
- Beautiful, modern UI with dark mode support

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+
- OpenAI API Key

## Installation

1. Clone the repository:
```bash
git clone https://github.com/TattyBOGLE/Programs365.git
```

2. Open the project in Xcode:
```bash
cd Programs365
open Programs365.xcodeproj
```

3. Set up your OpenAI API Key:
   - In Xcode, go to Edit Scheme > Run > Arguments > Environment Variables
   - Add a new variable named `OPENAI_API_KEY`
   - Enter your OpenAI API key as the value

4. Build and run the project

## Usage

1. Select an age group
2. Choose a track and field event
3. Select a training term
4. Choose a training period
5. View and generate weekly training programs

## Security

This project uses environment variables for sensitive information like API keys. Never commit API keys or other sensitive information to the repository.

## License

This project is licensed under the MIT License - see the LICENSE file for details. 