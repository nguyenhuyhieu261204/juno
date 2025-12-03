# Juno - Advanced MERN B2B Teams Project Management SaaS

## Title & Short Description

Juno is a comprehensive B2B Teams Project Management SaaS application built with the MERN stack (MongoDB, Express.js, React, Node.js) and TypeScript. It provides businesses with an intuitive platform to manage workspaces, projects, and tasks collaboratively with team members. The application features role-based permissions, Google authentication, and a modern UI with real-time analytics.

## Key Features

- **Authentication & Authorization**: Secure login with both email/password and Google OAuth integration
- **Workspaces**: Create and manage multiple workspaces with unique invite codes for team collaboration
- **Role-based Permissions**: Granular access control with customizable roles and permissions
- **Project Management**: Create, edit, and organize projects within workspaces with custom emojis
- **Task Management**: Create, assign, and track tasks with priority levels, status updates, and due dates
- **Team Collaboration**: Add members to workspaces and assign roles with different permission levels
- **Analytics Dashboard**: Real-time analytics showing task progress, overdue items, and completion rates
- **Responsive UI**: Mobile-friendly interface built with Tailwind CSS and modern UI components
- **Task Tables**: Interactive task management with filtering and sorting capabilities
- **User Profile Management**: Manage user information and profile pictures

## Installation

### Prerequisites

- Node.js (v18 or higher)
- MongoDB (local or cloud instance)
- Git

### Backend Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/nguyenhuyhieu261204/juno.git
   cd juno
   ```

2. Navigate to the backend directory:
   ```bash
   cd backend
   ```

3. Install dependencies:
   ```bash
   npm install
   ```

4. Create a `.env` file based on the `.env.example` file and set your environment variables:
   ```bash
   cp .env.example .env
   ```

### Frontend Setup

1. Navigate to the client directory:
   ```bash
   cd client
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Create a `.env` file based on the `.env.example` file:
   ```bash
   cp .env.example .env
   ```

## Usage

### Running the Application

1. **Start the Backend Server:**
   ```bash
   # In the backend directory
   npm run dev
   ```

2. **Start the Frontend Server:**
   ```bash
   # In the client directory
   npm run dev
   ```

3. Open your browser and navigate to `http://localhost:5173` to access the application.

### Getting Started

1. Register a new account or sign in with Google
2. Create your first workspace
3. Invite team members using the workspace invite code
4. Create projects within your workspace
5. Add tasks to your projects and assign them to team members

## Directory Structure / Architecture

```
Advanced-MERN-B2B-Teams-Project-Management-Saas/
├── backend/                    # Server-side application
│   ├── src/
│   │   ├── config/            # Configuration files
│   │   ├── controllers/       # Request handlers
│   │   ├── models/            # Database schemas
│   │   ├── routes/            # API route definitions
│   │   ├── services/          # Business logic
│   │   ├── middlewares/       # Request processing middleware
│   │   ├── enums/             # Constant enumerations
│   │   ├── utils/             # Utility functions
│   │   ├── validation/        # Request validation schemas
│   │   └── seeders/           # Database seeders
│   ├── package.json
│   └── .env.example
├── client/                     # Client-side application
│   ├── src/
│   │   ├── components/        # React UI components
│   │   ├── layout/            # Page layouts
│   │   ├── routes/            # Routing configuration
│   │   ├── hooks/             # Custom React hooks
│   │   ├── types/             # TypeScript type definitions
│   │   ├── context/           # React context providers
│   │   ├── lib/               # Utility libraries
│   │   ├── page/              # Page components
│   │   ├── assets/            # Static assets
│   │   └── constant/          # Constant values
│   ├── package.json
│   └── .env.example
└── README.md
```

### Backend Architecture
- **Models**: Mongoose schemas for User, Workspace, Project, Task, and Member entities
- **Controllers**: Business logic separated by feature (auth, user, workspace, project, task)
- **Services**: Reusable business logic functions
- **Middlewares**: Authentication, authorization, and error handling
- **Validation**: Zod schemas for request validation

### Frontend Architecture
- **Components**: Reusable UI components organized by feature
- **Context**: Authentication and state management
- **Routes**: Protected and public routing with different layouts
- **Types**: TypeScript interfaces for API responses and requests
- **Hooks**: Custom React hooks for data fetching and state management

## Configuration

### Backend Environment Variables

```env
NODE_ENV=development
PORT=5000
BASE_PATH=/api
MONGO_URI=mongodb://localhost:27017/juno
SESSION_SECRET=your-session-secret
SESSION_EXPIRES_IN=24h
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
GOOGLE_CALLBACK_URL=http://localhost:5000/api/auth/google/callback
FRONTEND_ORIGIN=http://localhost:5173
FRONTEND_GOOGLE_CALLBACK_URL=http://localhost:5173/auth/callback
```

### Frontend Environment Variables

```env
VITE_BACKEND_URL=http://localhost:5000
VITE_BACKEND_BASE_PATH=/api
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Make your changes
4. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
5. Push to the branch (`git push origin feature/AmazingFeature`)
6. Open a Pull Request

### Development Guidelines

- Follow TypeScript best practices
- Use functional components with hooks in React
- Follow the existing code structure and naming conventions
- Write clear, descriptive commit messages
- Add tests for new functionality if applicable
- Ensure code passes linting and type checks

## Bug Reports & Feature Requests

If you encounter any issues or have suggestions for new features, please open an issue in the GitHub repository with the following information:

- **Bug Reports**: Include steps to reproduce, expected behavior, actual behavior, and any relevant error messages
- **Feature Requests**: Describe the enhancement you'd like to see and the problem it would solve

## License

This project is licensed under the ISC License - see the [LICENSE](LICENSE) file for details.

## Authors & Acknowledgments

- Nguyen Huy Hieu - Initial work and development
- Express.js, React, MongoDB, and other open-source libraries that made this project possible
- The React and Node.js communities for providing excellent resources and documentation

---

For additional information or support, please contact the maintainers through GitHub.